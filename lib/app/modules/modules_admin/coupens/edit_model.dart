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
  final bool allowOnDiscountedItems;
  final String? discountPriceMode;

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
    this.allowOnDiscountedItems = false,
    this.discountPriceMode,
  });

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'description': description ?? '',
      'coupon_type': couponType,
      'discount_value': discountValue.toStringAsFixed(2),
      'start_date': _formatDateTime(startDate),
      'expiry_date': _formatDateTime(expiryDate),
      'is_global': isGlobal ? '1' : '0',
      'codes': codes,
      'usage_limit': usageLimit?.toString() ?? '',
      'usage_limit_per_user': usageLimitPerUser?.toString() ?? '',
      'minimum_amount': minimumAmount?.toStringAsFixed(2) ?? '',
      'maximum_discount': maximumDiscount?.toStringAsFixed(2) ?? '',
      'status': status,
      'allow_on_discounted_items': allowOnDiscountedItems ? '1' : '0',
    };

    if (couponType == 'discount') {
      map['discount_type'] = discountType ?? '';
    }

    if (!isGlobal && shopIds != null && shopIds!.isNotEmpty) {
      map['shop_ids'] = shopIds;
    }

    if (allowOnDiscountedItems && discountPriceMode != null) {
      map['discount_price_mode'] = discountPriceMode;
    }

    return map;
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
