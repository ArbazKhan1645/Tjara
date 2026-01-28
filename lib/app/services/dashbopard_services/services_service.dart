// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:tjara/app/core/dialogs/loading_dialog.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';

import 'package:tjara/app/modules/modules_customer/tjara_services/model/sevices_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

enum LoadingState { initial, loading, loaded, error, empty }

class ServicesService extends GetxService {
  Future<ServicesService> init() async {
    return this;
  }

  final String _apiUrl = 'https://api.libanbuy.com/api/services';

  // Observable data
  final productsModel = Rxn<ServicesResponse>();
  final RxList<ServiceData> adminProducts = <ServiceData>[].obs;
  final RxList<ServiceData> filteredProducts = <ServiceData>[].obs;

  // Loading and pagination state
  final Rx<LoadingState> loadingState = LoadingState.initial.obs;
  final RxBool isSearching = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isExporting = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 10.obs;
  final RxInt totalPages = 0.obs;
  final RxInt totalItems = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Controllers
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Debounce timer for search
  Worker? _searchWorker;

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _initializeSearchListener() {
    // Auto-search with debounce
    _searchWorker = debounce(
      searchQuery,
      (query) => _performSearch(query),
      time: const Duration(milliseconds: 500),
    );

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      filteredProducts.assignAll(adminProducts);
      return;
    }

    isSearching.value = true;
    try {
      await searchServices(query: query);
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> fetchProducts({required bool loaderType}) async {
    if (loaderType) {
      loadingState.value = LoadingState.loading;
    }

    try {
      final current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        throw Exception('User not authenticated');
      }
      _initializeSearchListener();

      final uri = Uri.parse(_apiUrl).replace(
        queryParameters: {
          'per_page': perPage.value.toString(),
          'page': currentPage.value.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['services'] == null) {
        throw Exception('Invalid response format');
      }

      final services = ServicesResponse.fromJson(data);
      productsModel.value = services;

      final newServices = services.services?.data ?? [];
      adminProducts.assignAll(newServices);
      filteredProducts.assignAll(newServices);

      totalPages.value = services.services?.lastPage ?? 0;
      totalItems.value = services.services?.total ?? 0;

      // Update loading state based on data
      if (newServices.isEmpty) {
        loadingState.value = LoadingState.empty;
      } else {
        loadingState.value = LoadingState.loaded;
      }

      errorMessage.value = '';
    } catch (e, stackTrace) {
      Logger().e('Error fetching services', error: e, stackTrace: stackTrace);
      errorMessage.value = _getErrorMessage(e);
      loadingState.value = LoadingState.error;
    } finally {
      if (loaderType) {
        // Loading state will be updated above
      }
    }
  }

  Future<void> searchServices({
    required String query,
    int? categoryId,
    String? status,
  }) async {
    if (query.trim().isEmpty) {
      filteredProducts.assignAll(adminProducts);
      return;
    }

    loadingState.value = LoadingState.loading;

    try {
      final current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        throw Exception('User not authenticated');
      }

      final queryParams = <String, String>{
        'search': query.trim(),
        'per_page': perPage.value.toString(),
        'page': '1',
      };

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(_apiUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Search failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['services'] == null) {
        throw Exception('Invalid search response');
      }

      final services = ServicesResponse.fromJson(data);
      productsModel.value = services;

      final searchResults = services.services?.data ?? [];
      adminProducts.assignAll(searchResults);
      filteredProducts.assignAll(searchResults);

      totalPages.value = services.services?.lastPage ?? 0;
      totalItems.value = services.services?.total ?? 0;
      currentPage.value = 1;

      if (searchResults.isEmpty) {
        loadingState.value = LoadingState.empty;
      } else {
        loadingState.value = LoadingState.loaded;
      }

      errorMessage.value = '';
    } catch (e, stackTrace) {
      Logger().e('Error searching services', error: e, stackTrace: stackTrace);
      errorMessage.value = _getErrorMessage(e);
      loadingState.value = LoadingState.error;

      Get.snackbar(
        'Search Failed',
        _getErrorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      isDeleting.value = true;

      final current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$_apiUrl/$serviceId/delete'),
        headers: {
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Remove from local lists
        adminProducts.removeWhere((service) => service.id == serviceId);
        filteredProducts.removeWhere((service) => service.id == serviceId);

        return true;
      } else {
        throw Exception('Failed to delete service');
      }
    } catch (e) {
      Logger().e('Error deleting service', error: e);
      Get.snackbar(
        'Error',
        'Failed to delete service: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> refreshData() async {
    currentPage.value = 1;
    searchController.clear();
    searchQuery.value = '';
    await fetchProducts(loaderType: true);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredProducts.assignAll(adminProducts);
  }

  List<int> visiblePageNumbers() {
    const int maxVisible = 5;
    final int current = currentPage.value;
    final int total = totalPages.value;

    if (total == 0) return [];

    int start = (current - (maxVisible ~/ 2)).clamp(1, total);
    final int end = (start + maxVisible - 1).clamp(1, total);

    if (end - start < maxVisible - 1) {
      start = (end - maxVisible + 1).clamp(1, total);
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      await fetchProducts(loaderType: false);
    }
  }

  Future<void> nextPage() async {
    if (currentPage.value < totalPages.value) {
      await goToPage(currentPage.value + 1);
    }
  }

  Future<void> previousPage() async {
    if (currentPage.value > 1) {
      await goToPage(currentPage.value - 1);
    }
  }

  Future<void> exportData({required BuildContext context}) async {
    try {
      isExporting.value = true;

      // Show loading dialog
      showTopLoaderDialog();

      // Create Excel workbook
      final excel = Excel.createExcel();
      final sheet = excel['Services Data'];

      // Add header row
      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Service Name'),
        TextCellValue('Category'),
        TextCellValue('Price'),
        TextCellValue('Status'),
        TextCellValue('Provider'),
        TextCellValue('Created Date'),
        TextCellValue('Updated Date'),
      ]);

      // Add data rows
      for (var service in adminProducts) {
        sheet.appendRow([
          IntCellValue((int.tryParse(service.id.toString())) ?? 0),
          TextCellValue(service.name ?? ''),

          TextCellValue(service.price?.toString() ?? '0'),
          TextCellValue(service.status ?? ''),

          TextCellValue(service.createdAt ?? ''),
          TextCellValue(service.updatedAt ?? ''),
        ]);
      }

      // Save and convert to Uint8List
      final List<int>? excelList = excel.save();
      if (excelList == null) {
        throw Exception('Failed to generate Excel file');
      }

      final Uint8List bytes = Uint8List.fromList(excelList);

      // Save file with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await FileSaver.instance.saveFile(
        name: 'services_export_$timestamp',
        bytes: bytes,

        mimeType: MimeType.microsoftExcel,
      );

      NotificationHelper.showSuccess(
        context,
        'Export Successful',
        'Services data exported successfully',
      );
    } catch (e) {
      Logger().e('Error exporting data', error: e);
      NotificationHelper.showError(
        context,
        'Export Failed',
        'Failed to export data: ${_getErrorMessage(e)}',
      );
    } finally {
      isExporting.value = false;
      hideLoaderDialog();
    }
  }

  Future<void> saveCsv({required BuildContext context}) async {
    try {
      isExporting.value = true;
      showTopLoaderDialog();

      final rows = <List<dynamic>>[
        [
          'ID',
          'Service Name',
          'Category',
          'Price',
          'Status',
          'Provider',
          'Created Date',
        ],
      ];

      // Add data rows
      for (var service in adminProducts) {
        rows.add([
          service.id ?? 0,
          service.name ?? '',

          service.price?.toString() ?? '0',
          service.status ?? '',

          service.createdAt ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final bytes = Uint8List.fromList(utf8.encode(csv));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await FileSaver.instance.saveFile(
        name: 'services_export_$timestamp',
        bytes: bytes,

        mimeType: MimeType.text,
      );

      NotificationHelper.showSuccess(
        context,
        'Export Successful',
        'CSV file saved successfully',
      );
    } catch (e) {
      Logger().e('Error saving CSV', error: e);
      NotificationHelper.showError(
        context,
        'Export Failed',
        'Failed to save CSV: ${_getErrorMessage(e)}',
      );
    } finally {
      isExporting.value = false;
      hideLoaderDialog();
    }
  }

  void hideLoaderDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }

  // Getters for UI state
  bool get isLoading => loadingState.value == LoadingState.loading;
  bool get hasError => loadingState.value == LoadingState.error;
  bool get isEmpty => loadingState.value == LoadingState.empty;
  bool get hasData =>
      loadingState.value == LoadingState.loaded && filteredProducts.isNotEmpty;
  bool get canGoNext => currentPage.value < totalPages.value;
  bool get canGoPrevious => currentPage.value > 1;
}
