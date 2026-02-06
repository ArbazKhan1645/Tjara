import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/model/promotion_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/model/shop_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/model/category_model.dart';

class PromotionApiException implements Exception {
  final String message;
  final int? statusCode;

  PromotionApiException(this.message, {this.statusCode});

  @override
  String toString() => 'PromotionApiException: $message';
}

class PromotionApiService {
  static const String baseUrl = 'https://api.libanbuy.com/api';
  static const Duration timeout = Duration(seconds: 30);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Request-From': 'Dashboard',
    'user-id': '121d6d13-a26f-49ff-8786-a3b203dc3068',
  };

  // Fetch all promotions
  Future<PromotionsResponse> fetchPromotions({int perPage = 100}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/global-promotions?per_page=$perPage'),
            headers: _headers,
          )
          .timeout(timeout);

      return _processPromotionsResponse(response);
    } on SocketException {
      throw PromotionApiException('No Internet connection');
    } on TimeoutException {
      throw PromotionApiException('Connection timeout');
    } catch (e) {
      if (e is PromotionApiException) rethrow;
      throw PromotionApiException('Something went wrong: ${e.toString()}');
    }
  }

  PromotionsResponse _processPromotionsResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        return PromotionsResponse.fromJson(jsonData);
      } catch (e) {
        throw PromotionApiException('Failed to parse response data');
      }
    } else {
      throw PromotionApiException(
        _getErrorMessage(response),
        statusCode: response.statusCode,
      );
    }
  }

  // Insert new promotion
  Future<bool> insertPromotion(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://api.libanbuy.com/api/global-promotions/insert'),
            headers: _headers,
            body: json.encode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw PromotionApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw PromotionApiException('No Internet connection');
    } on TimeoutException {
      throw PromotionApiException('Connection timeout');
    } catch (e) {
      if (e is PromotionApiException) rethrow;
      throw PromotionApiException(
        'Failed to create promotion: ${e.toString()}',
      );
    }
  }

  // Update existing promotion
  Future<bool> updatePromotion(
    String promotionId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/global-promotions/$promotionId/update'),
            headers: _headers,
            body: json.encode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw PromotionApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw PromotionApiException('No Internet connection');
    } on TimeoutException {
      throw PromotionApiException('Connection timeout');
    } catch (e) {
      if (e is PromotionApiException) rethrow;
      throw PromotionApiException(
        'Failed to update promotion: ${e.toString()}',
      );
    }
  }

  // Delete promotion
  Future<bool> deletePromotion(String promotionId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/global-promotions/$promotionId/delete'),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw PromotionApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw PromotionApiException('No Internet connection');
    } on TimeoutException {
      throw PromotionApiException('Connection timeout');
    } catch (e) {
      if (e is PromotionApiException) rethrow;
      throw PromotionApiException(
        'Failed to delete promotion: ${e.toString()}',
      );
    }
  }

  // Search shops
  Future<List<Shop>> searchShops({String query = ''}) async {
    try {
      final url =
          query.isEmpty ? '$baseUrl/shops' : '$baseUrl/shops?search=$query';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final shopsResponse = ShopsResponse.fromJson(jsonData);
        return shopsResponse.shops.data;
      } else {
        throw PromotionApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw PromotionApiException('No Internet connection');
    } on TimeoutException {
      throw PromotionApiException('Connection timeout');
    } catch (e) {
      if (e is PromotionApiException) rethrow;
      throw PromotionApiException('Failed to search shops: ${e.toString()}');
    }
  }

  // Search categories
  Future<List<Category>> searchCategories({String query = ''}) async {
    try {
      final url =
          '$baseUrl/product-attributes/categories?limit=all&hide_empty=true${query.isNotEmpty ? '&search=$query' : ''}';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final categoriesResponse = CategoriesResponse.fromJson(jsonData);
        return categoriesResponse
            .productAttribute
            .attributeItems
            .productAttributeItems;
      } else {
        throw PromotionApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw PromotionApiException('No Internet connection');
    } on TimeoutException {
      throw PromotionApiException('Connection timeout');
    } catch (e) {
      if (e is PromotionApiException) rethrow;
      throw PromotionApiException(
        'Failed to search categories: ${e.toString()}',
      );
    }
  }

  // Apply promotions to products
  Future<bool> applyPromotions({
    required List<String> promotionIds,
    required String applyTo,
    required String shopId,
    String? categoryId,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'promotion_ids': promotionIds,
        'apply_to': applyTo,
        'shop_id': shopId,
      };

      if (categoryId != null && applyTo == 'selected_category') {
        payload['category_id'] = categoryId;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/products/apply-promotions'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Request-From': 'Dashboard',
              'user-id': '121d6d13-a26f-49ff-8786-a3b203dc3068',
              'shop-id': '0000c539-9857-3456-bc53-2bbdc1474f1a',
            },
            body: json.encode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw PromotionApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw PromotionApiException('No Internet connection');
    } on TimeoutException {
      throw PromotionApiException('Connection timeout');
    } catch (e) {
      if (e is PromotionApiException) rethrow;
      throw PromotionApiException(
        'Failed to apply promotions: ${e.toString()}',
      );
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
