import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderDiscountCouponService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'X-Request-From': 'Website',
  };

  static Map<String, String> get _headersWithJson => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Request-From': 'Website',
  };

  /// Fetch settings from server
  static Future<SettingsResponse> fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/settings?_t=${DateTime.now().microsecondsSinceEpoch}',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final options = data['options'] as Map<String, dynamic>? ?? {};

        return SettingsResponse(
          success: true,
          settings: OrderDiscountCouponSettings.fromJson(options),
        );
      } else {
        return SettingsResponse(
          success: false,
          error: 'Failed to fetch settings. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SettingsResponse(success: false, error: 'Network error: $e');
    }
  }

  /// Update settings
  static Future<UpdateResponse> updateSettings(
    Map<String, String> settings,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/settings/update'),
        headers: _headersWithJson,
        body: jsonEncode(settings),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return UpdateResponse(
          success: true,
          message: data['message'] ?? 'Settings updated successfully',
        );
      } else {
        return UpdateResponse(
          success: false,
          message: data['message'] ?? 'Failed to update settings',
        );
      }
    } catch (e) {
      return UpdateResponse(success: false, message: 'Network error: $e');
    }
  }

  /// Search coupons
  static Future<List<CouponItem>> searchCoupons({String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '$_baseUrl/coupons',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final couponsData = data['coupons']['data'] as List? ?? [];

        return couponsData
            .map((coupon) => CouponItem.fromJson(coupon))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

// ============================================
// Models
// ============================================

/// Order Discount Coupon Settings
class OrderDiscountCouponSettings {
  final bool enabled;
  final String targetOrderStatus;
  final List<String> couponIds;
  final String sendingDelay;
  final String notificationText;
  final String emailSubject;
  final String emailBody;
  final String notificationSendBy;

  OrderDiscountCouponSettings({
    required this.enabled,
    required this.targetOrderStatus,
    required this.couponIds,
    required this.sendingDelay,
    required this.notificationText,
    required this.emailSubject,
    required this.emailBody,
    required this.notificationSendBy,
  });

  factory OrderDiscountCouponSettings.fromJson(Map<String, dynamic> json) {
    // Parse comma-separated coupon IDs
    final couponValue = json['order_discount_coupon']?.toString() ?? '';
    final couponIds =
        couponValue.isNotEmpty
            ? couponValue
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];

    return OrderDiscountCouponSettings(
      enabled: json['order_discount_coupon_enabled']?.toString() == '1',
      targetOrderStatus:
          json['order_discount_target_order_status']?.toString() ?? 'delivered',
      couponIds: couponIds,
      sendingDelay:
          json['order_discount_coupon_sending_delay']?.toString() ?? '5',
      notificationText:
          json['order_discount_coupon_notification_text']?.toString() ?? '',
      emailSubject:
          json['order_discount_coupon_email_subject']?.toString() ?? '',
      emailBody: json['order_discount_coupon_email_body']?.toString() ?? '',
      notificationSendBy:
          json['order_discount_coupon_notification_send_by']?.toString() ??
          'off',
    );
  }

  Map<String, String> toUpdatePayload() {
    return {
      'order_discount_coupon_enabled': enabled ? '1' : '0',
      'order_discount_target_order_status': targetOrderStatus,
      'order_discount_coupon': couponIds.join(','),
      'order_discount_coupon_sending_delay': sendingDelay,
      'order_discount_coupon_notification_text': notificationText,
      'order_discount_coupon_email_subject': emailSubject,
      'order_discount_coupon_email_body': emailBody,
      'order_discount_coupon_notification_send_by': notificationSendBy,
    };
  }
}

/// Coupon Item
class CouponItem {
  final String id;
  final String name;
  final String? discountType;
  final String? discountValue;
  final String? status;
  final String? code;

  CouponItem({
    required this.id,
    required this.name,
    this.discountType,
    this.discountValue,
    this.status,
    this.code,
  });

  factory CouponItem.fromJson(Map<String, dynamic> json) {
    String? firstCode;
    final codes = json['codes'] as List?;
    if (codes != null && codes.isNotEmpty) {
      firstCode = codes[0]['code']?.toString();
    }

    return CouponItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      discountType: json['discount_type']?.toString(),
      discountValue: json['discount_value']?.toString(),
      status: json['status']?.toString(),
      code: firstCode,
    );
  }

  String get displayName {
    if (code != null && code!.isNotEmpty) {
      return '$name ($code)';
    }
    return name;
  }
}

// ============================================
// Response Models
// ============================================

class SettingsResponse {
  final bool success;
  final OrderDiscountCouponSettings? settings;
  final String? error;

  SettingsResponse({required this.success, this.settings, this.error});
}

class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}
