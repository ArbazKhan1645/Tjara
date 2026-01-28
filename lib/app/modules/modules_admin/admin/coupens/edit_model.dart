// models/coupon_model.dart
class CouponInsertRequest {
  final String name;
  final String? description;
  final String couponType;
  final String? discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isGlobal;
  final List<String>? shopIds;
  final List<String> codes;
  final int? usageLimit;
  final int? usageLimitPerUser;
  final double? minimumAmount;
  final double? maximumDiscount;
  final String status;

  CouponInsertRequest({
    required this.name,
    this.description,
    required this.couponType,
    this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.expiryDate,
    required this.isGlobal,
    this.shopIds,
    required this.codes,
    this.usageLimit,
    this.usageLimitPerUser,
    this.minimumAmount,
    this.maximumDiscount,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'coupon_type': couponType,
      'discount_type': discountType,
      'discount_value': discountValue,
      'start_date': startDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'is_global': isGlobal,
      'shop_ids': shopIds,
      'codes': codes,
      'usage_limit': usageLimit,
      'usage_limit_per_user': usageLimitPerUser,
      'minimum_amount': minimumAmount,
      'maximum_discount': maximumDiscount,
      'status': status,
    };
  }
}

class CouponInsertResponse {
  final bool success;
  final String message;
  final dynamic data;

  CouponInsertResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CouponInsertResponse.fromJson(Map<String, dynamic> json) {
    return CouponInsertResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}