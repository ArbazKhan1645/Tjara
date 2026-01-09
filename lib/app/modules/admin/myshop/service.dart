import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/products/products_model.dart';

class ShopService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  // You may need to add authentication headers based on your API requirements
  Map<String, String> get headers => {
    'content-type': 'application/json',
    'accept': 'application/json, text/plain, /',
    'x-request-from': 'Dashboard',
    // Add authorization header if needed
    // 'Authorization': 'Bearer ${your_token}',
  };

  Future<ShopShop?> getShop(String shopId) async {
    try {
      final url = Uri.parse('$baseUrl/shops/$shopId');
      final response = await http.get(url, headers: headers);
      print('==-=-=-=-=-=-=-=-=-=-=-=-=-==-${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return ShopShop.fromJson(data['shop']);
      } else if (response.statusCode == 404) {
        throw Exception('Shop not found');
      } else {
        throw Exception('Failed to fetch shop: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error. Please check your connection.');
      }
      rethrow;
    }
  }

  Future<bool> updateShop(
    String shopId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/shops/$shopId/update');
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(updateData),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        final errors = errorData['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }
        throw Exception('Validation error occurred');
      } else if (response.statusCode == 404) {
        throw Exception('Shop not found');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to update this shop');
      } else {
        throw Exception('Failed to update shop: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error. Please check your connection.');
      }
      rethrow;
    }
  }
}
