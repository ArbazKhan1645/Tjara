import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/admin_products_module/admin_products_bundles/model/bundle_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_templates/model/product_model.dart';

class BundleApiException implements Exception {
  final String message;
  final int? statusCode;

  BundleApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class BundleApiService {
  static const String baseUrl = 'https://api.libanbuy.com/api';
  static const Duration timeout = Duration(seconds: 30);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Request-From': 'Dashboard',
    'user-id': '121d6d13-a26f-49ff-8786-a3b203dc3068',
  };

  // Fetch all bundles
  Future<BundlesResponse> fetchBundles({
    String orderBy = 'created_at',
    String order = 'desc',
    int perPage = 100,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/product-bundles?orderBy=$orderBy&order=$order&per_page=$perPage',
            ),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return BundlesResponse.fromJson(jsonData);
      } else {
        throw BundleApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw BundleApiException('No Internet connection');
    } on TimeoutException {
      throw BundleApiException('Connection timeout');
    } catch (e) {
      if (e is BundleApiException) rethrow;
      throw BundleApiException('Failed to load bundles: ${e.toString()}');
    }
  }

  // Insert new bundle
  Future<bool> insertBundle(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/product-bundles'),
            headers: _headers,
            body: json.encode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw BundleApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw BundleApiException('No Internet connection');
    } on TimeoutException {
      throw BundleApiException('Connection timeout');
    } catch (e) {
      if (e is BundleApiException) rethrow;
      throw BundleApiException('Failed to create bundle: ${e.toString()}');
    }
  }

  // Update existing bundle
  Future<bool> updateBundle(
    String bundleId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/product-bundles/$bundleId'),
            headers: _headers,
            body: json.encode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw BundleApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw BundleApiException('No Internet connection');
    } on TimeoutException {
      throw BundleApiException('Connection timeout');
    } catch (e) {
      if (e is BundleApiException) rethrow;
      throw BundleApiException('Failed to update bundle: ${e.toString()}');
    }
  }

  // Delete bundle
  Future<bool> deleteBundle(String bundleId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/product-bundles/$bundleId'),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw BundleApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw BundleApiException('No Internet connection');
    } on TimeoutException {
      throw BundleApiException('Connection timeout');
    } catch (e) {
      if (e is BundleApiException) rethrow;
      throw BundleApiException('Failed to delete bundle: ${e.toString()}');
    }
  }

  // Duplicate bundle
  Future<bool> duplicateBundle(String bundleId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/product-bundles/$bundleId/duplicate'),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw BundleApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw BundleApiException('No Internet connection');
    } on TimeoutException {
      throw BundleApiException('Connection timeout');
    } catch (e) {
      if (e is BundleApiException) rethrow;
      throw BundleApiException('Failed to duplicate bundle: ${e.toString()}');
    }
  }

  // Search products (reuse from templates)
  Future<List<Product>> searchProducts({String query = ''}) async {
    try {
      final url = query.isEmpty
          ? '$baseUrl/products?per_page=50'
          : '$baseUrl/products?search=$query&per_page=50';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final productsResponse = ProductsResponse.fromJson(jsonData);
        return productsResponse.products.data;
      } else {
        throw BundleApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw BundleApiException('No Internet connection');
    } on TimeoutException {
      throw BundleApiException('Connection timeout');
    } catch (e) {
      if (e is BundleApiException) rethrow;
      throw BundleApiException('Failed to search products: ${e.toString()}');
    }
  }

  // Get single product by ID
  Future<Product> getProductById(String productId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/products/$productId'),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Product.fromJson(jsonData['product'] ?? {});
      } else {
        throw BundleApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw BundleApiException('No Internet connection');
    } on TimeoutException {
      throw BundleApiException('Connection timeout');
    } catch (e) {
      if (e is BundleApiException) rethrow;
      throw BundleApiException('Failed to get product: ${e.toString()}');
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final jsonData = json.decode(response.body);
      return jsonData['message'] ??
          'Request failed with status: ${response.statusCode}';
    } catch (e) {
      return 'Request failed with status: ${response.statusCode}';
    }
  }
}
