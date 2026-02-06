// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

enum ProductStatus { all, active, inactive, deleted }

enum FilterColumn { salePrice, featured, productGroup, productType, status }

class ProductFilter {
  final String name;
  final String value;
  final FilterColumn column;
  final String operator;

  ProductFilter({
    required this.name,
    required this.value,
    required this.column,
    required this.operator,
  });
}

class AdminProductsService extends GetxService {
  static const String _baseUrl = 'https://api.libanbuy.com/api/products';
  static const String _commonParams =
      '?with=thumbnail,shop&filterByColumns[filterJoin]=AND';

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

  // Search and filters
  final RxString searchQuery = ''.obs;
  final RxString searchField = 'name'.obs; // name, id, sku
  final Rx<ProductStatus> selectedStatus = ProductStatus.all.obs;
  final RxList<ProductFilter> activeFilters = <ProductFilter>[].obs;
  final Rx<DateTime?> startDate = Rxn<DateTime>();
  final Rx<DateTime?> endDate = Rxn<DateTime>();

  // Debounce for search
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _initializeSearchWorker();
    _initializeScrollController();
  }

  void _initializeSearchWorker() {
    _searchWorker = debounce(
      searchQuery,
      (String query) => _handleSearch(query),
      time: const Duration(milliseconds: 500),
    );
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

  // Main fetch method with comprehensive filtering
  Future<void> fetchProducts({
    bool refresh = false,
    bool showLoader = true,
  }) async {
    try {
      if (refresh) {
        adminProducts.clear();
        currentPage.value = 1; // Reset to page 1 on refresh
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

      if (current?.user?.role != 'admin') {
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
        return;
      }

      final data = jsonDecode(response.body);
      if (data['products'] == null) {
        throw Exception('Products data is missing from response');
      }

      final products = AdminProductsModel.fromJson(data);
      productsModel.value = products;

      if (refresh) {
        adminProducts.clear();
      }

      if (products.products?.data != null) {
        adminProducts.addAll(products.products!.data!);
      }

      // Update pagination info - but don't override currentPage if it was manually set
      final productsData = data['products'];
      totalItems.value = productsData['total'] ?? 0;
      totalPages.value = productsData['last_page'] ?? 0;
      // Only update currentPage from response if we're not on a manual page navigation
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
      currentPage.value--; // Revert on error
      Logger().e('Error loading more products', error: e);
    }
  }

  // Search functionality
  void _handleSearch(String query) {
    if (query.isEmpty && searchQuery.value.isEmpty) return;
    currentPage.value = 1; // Reset to first page when searching
    fetchProducts(refresh: true);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateSearchField(String field) {
    searchField.value = field;
    if (searchQuery.value.isNotEmpty) {
      currentPage.value = 1; // Reset to first page when changing search field
      fetchProducts(refresh: true);
    }
  }

  // Filter methods
  void updateStatusFilter(ProductStatus status) {
    selectedStatus.value = status;
    currentPage.value = 1; // Reset to first page when filtering
    fetchProducts(refresh: true);
  }

  void addColumnFilter(ProductFilter filter) {
    activeFilters.removeWhere((f) => f.column == filter.column);
    activeFilters.add(filter);
    currentPage.value = 1; // Reset to first page when filtering
    fetchProducts(refresh: true);
  }

  void removeColumnFilter(FilterColumn column) {
    activeFilters.removeWhere((f) => f.column == column);
    currentPage.value = 1; // Reset to first page when filtering
    fetchProducts(refresh: true);
  }

  void clearAllFilters() {
    activeFilters.clear();
    selectedStatus.value = ProductStatus.all;
    searchQuery.value = '';
    startDate.value = null;
    endDate.value = null;
    currentPage.value = 1; // Reset to first page when clearing filters
    fetchProducts(refresh: true);
  }

  void updateDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    currentPage.value = 1; // Reset to first page when filtering
    fetchProducts(refresh: true);
  }

  // URI building with all filters
  Uri _buildUri() {
    final Map<String, String> queryParams = {
      'with': 'thumbnail,shop',
      'per_page': perPage.value.toString(),
      'page': currentPage.value.toString(),
      '_t': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    int columnIndex = 0;

    // 1. Add status filter first (this is important for working query)
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

    if ((AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '')
        .isNotEmpty) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] = 'shop_id';
      queryParams['filterByColumns[columns][$columnIndex][value]'] = 'car';
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // 4. Add created_at date range filter if provided
    if (startDate.value != null && endDate.value != null) {
      final start = startDate.value!.toIso8601String().split('T')[0];
      final end = endDate.value!.toIso8601String().split('T')[0];

      queryParams['filterByColumns[columns][$columnIndex][column]'] =
          'created_at';
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '>=';
      queryParams['filterByColumns[columns][$columnIndex][value]'] = start;
      columnIndex++;

      queryParams['filterByColumns[columns][$columnIndex][column]'] =
          'created_at';
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '<=';
      queryParams['filterByColumns[columns][$columnIndex][value]'] = end;
      columnIndex++;
    }

    // 5. Add search parameters if any
    if (searchQuery.value.isNotEmpty) {
      switch (searchField.value) {
        case 'name':
          queryParams['search'] = searchQuery.value;
          break;
        case 'id':
          queryParams['search_by_id'] = searchQuery.value;
          break;
        case 'sku':
          queryParams['sku'] = searchQuery.value;
          break;
      }
    }

    // 6. Add custom active filters
    for (var filter in activeFilters) {
      queryParams['filterByColumns[columns][$columnIndex][column]'] =
          _getColumnName(filter.column);
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          filter.value;
      queryParams['filterByColumns[columns][$columnIndex][operator]'] =
          filter.operator;
      columnIndex++;
    }

    // 7. Add filterJoin if any filters were added
    if (columnIndex > 0) {
      queryParams['filterByColumns[filterJoin]'] = 'AND';
    }

    return Uri.parse(_baseUrl).replace(queryParameters: queryParams);
  }

  String _getColumnName(FilterColumn column) {
    switch (column) {
      case FilterColumn.salePrice:
        return 'sale_price';
      case FilterColumn.featured:
        return 'is_featured';
      case FilterColumn.productGroup:
        return 'product_group';
      case FilterColumn.productType:
        return 'product_type';
      case FilterColumn.status:
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
      // Don't use refresh=true here to maintain pagination
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

  // Refresh method for pull-to-refresh
  Future<void> refreshProducts() async {
    await fetchProducts(refresh: true);
  }

  // Get predefined filters
  List<ProductFilter> getPredefinedFilters() {
    return [
      ProductFilter(
        name: 'Products with Sale Price',
        value: '0',
        column: FilterColumn.salePrice,
        operator: '!=',
      ),
      ProductFilter(
        name: 'Non-Featured Products',
        value: '0',
        column: FilterColumn.featured,
        operator: '=',
      ),
      ProductFilter(
        name: 'Car Products',
        value: 'car',
        column: FilterColumn.productGroup,
        operator: '=',
      ),
      ProductFilter(
        name: 'Auction Products',
        value: 'auction',
        column: FilterColumn.productType,
        operator: '=',
      ),
    ];
  }

  // Get filter summary for UI
  String getFilterSummary() {
    final List<String> filters = [];

    if (searchQuery.value.isNotEmpty) {
      filters.add('Search: ${searchQuery.value}');
    }

    if (selectedStatus.value != ProductStatus.all) {
      filters.add('Status: ${selectedStatus.value.name}');
    }

    if (startDate.value != null && endDate.value != null) {
      filters.add('Date Range Applied');
    }

    filters.addAll(activeFilters.map((f) => f.name));

    return filters.isEmpty ? 'No filters applied' : filters.join(', ');
  }
}
