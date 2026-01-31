import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/services/auth/auth_service.dart';

class CouponValidationResult {
  final bool success;
  final bool valid;
  final String? message;
  final double discountAmount;
  final double walletAmount;
  final double finalAmount;
  final double eligibleCartTotal;
  final String? couponCode;
  final String? couponName;
  final String? discountType;
  final double? discountValue;
  final String? error;

  CouponValidationResult({
    required this.success,
    required this.valid,
    this.message,
    this.discountAmount = 0,
    this.walletAmount = 0,
    this.finalAmount = 0,
    this.eligibleCartTotal = 0,
    this.couponCode,
    this.couponName,
    this.discountType,
    this.discountValue,
    this.error,
  });

  factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
    final couponCode = json['coupon_code'];
    final coupon = json['coupon'];

    return CouponValidationResult(
      success: json['success'] ?? false,
      valid: json['valid'] ?? false,
      message: json['message'],
      discountAmount: _parseDouble(json['discount_amount']),
      walletAmount: _parseDouble(json['wallet_amount']),
      finalAmount: _parseDouble(json['final_amount']),
      eligibleCartTotal: _parseDouble(json['eligible_cart_total']),
      couponCode: couponCode != null ? couponCode['code'] : null,
      couponName: coupon != null ? coupon['name'] : null,
      discountType: coupon != null ? coupon['discount_type'] : null,
      discountValue: coupon != null ? _parseDouble(coupon['discount_value']) : null,
    );
  }

  factory CouponValidationResult.error(String errorMessage) {
    return CouponValidationResult(
      success: false,
      valid: false,
      error: errorMessage,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class CouponApplyResult {
  final bool success;
  final String? message;
  final double discountAmount;
  final double walletAmount;
  final double eligibleCartTotal;
  final double finalAmount;
  final String? usageId;
  final int skippedItemsCount;
  final String? error;

  CouponApplyResult({
    required this.success,
    this.message,
    this.discountAmount = 0,
    this.walletAmount = 0,
    this.eligibleCartTotal = 0,
    this.finalAmount = 0,
    this.usageId,
    this.skippedItemsCount = 0,
    this.error,
  });

  factory CouponApplyResult.fromJson(Map<String, dynamic> json) {
    return CouponApplyResult(
      success: json['success'] ?? false,
      message: json['message'],
      discountAmount: _parseDouble(json['discount_amount']),
      walletAmount: _parseDouble(json['wallet_amount']),
      eligibleCartTotal: _parseDouble(json['eligible_cart_total']),
      finalAmount: _parseDouble(json['final_amount']),
      usageId: json['usage_id'],
      skippedItemsCount: json['skipped_items_count'] ?? 0,
    );
  }

  factory CouponApplyResult.error(String errorMessage) {
    return CouponApplyResult(
      success: false,
      error: errorMessage,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class CouponService {
  static const String _baseUrl = "https://api.libanbuy.com/api/coupons";

  /// Validate a coupon code
  static Future<CouponValidationResult> validateCoupon({
    required String code,
    required double orderAmount,
    String? shopId,
  }) async {
    try {
      final userId = AuthService.instance.authCustomer?.user?.id ?? '';
      if (userId.isEmpty) {
        return CouponValidationResult.error('User authentication required. Please login again.');
      }

      if (code.trim().isEmpty) {
        return CouponValidationResult.error('Please enter a coupon code');
      }

      final Map<String, dynamic> body = {
        "code": code.trim(),
        "order_amount": orderAmount,
        "user_id": userId,
      };

      // Add shop_id if provided (for shop-specific coupons)
      if (shopId != null && shopId.isNotEmpty) {
        body["shop_id"] = shopId;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/validate'),
        headers: {
          "Content-Type": "application/json",
          'user-id': userId,
          'X-Request-From': 'Application',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CouponValidationResult.fromJson(responseData);
      } else {
        // Handle error responses
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Failed to validate coupon';
        return CouponValidationResult.error(errorMessage);
      }
    } catch (e) {
      return CouponValidationResult.error('Network error: ${e.toString()}');
    }
  }

  /// Apply a coupon code
  static Future<CouponApplyResult> applyCoupon({
    required String code,
    required double orderAmount,
    String? shopId,
  }) async {
    try {
      final userId = AuthService.instance.authCustomer?.user?.id ?? '';
      if (userId.isEmpty) {
        return CouponApplyResult.error('User authentication required. Please login again.');
      }

      if (code.trim().isEmpty) {
        return CouponApplyResult.error('Please enter a coupon code');
      }

      final Map<String, dynamic> body = {
        "code": code.trim(),
        "order_amount": orderAmount,
        "user_id": userId,
      };

      // Add shop_id if provided (for shop-specific coupons)
      if (shopId != null && shopId.isNotEmpty) {
        body["shop_id"] = shopId;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/apply'),
        headers: {
          "Content-Type": "application/json",
          'user-id': userId,
          'X-Request-From': 'Application',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CouponApplyResult.fromJson(responseData);
      } else {
        // Handle error responses
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Failed to apply coupon';
        return CouponApplyResult.error(errorMessage);
      }
    } catch (e) {
      return CouponApplyResult.error('Network error: ${e.toString()}');
    }
  }
}
