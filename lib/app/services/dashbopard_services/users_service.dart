// ignore_for_file: use_build_context_synchronously

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
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

enum LoadingState { initial, loading, loaded, error, empty }

class AdminUsersService extends GetxService {
  final String _apiUrl = 'https://api.libanbuy.com/api/users';

  Future<AdminUsersService> init() async {
    return this;
  }

  // Observable data
  final productsModel = Rxn<User>();
  final RxList<User> adminProducts = <User>[].obs;
  final RxList<User> filteredProducts = <User>[].obs;

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

  // Basic Search Controllers
  final scrollController = ScrollController();
  final searchController = TextEditingController();
  final userIdController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Date Controllers
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  // Custom Filter Controllers
  final referralCodeController = TextEditingController();

  // Dropdown Values
  final RxString selectedStatus = 'All Status'.obs;
  final RxString selectedRole = 'All Roles'.obs;
  final RxString selectedEmailVerification = 'All Users'.obs;
  final RxString selectedAcquisitionSource = 'All Sources'.obs;
  final RxString selectedOrderBy = 'created_at'.obs;

  // Debounce timer for search
  Worker? _searchWorker;

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchController.dispose();
    userIdController.dispose();
    emailController.dispose();
    phoneController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    referralCodeController.dispose();
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
      await fetchusersSearch(loaderType: false, searchKeyword: query);
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> performAdvancedSearch() async {
    isSearching.value = true;
    try {
      await fetchAdvancedUsersSearch(loaderType: true);
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

      if (data['users'] == null) {
        throw Exception('Invalid response format');
      }

      final usersList =
          (data['users']['data'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();

      adminProducts.assignAll(usersList);
      filteredProducts.assignAll(usersList);

      totalPages.value = data['users']['last_page'] ?? 0;
      totalItems.value = data['users']['total'] ?? 0;

      // Update loading state based on data
      if (usersList.isEmpty) {
        loadingState.value = LoadingState.empty;
      } else {
        loadingState.value = LoadingState.loaded;
      }

      errorMessage.value = '';
    } catch (e, stackTrace) {
      Logger().e('Error fetching users', error: e, stackTrace: stackTrace);
      errorMessage.value = _getErrorMessage(e);
      loadingState.value = LoadingState.error;
    }
  }

  static Future<void> updateUser({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String role,
    String? storeName,
    int? thumbnailId,
    required BuildContext context,
  }) async {
    final String url = 'https://api.libanbuy.com/api/users/$userId/update';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-Request-From": "Application",
        },
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'role': role,
          if (storeName != null) 'store_name': storeName,
          if (thumbnailId != null) 'thumbnail_id': thumbnailId.toString(),
        },
      );

      if (response.statusCode == 200) {
        Get.back();
        NotificationHelper.showSuccess(
          context,
          'User updated successfully.',
          'User information has been updated.',
        );
      } else {
        NotificationHelper.showError(
          context,
          'Failed to update user.',
          response.body,
        );
      }
    } catch (e) {
      NotificationHelper.showError(
        context,
        'Failed to update user.',
        e.toString(),
      );
    }
  }

  // ✅ CORRECTED ADVANCED SEARCH METHOD WITH USER ID AS META FIELD
  Future<void> fetchAdvancedUsersSearch({required bool loaderType}) async {
    if (loaderType) {
      loadingState.value = LoadingState.loading;
    }

    try {
      final current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        throw Exception('User not authenticated');
      }

      final query = <String, String>{
        'per_page': perPage.value.toString(),
        'page': currentPage.value.toString(),
        'with': 'thumbnail,user,reseller_program',
        'orderBy': selectedOrderBy.value,
        'order': 'desc',
      };

      // ✅ UPDATED: Removed userIdController from basic search parameters
      // User ID will now be handled as a meta field instead

      if (searchController.text.isNotEmpty) {
        query['search'] = searchController.text.trim();
      }

      if (emailController.text.isNotEmpty) {
        query['email'] = emailController.text.trim();
      }

      if (phoneController.text.isNotEmpty) {
        query['phone'] = phoneController.text.trim();
      }

      // Filter by columns - only add if we have filters
      bool hasColumnFilters = false;
      final Map<String, String> columnFilters = {};
      int columnIndex = 0;

      // Status filter
      if (selectedStatus.value != 'All Status') {
        columnFilters['filterByColumns[columns][$columnIndex][column]'] =
            'status';
        columnFilters['filterByColumns[columns][$columnIndex][value]'] =
            selectedStatus.value;
        columnFilters['filterByColumns[columns][$columnIndex][operator]'] = '=';
        columnIndex++;
        hasColumnFilters = true;
      }

      // ✅ FIXED: Role filter logic
      if (selectedRole.value != 'All Roles') {
        columnFilters['filterByColumns[columns][$columnIndex][column]'] =
            'role';
        columnFilters['filterByColumns[columns][$columnIndex][value]'] =
            selectedRole.value;
        columnFilters['filterByColumns[columns][$columnIndex][operator]'] = '=';
        columnIndex++;
        hasColumnFilters = true;
      }
      // ✅ REMOVED: The problematic else clause that added role != 'all'
      // This was causing unwanted filtering when "All Roles" was selected

      // Email verification filter
      if (selectedEmailVerification.value == 'verified') {
        columnFilters['filterByColumns[columns][$columnIndex][column]'] =
            'email_verified_at';
        columnFilters['filterByColumns[columns][$columnIndex][operator]'] =
            '!=';
        columnIndex++;
        hasColumnFilters = true;
      } else if (selectedEmailVerification.value == 'unverified') {
        columnFilters['filterByColumns[columns][$columnIndex][column]'] =
            'email_verified_at';
        columnFilters['filterByColumns[columns][$columnIndex][operator]'] = '=';
        columnIndex++;
        hasColumnFilters = true;
      }

      // Date range filters
      if (fromDateController.text.isNotEmpty) {
        columnFilters['filterByColumns[columns][$columnIndex][column]'] =
            'created_at';
        columnFilters['filterByColumns[columns][$columnIndex][value]'] =
            fromDateController.text;
        columnFilters['filterByColumns[columns][$columnIndex][operator]'] = '>';
        columnIndex++;
        hasColumnFilters = true;
      }

      if (toDateController.text.isNotEmpty) {
        columnFilters['filterByColumns[columns][$columnIndex][column]'] =
            'created_at';
        columnFilters['filterByColumns[columns][$columnIndex][value]'] =
            toDateController.text;
        columnFilters['filterByColumns[columns][$columnIndex][operator]'] = '<';
        columnIndex++;
        hasColumnFilters = true;
      }

      // Add column filters to query if any exist
      if (hasColumnFilters) {
        query['filterByColumns[filterJoin]'] = 'AND';
        query.addAll(columnFilters);
      }

      // Meta fields filters - only add if we have meta filters
      bool hasMetaFilters = false;
      final Map<String, String> metaFilters = {};
      int metaFieldIndex = 0;

      // ✅ NEW: User ID as meta field filter
      if (userIdController.text.isNotEmpty) {
        metaFilters['filterByMetaFields[fields][$metaFieldIndex][key]'] =
            'user_id'; // or whatever the meta field key should be
        metaFilters['filterByMetaFields[fields][$metaFieldIndex][value]'] =
            userIdController.text.trim();
        metaFilters['filterByMetaFields[fields][$metaFieldIndex][operator]'] =
            '=';
        metaFieldIndex++;
        hasMetaFilters = true;
      }

      // Acquisition source meta field
      if (selectedAcquisitionSource.value != 'All Sources') {
        metaFilters['filterByMetaFields[fields][$metaFieldIndex][key]'] =
            'acquisition_source';
        metaFilters['filterByMetaFields[fields][$metaFieldIndex][value]'] =
            selectedAcquisitionSource.value;
        metaFilters['filterByMetaFields[fields][$metaFieldIndex][operator]'] =
            '=';
        metaFieldIndex++;
        hasMetaFilters = true;
      }

      // Add meta filters to query if any exist
      if (hasMetaFilters) {
        query['filterByMetaFields[filterJoin]'] = 'AND';
        query.addAll(metaFilters);
      }

      // Custom filters - only add if we have custom filters
      bool hasCustomFilters = false;
      final Map<String, String> customFilters = {};
      int customFilterIndex = 0;

      // Referral code custom filter
      if (referralCodeController.text.isNotEmpty) {
        customFilters['CustomFilters[filters][$customFilterIndex][key]'] =
            'referral_code';
        customFilters['CustomFilters[filters][$customFilterIndex][value]'] =
            referralCodeController.text;
        customFilters['CustomFilters[filters][$customFilterIndex][operator]'] =
            'LIKE';
        customFilterIndex++;
        hasCustomFilters = true;
      }

      // Add custom filters to query if any exist
      if (hasCustomFilters) {
        query['CustomFilters[filterJoin]'] = 'AND';
        query.addAll(customFilters);
      }

      final uri = Uri.parse(_apiUrl).replace(queryParameters: query);

      // Group parameters for better readability
      final Map<String, List<MapEntry<String, String>>> groupedParams = {
        'Basic': [],
        'Pagination & Sorting': [],
        'Column Filters': [],
        'Meta Filters': [],
        'Custom Filters': [],
      };

      for (var entry in query.entries) {
        if (['search', 'email', 'phone'].contains(entry.key)) {
          // ✅ UPDATED: Removed 'userid' from basic params
          groupedParams['Basic']!.add(entry);
        } else if ([
          'per_page',
          'page',
          'with',
          'orderBy',
          'order',
        ].contains(entry.key)) {
          groupedParams['Pagination & Sorting']!.add(entry);
        } else if (entry.key.startsWith('filterByColumns')) {
          groupedParams['Column Filters']!.add(entry);
        } else if (entry.key.startsWith('filterByMetaFields')) {
          groupedParams['Meta Filters']!.add(entry);
        } else if (entry.key.startsWith('CustomFilters')) {
          groupedParams['Custom Filters']!.add(entry);
        }
      }

      groupedParams.forEach((group, params) {
        if (params.isNotEmpty) {
          print('\n   📂 $group:');
          for (var param in params) {
            print('      • ${param.key} = ${param.value}');
          }
        }
      });

      print('\n${'=' * 100}');
      print('⏳ Making API Request...');
      print('=' * 100 + '\n');

      final response = await http.get(
        uri,
        headers: {
          'X-Request-From': 'Dashboard',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Advanced search failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['users'] == null) {
        throw Exception('Invalid advanced search response');
      }

      final usersList =
          (data['users']['data'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();

      adminProducts.assignAll(usersList);
      filteredProducts.assignAll(usersList);

      totalPages.value = data['users']['last_page'] ?? 0;
      totalItems.value = data['users']['total'] ?? 0;

      if (usersList.isEmpty) {
        loadingState.value = LoadingState.empty;
      } else {
        loadingState.value = LoadingState.loaded;
      }

      errorMessage.value = '';
    } catch (e, stackTrace) {
      Logger().e('Error in advanced search', error: e, stackTrace: stackTrace);
      errorMessage.value = _getErrorMessage(e);
      loadingState.value = LoadingState.error;
    }
  }

  Future<void> fetchusersSearch({
    required bool loaderType,
    String? searchKeyword,
    String? role,
    String? status,
  }) async {
    if (loaderType) {
      loadingState.value = LoadingState.loading;
    }

    try {
      final current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        throw Exception('User not authenticated');
      }

      final query = <String, String>{
        'per_page': perPage.value.toString(),
        'page': currentPage.value.toString(),
      };

      if (searchKeyword != null && searchKeyword.isNotEmpty) {
        query['search'] = searchKeyword;
      }
      if (role != null && role.isNotEmpty) {
        query['role'] = role;
      }
      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }

      final uri = Uri.parse(_apiUrl).replace(queryParameters: query);

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

      if (data['users'] == null) {
        throw Exception('Invalid search response');
      }

      final usersList =
          (data['users']['data'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();

      adminProducts.assignAll(usersList);
      filteredProducts.assignAll(usersList);

      totalPages.value = data['users']['last_page'] ?? 0;
      totalItems.value = data['users']['total'] ?? 0;

      if (usersList.isEmpty) {
        loadingState.value = LoadingState.empty;
      } else {
        loadingState.value = LoadingState.loaded;
      }

      errorMessage.value = '';
    } catch (e, stackTrace) {
      Logger().e('Error searching users', error: e, stackTrace: stackTrace);
      errorMessage.value = _getErrorMessage(e);
      loadingState.value = LoadingState.error;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      isDeleting.value = true;

      final current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$_apiUrl/$userId/delete'),
        headers: {
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Remove from local lists
        adminProducts.removeWhere((user) => user.id == userId);
        filteredProducts.removeWhere((user) => user.id == userId);

        return true;
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      Logger().e('Error deleting user', error: e);
      Get.snackbar(
        'Error',
        'Failed to delete user: ${_getErrorMessage(e)}',
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

  // ✅ ENHANCED: Clear all advanced filters
  void clearAdvancedFilters() {
    // Clear text controllers
    userIdController.clear();
    emailController.clear();
    phoneController.clear();
    fromDateController.clear();
    toDateController.clear();
    referralCodeController.clear();

    // Reset dropdown values
    selectedStatus.value = 'All Status';
    selectedRole.value = 'All Roles';
    selectedEmailVerification.value = 'All Users';
    selectedAcquisitionSource.value = 'All Sources';
    selectedOrderBy.value = 'created_at';

    // Refresh data with cleared filters
    refreshData();
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
      showTopLoaderDialog();

      // Create Excel workbook
      final excel = Excel.createExcel();
      final sheet = excel['Users Data'];

      // Add header row
      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('First Name'),
        TextCellValue('Last Name'),
        TextCellValue('Email'),
        TextCellValue('Phone'),
        TextCellValue('Role'),
        TextCellValue('Status'),
        TextCellValue('Email Verified'),
        TextCellValue('Join Date'),
        TextCellValue('Last Active'),
      ]);

      // Add data rows
      for (var user in adminProducts) {
        sheet.appendRow([
          const IntCellValue(0),
          TextCellValue(user.firstName ?? ''),
          TextCellValue(user.lastName ?? ''),
          TextCellValue(user.email ?? ''),
          TextCellValue(user.phone ?? ''),
          TextCellValue(user.role ?? ''),
          TextCellValue(user.status ?? ''),
          TextCellValue(
            user.emailVerifiedAt != null ? 'Verified' : 'Not Verified',
          ),
          TextCellValue(user.createdAt ?? ''),
          TextCellValue(user.updatedAt ?? ''),
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
        name: 'users_export_$timestamp',
        bytes: bytes,

        mimeType: MimeType.microsoftExcel,
      );

      NotificationHelper.showSuccess(
        context,
        'Export Successful',
        'Users data exported successfully',
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
          'First Name',
          'Last Name',
          'Email',
          'Phone',
          'Role',
          'Status',
          'Email Verified',
          'Join Date',
        ],
      ];

      // Add data rows
      for (var user in adminProducts) {
        rows.add([
          user.id ?? 0,
          user.firstName ?? '',
          user.lastName ?? '',
          user.email ?? '',
          user.phone ?? '',
          user.role ?? '',
          user.status ?? '',
          user.emailVerifiedAt != null ? 'Verified' : 'Not Verified',
          user.createdAt ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final bytes = Uint8List.fromList(utf8.encode(csv));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await FileSaver.instance.saveFile(
        name: 'users_export_$timestamp',
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

  // ✅ ADDED: Method to check if any advanced filters are active
  bool get hasActiveAdvancedFilters {
    return userIdController.text.isNotEmpty ||
        searchController.text.isNotEmpty ||
        emailController.text.isNotEmpty ||
        phoneController.text.isNotEmpty ||
        selectedStatus.value != 'All Status' ||
        selectedRole.value != 'All Roles' ||
        selectedEmailVerification.value != 'All Users' ||
        selectedAcquisitionSource.value != 'All Sources' ||
        fromDateController.text.isNotEmpty ||
        toDateController.text.isNotEmpty ||
        referralCodeController.text.isNotEmpty ||
        selectedOrderBy.value != 'created_at';
  }

  // ✅ ADDED: Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (userIdController.text.isNotEmpty) count++;
    if (searchController.text.isNotEmpty) count++;
    if (emailController.text.isNotEmpty) count++;
    if (phoneController.text.isNotEmpty) count++;
    if (selectedStatus.value != 'All Status') count++;
    if (selectedRole.value != 'All Roles') count++;
    if (selectedEmailVerification.value != 'All Users') count++;
    if (selectedAcquisitionSource.value != 'All Sources') count++;
    if (fromDateController.text.isNotEmpty) count++;
    if (toDateController.text.isNotEmpty) count++;
    if (referralCodeController.text.isNotEmpty) count++;
    if (selectedOrderBy.value != 'created_at') count++;
    return count;
  }

  // ✅ ADDED: Get list of active filter names
  List<String> get activeFiltersList {
    final List<String> filters = [];
    if (userIdController.text.isNotEmpty) {
      filters.add('User ID: ${userIdController.text}');
    }
    if (searchController.text.isNotEmpty) {
      filters.add('Search: ${searchController.text}');
    }
    if (emailController.text.isNotEmpty) {
      filters.add('Email: ${emailController.text}');
    }
    if (phoneController.text.isNotEmpty) {
      filters.add('Phone: ${phoneController.text}');
    }
    if (selectedStatus.value != 'All Status') {
      filters.add('Status: ${selectedStatus.value}');
    }
    if (selectedRole.value != 'All Roles') {
      filters.add('Role: ${selectedRole.value}');
    }
    if (selectedEmailVerification.value != 'All Users') {
      filters.add('Email Verification: ${selectedEmailVerification.value}');
    }
    if (selectedAcquisitionSource.value != 'All Sources') {
      filters.add('Source: ${selectedAcquisitionSource.value}');
    }
    if (fromDateController.text.isNotEmpty) {
      filters.add('From: ${fromDateController.text}');
    }
    if (toDateController.text.isNotEmpty) {
      filters.add('To: ${toDateController.text}');
    }
    if (referralCodeController.text.isNotEmpty) {
      filters.add('Referral Code: ${referralCodeController.text}');
    }
    if (selectedOrderBy.value != 'created_at') {
      filters.add('Order By: ${selectedOrderBy.value}');
    }
    return filters;
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
