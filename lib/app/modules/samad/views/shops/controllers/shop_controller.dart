// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages, unnecessary_import, use_build_context_synchronously

import 'dart:ui';
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/samad/const/app_urls.dart';
import 'package:tjara/app/modules/samad/models/shopData_model.dart';
import 'dart:convert';

class ShopController extends GetxController {
  // Constants
  static const int _requestTimeout = 30;
  static const int _perPage = 10;
  static const int _snackbarDuration = 3;
  static const int _maxRetries = 3;

  // Observable variables
  var shopInfo = ShopData().obs;
  var currentPage = 1.obs;
  var totalPages = 5.obs;
  var loading = false.obs;

  // Controllers
  var ShopNameController = TextEditingController().obs;
  var OwnerNameController = TextEditingController().obs;
  var OwnerEmailController = TextEditingController().obs;
  var OwnerPhoneController = TextEditingController().obs;

  // Private variables
  Timer? _debounceTimer;
  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    ShopNameController.value.dispose();
    OwnerNameController.value.dispose();
    OwnerEmailController.value.dispose();
    OwnerPhoneController.value.dispose();
    super.onClose();
  }

  // Initialize data with error handling
  Future<void> _initializeData() async {
    try {
      await getShopData("1", "", "", "", "");
    } catch (e) {
      _handleError('Failed to initialize shop data', e);
    }
  }

  // Enhanced pagination methods
  Future<void> goToPreviousPage() async {
    if (loading.value) return;

    if (currentPage.value > 1) {
      currentPage.value--;
      await _refreshShopData();
    }
  }

  Future<void> goToNextPage() async {
    if (loading.value) return;

    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      await _refreshShopData();
    }
  }

  Future<void> goToPage(int page) async {
    if (loading.value) return;

    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      await _refreshShopData();
    }
  }

  // Refresh current page data
  Future<void> refreshCurrentPage() async {
    await _refreshShopData();
  }

  // Search with debounce
  void searchShops() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      currentPage.value = 1; // Reset to first page for new search
      _refreshShopData();
    });
  }

  // Clear search filters
  void clearFilters() {
    ShopNameController.value.clear();
    OwnerNameController.value.clear();
    OwnerEmailController.value.clear();
    OwnerPhoneController.value.clear();
    currentPage.value = 1;
    _refreshShopData();
  }

  int calculateStartPage() {
    int start = currentPage.value;
    // Clamp start to ensure we don't exceed total pages when adding 4
    if (start + 4 > totalPages.value) {
      start = (totalPages.value - 4).clamp(1, totalPages.value);
    }
    return start;
  }

  // Private method to refresh shop data
  Future<void> _refreshShopData() async {
    await getShopData(
      currentPage.toString(),
      ShopNameController.value.text.trim(),
      OwnerEmailController.value.text.trim(),
      OwnerPhoneController.value.text.trim(),
      OwnerNameController.value.text.trim(),
    );
  }

  // Enhanced getShopData with better error handling and retry mechanism
  Future<void> getShopData(
    String PageNo,
    String shopName,
    String ownerEmail,
    String Ph,
    String OwnerName,
  ) async {
    if (loading.value) return;

    final headers = {
      'X-Request-From': 'Dashboard',
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
    };

    print(verificationFilter.value);

    final queryParams = {
      'page': PageNo,
      'per_page': _perPage.toString(),
      'search': shopName,
      'searchByOwnerEmail': ownerEmail,
      'searchByOwnerPhone': Ph,
      'searchByOwnerName': OwnerName,
      '_t': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    // Track current filter column index
    int columnIndex = 0;

    // Add verification filter if applicable
    if (verificationFilter.value != "all") {
      queryParams['filterByColumns[columns][$columnIndex][column]'] =
          'is_verified';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          verificationFilter.value == "verified" ? "1" : "0";
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
      columnIndex++;
    }

    // Add status filter if applicable
    if (statusFilter.value != "all") {
      queryParams['filterByColumns[columns][$columnIndex][column]'] = 'status';
      queryParams['filterByColumns[columns][$columnIndex][value]'] =
          statusFilter.value;
      queryParams['filterByColumns[columns][$columnIndex][operator]'] = '=';
    }

    final uri = Uri.parse(
      '${AppUrl.baseURL}${AppUrl.shopData}',
    ).replace(queryParameters: queryParams);

    await _executeWithRetry(() async {
      loading.value = true;
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: _requestTimeout));

      await _handleShopDataResponse(response);
    });
  }

  var verificationFilter = "all".obs; // "all", "verified", "pending"
  var statusFilter = "all".obs; // "all", "active", "inactive"

  // Add these methods to your ShopController class
  void setVerificationFilter(String value) {
    verificationFilter.value = value;
    currentPage.value = 1;
    _refreshShopData();
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    currentPage.value = 1;
    _refreshShopData();
  }

  // Handle shop data response
  Future<void> _handleShopDataResponse(http.Response response) async {
    switch (response.statusCode) {
      case 200:
        try {
          final data = jsonDecode(response.body);

          if (data == null) {
            throw Exception('Response data is null');
          }

          shopInfo.value = ShopData.fromJson(data);
          totalPages.value = shopInfo.value.shops?.lastPage ?? 1;

          // Ensure current page is within bounds
          if (currentPage.value > totalPages.value) {
            currentPage.value = totalPages.value;
          }
        } catch (e) {
          throw Exception('Failed to parse shop data: $e');
        }
        break;

      case 400:
        throw Exception('Bad request - Invalid parameters');
      case 401:
        throw Exception('Unauthorized - Please login again');
      case 403:
        throw Exception('Forbidden - Access denied');
      case 404:
        shopInfo.value = ShopData(shops: Shops());

        break;

      case 429:
        throw Exception('Too many requests - Please try again later');
      case 500:
        throw Exception('Server error - Please try again later');
      default:
        throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  // Enhanced updateShop with better error handling
  Future<void> updateShop(
    String shopId,
    bool verify,
    BuildContext context,
  ) async {
    if (shopId.isEmpty) {
      _showErrorSnackBar(context, 'Invalid shop ID');
      return;
    }

    final requestBody = {"is_verified": "1"};

    final headers = {
      'Content-Type': 'application/json',
      'X-Request-From': 'Application',
      'Accept': 'application/json',
      'shop-id': shopId,
    };

    await _executeWithRetry(() async {
      final response = await http
          .put(
            Uri.parse("${AppUrl.baseURL}api/shops/$shopId/update"),
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: _requestTimeout));

      await _handleUpdateResponse(response, context, verify);
    });
  }

  // Handle update response
  Future<void> _handleUpdateResponse(
    http.Response response,
    BuildContext context,
    bool verify,
  ) async {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        _showSuccessSnackBar(
          context,
          verify
              ? 'Shop verified successfully'
              : 'Shop unverified successfully',
        );
        await _refreshShopData();
        break;

      case 400:
        _showErrorSnackBar(context, 'Invalid request data');
        break;
      case 401:
        _showErrorSnackBar(context, 'Unauthorized - Please login again');
        break;
      case 403:
        _showErrorSnackBar(context, 'Access denied');
        break;
      case 404:
        _showErrorSnackBar(context, 'Shop not found');
        break;
      case 422:
        _showErrorSnackBar(context, 'Validation failed');
        break;
      case 429:
        _showErrorSnackBar(
          context,
          'Too many requests - Please try again later',
        );
        break;
      case 500:
        _showErrorSnackBar(context, 'Server error - Please try again later');
        break;
      default:
        _showErrorSnackBar(context, 'Verification failed');
    }
  }

  // Execute with retry mechanism
  Future<void> _executeWithRetry(Future<void> Function() operation) async {
    int retryCount = 0;

    while (retryCount < _maxRetries) {
      try {
        await operation();
        loading.value = false;
        return;
      } catch (e) {
        retryCount++;

        if (retryCount >= _maxRetries) {
          loading.value = false;
          rethrow;
        }

        // Exponential backoff
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  // Centralized error handling
  void _handleError(String message, dynamic error) {
    loading.value = false;

    String errorMessage = message;

    if (error is SocketException) {
      errorMessage = 'No internet connection';
    } else if (error is TimeoutException) {
      errorMessage = 'Request timeout - Please try again';
    } else if (error is FormatException) {
      errorMessage = 'Invalid data format';
    } else if (error is Exception) {
      errorMessage = error.toString().replaceAll('Exception: ', '');
    }

    print('Error: $errorMessage');

    // Show error to user if context is available
    if (Get.context != null) {
      _showErrorSnackBar(Get.context!, errorMessage);
    }
  }

  // Success snackbar
  void _showSuccessSnackBar(BuildContext context, String content) {
    _showSnackBar(context, content, Colors.green);
  }

  // Error snackbar
  void _showErrorSnackBar(BuildContext context, String content) {
    _showSnackBar(context, content, Colors.red);
  }

  // Enhanced snackbar with color support
  void _showSnackBar(
    BuildContext context,
    String content,
    Color backgroundColor,
  ) {
    if (content.isEmpty) return;

    Get.rawSnackbar(
      duration: const Duration(seconds: _snackbarDuration),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 12,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      messageText: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: backgroundColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  backgroundColor == Colors.green
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Legacy method for backward compatibility
  void showSnackBar(BuildContext context, String content) {
    _showSuccessSnackBar(context, content);
  }

  // Utility methods
  bool get hasData => shopInfo.value.shops?.data?.isNotEmpty ?? false;
  bool get hasNextPage => currentPage.value < totalPages.value;
  bool get hasPreviousPage => currentPage.value > 1;
  int get totalItems => shopInfo.value.shops?.total ?? 0;

  // Get current page info
  String get pageInfo {
    if (totalItems == 0) return 'No items';

    final start = ((currentPage.value - 1) * _perPage) + 1;
    final end = (currentPage.value * _perPage).clamp(1, totalItems);

    return 'Showing $start-$end of $totalItems items';
  }
}

// Custom cancel token for request cancellation
class CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}
