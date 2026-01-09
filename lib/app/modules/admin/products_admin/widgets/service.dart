import 'package:http/http.dart' as http;
import 'dart:convert';

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
        'X-Request-From': 'Application',
        'shop-id': shopId,
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
        'X-Request-From': 'Application',
        'shop-id': shopId,
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
        'X-Request-From': 'Application',
        'shop-id': shopId,
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
        'X-Request-From': 'Application',
        'shop-id': shopId,
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
