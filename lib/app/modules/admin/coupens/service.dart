// services/coupon_service.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/coupens/coupens_model.dart';

class CouponService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  // Add your headers here
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'X-Request-From': 'Application',
    'Accept': 'application/json',
  };

  static Future<CouponResponse> getCoupons({
    String search = '',
    String searchById = '',
    String orderBy = 'created_at',
    String order = 'desc',
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/coupons').replace(
        queryParameters: {
          'with': 'shop',
          'search': search,
          'search_by_id': searchById,
          'orderBy': orderBy,
          'order': order,
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CouponResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access');
      } else if (response.statusCode == 403) {
        throw ForbiddenException('Access forbidden');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Coupons not found');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error occurred');
      } else {
        throw ApiException;
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  static Future<bool> deleteCoupon(String couponId) async {
    try {
      final uri = Uri.parse('$baseUrl/coupons/$couponId/delete');
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized access');
      } else if (response.statusCode == 403) {
        throw ForbiddenException('Access forbidden');
      } else if (response.statusCode == 404) {
        throw NotFoundException('Coupon not found');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error occurred');
      } else {
        throw ApiException;
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }
}

// Custom Exception Classes
abstract class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}
