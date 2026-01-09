// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/products_review_model/products_review_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.libanbuy.com/api';
  static const Duration timeoutDuration = Duration(seconds: 30);

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Request-From': 'Application',
    // Add authorization header if needed
    // 'Authorization': 'Bearer ${your_token}',
  };

  static Future<http.Response> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final finalUri =
        queryParams != null ? uri.replace(queryParameters: queryParams) : uri;

    try {
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(finalUri, headers: _headers)
              .timeout(timeoutDuration);
          break;
        case 'POST':
          response = await http
              .post(
                finalUri,
                headers: _headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'PUT':
          response = await http
              .put(
                finalUri,
                headers: _headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'DELETE':
          response = await http
              .delete(finalUri, headers: _headers)
              .timeout(timeoutDuration);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return response;
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final response = await _makeRequest(
      method: 'GET',
      endpoint: endpoint,
      queryParams: queryParams,
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      endpoint: endpoint,
      body: body,
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await _makeRequest(method: 'DELETE', endpoint: endpoint);

    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else {
      String errorMessage = 'Request failed with status ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (e) {
        // Use default error message if parsing fails
      }
      throw Exception(errorMessage);
    }
  }
}

class ProductReviewService {
  static Future<ProductReviewResponse> getReviews({
    int page = 1,
    int perPage = 15,
    String? productgroupId,
  }) async {
    try {
      final response = await ApiService.get(
        '/products/reviews',
        queryParams: {'page': page.toString(), 'per_page': perPage.toString()},
      );

      return ProductReviewResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  static Future<bool> deleteReview(String reviewId) async {
    try {
      await ApiService.delete('/products/reviews/$reviewId/delete');
      return true;
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
