/// Safe int parser — handles String, int, double, null
int _parseInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

/// Safe double parser — handles String, int, double, null
double _parseDouble(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

/// Paginated response wrapper
class NotificationLogResponse {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final List<NotificationLogItem> data;

  NotificationLogResponse({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    required this.data,
  });

  factory NotificationLogResponse.fromJson(Map<String, dynamic> json) {
    final logs = json['logs'] ?? json;
    final List<dynamic> dataList = logs['data'] as List<dynamic>? ?? [];

    return NotificationLogResponse(
      currentPage: _parseInt(logs['current_page'], 1),
      lastPage: _parseInt(logs['last_page'], 1),
      total: _parseInt(logs['total']),
      perPage: _parseInt(logs['per_page'], 10),
      data: dataList
          .map((item) =>
              NotificationLogItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Single notification log entry
class NotificationLogItem {
  final String id;
  final String type;
  final String status;
  final String eventType;
  final String? recipient;
  final String? subject;
  final String? message;
  final String? provider;
  final String? sentAt;
  final NotificationMetadata? metadata;
  final NotificationUser? user;
  final NotificationCoupon? coupon;
  final NotificationCouponCode? couponCode;

  NotificationLogItem({
    required this.id,
    required this.type,
    required this.status,
    required this.eventType,
    this.recipient,
    this.subject,
    this.message,
    this.provider,
    this.sentAt,
    this.metadata,
    this.user,
    this.coupon,
    this.couponCode,
  });

  factory NotificationLogItem.fromJson(Map<String, dynamic> json) {
    return NotificationLogItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? '',
      recipient: json['recipient']?.toString(),
      subject: json['subject']?.toString(),
      message: json['message']?.toString(),
      provider: json['provider']?.toString(),
      sentAt: json['sent_at']?.toString(),
      metadata: json['metadata'] != null && json['metadata'] is Map
          ? NotificationMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null && json['user'] is Map
          ? NotificationUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      coupon: json['coupon'] != null && json['coupon'] is Map
          ? NotificationCoupon.fromJson(json['coupon'] as Map<String, dynamic>)
          : null,
      couponCode: json['coupon_code'] != null && json['coupon_code'] is Map
          ? NotificationCouponCode.fromJson(
              json['coupon_code'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Metadata embedded in each log
class NotificationMetadata {
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? couponCode;
  final String? couponName;
  final String? couponType;
  final String? discountType;
  final String? discountValue;
  final double discountAmount;
  final double orderAmount;
  final double finalAmount;

  NotificationMetadata({
    this.userName,
    this.userEmail,
    this.userPhone,
    this.couponCode,
    this.couponName,
    this.couponType,
    this.discountType,
    this.discountValue,
    this.discountAmount = 0,
    this.orderAmount = 0,
    this.finalAmount = 0,
  });

  factory NotificationMetadata.fromJson(Map<String, dynamic> json) {
    return NotificationMetadata(
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),
      userPhone: json['user_phone']?.toString(),
      couponCode: json['coupon_code']?.toString(),
      couponName: json['coupon_name']?.toString(),
      couponType: json['coupon_type']?.toString(),
      discountType: json['discount_type']?.toString(),
      discountValue: json['discount_value']?.toString(),
      discountAmount: _parseDouble(json['discount_amount']),
      orderAmount: _parseDouble(json['order_amount']),
      finalAmount: _parseDouble(json['final_amount']),
    );
  }
}

/// User who triggered the notification
class NotificationUser {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? role;

  NotificationUser({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.role,
  });

  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['id']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
    );
  }

  String get fullName {
    final parts = [firstName, lastName].where((s) => s != null && s.isNotEmpty);
    return parts.join(' ');
  }
}

/// Coupon associated with the notification
class NotificationCoupon {
  final String? id;
  final String? name;
  final String? couponType;
  final String? discountType;
  final String? discountValue;
  final String? status;

  NotificationCoupon({
    this.id,
    this.name,
    this.couponType,
    this.discountType,
    this.discountValue,
    this.status,
  });

  factory NotificationCoupon.fromJson(Map<String, dynamic> json) {
    return NotificationCoupon(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      couponType: json['coupon_type']?.toString(),
      discountType: json['discount_type']?.toString(),
      discountValue: json['discount_value']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

/// Coupon code details
class NotificationCouponCode {
  final String? id;
  final String? code;
  final bool isUsed;
  final int usedCount;

  NotificationCouponCode({
    this.id,
    this.code,
    this.isUsed = false,
    this.usedCount = 0,
  });

  factory NotificationCouponCode.fromJson(Map<String, dynamic> json) {
    return NotificationCouponCode(
      id: json['id']?.toString(),
      code: json['code']?.toString(),
      isUsed: json['is_used'] == true || json['is_used'] == 1,
      usedCount: _parseInt(json['used_count']),
    );
  }
}
