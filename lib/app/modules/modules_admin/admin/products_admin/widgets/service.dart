import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tjara/app/services/auth/auth_service.dart';

class ProductService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  // Get auth token from storage or your auth service

  /// Update product active status
  static Future<ApiResponse> updateActiveStatus({
    required String productId,
    required String shopId,
    required bool isActive,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/update');

      final body = json.encode({'status': isActive ? 'active' : 'inactive'});
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);

      return _handleResponse(response, 'Product status updated successfully');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update product featured status
  static Future<ApiResponse> updateFeaturedStatus({
    required String productId,
    required String shopId,
    required bool isFeatured,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/update');

      final body = json.encode({'is_featured': isFeatured});
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);

      return _handleResponse(
        response,
        'Product featured status updated successfully',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update product deal status
  static Future<ApiResponse> updateDealStatus({
    required String productId,
    required String shopId,
    required bool isDeal,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/update');

      final body = json.encode({'is_deal': isDeal});
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);

      return _handleResponse(
        response,
        'Product deal status updated successfully',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update product inventory status (assign/unassign)
  static Future<ApiResponse> updateInventoryStatus({
    required String productId,
    required String shopId,
    required bool hasInventory,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/update');

      final body = json.encode({
        'meta': [
          {
            'inventory_updated_at':
                hasInventory ? null : DateTime.now().toUtc().toIso8601String(),
          },
        ],
      });
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);

      return _handleResponse(
        response,
        'Product inventory status updated successfully',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update product pin sale status
  static Future<ApiResponse> updatePinSaleStatus({
    required String productId,
    required String shopId,
    required bool isPinned,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/update');

      final body = json.encode({
        'meta': [
          {'is_pinned_sale': isPinned ? '0' : '1'},
        ],
      });
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);

      return _handleResponse(
        response,
        'Product pin sale status updated successfully',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update product private status
  static Future<ApiResponse> updatePrivateStatus({
    required String productId,
    required String shopId,
    required bool isPrivate,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/update');

      final body = json.encode({'status': isPrivate ? 'active' : 'private'});
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);

      return _handleResponse(
        response,
        'Product visibility updated successfully',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update product name
  static Future<ApiResponse> updateProductName({
    required String productId,
    required String shopId,
    required String name,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/update');
      final body = json.encode({'name': name});
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);
      return _handleResponse(response, 'Product name updated successfully');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update product price (regular or sale)
  static Future<ApiResponse> updateProductPrice({
    required String productId,
    required String shopId,
    required double price,
    bool isSalePrice = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/update');
      final body = json.encode({
        isSalePrice ? 'sale_price' : 'price': price,
        'product_type': 'simple',
      });
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);
      return _handleResponse(response, 'Product price updated successfully');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update product stock
  static Future<ApiResponse> updateProductStock({
    required String productId,
    required String shopId,
    required int stock,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/update');
      final body = json.encode({'stock': stock, 'product_type': 'simple'});
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);

      return _handleResponse(response, 'Product stock updated successfully');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update product sold status (uses meta/update endpoint)
  static Future<ApiResponse> updateSoldStatus({
    required String productId,
    required bool isSold,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/meta/update');
      final body = json.encode({
        'key': 'is_sold',
        'value': isSold ? '1' : '0',
      });
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.put(url, headers: headers, body: body);
      return _handleResponse(response, 'Product sold status updated successfully');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Delete product
  static Future<ApiResponse> deleteProduct({
    required String productId,
    required String shopId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/products/$productId/delete');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'shop-id':
            AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
        'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        'X-Request-From': 'Dashboard',
      };

      final response = await http.delete(url, headers: headers);

      return _handleResponse(response, 'Product deleted successfully');
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Bulk update active status
  static Future<BulkOperationResult> bulkUpdateActiveStatus({
    required List<String> productIds,
    required String shopId,
    required bool setActive,
    void Function(int completed, int total)? onProgress,
  }) async {
    int successCount = 0;
    int failCount = 0;
    final total = productIds.length;

    for (int i = 0; i < total; i++) {
      final response = await updateActiveStatus(
        productId: productIds[i],
        shopId: shopId,
        isActive: !setActive,
      );
      if (response.success) {
        successCount++;
      } else {
        failCount++;
      }
      onProgress?.call(i + 1, total);
    }

    return BulkOperationResult(
      total: total,
      successCount: successCount,
      failCount: failCount,
    );
  }

  /// Bulk update featured status
  static Future<BulkOperationResult> bulkUpdateFeaturedStatus({
    required List<String> productIds,
    required String shopId,
    required bool setFeatured,
    void Function(int completed, int total)? onProgress,
  }) async {
    int successCount = 0;
    int failCount = 0;
    final total = productIds.length;

    for (int i = 0; i < total; i++) {
      final response = await updateFeaturedStatus(
        productId: productIds[i],
        shopId: shopId,
        isFeatured: !setFeatured,
      );
      if (response.success) {
        successCount++;
      } else {
        failCount++;
      }
      onProgress?.call(i + 1, total);
    }

    return BulkOperationResult(
      total: total,
      successCount: successCount,
      failCount: failCount,
    );
  }

  /// Bulk update deal status
  static Future<BulkOperationResult> bulkUpdateDealStatus({
    required List<String> productIds,
    required String shopId,
    required bool setDeal,
    void Function(int completed, int total)? onProgress,
  }) async {
    int successCount = 0;
    int failCount = 0;
    final total = productIds.length;

    for (int i = 0; i < total; i++) {
      final response = await updateDealStatus(
        productId: productIds[i],
        shopId: shopId,
        isDeal: !setDeal,
      );
      if (response.success) {
        successCount++;
      } else {
        failCount++;
      }
      onProgress?.call(i + 1, total);
    }

    return BulkOperationResult(
      total: total,
      successCount: successCount,
      failCount: failCount,
    );
  }

  /// Bulk delete products
  static Future<BulkOperationResult> bulkDeleteProducts({
    required List<String> productIds,
    required String shopId,
    void Function(int completed, int total)? onProgress,
  }) async {
    int successCount = 0;
    int failCount = 0;
    final total = productIds.length;

    for (int i = 0; i < total; i++) {
      final response = await deleteProduct(
        productId: productIds[i],
        shopId: shopId,
      );
      if (response.success) {
        successCount++;
      } else {
        failCount++;
      }
      onProgress?.call(i + 1, total);
    }

    return BulkOperationResult(
      total: total,
      successCount: successCount,
      failCount: failCount,
    );
  }

  /// Bulk update inventory status
  static Future<BulkOperationResult> bulkUpdateInventoryStatus({
    required List<String> productIds,
    required String shopId,
    required bool setInventory,
    void Function(int completed, int total)? onProgress,
  }) async {
    int successCount = 0;
    int failCount = 0;
    final total = productIds.length;

    for (int i = 0; i < total; i++) {
      final response = await updateInventoryStatus(
        productId: productIds[i],
        shopId: shopId,
        hasInventory: !setInventory,
      );
      if (response.success) {
        successCount++;
      } else {
        failCount++;
      }
      onProgress?.call(i + 1, total);
    }

    return BulkOperationResult(
      total: total,
      successCount: successCount,
      failCount: failCount,
    );
  }

  /// Bulk update pin sale status
  static Future<BulkOperationResult> bulkUpdatePinSaleStatus({
    required List<String> productIds,
    required String shopId,
    required bool setPinned,
    void Function(int completed, int total)? onProgress,
  }) async {
    int successCount = 0;
    int failCount = 0;
    final total = productIds.length;

    for (int i = 0; i < total; i++) {
      final response = await updatePinSaleStatus(
        productId: productIds[i],
        shopId: shopId,
        isPinned: !setPinned,
      );
      if (response.success) {
        successCount++;
      } else {
        failCount++;
      }
      onProgress?.call(i + 1, total);
    }

    return BulkOperationResult(
      total: total,
      successCount: successCount,
      failCount: failCount,
    );
  }

  /// Bulk update private status
  static Future<BulkOperationResult> bulkUpdatePrivateStatus({
    required List<String> productIds,
    required String shopId,
    required bool setPrivate,
    void Function(int completed, int total)? onProgress,
  }) async {
    int successCount = 0;
    int failCount = 0;
    final total = productIds.length;

    for (int i = 0; i < total; i++) {
      final response = await updatePrivateStatus(
        productId: productIds[i],
        shopId: shopId,
        isPrivate: !setPrivate,
      );
      if (response.success) {
        successCount++;
      } else {
        failCount++;
      }
      onProgress?.call(i + 1, total);
    }

    return BulkOperationResult(
      total: total,
      successCount: successCount,
      failCount: failCount,
    );
  }

  /// Bulk update sold status
  static Future<BulkOperationResult> bulkUpdateSoldStatus({
    required List<String> productIds,
    required bool setSold,
    void Function(int completed, int total)? onProgress,
  }) async {
    int successCount = 0;
    int failCount = 0;
    final total = productIds.length;

    for (int i = 0; i < total; i++) {
      final response = await updateSoldStatus(
        productId: productIds[i],
        isSold: setSold,
      );
      if (response.success) {
        successCount++;
      } else {
        failCount++;
      }
      onProgress?.call(i + 1, total);
    }

    return BulkOperationResult(
      total: total,
      successCount: successCount,
      failCount: failCount,
    );
  }

  /// Handle API response
  static ApiResponse _handleResponse(
    http.Response response,
    String successMessage,
  ) {
    try {
      final Map<String, dynamic> responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
        case 201:
          return ApiResponse(
            success: true,
            message: responseData['message'] ?? successMessage,
            data: responseData['data'],
          );

        case 400:
          return ApiResponse(
            success: false,
            message: responseData['message'] ?? 'Bad request',
            errors: responseData['errors'],
          );

        case 401:
          return ApiResponse(
            success: false,
            message: 'Unauthorized access. Please login again.',
          );

        case 403:
          return ApiResponse(
            success: false,
            message: 'You don\'t have permission to perform this action.',
          );

        case 404:
          return ApiResponse(success: false, message: 'Product not found.');

        case 422:
          return ApiResponse(
            success: false,
            message: responseData['message'] ?? 'Validation failed',
            errors: responseData['errors'],
          );

        case 500:
          return ApiResponse(
            success: false,
            message: 'Server error. Please try again later.',
          );

        default:
          return ApiResponse(
            success: false,
            message: responseData['message'] ?? 'An unexpected error occurred',
          );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse response: ${e.toString()}',
      );
    }
  }
}

/// Bulk Operation Result
class BulkOperationResult {
  final int total;
  final int successCount;
  final int failCount;

  BulkOperationResult({
    required this.total,
    required this.successCount,
    required this.failCount,
  });

  bool get allSucceeded => successCount == total;
  bool get allFailed => failCount == total;
}

/// API Response Model
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'],
    );
  }
}
