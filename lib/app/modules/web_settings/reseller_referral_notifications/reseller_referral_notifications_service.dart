import 'dart:convert';
import 'package:http/http.dart' as http;

class ResellerReferralNotificationsService {
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
          settings: ResellerReferralSettings.fromJson(options),
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
}

// ============================================
// Models
// ============================================

/// Reseller & Referral Notification Settings
class ResellerReferralSettings {
  // Reseller Bonus Earned
  final String bonusEarnedNotificationText;
  final String bonusEarnedEmailSubject;
  final String bonusEarnedEmailBody;
  final String bonusEarnedSendBy;

  // Referral Earnings
  final String referralEarningsNotificationText;
  final String referralEarningsEmailSubject;
  final String referralEarningsEmailBody;
  final String referralEarningsSendBy;

  // Level Upgrade
  final String levelUpgradeNotificationText;
  final String levelUpgradeEmailSubject;
  final String levelUpgradeEmailBody;
  final String levelUpgradeSendBy;

  ResellerReferralSettings({
    required this.bonusEarnedNotificationText,
    required this.bonusEarnedEmailSubject,
    required this.bonusEarnedEmailBody,
    required this.bonusEarnedSendBy,
    required this.referralEarningsNotificationText,
    required this.referralEarningsEmailSubject,
    required this.referralEarningsEmailBody,
    required this.referralEarningsSendBy,
    required this.levelUpgradeNotificationText,
    required this.levelUpgradeEmailSubject,
    required this.levelUpgradeEmailBody,
    required this.levelUpgradeSendBy,
  });

  factory ResellerReferralSettings.fromJson(Map<String, dynamic> json) {
    return ResellerReferralSettings(
      // Reseller Bonus Earned
      bonusEarnedNotificationText:
          json['reseller_bonus_earned_notification_text']?.toString() ?? '',
      bonusEarnedEmailSubject:
          json['reseller_bonus_earned_email_subject']?.toString() ?? '',
      bonusEarnedEmailBody:
          json['reseller_bonus_earned_email_body']?.toString() ?? '',
      bonusEarnedSendBy:
          json['reseller_bonus_earned_notification_send_by']?.toString() ??
          'off',

      // Referral Earnings
      referralEarningsNotificationText:
          json['referral_earnings_notification_text']?.toString() ?? '',
      referralEarningsEmailSubject:
          json['referral_earnings_email_subject']?.toString() ?? '',
      referralEarningsEmailBody:
          json['referral_earnings_email_body']?.toString() ?? '',
      referralEarningsSendBy:
          json['referral_earnings_notification_send_by']?.toString() ?? 'off',

      // Level Upgrade
      levelUpgradeNotificationText:
          json['reseller_level_upgrade_notification_text']?.toString() ?? '',
      levelUpgradeEmailSubject:
          json['reseller_level_upgrade_email_subject']?.toString() ?? '',
      levelUpgradeEmailBody:
          json['reseller_level_upgrade_email_body']?.toString() ?? '',
      levelUpgradeSendBy:
          json['reseller_level_upgrade_notification_send_by']?.toString() ??
          'off',
    );
  }

  Map<String, String> toUpdatePayload() {
    return {
      // Reseller Bonus Earned
      'reseller_bonus_earned_notification_text': bonusEarnedNotificationText,
      'reseller_bonus_earned_email_subject': bonusEarnedEmailSubject,
      'reseller_bonus_earned_email_body': bonusEarnedEmailBody,
      'reseller_bonus_earned_notification_send_by': bonusEarnedSendBy,

      // Referral Earnings
      'referral_earnings_notification_text': referralEarningsNotificationText,
      'referral_earnings_email_subject': referralEarningsEmailSubject,
      'referral_earnings_email_body': referralEarningsEmailBody,
      'referral_earnings_notification_send_by': referralEarningsSendBy,

      // Level Upgrade
      'reseller_level_upgrade_notification_text': levelUpgradeNotificationText,
      'reseller_level_upgrade_email_subject': levelUpgradeEmailSubject,
      'reseller_level_upgrade_email_body': levelUpgradeEmailBody,
      'reseller_level_upgrade_notification_send_by': levelUpgradeSendBy,
    };
  }
}

// ============================================
// Response Models
// ============================================

class SettingsResponse {
  final bool success;
  final ResellerReferralSettings? settings;
  final String? error;

  SettingsResponse({required this.success, this.settings, this.error});
}

class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}
