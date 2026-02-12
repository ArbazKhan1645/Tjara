import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals/model/flash_deal_model.dart';

class FlashDealApiException implements Exception {
  final String message;
  final int? statusCode;

  FlashDealApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class FlashDealApiService {
  static const String baseUrl = 'https://api.libanbuy.com/api';
  static const Duration timeout = Duration(seconds: 30);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Request-From': 'Dashboard',
    'user-id': '121d6d13-a26f-49ff-8786-a3b203dc3068',
  };

  /// Fetch all settings (for real-time updates)
  Future<SettingsResponse> fetchSettings() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/settings?_t=${DateTime.now().microsecondsSinceEpoch}',
            ),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        return SettingsResponse.fromJson(jsonData);
      } else {
        throw FlashDealApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw FlashDealApiException('No Internet connection');
    } on TimeoutException {
      throw FlashDealApiException('Connection timeout');
    } catch (e) {
      if (e is FlashDealApiException) rethrow;
      throw FlashDealApiException('Failed to load settings: ${e.toString()}');
    }
  }

  /// Update settings
  Future<bool> updateSettings(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/settings/update'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Request-From': 'Website',
            },
            body: json.encode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw FlashDealApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw FlashDealApiException('No Internet connection');
    } on TimeoutException {
      throw FlashDealApiException('Connection timeout');
    } catch (e) {
      if (e is FlashDealApiException) rethrow;
      throw FlashDealApiException('Failed to update settings: ${e.toString()}');
    }
  }

  /// Skip a flash deal product
  Future<bool> skipFlashDeal(String productId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/products/$productId/skip-flash-deal'),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw FlashDealApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw FlashDealApiException('No Internet connection');
    } on TimeoutException {
      throw FlashDealApiException('Connection timeout');
    } catch (e) {
      if (e is FlashDealApiException) rethrow;
      throw FlashDealApiException('Failed to skip deal: ${e.toString()}');
    }
  }

  /// Restore a skipped flash deal product
  Future<bool> restoreFlashDeal(String productId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/products/$productId/restore-flash-deal'),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw FlashDealApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw FlashDealApiException('No Internet connection');
    } on TimeoutException {
      throw FlashDealApiException('Connection timeout');
    } catch (e) {
      if (e is FlashDealApiException) rethrow;
      throw FlashDealApiException('Failed to restore deal: ${e.toString()}');
    }
  }

  /// Save flash deal products (main save API)
  Future<bool> saveFlashDealProducts({
    required List<String> productIds,
    required String scheduledStart,
    required int dealDurationSeconds,
    required int intervalSeconds,
  }) async {
    try {
      final payload = {
        'product_ids': productIds,
        'scheduled_start': scheduledStart,
        'deal_duration_seconds': dealDurationSeconds,
        'interval_seconds': intervalSeconds,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/flash-deal-products'),
            headers: _headers,
            body: json.encode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw FlashDealApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw FlashDealApiException('No Internet connection');
    } on TimeoutException {
      throw FlashDealApiException('Connection timeout');
    } catch (e) {
      if (e is FlashDealApiException) rethrow;
      throw FlashDealApiException(
        'Failed to save flash deals: ${e.toString()}',
      );
    }
  }

  /// Search products
  Future<List<FlashDealProduct>> searchProducts({String query = ''}) async {
    try {
      final url =
          query.isEmpty
              ? '$baseUrl/products?per_page=50'
              : '$baseUrl/products?search=$query&per_page=50';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final productsResponse = FlashDealProductsResponse.fromJson(jsonData);
        return productsResponse.products.data
            .where((e) => e.is_deal == '1')
            .toList();
      } else {
        throw FlashDealApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw FlashDealApiException('No Internet connection');
    } on TimeoutException {
      throw FlashDealApiException('Connection timeout');
    } catch (e) {
      if (e is FlashDealApiException) rethrow;
      throw FlashDealApiException('Failed to search products: ${e.toString()}');
    }
  }

  /// Get single product by ID
  Future<FlashDealProduct> getProductById(String productId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/$productId'), headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return FlashDealProduct.fromJson(jsonData['product'] ?? {});
      } else {
        throw FlashDealApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw FlashDealApiException('No Internet connection');
    } on TimeoutException {
      throw FlashDealApiException('Connection timeout');
    } catch (e) {
      if (e is FlashDealApiException) rethrow;
      throw FlashDealApiException('Failed to get product: ${e.toString()}');
    }
  }

  /// Get multiple products by IDs
  Future<List<FlashDealProduct>> getProductsByIds(
    List<String> productIds,
  ) async {
    if (productIds.isEmpty) return [];

    final List<FlashDealProduct> products = [];
    for (final id in productIds) {
      try {
        final product = await getProductById(id);
        products.add(product);
      } catch (e) {
        // Continue with other products if one fails
        products.add(
          FlashDealProduct(id: id, name: 'Product #$id', is_deal: '1'),
        );
      }
    }
    return products;
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
