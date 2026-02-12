// models/coupon_models.dart

class CouponResponse {
  final bool success;
  final CouponData coupons;
  final String message;

  CouponResponse({
    required this.success,
    required this.coupons,
    required this.message,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      success: json['success'] ?? false,
      coupons: CouponData.fromJson(json['coupons'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class CouponData {
  final int currentPage;
  final List<Coupon> data;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  CouponData({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Coupon.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List<dynamic>?)
              ?.map((e) => PaginationLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}

class Coupon {
  final String id;
  final String name;
  final String? description;
  final String couponType;
  final String discountType;
  final String discountValue;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isGlobal;
  final int? usageLimit;
  final int? usageLimitPerUser;
  final String? minimumAmount;
  final String? maximumDiscount;
  final String status;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final CouponMeta meta;
  final bool isExpired;
  final bool isActiveNow;
  final int daysRemaining;
  final int totalCodes;
  final int usedCodes;
  final int availableCodes;
  final double usagePercentage;
  final List<dynamic> shops;
  final List<CouponCode> codes;
  final bool allowOnDiscountedItems;
  final String? discountPriceMode;

  Coupon({
    required this.id,
    required this.name,
    this.description,
    required this.couponType,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.expiryDate,
    required this.isGlobal,
    this.usageLimit,
    this.usageLimitPerUser,
    this.minimumAmount,
    this.maximumDiscount,
    required this.status,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.meta,
    required this.isExpired,
    required this.isActiveNow,
    required this.daysRemaining,
    required this.totalCodes,
    required this.usedCodes,
    required this.availableCodes,
    required this.usagePercentage,
    required this.shops,
    required this.codes,
    this.allowOnDiscountedItems = false,
    this.discountPriceMode,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      couponType: json['coupon_type'] ?? '',
      discountType: json['discount_type'] ?? '',
      discountValue: json['discount_value'] ?? '0',
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      expiryDate: DateTime.parse(json['expiry_date'] ?? DateTime.now().toIso8601String()),
      isGlobal: json['is_global'] == 1 || json['is_global'] == true,
      usageLimit: json['usage_limit'],
      usageLimitPerUser: json['usage_limit_per_user'],
      minimumAmount: json['minimum_amount'],
      maximumDiscount: json['maximum_discount'],
      status: json['status'] ?? '',
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      meta: CouponMeta.fromJson(json['meta'] ?? {}),
      isExpired: json['is_expired'] ?? false,
      isActiveNow: json['is_active_now'] ?? false,
      daysRemaining: json['days_remaining'] ?? 0,
      totalCodes: json['total_codes'] ?? 0,
      usedCodes: json['used_codes'] ?? 0,
      availableCodes: json['available_codes'] ?? 0,
      usagePercentage: (json['usage_percentage'] ?? 0).toDouble(),
      shops: json['shops'] ?? [],
      codes: (json['codes'] as List<dynamic>?)
              ?.map((e) => CouponCode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      allowOnDiscountedItems: json['allow_on_discounted_items'] == 1 || json['allow_on_discounted_items'] == true,
      discountPriceMode: json['discount_price_mode'],
    );
  }
}

class CouponMeta {
  final String couponId;

  CouponMeta({required this.couponId});

  factory CouponMeta.fromJson(Map<String, dynamic> json) {
    return CouponMeta(
      couponId: json['coupon_id'] ?? '',
    );
  }
}

class CouponCode {
  final String id;
  final String couponId;
  final String code;
  final bool isUsed;
  final int usedCount;
  final DateTime? firstUsedAt;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouponCode({
    required this.id,
    required this.couponId,
    required this.code,
    required this.isUsed,
    required this.usedCount,
    this.firstUsedAt,
    this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CouponCode.fromJson(Map<String, dynamic> json) {
    return CouponCode(
      id: json['id'] ?? '',
      couponId: json['coupon_id'] ?? '',
      code: json['code'] ?? '',
      isUsed: json['is_used'] ?? false,
      usedCount: json['used_count'] ?? 0,
      firstUsedAt: json['first_used_at'] != null ? DateTime.parse(json['first_used_at']) : null,
      lastUsedAt: json['last_used_at'] != null ? DateTime.parse(json['last_used_at']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}