// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

enum ProductStatus { all, active, inactive, deleted }

enum FilterColumn { featured, deals, notDeals, onSale, pinnedSale }

enum SortOrder {
  none,
  // Price & Date
  priceAsc,
  priceDesc,
  recentUpdatedAll,
  recentUpdatedPrice,
  recentUpdatedSalePrice,
  recentUpdatedStock,
  // Analytics - Views
  mostViews,
  leastViews,
  // Analytics - Cart
  mostAddedToCart,
  leastAddedToCart,
  // Analytics - Engagement
  mostEnquired,
  leastEnquired,
  mostAddedToWishlist,
  leastAddedToWishlist,
  // Analytics - Contact
  mostCalled,
  leastCalled,
  mostWhatsAppContacted,
  leastWhatsAppContacted,
  // Analytics - Performance
  mostTotalInteractions,
  leastTotalInteractions,
  bestConversionRate,
  worstConversionRate,
  bestContactRate,
  worstContactRate,
}

enum SkuFilter { all, existing, withoutSku }

enum FeaturedFilter { all, featured, notFeatured }

class ProductFilter {
  final String name;
  final String value;
  final FilterColumn column;
  final String operator;
  final bool isMetaField;

  ProductFilter({
    required this.name,
    required this.value,
    required this.column,
    required this.operator,
    this.isMetaField = false,
  });
}

class ShopItem {
  final String id;
  final String name;

  ShopItem({required this.id, required this.name});
}

class CategoryItem {
  final String id;
  final String name;

  CategoryItem({required this.id, required this.name});
}

class AdminProductsService extends GetxService {
  static const String _baseUrl = 'https://api.libanbuy.com/api/products';
  static const String _shopsUrl = 'https://api.libanbuy.com/api/shops';
  static const String _categoriesUrl =
      'https://api.libanbuy.com/api/product-attributes/categories';

  final productsModel = Rxn<AdminProductsModel>();
  final RxList<AdminProducts> adminProducts = <AdminProducts>[].obs;
  final scrollController = ScrollController();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isPaginationLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 10.obs;
  final RxInt totalPages = 0.obs;
  final RxInt totalItems = 0.obs;

  // Search fields - all active simultaneously
  final RxString searchName = ''.obs;
  final RxString searchId = ''.obs;
  final RxString searchSku = ''.obs;

  // Status filter
  final Rx<ProductStatus> selectedStatus = ProductStatus.all.obs;

  // Created at date range
  final Rx<DateTime?> startDate = Rxn<DateTime>();
  final Rx<DateTime?> endDate = Rxn<DateTime>();

  // Sorting
  final Rx<SortOrder> sortOrder = SortOrder.none.obs;

  // Shop filter
  final RxString selectedShopId = ''.obs;
  final RxString selectedShopName = ''.obs;
  final RxList<ShopItem> shopSearchResults = <ShopItem>[].obs;
  final RxBool isSearchingShops = false.obs;

  // Featured filter
  final Rx<FeaturedFilter> featuredFilter = FeaturedFilter.all.obs;

  // Category filter
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedCategoryName = ''.obs;
  final RxString categoryOperator = '='.obs; // = for Include, != for Exclude
  final RxList<CategoryItem> categorySearchResults = <CategoryItem>[].obs;
  final RxBool isSearchingCategories = false.obs;

  // Group by SKU
  final RxBool groupBySku = false.obs;

  // Inventory Updated
  final RxBool inventoryUpdatedEnabled = false.obs;
  final Rx<DateTime?> inventoryStartDate = Rxn<DateTime>();
  final Rx<DateTime?> inventoryEndDate = Rxn<DateTime>();

  // Flash Deals Added
  final RxBool flashDealsAddedEnabled = false.obs;
  final Rx<DateTime?> flashDealsStartDate = Rxn<DateTime>();
  final Rx<DateTime?> flashDealsEndDate = Rxn<DateTime>();

  // Analytics date range
  final Rx<DateTime?> analyticsStartDate = Rxn<DateTime>();
  final Rx<DateTime?> analyticsEndDate = Rxn<DateTime>();

  // SKU filter
  final Rx<SkuFilter> skuFilter = SkuFilter.all.obs;

  // Multi-select
  final RxSet<String> selectedProductIds = <String>{}.obs;
  final RxBool isBulkOperationRunning = false.obs;
  final RxInt bulkOperationProgress = 0.obs;
  final RxInt bulkOperationTotal = 0.obs;

  bool get isAllSelected =>
      adminProducts.isNotEmpty &&
      adminProducts.every((p) => selectedProductIds.contains(p.id));

  void toggleProductSelection(String productId) {
    if (selectedProductIds.contains(productId)) {
      selectedProductIds.remove(productId);
    } else {
      selectedProductIds.add(productId);
    }
  }

  void toggleSelectAll() {
    if (isAllSelected) {
      selectedProductIds.clear();
    } else {
      selectedProductIds.addAll(
        adminProducts.map((p) => p.id).whereType<String>(),
      );
    }
  }

  void clearSelection() {
    selectedProductIds.clear();
  }

  // Legacy fields kept for backward compatibility
  final RxString searchQuery = ''.obs;
  final RxString searchField = 'name'.obs;
  final RxList<ProductFilter> activeFilters = <ProductFilter>[].obs;

  // Debounce workers
  Worker? _searchNameWorker;
  Worker? _searchIdWorker;
  Worker? _searchSkuWorker;

  @override
  void onInit() {
    super.onInit();
    _initializeSearchWorkers();
    _initializeScrollController();
  }

  void _initializeSearchWorkers() {
    _searchNameWorker = debounce(
      searchName,
      (_) => _onSearchChanged(),
      time: const Duration(milliseconds: 500),
    );
    _searchIdWorker = debounce(
      searchId,
      (_) => _onSearchChanged(),
      time: const Duration(milliseconds: 500),
    );
    _searchSkuWorker = debounce(
      searchSku,
      (_) => _onSearchChanged(),
      time: const Duration(milliseconds: 500),
    );
  }

  void _onSearchChanged() {
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  void _initializeScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8) {
        if (!isPaginationLoading.value &&
            currentPage.value < totalPages.value) {
          loadMoreProducts();
        }
      }
    });
  }

  Future<AdminProductsService> init() async {
    await fetchProducts(refresh: true);
    return this;
  }

  // Main fetch method
  Future<void> fetchProducts({
    bool refresh = false,
    bool showLoader = true,
  }) async {
    try {
      if (refresh) {
        currentPage.value = 1;
      }

      if (showLoader) {
        if (refresh) {
          isRefreshing.value = true;
        } else {
          isLoading.value = true;
        }
      }

      final LoginResponse? current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        return;
      }

      if (current?.user?.role == 'customer') {
        return;
      }

      final uri = _buildUri();
      final response = await http.get(
        uri,
        headers: {
          'dashboard-view':
              AuthService.instance.authCustomer?.user?.meta?.dashboardView ??
              '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
        },
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 404) {
        throw Exception(
          'Failed to fetch products. Status: ${response.statusCode}',
        );
      }

      if (response.statusCode == 404) {
        adminProducts.clear();
        totalItems.value = 0;
        totalPages.value = 0;
        return;
      }

      final data = jsonDecode(response.body);
      if (data['products'] == null) {
        adminProducts.clear();
        totalItems.value = 0;
        totalPages.value = 0;
        return;
      }

      final products = AdminProductsModel.fromJson(data);
      productsModel.value = products;

      if (products.products?.data != null) {
        adminProducts.assignAll(products.products!.data!);
      } else {
        adminProducts.clear();
      }

      final productsData = data['products'];
      totalItems.value = productsData['total'] ?? 0;
      totalPages.value = productsData['last_page'] ?? 0;
      if (refresh) {
        currentPage.value = productsData['current_page'] ?? 1;
      }

      await _saveProductsToCache(products);
    } catch (e, stackTrace) {
      Logger().e('Error fetching products', error: e, stackTrace: stackTrace);
      _showErrorSnackbar('Failed to load products: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isPaginationLoading.value = false;
      hideLoaderDialog();
    }
  }

  // Load more products for pagination
  Future<void> loadMoreProducts() async {
    if (isPaginationLoading.value || currentPage.value >= totalPages.value) {
      return;
    }

    isPaginationLoading.value = true;
    currentPage.value++;

    try {
      await fetchProducts(refresh: false, showLoader: false);
    } catch (e) {
      currentPage.value--;
      Logger().e('Error loading more products', error: e);
    }
  }

  // Search methods - all fields work simultaneously
  void updateSearchName(String query) {
    searchName.value = query;
  }

  void updateSearchId(String query) {
    searchId.value = query;
  }

  void updateSearchSku(String query) {
    searchSku.value = query;
  }

  // Legacy search methods for backward compat
  void updateSearchQuery(String query) {
    searchName.value = query;
  }

  void updateSearchField(String field) {
    searchField.value = field;
  }

  // Status filter
  void updateStatusFilter(ProductStatus status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Sort filter
  void updateSortOrder(SortOrder order) {
    sortOrder.value = order;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Shop filter
  Future<void> searchShops(String query) async {
    if (query.isEmpty) {
      shopSearchResults.clear();
      return;
    }

    isSearchingShops.value = true;
    try {
      final uri = Uri.parse('$_shopsUrl?search=$query');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final shops = data['shops']?['data'] as List? ?? [];
        shopSearchResults.value =
            shops
                .map(
                  (s) => ShopItem(
                    id: s['id']?.toString() ?? '',
                    name: s['name']?.toString() ?? '',
                  ),
                )
                .toList();
      }
    } catch (e) {
      Logger().e('Error searching shops', error: e);
    } finally {
      isSearchingShops.value = false;
    }
  }

  void selectShop(ShopItem? shop) {
    if (shop == null) {
      selectedShopId.value = '';
      selectedShopName.value = '';
    } else {
      selectedShopId.value = shop.id;
      selectedShopName.value = shop.name;
    }
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Featured filter
  void updateFeaturedFilter(FeaturedFilter filter) {
    featuredFilter.value = filter;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Category filter
  Future<void> searchCategories(String query) async {
    if (query.isEmpty) {
      categorySearchResults.clear();
      return;
    }

    isSearchingCategories.value = true;
    try {
      final uri = Uri.parse(
        '$_categoriesUrl?limit=all&hide_empty=true&search=$query',
      );
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final categories =
            data is List
                ? data
                : (data['product_attribute']['attribute_items']['product_attribute_items']
                        as List? ??
                    []);
        categorySearchResults.value =
            categories
                .map(
                  (c) => CategoryItem(
                    id: c['id']?.toString() ?? '',
                    name: c['name']?.toString() ?? '',
                  ),
                )
                .toList();
      }
    } catch (e) {
      Logger().e('Error searching categories', error: e);
    } finally {
      isSearchingCategories.value = false;
    }
  }

  void selectCategory(CategoryItem? category) {
    if (category == null) {
      selectedCategoryId.value = '';
      selectedCategoryName.value = '';
    } else {
      selectedCategoryId.value = category.id;
      selectedCategoryName.value = category.name;
    }
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  void updateCategoryOperator(String op) {
    categoryOperator.value = op;
    if (selectedCategoryId.value.isNotEmpty) {
      currentPage.value = 1;
      fetchProducts(refresh: true);
    }
  }

  // Group by SKU
  void toggleGroupBySku(bool value) {
    groupBySku.value = value;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Inventory Updated
  void toggleInventoryUpdated(bool value) {
    inventoryUpdatedEnabled.value = value;
    if (!value) {
      inventoryStartDate.value = null;
      inventoryEndDate.value = null;
    }
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  void updateInventoryDateRange(DateTime? start, DateTime? end) {
    inventoryStartDate.value = start;
    inventoryEndDate.value = end;
    if (inventoryUpdatedEnabled.value) {
      currentPage.value = 1;
      fetchProducts(refresh: true);
    }
  }

  // Flash Deals Added
  void toggleFlashDealsAdded(bool value) {
    flashDealsAddedEnabled.value = value;
    if (!value) {
      flashDealsStartDate.value = null;
      flashDealsEndDate.value = null;
    }
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  void updateFlashDealsDateRange(DateTime? start, DateTime? end) {
    flashDealsStartDate.value = start;
    flashDealsEndDate.value = end;
    if (flashDealsAddedEnabled.value) {
      currentPage.value = 1;
      fetchProducts(refresh: true);
    }
  }

  // Analytics date range
  void updateAnalyticsDateRange(DateTime? start, DateTime? end) {
    analyticsStartDate.value = start;
    analyticsEndDate.value = end;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // SKU filter (mutually exclusive with quick filters)
  void updateSkuFilter(SkuFilter filter) {
    // Clear active quick filters when selecting SKU filter
    if (filter != SkuFilter.all) {
      activeFilters.clear();
    }
    skuFilter.value = filter;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Date range filter
  void updateDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Column filters (mutually exclusive - only one quick filter at a time)
  void addColumnFilter(ProductFilter filter) {
    // Clear all active filters and SKU filter (only one quick filter at a time)
    activeFilters.clear();
    skuFilter.value = SkuFilter.all;
    activeFilters.add(filter);
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  void removeColumnFilter(FilterColumn column) {
    activeFilters.removeWhere((f) => f.column == column);
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Clear all filters
  void clearAllFilters() {
    activeFilters.clear();
    selectedStatus.value = ProductStatus.all;
    searchName.value = '';
    searchId.value = '';
    searchSku.value = '';
    searchQuery.value = '';
    startDate.value = null;
    endDate.value = null;
    sortOrder.value = SortOrder.none;
    selectedShopId.value = '';
    selectedShopName.value = '';
    featuredFilter.value = FeaturedFilter.all;
    selectedCategoryId.value = '';
    selectedCategoryName.value = '';
    categoryOperator.value = '=';
    groupBySku.value = false;
    inventoryUpdatedEnabled.value = false;
    inventoryStartDate.value = null;
    inventoryEndDate.value = null;
    flashDealsAddedEnabled.value = false;
    flashDealsStartDate.value = null;
    flashDealsEndDate.value = null;
    analyticsStartDate.value = null;
    analyticsEndDate.value = null;
    skuFilter.value = SkuFilter.all;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // URI building with all filters
  Uri _buildUri() {
    final Map<String, String> queryParams = {
      'with': 'thumbnail,shop,variations',
      'include_analytics': 'true',
      'per_page': perPage.value.toString(),
      'page': currentPage.value.toString(),
      'start_date': '2000-01-01 00:00:01',
      'end_date': '2100-01-01 00:00:01',
      '_t': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    // Search fields - all sent simultaneously with filterJoin=OR
    bool hasSearch = false;
    if (searchName.value.isNotEmpty) {
      queryParams['search'] = searchName.value;
      hasSearch = true;
    }
    if (searchId.value.isNotEmpty) {
      queryParams['search_by_id'] = searchId.value;
      hasSearch = true;
    }
    if (searchSku.value.isNotEmpty) {
      queryParams['sku'] = searchSku.value;
      hasSearch = true;
    }
    if (hasSearch) {
      queryParams['filterJoin'] = 'OR';
    }

    // Sorting
    if (sortOrder.value == SortOrder.priceAsc) {
      queryParams['orderBy'] = 'price';
      queryParams['order'] = 'asc';
    } else if (sortOrder.value == SortOrder.priceDesc) {
      queryParams['orderBy'] = 'price';
      queryParams['order'] = 'desc';
    } else if (sortOrder.value == SortOrder.recentUpdatedAll) {
      queryParams['orderBy'] = 'created_at';
      queryParams['order'] = 'desc';
    } else if (sortOrder.value != SortOrder.none) {
      // All customOrder sorts keep default orderBy=price&order=asc
      queryParams['orderBy'] = 'price';
      queryParams['order'] = 'asc';
      queryParams['customOrder'] = _getCustomOrderValue(sortOrder.value);
    }

    // Group by SKU
    if (groupBySku.value) {
      queryParams['group_by_sku'] = 'true';
    }

    int columnIndex = 0;

    // 1. Status filter
    if (selectedStatus.value != ProductStatus.all) {
      final statusValue =
          selectedStatus.value == ProductStatus.active
              ? 'active'
              : selectedStatus.value == ProductStatus.inactive
              ? 'inactive'
              : 'deleted';

      queryParams['filterByColumns[columns][$columnIndex][column]'] = 'status';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          statusValue;
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // 2. Exclude product_group = car
    queryParams['filterByColumns[columns][$columnIndex][column]'] =
        'product_group';
    queryParams['filterByColumns[columns][$columnIndex][value]'] = 'car';
    queryParams['filterByColumns[columns][$columnIndex][operator]'] = '!=';
    columnIndex++;

    // 3. Exclude product_type = auction
    queryParams['filterByColumns[columns][$columnIndex][column]'] =
        'product_type';
    queryParams['filterByColumns[columns][$columnIndex][value]'] = 'auction';
    queryParams['filterByColumns[columns][$columnIndex][operator]'] = '!=';
    columnIndex++;

    // 4. Featured filter
    if (featuredFilter.value != FeaturedFilter.all) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] =
          'is_featured';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          featuredFilter.value == FeaturedFilter.featured ? '1' : '0';
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // 5. Shop filter
    if (selectedShopId.value.isNotEmpty) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] = 'shop_id';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          selectedShopId.value;
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // 6. Created_at date range
    if (startDate.value != null && endDate.value != null) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] =
          'created_at';
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '>=';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          startDate.value!.toIso8601String();
      columnIndex++;

      queryParams['filterByColumns[columns][$columnIndex][column]'] =
          'created_at';
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '<=';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          endDate.value!.toIso8601String();
      columnIndex++;
    }

    // 7. Flash Deals (is_deal column filter)
    if (flashDealsAddedEnabled.value) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] = 'is_deal';
      queryParams['filterByColumns[columns][$columnIndex][value]'] = '1';
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // 8. Custom active filters (column-based only, meta fields handled below)
    for (var filter in activeFilters) {
      if (!filter.isMetaField) {
        queryParams['filterByColumns[columns][$columnIndex][column]'] =
            _getColumnName(filter.column);
        queryParams['filterByColumns[columns][$columnIndex][value]'] =
            filter.value;
        queryParams['filterByColumns[columns][$columnIndex][operator]'] =
            filter.operator;
        columnIndex++;
      }
    }

    // filterByColumns join
    if (columnIndex > 0) {
      queryParams['filterByColumns[filterJoin]'] = 'AND';
    }

    // filterByAttributes - Category filter
    if (selectedCategoryId.value.isNotEmpty) {
      queryParams['filterByAttributes[filterJoin]'] = 'AND';
      queryParams['filterByAttributes[attributes][0][key]'] = 'categories';
      queryParams['filterByAttributes[attributes][0][value]'] =
          selectedCategoryId.value;
      queryParams['filterByAttributes[attributes][0][operator]'] =
          categoryOperator.value;
    }

    // filterByMetaFields
    int metaFieldIndex = 0;
    bool hasMetaFields = false;

    // Active filters that are meta fields
    for (var filter in activeFilters) {
      if (filter.isMetaField) {
        hasMetaFields = true;
        queryParams['filterByMetaFields[fields][$metaFieldIndex][key]'] =
            _getColumnName(filter.column);
        queryParams['filterByMetaFields[fields][$metaFieldIndex][value]'] =
            filter.value;
        queryParams['filterByMetaFields[fields][$metaFieldIndex][operator]'] =
            filter.operator;
        metaFieldIndex++;
      }
    }

    // Inventory Updated date range
    if (inventoryUpdatedEnabled.value &&
        inventoryStartDate.value != null &&
        inventoryEndDate.value != null) {
      hasMetaFields = true;
      queryParams['filterByMetaFields[fields][$metaFieldIndex][key]'] =
          'inventory_updated_at';
      queryParams['filterByMetaFields[fields][$metaFieldIndex][value]'] =
          '${inventoryStartDate.value!.toIso8601String()},${inventoryEndDate.value!.toIso8601String()}';
      queryParams['filterByMetaFields[fields][$metaFieldIndex][operator]'] =
          'BETWEEN';
      metaFieldIndex++;
    }

    // Flash Deals Added meta field
    if (flashDealsAddedEnabled.value) {
      hasMetaFields = true;
      queryParams['filterByMetaFields[fields][$metaFieldIndex][key]'] =
          'added_in_flash_deals_at';
      queryParams['filterByMetaFields[fields][$metaFieldIndex][value]'] =
          'NOT_EMPTY';
      queryParams['filterByMetaFields[fields][$metaFieldIndex][operator]'] =
          'IS_NOT_EMPTY';
      metaFieldIndex++;
    }

    // SKU filter
    if (skuFilter.value == SkuFilter.existing) {
      hasMetaFields = true;
      queryParams['filterByMetaFields[fields][$metaFieldIndex][key]'] = 'sku';
      queryParams['filterByMetaFields[fields][$metaFieldIndex][value]'] =
          'NOT_EMPTY';
      queryParams['filterByMetaFields[fields][$metaFieldIndex][operator]'] =
          'IS_NOT_EMPTY';
      metaFieldIndex++;
    } else if (skuFilter.value == SkuFilter.withoutSku) {
      hasMetaFields = true;
      queryParams['filterByMetaFields[fields][$metaFieldIndex][key]'] = 'sku';
      queryParams['filterByMetaFields[fields][$metaFieldIndex][value]'] =
          'EMPTY';
      queryParams['filterByMetaFields[fields][$metaFieldIndex][operator]'] =
          'IS_EMPTY';
      metaFieldIndex++;
    }

    if (hasMetaFields) {
      queryParams['filterByMetaFields[filterJoin]'] = 'AND';
    }

    // Analytics date range
    if (analyticsStartDate.value != null && analyticsEndDate.value != null) {
      queryParams['analytics_date_range[start_date]'] =
          analyticsStartDate.value!.toIso8601String();
      queryParams['analytics_date_range[end_date]'] =
          analyticsEndDate.value!.toIso8601String();
    }

    return Uri.parse(_baseUrl).replace(queryParameters: queryParams);
  }

  String _getColumnName(FilterColumn column) {
    switch (column) {
      case FilterColumn.featured:
        return 'is_featured';
      case FilterColumn.deals:
        return 'is_deal';
      case FilterColumn.notDeals:
        return 'is_deal';
      case FilterColumn.onSale:
        return 'sale_price';
      case FilterColumn.pinnedSale:
        return 'is_pinned_sale';
    }
  }

  String _getCustomOrderValue(SortOrder order) {
    switch (order) {
      case SortOrder.recentUpdatedPrice:
        return 'recent_price_updated_products_first';
      case SortOrder.recentUpdatedSalePrice:
        return 'recent_sale_price_updated_products_first';
      case SortOrder.recentUpdatedStock:
        return 'recent_stock_updated_products_first';
      case SortOrder.mostViews:
        return 'analytics_views_desc';
      case SortOrder.leastViews:
        return 'analytics_views_asc';
      case SortOrder.mostAddedToCart:
        return 'analytics_add_to_cart_desc';
      case SortOrder.leastAddedToCart:
        return 'analytics_add_to_cart_asc';
      case SortOrder.mostEnquired:
        return 'analytics_enquire_now_desc';
      case SortOrder.leastEnquired:
        return 'analytics_enquire_now_asc';
      case SortOrder.mostAddedToWishlist:
        return 'analytics_add_to_wishlist_desc';
      case SortOrder.leastAddedToWishlist:
        return 'analytics_add_to_wishlist_asc';
      case SortOrder.mostCalled:
        return 'analytics_call_desc';
      case SortOrder.leastCalled:
        return 'analytics_call_asc';
      case SortOrder.mostWhatsAppContacted:
        return 'analytics_whatsapp_desc';
      case SortOrder.leastWhatsAppContacted:
        return 'analytics_whatsapp_asc';
      case SortOrder.mostTotalInteractions:
        return 'analytics_total_interactions_desc';
      case SortOrder.leastTotalInteractions:
        return 'analytics_total_interactions_asc';
      case SortOrder.bestConversionRate:
        return 'analytics_conversion_rate_desc';
      case SortOrder.worstConversionRate:
        return 'analytics_conversion_rate_asc';
      case SortOrder.bestContactRate:
        return 'analytics_contact_rate_desc';
      case SortOrder.worstContactRate:
        return 'analytics_contact_rate_asc';
      default:
        return '';
    }
  }

  static String getSortOrderDisplayName(SortOrder order) {
    switch (order) {
      case SortOrder.none:
        return 'Default';
      case SortOrder.priceAsc:
        return 'Low to high (Price)';
      case SortOrder.priceDesc:
        return 'High to low (Price)';
      case SortOrder.recentUpdatedAll:
        return 'Recent Updated (All Fields)';
      case SortOrder.recentUpdatedPrice:
        return 'Recent Updated (Price)';
      case SortOrder.recentUpdatedSalePrice:
        return 'Recent Updated (Sale Price)';
      case SortOrder.recentUpdatedStock:
        return 'Recent Updated (Stock)';
      case SortOrder.mostViews:
        return 'Most Views';
      case SortOrder.leastViews:
        return 'Least Views';
      case SortOrder.mostAddedToCart:
        return 'Most Added to Cart';
      case SortOrder.leastAddedToCart:
        return 'Least Added to Cart';
      case SortOrder.mostEnquired:
        return 'Most Enquired';
      case SortOrder.leastEnquired:
        return 'Least Enquired';
      case SortOrder.mostAddedToWishlist:
        return 'Most Added to Wishlist';
      case SortOrder.leastAddedToWishlist:
        return 'Least Added to Wishlist';
      case SortOrder.mostCalled:
        return 'Most Called';
      case SortOrder.leastCalled:
        return 'Least Called';
      case SortOrder.mostWhatsAppContacted:
        return 'Most WhatsApp Contacted';
      case SortOrder.leastWhatsAppContacted:
        return 'Least WhatsApp Contacted';
      case SortOrder.mostTotalInteractions:
        return 'Most Total Interactions';
      case SortOrder.leastTotalInteractions:
        return 'Least Total Interactions';
      case SortOrder.bestConversionRate:
        return 'Best Conversion Rate';
      case SortOrder.worstConversionRate:
        return 'Worst Conversion Rate';
      case SortOrder.bestContactRate:
        return 'Best Contact Rate';
      case SortOrder.worstContactRate:
        return 'Worst Contact Rate';
    }
  }

  // Pagination methods
  List<int> visiblePageNumbers() {
    const int maxVisible = 5;
    final int current = currentPage.value;
    int start = current - (maxVisible ~/ 2);
    if (start < 1) start = 1;

    int end = start + maxVisible - 1;
    if (end > totalPages.value) {
      end = totalPages.value;
      start = (end - maxVisible + 1).clamp(1, totalPages.value);
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      await fetchProducts(refresh: false);
    }
  }

  Future<void> nextPage() => goToPage(currentPage.value + 1);
  Future<void> previousPage() => goToPage(currentPage.value - 1);

  // Utility methods
  Future<void> _saveProductsToCache(AdminProductsModel? products) async {
    // Implement caching logic here
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void hideLoaderDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<void> refreshProducts() async {
    await fetchProducts(refresh: true);
  }

  // Get predefined filters
  List<ProductFilter> getPredefinedFilters() {
    return [
      ProductFilter(
        name: 'Featured',
        value: '1',
        column: FilterColumn.featured,
        operator: '=',
      ),
      ProductFilter(
        name: 'Deals',
        value: '1',
        column: FilterColumn.deals,
        operator: '=',
      ),
      ProductFilter(
        name: 'Not Deals',
        value: '0',
        column: FilterColumn.notDeals,
        operator: '=',
      ),
      ProductFilter(
        name: 'On Sale',
        value: '0',
        column: FilterColumn.onSale,
        operator: '!=',
      ),
      ProductFilter(
        name: 'Pinned Sale',
        value: '1',
        column: FilterColumn.pinnedSale,
        operator: '=',
        isMetaField: true,
      ),
    ];
  }

  // Get filter summary for UI
  String getFilterSummary() {
    final List<String> filters = [];

    if (searchName.value.isNotEmpty) {
      filters.add('Name: ${searchName.value}');
    }
    if (searchId.value.isNotEmpty) {
      filters.add('ID: ${searchId.value}');
    }
    if (searchSku.value.isNotEmpty) {
      filters.add('SKU: ${searchSku.value}');
    }

    if (selectedStatus.value != ProductStatus.all) {
      filters.add('Status: ${selectedStatus.value.name}');
    }

    if (sortOrder.value != SortOrder.none) {
      filters.add(
        sortOrder.value == SortOrder.priceAsc
            ? 'Sort: Low to High'
            : 'Sort: High to Low',
      );
    }

    if (selectedShopName.value.isNotEmpty) {
      filters.add('Shop: ${selectedShopName.value}');
    }

    if (featuredFilter.value != FeaturedFilter.all) {
      filters.add(
        featuredFilter.value == FeaturedFilter.featured
            ? 'Featured'
            : 'Not Featured',
      );
    }

    if (selectedCategoryName.value.isNotEmpty) {
      final op = categoryOperator.value == '=' ? 'Include' : 'Exclude';
      filters.add('Category ($op): ${selectedCategoryName.value}');
    }

    if (startDate.value != null && endDate.value != null) {
      filters.add('Date Range Applied');
    }

    if (groupBySku.value) {
      filters.add('Group By SKU');
    }

    if (inventoryUpdatedEnabled.value) {
      filters.add('Inventory Updated');
    }

    if (flashDealsAddedEnabled.value) {
      filters.add('Flash Deals Added');
    }

    if (analyticsStartDate.value != null && analyticsEndDate.value != null) {
      filters.add('Analytics Date Range Applied');
    }

    if (skuFilter.value == SkuFilter.existing) {
      filters.add('Existing SKU');
    } else if (skuFilter.value == SkuFilter.withoutSku) {
      filters.add('Without SKU');
    }

    filters.addAll(activeFilters.map((f) => f.name));

    return filters.isEmpty ? 'No filters applied' : filters.join(', ');
  }
}
