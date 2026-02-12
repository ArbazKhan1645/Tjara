// services/coupon_service.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/shops/shops_model.dart';
import 'package:tjara/app/modules/modules_admin/coupens/edit_model.dart';

class CouponEditService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  // Insert coupon
  static Future insertCoupon(CouponInsertRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/coupons/insert'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Application',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to create coupon',
        );
      }
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please check your network.',
      );
    } on FormatException {
      throw ApiException(
        statusCode: -1,
        message: 'Invalid response format from server.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: -1,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Update coupon
  static Future updateCoupon(
    String couponId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/coupons/$couponId/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Application',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to update coupon',
        );
      }
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please check your network.',
      );
    } on FormatException {
      throw ApiException(
        statusCode: -1,
        message: 'Invalid response format from server.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: -1,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Fetch shops
  static Future<ShopResponse> fetchShops({String search = ''}) async {
    try {
      final Uri uri = Uri.parse(
        '$baseUrl/shops',
      ).replace(queryParameters: search.isNotEmpty ? {'search': search} : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ShopResponse.fromJson(responseData['shops']);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: responseData['message'] ?? 'Failed to fetch shops',
        );
      }
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please check your network.',
      );
    } on FormatException {
      throw ApiException(
        statusCode: -1,
        message: 'Invalid response format from server.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: -1,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
