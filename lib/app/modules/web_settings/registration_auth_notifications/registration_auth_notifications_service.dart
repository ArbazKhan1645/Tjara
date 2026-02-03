import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistrationAuthNotificationsService {
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
          settings: RegistrationAuthSettings.fromJson(options),
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

/// Registration & Authentication Notification Settings
class RegistrationAuthSettings {
  // Customer Welcome Messages
  final String customerWelcomeNotification;
  final String customerWelcomeEmailSubject;
  final String customerWelcomeEmailBody;
  final String customerWelcomeSendBy;

  // Vendor Welcome Messages
  final String vendorWelcomeNotification;
  final String vendorWelcomeEmailSubject;
  final String vendorWelcomeEmailBody;
  final String vendorWelcomeSendBy;

  // Customer Standard Email Verification
  final String customerEmailVerificationNotification;
  final String customerEmailVerificationEmailSubject;
  final String customerEmailVerificationEmailBody;
  final String customerEmailVerificationSendBy;

  // Vendor Email Verification
  final String vendorEmailVerificationNotification;
  final String vendorEmailVerificationEmailSubject;
  final String vendorEmailVerificationEmailBody;
  final String vendorEmailVerificationSendBy;

  // Customer Quick Registration Verification
  final String quickRegistrationVerificationNotification;
  final String quickRegistrationVerificationEmailSubject;
  final String quickRegistrationVerificationEmailBody;
  final String quickRegistrationVerificationSendBy;

  // Seller Phone Verification Code
  final String phoneVerificationCodeNotification;
  final String phoneVerificationCodeEmailSubject;
  final String phoneVerificationCodeEmailBody;
  final String phoneVerificationCodeSendBy;

  // Phone Verification Resend
  final String phoneVerificationResendNotification;
  final String phoneVerificationResendEmailSubject;
  final String phoneVerificationResendEmailBody;
  final String phoneVerificationResendSendBy;

  // Password Reset Link
  final String passwordResetLinkNotification;
  final String passwordResetLinkEmailSubject;
  final String passwordResetLinkEmailBody;
  final String passwordResetLinkSendBy;

  // Password Reset Success
  final String passwordResetSuccessNotification;
  final String passwordResetSuccessEmailSubject;
  final String passwordResetSuccessEmailBody;
  final String passwordResetSuccessSendBy;

  RegistrationAuthSettings({
    required this.customerWelcomeNotification,
    required this.customerWelcomeEmailSubject,
    required this.customerWelcomeEmailBody,
    required this.customerWelcomeSendBy,
    required this.vendorWelcomeNotification,
    required this.vendorWelcomeEmailSubject,
    required this.vendorWelcomeEmailBody,
    required this.vendorWelcomeSendBy,
    required this.customerEmailVerificationNotification,
    required this.customerEmailVerificationEmailSubject,
    required this.customerEmailVerificationEmailBody,
    required this.customerEmailVerificationSendBy,
    required this.vendorEmailVerificationNotification,
    required this.vendorEmailVerificationEmailSubject,
    required this.vendorEmailVerificationEmailBody,
    required this.vendorEmailVerificationSendBy,
    required this.quickRegistrationVerificationNotification,
    required this.quickRegistrationVerificationEmailSubject,
    required this.quickRegistrationVerificationEmailBody,
    required this.quickRegistrationVerificationSendBy,
    required this.phoneVerificationCodeNotification,
    required this.phoneVerificationCodeEmailSubject,
    required this.phoneVerificationCodeEmailBody,
    required this.phoneVerificationCodeSendBy,
    required this.phoneVerificationResendNotification,
    required this.phoneVerificationResendEmailSubject,
    required this.phoneVerificationResendEmailBody,
    required this.phoneVerificationResendSendBy,
    required this.passwordResetLinkNotification,
    required this.passwordResetLinkEmailSubject,
    required this.passwordResetLinkEmailBody,
    required this.passwordResetLinkSendBy,
    required this.passwordResetSuccessNotification,
    required this.passwordResetSuccessEmailSubject,
    required this.passwordResetSuccessEmailBody,
    required this.passwordResetSuccessSendBy,
  });

  factory RegistrationAuthSettings.fromJson(Map<String, dynamic> json) {
    return RegistrationAuthSettings(
      // Customer Welcome Messages
      customerWelcomeNotification:
          json['registration_welcome_customer_notification_text']?.toString() ??
          '',
      customerWelcomeEmailSubject:
          json['registration_welcome_customer_email_subject']?.toString() ?? '',
      customerWelcomeEmailBody:
          json['registration_welcome_customer_email_body']?.toString() ?? '',
      customerWelcomeSendBy:
          json['registration_welcome_customer_notification_send_by']
              ?.toString() ??
          'email',

      // Vendor Welcome Messages
      vendorWelcomeNotification:
          json['registration_welcome_vendor_notification_text']?.toString() ??
          '',
      vendorWelcomeEmailSubject:
          json['registration_welcome_vendor_email_subject']?.toString() ?? '',
      vendorWelcomeEmailBody:
          json['registration_welcome_vendor_email_body']?.toString() ?? '',
      vendorWelcomeSendBy:
          json['registration_welcome_vendor_notification_send_by']
              ?.toString() ??
          'email',

      // Customer Standard Email Verification
      customerEmailVerificationNotification:
          json['registration_verification_customer_notification_text']
              ?.toString() ??
          '',
      customerEmailVerificationEmailSubject:
          json['registration_verification_customer_email_subject']
              ?.toString() ??
          '',
      customerEmailVerificationEmailBody:
          json['registration_verification_customer_email_body']?.toString() ??
          '',
      customerEmailVerificationSendBy:
          json['registration_verification_customer_notification_send_by']
              ?.toString() ??
          'email',

      // Vendor Email Verification
      vendorEmailVerificationNotification:
          json['registration_verification_vendor_notification_text']
              ?.toString() ??
          '',
      vendorEmailVerificationEmailSubject:
          json['registration_verification_vendor_email_subject']?.toString() ??
          '',
      vendorEmailVerificationEmailBody:
          json['registration_verification_vendor_email_body']?.toString() ?? '',
      vendorEmailVerificationSendBy:
          json['registration_verification_vendor_notification_send_by']
              ?.toString() ??
          'email',

      // Customer Quick Registration Verification
      quickRegistrationVerificationNotification:
          json['quick_registration_verification_customer_notification_text']
              ?.toString() ??
          '',
      quickRegistrationVerificationEmailSubject:
          json['quick_registration_verification_customer_email_subject']
              ?.toString() ??
          '',
      quickRegistrationVerificationEmailBody:
          json['quick_registration_verification_customer_email_body']
              ?.toString() ??
          '',
      quickRegistrationVerificationSendBy:
          json['quick_registration_verification_customer_notification_send_by']
              ?.toString() ??
          'email',

      // Seller Phone Verification Code
      phoneVerificationCodeNotification:
          json['phone_verification_code_notification_text']?.toString() ?? '',
      phoneVerificationCodeEmailSubject:
          json['phone_verification_code_email_subject']?.toString() ?? '',
      phoneVerificationCodeEmailBody:
          json['phone_verification_code_email_body']?.toString() ?? '',
      phoneVerificationCodeSendBy:
          json['phone_verification_code_notification_send_by']?.toString() ??
          'sms',

      // Phone Verification Resend
      phoneVerificationResendNotification:
          json['phone_verification_resend_notification_text']?.toString() ?? '',
      phoneVerificationResendEmailSubject:
          json['phone_verification_resend_email_subject']?.toString() ?? '',
      phoneVerificationResendEmailBody:
          json['phone_verification_resend_email_body']?.toString() ?? '',
      phoneVerificationResendSendBy:
          json['phone_verification_resend_notification_send_by']?.toString() ??
          'sms',

      // Password Reset Link
      passwordResetLinkNotification:
          json['password_reset_link_notification_text']?.toString() ?? '',
      passwordResetLinkEmailSubject:
          json['password_reset_link_email_subject']?.toString() ?? '',
      passwordResetLinkEmailBody:
          json['password_reset_link_email_body']?.toString() ?? '',
      passwordResetLinkSendBy:
          json['password_reset_link_notification_send_by']?.toString() ??
          'email',

      // Password Reset Success
      passwordResetSuccessNotification:
          json['password_reset_success_notification_text']?.toString() ?? '',
      passwordResetSuccessEmailSubject:
          json['password_reset_success_email_subject']?.toString() ?? '',
      passwordResetSuccessEmailBody:
          json['password_reset_success_email_body']?.toString() ?? '',
      passwordResetSuccessSendBy:
          json['password_reset_success_notification_send_by']?.toString() ??
          'email',
    );
  }

  Map<String, String> toUpdatePayload() {
    return {
      // Customer Welcome Messages
      'registration_welcome_customer_notification_text':
          customerWelcomeNotification,
      'registration_welcome_customer_email_subject':
          customerWelcomeEmailSubject,
      'registration_welcome_customer_email_body': customerWelcomeEmailBody,
      'registration_welcome_customer_notification_send_by':
          customerWelcomeSendBy,

      // Vendor Welcome Messages
      'registration_welcome_vendor_notification_text':
          vendorWelcomeNotification,
      'registration_welcome_vendor_email_subject': vendorWelcomeEmailSubject,
      'registration_welcome_vendor_email_body': vendorWelcomeEmailBody,
      'registration_welcome_vendor_notification_send_by': vendorWelcomeSendBy,

      // Customer Standard Email Verification
      'registration_verification_customer_notification_text':
          customerEmailVerificationNotification,
      'registration_verification_customer_email_subject':
          customerEmailVerificationEmailSubject,
      'registration_verification_customer_email_body':
          customerEmailVerificationEmailBody,
      'registration_verification_customer_notification_send_by':
          customerEmailVerificationSendBy,

      // Vendor Email Verification
      'registration_verification_vendor_notification_text':
          vendorEmailVerificationNotification,
      'registration_verification_vendor_email_subject':
          vendorEmailVerificationEmailSubject,
      'registration_verification_vendor_email_body':
          vendorEmailVerificationEmailBody,
      'registration_verification_vendor_notification_send_by':
          vendorEmailVerificationSendBy,

      // Customer Quick Registration Verification
      'quick_registration_verification_customer_notification_text':
          quickRegistrationVerificationNotification,
      'quick_registration_verification_customer_email_subject':
          quickRegistrationVerificationEmailSubject,
      'quick_registration_verification_customer_email_body':
          quickRegistrationVerificationEmailBody,
      'quick_registration_verification_customer_notification_send_by':
          quickRegistrationVerificationSendBy,

      // Seller Phone Verification Code
      'phone_verification_code_notification_text':
          phoneVerificationCodeNotification,
      'phone_verification_code_email_subject':
          phoneVerificationCodeEmailSubject,
      'phone_verification_code_email_body': phoneVerificationCodeEmailBody,
      'phone_verification_code_notification_send_by':
          phoneVerificationCodeSendBy,

      // Phone Verification Resend
      'phone_verification_resend_notification_text':
          phoneVerificationResendNotification,
      'phone_verification_resend_email_subject':
          phoneVerificationResendEmailSubject,
      'phone_verification_resend_email_body': phoneVerificationResendEmailBody,
      'phone_verification_resend_notification_send_by':
          phoneVerificationResendSendBy,

      // Password Reset Link
      'password_reset_link_notification_text': passwordResetLinkNotification,
      'password_reset_link_email_subject': passwordResetLinkEmailSubject,
      'password_reset_link_email_body': passwordResetLinkEmailBody,
      'password_reset_link_notification_send_by': passwordResetLinkSendBy,

      // Password Reset Success
      'password_reset_success_notification_text':
          passwordResetSuccessNotification,
      'password_reset_success_email_subject': passwordResetSuccessEmailSubject,
      'password_reset_success_email_body': passwordResetSuccessEmailBody,
      'password_reset_success_notification_send_by': passwordResetSuccessSendBy,
    };
  }
}

// ============================================
// Response Models
// ============================================

class SettingsResponse {
  final bool success;
  final RegistrationAuthSettings? settings;
  final String? error;

  SettingsResponse({required this.success, this.settings, this.error});
}

class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}
