// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

enum CarProductStatus { all, active, inactive, deleted }

enum CarFilterColumn { salePrice, featured, productGroup, productType, status }

enum CarSortOrder { none, priceAsc, priceDesc }

enum CarFeaturedFilter { all, featured, notFeatured }

class CarProductFilter {
  final String name;
  final String value;
  final CarFilterColumn column;
  final String operator;

  CarProductFilter({
    required this.name,
    required this.value,
    required this.column,
    required this.operator,
  });
}

class CarShopItem {
  final String id;
  final String name;

  CarShopItem({required this.id, required this.name});
}

class CarCategoryItem {
  final String id;
  final String name;

  CarCategoryItem({required this.id, required this.name});
}

class AdminCarsService extends GetxService {
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
  final Rx<CarProductStatus> selectedStatus = CarProductStatus.all.obs;

  // Created at date range
  final Rx<DateTime?> startDate = Rxn<DateTime>();
  final Rx<DateTime?> endDate = Rxn<DateTime>();

  // Sorting
  final Rx<CarSortOrder> sortOrder = CarSortOrder.none.obs;

  // Shop filter
  final RxString selectedShopId = ''.obs;
  final RxString selectedShopName = ''.obs;
  final RxList<CarShopItem> shopSearchResults = <CarShopItem>[].obs;
  final RxBool isSearchingShops = false.obs;

  // Featured filter
  final Rx<CarFeaturedFilter> featuredFilter = CarFeaturedFilter.all.obs;

  // Category filter (Make for cars)
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedCategoryName = ''.obs;
  final RxString categoryOperator = '='.obs;
  final RxList<CarCategoryItem> categorySearchResults = <CarCategoryItem>[].obs;
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
  final RxList<CarProductFilter> activeFilters = <CarProductFilter>[].obs;

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

  Future<AdminCarsService> init() async {
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
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id':
              AuthService.instance.authCustomer?.user?.id?.toString() ?? '',
        },
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 404) {
        throw Exception(
          'Failed to fetch cars. Status: ${response.statusCode}',
        );
      }

      if (response.statusCode == 404) {
        return;
      }

      final data = jsonDecode(response.body);
      if (data['products'] == null) {
        throw Exception('Products data is missing from response');
      }

      final products = AdminProductsModel.fromJson(data);
      productsModel.value = products;

      if (products.products?.data != null) {
        adminProducts.assignAll(products.products!.data!);
      }

      final productsData = data['products'];
      totalItems.value = productsData['total'] ?? 0;
      totalPages.value = productsData['last_page'] ?? 0;
      if (refresh) {
        currentPage.value = productsData['current_page'] ?? 1;
      }

      await _saveProductsToCache(products);
    } catch (e, stackTrace) {
      Logger().e('Error fetching cars', error: e, stackTrace: stackTrace);
      _showErrorSnackbar('Failed to load cars: ${e.toString()}');
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
      Logger().e('Error loading more cars', error: e);
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
  void updateStatusFilter(CarProductStatus status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Sort filter
  void updateSortOrder(CarSortOrder order) {
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
          'user-id':
              AuthService.instance.authCustomer?.user?.id?.toString() ?? '',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final shops = data['shops']?['data'] as List? ?? [];
        shopSearchResults.value =
            shops
                .map(
                  (s) => CarShopItem(
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

  void selectShop(CarShopItem? shop) {
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
  void updateFeaturedFilter(CarFeaturedFilter filter) {
    featuredFilter.value = filter;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Category filter (Make for cars)
  Future<void> searchCategories(String query) async {
    if (query.isEmpty) {
      categorySearchResults.clear();
      return;
    }

    isSearchingCategories.value = true;
    try {
      final uri = Uri.parse(
        '$_categoriesUrl?limit=all&hide_empty=true&search=$query&post_type=car',
      );
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id':
              AuthService.instance.authCustomer?.user?.id?.toString() ?? '',
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
                  (c) => CarCategoryItem(
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

  void selectCategory(CarCategoryItem? category) {
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

  // Date range filter
  void updateDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Column filters
  void addColumnFilter(CarProductFilter filter) {
    activeFilters.removeWhere((f) => f.column == filter.column);
    activeFilters.add(filter);
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  void removeColumnFilter(CarFilterColumn column) {
    activeFilters.removeWhere((f) => f.column == column);
    currentPage.value = 1;
    fetchProducts(refresh: true);
  }

  // Clear all filters
  void clearAllFilters() {
    activeFilters.clear();
    selectedStatus.value = CarProductStatus.all;
    searchName.value = '';
    searchId.value = '';
    searchSku.value = '';
    searchQuery.value = '';
    startDate.value = null;
    endDate.value = null;
    sortOrder.value = CarSortOrder.none;
    selectedShopId.value = '';
    selectedShopName.value = '';
    featuredFilter.value = CarFeaturedFilter.all;
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
    if (sortOrder.value != CarSortOrder.none) {
      queryParams['orderBy'] = 'price';
      queryParams['order'] =
          sortOrder.value == CarSortOrder.priceAsc ? 'asc' : 'desc';
    }

    // Group by SKU
    if (groupBySku.value) {
      queryParams['group_by_sku'] = 'true';
    }

    int columnIndex = 0;

    // 1. Status filter
    if (selectedStatus.value != CarProductStatus.all) {
      final statusValue =
          selectedStatus.value == CarProductStatus.active
              ? 'active'
              : selectedStatus.value == CarProductStatus.inactive
              ? 'inactive'
              : 'deleted';

      queryParams['filterByColumns[columns][$columnIndex][column]'] = 'status';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          statusValue;
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // 2. Include product_group = car (key difference from auction/products service)
    queryParams['filterByColumns[columns][$columnIndex][column]'] =
        'product_group';
    queryParams['filterByColumns[columns][$columnIndex][value]'] = 'car';
    queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
    columnIndex++;

    // 3. Featured filter
    if (featuredFilter.value != CarFeaturedFilter.all) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] =
          'is_featured';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          featuredFilter.value == CarFeaturedFilter.featured ? '1' : '0';
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // 4. Shop filter
    if (selectedShopId.value.isNotEmpty) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] = 'shop_id';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          selectedShopId.value;
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // 5. Created_at date range
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

    // 6. Flash Deals (is_deal column filter)
    if (flashDealsAddedEnabled.value) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] = 'is_deal';
      queryParams['filterByColumns[columns][$columnIndex][value]'] = '1';
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // 7. Custom active filters
    for (var filter in activeFilters) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] =
          _getColumnName(filter.column);
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          filter.value;
      queryParams['filterByColumns[columns][$columnIndex][operator]'] =
          filter.operator;
      columnIndex++;
    }

    // filterByColumns join
    if (columnIndex > 0) {
      queryParams['filterByColumns[filterJoin]'] = 'AND';
    }

    // filterByAttributes - Category filter (Make for cars)
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

    if (hasMetaFields) {
      queryParams['filterByMetaFields[filterJoin]'] = 'AND';
    }

    return Uri.parse(_baseUrl).replace(queryParameters: queryParams);
  }

  String _getColumnName(CarFilterColumn column) {
    switch (column) {
      case CarFilterColumn.salePrice:
        return 'sale_price';
      case CarFilterColumn.featured:
        return 'is_featured';
      case CarFilterColumn.productGroup:
        return 'product_group';
      case CarFilterColumn.productType:
        return 'product_type';
      case CarFilterColumn.status:
        return 'status';
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
  List<CarProductFilter> getPredefinedFilters() {
    return [
      CarProductFilter(
        name: 'Cars with Sale Price',
        value: '0',
        column: CarFilterColumn.salePrice,
        operator: '!=',
      ),
      CarProductFilter(
        name: 'Non-Featured Cars',
        value: '0',
        column: CarFilterColumn.featured,
        operator: '=',
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

    if (selectedStatus.value != CarProductStatus.all) {
      filters.add('Status: ${selectedStatus.value.name}');
    }

    if (sortOrder.value != CarSortOrder.none) {
      filters.add(
        sortOrder.value == CarSortOrder.priceAsc
            ? 'Sort: Low to High'
            : 'Sort: High to Low',
      );
    }

    if (selectedShopName.value.isNotEmpty) {
      filters.add('Shop: ${selectedShopName.value}');
    }

    if (featuredFilter.value != CarFeaturedFilter.all) {
      filters.add(
        featuredFilter.value == CarFeaturedFilter.featured
            ? 'Featured'
            : 'Not Featured',
      );
    }

    if (selectedCategoryName.value.isNotEmpty) {
      final op = categoryOperator.value == '=' ? 'Include' : 'Exclude';
      filters.add('Make ($op): ${selectedCategoryName.value}');
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

    filters.addAll(activeFilters.map((f) => f.name));

    return filters.isEmpty ? 'No filters applied' : filters.join(', ');
  }
}
