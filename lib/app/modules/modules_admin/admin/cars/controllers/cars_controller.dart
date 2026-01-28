// cars_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/admin_products_model.dart' hide ShopData;
import 'package:tjara/app/models/product_attributes/products_attributes_model.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/const/app_urls.dart';
import 'package:tjara/app/modules/modules_admin/admin_shops_module/models/shopData_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

enum ViewState { loading, success, error, empty }

class CarsController extends GetxController {
  // Additional filter variables in CarsController
  var selectedDateRange = ''.obs;
  var selectedShop = ''.obs;
  var selectedMake = ''.obs; // This will be category from API
  var selectedStatus = 'active'.obs; // Default to active
  var groupBySku = false.obs; // Toggle for group_by_sku
  var selectedCustomOrder = ''.obs;

  // Date range variables
  var startDate = ''.obs;
  var endDate = ''.obs;

  // Add these methods to your CarsController:

  void onShopChanged(String? value) {
    selectedShop.value = value ?? '';
    _performSearch();
  }

  void onStatusChanged(String? value) {
    selectedStatus.value = value ?? 'active';
    _performSearch();
  }

  void onMakeChanged(String? value) {
    selectedMake.value = value ?? '';
    _performSearch();
  }

  void toggleGroupBySku(bool value) {
    groupBySku.value = value;
    _performSearch();
  }

  void onDateRangeSelected(String start, String end) {
    startDate.value = start;
    endDate.value = end;
    selectedDateRange.value = '$start - $end';
    _performSearch();
  }

  // Updated _makeApiRequest method in CarsController:
  Future<http.Response> _makeApiRequest() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Request-From': 'Dashboard',
      'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
      'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
    };
    // Build filter columns
    final List<String> filterColumns = [];
    int columnIndex = 0;

    // Status filter
    filterColumns.add('&filterByColumns[columns][$columnIndex][column]=status');
    filterColumns.add(
      '&filterByColumns[columns][$columnIndex][value]=${selectedStatus.value}',
    );
    filterColumns.add(
      '&filterByColumns[columns][$columnIndex][operator]=%3D',
    ); // Changed from == to %3D
    columnIndex++;

    // Product group (always car)
    filterColumns.add(
      '&filterByColumns[columns][$columnIndex][column]=product_group',
    );
    filterColumns.add('&filterByColumns[columns][$columnIndex][value]=car');
    filterColumns.add('&filterByColumns[columns][$columnIndex][operator]=%3D');
    columnIndex++;

    // Shop filter
    if (selectedShop.value.isNotEmpty) {
      filterColumns.add(
        '&filterByColumns[columns][$columnIndex][column]=shop_id',
      );
      filterColumns.add(
        '&filterByColumns[columns][$columnIndex][value]=${selectedShop.value}',
      );
      filterColumns.add(
        '&filterByColumns[columns][$columnIndex][operator]=%3D',
      );
      columnIndex++;
    }

    // Date range filter
    if (startDate.value.isNotEmpty && endDate.value.isNotEmpty) {
      final start = startDate.value;
      final end = endDate.value;

      filterColumns.add(
        '&filterByColumns[columns][$columnIndex][column]=created_at',
      );
      filterColumns.add(
        '&filterByColumns[columns][$columnIndex][value]=$start',
      );
      filterColumns.add(
        '&filterByColumns[columns][$columnIndex][operator]=%3E%3D', // >=
      );
      columnIndex++;

      filterColumns.add(
        '&filterByColumns[columns][$columnIndex][column]=created_at',
      );
      filterColumns.add('&filterByColumns[columns][$columnIndex][value]=$end');
      filterColumns.add(
        '&filterByColumns[columns][$columnIndex][operator]=%3C%3D', // <=
      );
      columnIndex++;
    }

    // Build filter attributes for categories (Make)
    final List<String> filterAttributes = [];
    if (selectedMake.value.isNotEmpty) {
      filterAttributes.add('&filterByAttributes[filterJoin]=AND');
      filterAttributes.add(
        '&filterByAttributes[attributes][0][key]=categories',
      );
      filterAttributes.add(
        '&filterByAttributes[attributes][0][value]=${selectedMake.value}',
      );
      filterAttributes.add('&filterByAttributes[attributes][0][operator]=%3D');
    }

    // Build custom order
    String customOrderParam = '';
    if (selectedCustomOrder.value.isNotEmpty) {
      customOrderParam = '&customOrder=${selectedCustomOrder.value}';
    } else if (customOrder.value.isNotEmpty) {
      customOrderParam = '&customOrder=${customOrder.value}';
    }

    final uri = Uri.parse(
      '${AppUrl.baseURL}${AppUrl.CarsData}'
      '&with=thumbnail,shop,variations'
      '&filterJoin=OR'
      '&per_page=$itemsPerPage'
      '&page=${currentPage.value}'
      '&search=${titleController.text}'
      '&search_by_id=${idController.text}'
      '&sku=${skuController.text}'
      '&orderBy=${orderBy.value.isEmpty ? 'created_at' : orderBy.value}'
      '&order=${order.value.isEmpty ? 'desc' : order.value}'
      '&filterByColumns[filterJoin]=AND'
      '${filterColumns.join('')}'
      '${filterAttributes.join('')}'
      '$customOrderParam'
      '&group_by_sku=${groupBySku.value}'
      '&_t=${DateTime.now().millisecondsSinceEpoch}',
    );

    debugPrint("API URL: ${uri.toString()}");
    debugPrint("Making API request for page: ${currentPage.value}");

    final response = await http
        .get(uri, headers: headers)
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Request timeout'),
        );

    debugPrint(
      "API response received: ${response.statusCode}, body length: ${response.body.length}",
    );

    return response;
  }

  // State Management
  var viewState = ViewState.loading.obs;
  var errorMessage = ''.obs;

  // Data
  var products = <AdminProducts>[].obs;
  var shops = ShopData().obs;
  var carMAKES = ProductAttributes().obs;
  var totalItems = 0.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var itemsPerPage = 15;

  // Controllers
  late TextEditingController titleController;
  late TextEditingController idController;
  late TextEditingController skuController;

  // Filter & Sort
  var selectedSort = ''.obs;
  var orderBy = ''.obs;
  var order = ''.obs;
  var customOrder = ''.obs;
  var shopID = ''.obs;

  // Search debouncing
  Timer? _searchDebouncer;

  // Sort options
  final List<String> sortOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
    'Recently Updated',
  ];

  @override
  void onInit() {
    super.onInit();
    debugPrint("CarsController onInit called");
    _initializeControllers();
    _loadInitialData();
  }

  @override
  void onClose() {
    _disposeControllers();
    _searchDebouncer?.cancel();
    super.onClose();
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    idController = TextEditingController();
    skuController = TextEditingController();
  }

  void _disposeControllers() {
    titleController.dispose();
    idController.dispose();
    skuController.dispose();
  }

  Future<void> _loadInitialData() async {
    debugPrint("_loadInitialData called");
    await Future.wait([getCarsData(), _getShopData(), _getCarMakesData()]);
    debugPrint("_loadInitialData completed");
  }

  // Search with debouncing
  void onSearchChanged(String value) {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void onSortChanged(String? value) {
    if (value == null) return;

    selectedSort.value = value;
    _updateSortParameters(value);
    _performSearch();
  }

  void _updateSortParameters(String sortValue) {
    switch (sortValue) {
      case 'Default':
        orderBy.value = 'created_at';
        order.value = 'desc';
        selectedCustomOrder.value = '';
        break;
      case 'Price: Low to High':
        orderBy.value = 'price';
        order.value = 'asc';
        selectedCustomOrder.value = '';
        break;
      case 'Price: High to Low':
        orderBy.value = 'price';
        order.value = 'desc';
        selectedCustomOrder.value = '';
        break;
      case 'Recently Updated':
        orderBy.value = 'updated_at';
        order.value = 'desc';
        selectedCustomOrder.value = '';
        break;
      case 'Most Viewed':
        orderBy.value = '';
        order.value = '';
        selectedCustomOrder.value = 'analytics_views_desc';
        break;
    }
  }

  Future<void> _performSearch() async {
    currentPage.value = 1; // Reset to first page when searching
    await getCarsData();
  }

  Future<void> getCarsData() async {
    debugPrint(
      "getCarsData called: currentPage=${currentPage.value}, totalPages=${totalPages.value}",
    );
    try {
      if (currentPage.value == 1) {
        viewState.value = ViewState.loading;
      }

      final response = await _makeApiRequest();
      debugPrint("API response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(
          "Parsed JSON data: ${data.toString().substring(0, 200)}...",
        ); // First 200 chars

        final model = AdminProductsModel.fromJson(data);
        debugPrint(
          "Model parsed: products.data=${model.products?.data?.length}, total=${model.products?.total}, lastPage=${model.products?.lastPage}",
        );

        products.value = model.products?.data ?? [];
        totalItems.value = model.products?.total ?? 0;
        totalPages.value = model.products?.lastPage ?? 1;

        debugPrint(
          "Data loaded: products=${products.length}, totalItems=${totalItems.value}, totalPages=${totalPages.value}",
        );

        // Log first product ID to verify data changed
        if (products.isNotEmpty) {
          debugPrint("First product ID: ${products.first.id}");
        }

        _updateViewState();
      } else {
        debugPrint("API error response: ${response.body}");
        _handleApiError(response);
      }
    } catch (e) {
      debugPrint("Exception in getCarsData: $e");
      _handleException(e);
    }
  }

  void _updateViewState() {
    if (products.isEmpty) {
      viewState.value = ViewState.empty;
    } else {
      viewState.value = ViewState.success;
    }
  }

  void _handleApiError(http.Response response) {
    final data = jsonDecode(response.body);
    if (data['message'] == 'No products found') {
      products.clear();
      viewState.value = ViewState.empty;
    } else {
      errorMessage.value =
          'Failed to load data. Status: ${response.statusCode}';
      viewState.value = ViewState.error;
    }
  }

  void _handleException(dynamic e) {
    debugPrint('Error loading cars: $e');
    if (e is TimeoutException) {
      errorMessage.value = 'Request timeout. Please check your connection.';
    } else {
      errorMessage.value = 'An unexpected error occurred. Please try again.';
    }
    viewState.value = ViewState.error;
  }

  Future<void> _getShopData() async {
    try {
      final headers = {
        'X-Request-From': 'Application',
        'Content-Type': 'application/json',
      };

      final response = await http
          .get(
            Uri.parse(
              '${AppUrl.baseURL}${AppUrl.shopData}?page=1&per_page=100',
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parsedData = ShopData.fromJson(data);

        shops.value = parsedData;
      }
    } catch (e) {
      debugPrint('Error loading shops: $e');
      // Don't change view state for shop loading errors
    }
  }

  Future<void> _getCarMakesData() async {
    try {
      final headers = {
        'X-Request-From': 'Application',
        'Content-Type': 'application/json',
      };

      final response = await http
          .get(
            Uri.parse(
              'https://api.libanbuy.com/api/product-attributes/categories?post_type=car&search=&limit=100',
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parsedData = ProductAttributes.fromJson(
          data['product_attribute'],
        );

        carMAKES.value = parsedData;
      }
    } catch (e) {
      debugPrint('Error loading shops: $e');
      // Don't change view state for shop loading errors
    }
  }

  // Pagination methods
  Future<void> goToPreviousPage() async {
    debugPrint(
      "goToPreviousPage called: currentPage=${currentPage.value}, totalPages=${totalPages.value}",
    );
    if (currentPage.value > 1) {
      currentPage.value--;
      debugPrint("Going to previous page: ${currentPage.value}");
      await getCarsData();
    } else {
      debugPrint("Cannot go to previous page: already at page 1");
    }
  }

  Future<void> goToNextPage() async {
    debugPrint(
      "goToNextPage called: currentPage=${currentPage.value}, totalPages=${totalPages.value}",
    );
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      debugPrint("Going to next page: ${currentPage.value}");
      await getCarsData();
    } else {
      debugPrint("Cannot go to next page: already at last page");
    }
  }

  Future<void> goToPage(int page) async {
    debugPrint(
      "goToPage called: page=$page, currentPage=${currentPage.value}, totalPages=${totalPages.value}",
    );
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      debugPrint("Going to page: ${currentPage.value}");
      await getCarsData();
    } else {
      debugPrint("Cannot go to page $page: invalid or same page");
    }
  }

  int calculateStartPage() {
    int start = currentPage.value - 2;
    if (start < 1) start = 1;
    if (start + 4 > totalPages.value) {
      start = (totalPages.value - 4).clamp(1, totalPages.value);
    }
    return start;
  }

  String getDisplayRange() {
    if (totalItems.value == 0) return "0 to 0";

    final int start = ((currentPage.value - 1) * itemsPerPage) + 1;
    final int end = (currentPage.value * itemsPerPage).clamp(
      1,
      totalItems.value,
    );

    return "$start to $end";
  }

  // Retry functionality
  Future<void> retryLoadData() async {
    await _loadInitialData();
  }

  // Refresh functionality
  Future<void> refreshData() async {
    currentPage.value = 1;
    await _loadInitialData();
  }

  // Clear filters
  void clearFilters() {
    titleController.clear();
    idController.clear();
    skuController.clear();
    selectedSort.value = '';
    orderBy.value = '';
    order.value = '';
    customOrder.value = '';
    shopID.value = '';

    _performSearch();
  }

  // Utility methods
  bool get hasData => products.isNotEmpty;
  bool get isLoading => viewState.value == ViewState.loading;
  bool get hasError => viewState.value == ViewState.error;
  bool get isEmpty => viewState.value == ViewState.empty;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

// Extension for better error handling
extension ResponseExtension on http.Response {
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
}
