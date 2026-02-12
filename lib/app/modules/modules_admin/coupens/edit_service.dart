// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/shops/shops_model.dart';
import 'package:tjara/app/modules/modules_admin/coupens/edit_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class CouponEditService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  static Map<String, String> get _headers => {
    'x-request-from': 'Dashboard',
    'shop-id': AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
    'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
    'Content-Type': 'application/json',
  };

  static String _parseErrorResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        if (body.containsKey('errors')) {
          final errors = body['errors'] as Map<String, dynamic>;
          final messages = errors.values
              .expand((v) => v is List ? v : [v])
              .join(', ');
          return messages;
        }
        if (body.containsKey('message')) {
          return body['message'];
        }
      }
    } catch (_) {}
    return 'Request failed with status ${response.statusCode}';
  }

  static void _handleErrorResponse(http.Response response) {
    if (response.statusCode == 422) {
      throw ApiException(
        statusCode: 422,
        message: _parseErrorResponse(response),
      );
    } else if (response.statusCode == 401) {
      throw ApiException(
        statusCode: 401,
        message: 'Unauthorized. Please log in again.',
      );
    } else if (response.statusCode == 403) {
      throw ApiException(
        statusCode: 403,
        message: 'You do not have permission for this action.',
      );
    } else if (response.statusCode == 404) {
      throw ApiException(statusCode: 404, message: 'Coupon not found.');
    } else if (response.statusCode >= 500) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Server error. Please try again later.',
      );
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorResponse(response),
      );
    }
  }

  static Future insertCoupon(CouponInsertRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/coupons/insert'),
        headers: _headers,
        body: jsonEncode({...request.toJson(), 'is_active_now': true}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        _handleErrorResponse(response);
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

  static Future updateCoupon(
    String couponId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/coupons/$couponId/update'),
        headers: _headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        _handleErrorResponse(response);
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

  static Future<ShopResponse> fetchShops({String search = ''}) async {
    try {
      final Uri uri = Uri.parse(
        '$baseUrl/shops',
      ).replace(queryParameters: search.isNotEmpty ? {'search': search} : null);

      final response = await http.get(uri, headers: _headers);

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
