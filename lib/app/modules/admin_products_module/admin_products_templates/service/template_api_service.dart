import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/admin_products_module/admin_products_templates/model/template_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_templates/model/product_model.dart';

class TemplateApiException implements Exception {
  final String message;
  final int? statusCode;

  TemplateApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class TemplateApiService {
  static const String baseUrl = 'https://api.libanbuy.com/api';
  static const Duration timeout = Duration(seconds: 30);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Request-From': 'Dashboard',
    'user-id': '121d6d13-a26f-49ff-8786-a3b203dc3068',
  };

  // Fetch all templates
  Future<TemplatesResponse> fetchTemplates({
    String status = 'active',
    String orderBy = 'created_at',
    String order = 'desc',
    int perPage = 100,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/product-sorting-templates?status=$status&orderBy=$orderBy&order=$order&per_page=$perPage',
            ),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TemplatesResponse.fromJson(jsonData);
      } else {
        throw TemplateApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw TemplateApiException('No Internet connection');
    } on TimeoutException {
      throw TemplateApiException('Connection timeout');
    } catch (e) {
      if (e is TemplateApiException) rethrow;
      throw TemplateApiException('Failed to load templates: ${e.toString()}');
    }
  }

  // Insert new template
  Future<bool> insertTemplate(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/product-sorting-templates'),
            headers: _headers,
            body: json.encode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw TemplateApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw TemplateApiException('No Internet connection');
    } on TimeoutException {
      throw TemplateApiException('Connection timeout');
    } catch (e) {
      if (e is TemplateApiException) rethrow;
      throw TemplateApiException('Failed to create template: ${e.toString()}');
    }
  }

  // Update existing template
  Future<bool> updateTemplate(
    String templateId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/product-sorting-templates/$templateId'),
            headers: _headers,
            body: json.encode(payload),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw TemplateApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw TemplateApiException('No Internet connection');
    } on TimeoutException {
      throw TemplateApiException('Connection timeout');
    } catch (e) {
      if (e is TemplateApiException) rethrow;
      throw TemplateApiException('Failed to update template: ${e.toString()}');
    }
  }

  // Delete template
  Future<bool> deleteTemplate(String templateId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/product-sorting-templates/$templateId'),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw TemplateApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw TemplateApiException('No Internet connection');
    } on TimeoutException {
      throw TemplateApiException('Connection timeout');
    } catch (e) {
      if (e is TemplateApiException) rethrow;
      throw TemplateApiException('Failed to delete template: ${e.toString()}');
    }
  }

  // Search products
  Future<List<Product>> searchProducts({String query = ''}) async {
    try {
      print('object');
      final url =
          query.isEmpty
              ? '$baseUrl/products?per_page=50'
              : '$baseUrl/products?search=$query&per_page=50';

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(timeout);

      print(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final productsResponse = ProductsResponse.fromJson(jsonData);
        return productsResponse.products.data;
      } else {
        throw TemplateApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw TemplateApiException('No Internet connection');
    } on TimeoutException {
      throw TemplateApiException('Connection timeout');
    } catch (e) {
      if (e is TemplateApiException) rethrow;
      throw TemplateApiException('Failed to search products: ${e.toString()}');
    }
  }

  // Get single product by ID
  Future<Product> getProductById(String productId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/$productId'), headers: _headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Product.fromJson(jsonData['product'] ?? {});
      } else {
        throw TemplateApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw TemplateApiException('No Internet connection');
    } on TimeoutException {
      throw TemplateApiException('Connection timeout');
    } catch (e) {
      if (e is TemplateApiException) rethrow;
      throw TemplateApiException('Failed to get product: ${e.toString()}');
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
