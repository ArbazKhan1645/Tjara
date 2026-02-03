import 'dart:convert';
import 'package:http/http.dart' as http;

class WalletCreditVoucherService {
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
          settings: WalletCreditVoucherSettings.fromJson(options),
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

  /// Fetch coupon by ID
  static Future<CouponItem?> fetchCouponById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/coupons/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['coupon'] != null) {
          return CouponItem.fromJson(data['coupon']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// ============================================
// Models
// ============================================

/// Wallet Credit Voucher Settings
class WalletCreditVoucherSettings {
  final bool enabled;
  final List<String> couponIds; // comma-separated IDs as list
  final String notificationText;
  final String emailSubject;
  final String emailBody;
  final String notificationSendBy; // 'sms', 'email', 'off'

  WalletCreditVoucherSettings({
    required this.enabled,
    required this.couponIds,
    required this.notificationText,
    required this.emailSubject,
    required this.emailBody,
    required this.notificationSendBy,
  });

  factory WalletCreditVoucherSettings.fromJson(Map<String, dynamic> json) {
    // Parse comma-separated coupon IDs
    final voucherValue = json['wallet_credit_voucher']?.toString() ?? '';
    final couponIds =
        voucherValue.isNotEmpty
            ? voucherValue
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[];

    return WalletCreditVoucherSettings(
      enabled: json['wallet_credit_voucher_enabled']?.toString() == '1',
      couponIds: couponIds,
      notificationText:
          json['wallet_credit_voucher_notification_text']?.toString() ?? '',
      emailSubject:
          json['wallet_credit_voucher_email_subject']?.toString() ?? '',
      emailBody: json['wallet_credit_voucher_email_body']?.toString() ?? '',
      notificationSendBy:
          json['wallet_credit_voucher_notification_send_by']?.toString() ??
          'off',
    );
  }

  Map<String, String> toUpdatePayload() {
    return {
      'wallet_credit_voucher_enabled': enabled ? '1' : '0',
      'wallet_credit_voucher': couponIds.join(','),
      'wallet_credit_voucher_notification_text': notificationText,
      'wallet_credit_voucher_email_subject': emailSubject,
      'wallet_credit_voucher_email_body': emailBody,
      'wallet_credit_voucher_notification_send_by': notificationSendBy,
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
  final String? code; // First code from codes array

  CouponItem({
    required this.id,
    required this.name,
    this.discountType,
    this.discountValue,
    this.status,
    this.code,
  });

  factory CouponItem.fromJson(Map<String, dynamic> json) {
    // Get first code from codes array if available
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
  final WalletCreditVoucherSettings? settings;
  final String? error;

  SettingsResponse({required this.success, this.settings, this.error});
}

class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}
