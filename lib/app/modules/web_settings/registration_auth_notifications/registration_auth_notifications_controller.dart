import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/registration_auth_notifications/registration_auth_notifications_service.dart';

class RegistrationAuthNotificationsController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;

  // Error message
  var errorMessage = Rxn<String>();

  // ============================================
  // Customer Welcome Messages
  // ============================================
  final customerWelcomeNotificationController = TextEditingController();
  final customerWelcomeEmailSubjectController = TextEditingController();
  final customerWelcomeEmailBodyController = TextEditingController();
  var customerWelcomeSendBy = 'email'.obs;

  // ============================================
  // Vendor Welcome Messages
  // ============================================
  final vendorWelcomeNotificationController = TextEditingController();
  final vendorWelcomeEmailSubjectController = TextEditingController();
  final vendorWelcomeEmailBodyController = TextEditingController();
  var vendorWelcomeSendBy = 'email'.obs;

  // ============================================
  // Customer Standard Email Verification
  // ============================================
  final customerEmailVerificationNotificationController = TextEditingController();
  final customerEmailVerificationEmailSubjectController = TextEditingController();
  final customerEmailVerificationEmailBodyController = TextEditingController();
  var customerEmailVerificationSendBy = 'email'.obs;

  // ============================================
  // Vendor Email Verification
  // ============================================
  final vendorEmailVerificationNotificationController = TextEditingController();
  final vendorEmailVerificationEmailSubjectController = TextEditingController();
  final vendorEmailVerificationEmailBodyController = TextEditingController();
  var vendorEmailVerificationSendBy = 'email'.obs;

  // ============================================
  // Customer Quick Registration Verification
  // ============================================
  final quickRegistrationVerificationNotificationController = TextEditingController();
  final quickRegistrationVerificationEmailSubjectController = TextEditingController();
  final quickRegistrationVerificationEmailBodyController = TextEditingController();
  var quickRegistrationVerificationSendBy = 'email'.obs;

  // ============================================
  // Seller Phone Verification Code
  // ============================================
  final phoneVerificationCodeNotificationController = TextEditingController();
  final phoneVerificationCodeEmailSubjectController = TextEditingController();
  final phoneVerificationCodeEmailBodyController = TextEditingController();
  var phoneVerificationCodeSendBy = 'sms'.obs;

  // ============================================
  // Phone Verification Resend
  // ============================================
  final phoneVerificationResendNotificationController = TextEditingController();
  final phoneVerificationResendEmailSubjectController = TextEditingController();
  final phoneVerificationResendEmailBodyController = TextEditingController();
  var phoneVerificationResendSendBy = 'sms'.obs;

  // ============================================
  // Password Reset Link
  // ============================================
  final passwordResetLinkNotificationController = TextEditingController();
  final passwordResetLinkEmailSubjectController = TextEditingController();
  final passwordResetLinkEmailBodyController = TextEditingController();
  var passwordResetLinkSendBy = 'email'.obs;

  // ============================================
  // Password Reset Success
  // ============================================
  final passwordResetSuccessNotificationController = TextEditingController();
  final passwordResetSuccessEmailSubjectController = TextEditingController();
  final passwordResetSuccessEmailBodyController = TextEditingController();
  var passwordResetSuccessSendBy = 'email'.obs;

  // Notification type options
  final notificationOptions = [
    {'value': 'sms', 'label': 'SMS'},
    {'value': 'email', 'label': 'Email'},
    {'value': 'off', 'label': 'Off'},
  ];

  // Common Placeholders
  final commonPlaceholders = [
    {'placeholder': '{user_name}', 'description': 'User\'s name'},
    {'placeholder': '{email}', 'description': 'User\'s email address'},
    {'placeholder': '{website_name}', 'description': 'Website name'},
    {'placeholder': '{support_email}', 'description': 'Support email address'},
    {'placeholder': '{role}', 'description': 'User role (customer/vendor)'},
  ];

  // Verification Placeholders
  final verificationPlaceholders = [
    {'placeholder': '{verification_code}', 'description': 'Verification code'},
    {'placeholder': '{verification_link}', 'description': 'Verification link URL'},
    {'placeholder': '{discount_percentage}', 'description': 'Discount percentage'},
  ];

  // Vendor Placeholders
  final vendorPlaceholders = [
    {'placeholder': '{shop_name}', 'description': 'Vendor\'s shop name'},
  ];

  // Password Reset Placeholders
  final passwordResetPlaceholders = [
    {'placeholder': '{reset_link}', 'description': 'Password reset link URL'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    // Customer Welcome
    customerWelcomeNotificationController.dispose();
    customerWelcomeEmailSubjectController.dispose();
    customerWelcomeEmailBodyController.dispose();

    // Vendor Welcome
    vendorWelcomeNotificationController.dispose();
    vendorWelcomeEmailSubjectController.dispose();
    vendorWelcomeEmailBodyController.dispose();

    // Customer Email Verification
    customerEmailVerificationNotificationController.dispose();
    customerEmailVerificationEmailSubjectController.dispose();
    customerEmailVerificationEmailBodyController.dispose();

    // Vendor Email Verification
    vendorEmailVerificationNotificationController.dispose();
    vendorEmailVerificationEmailSubjectController.dispose();
    vendorEmailVerificationEmailBodyController.dispose();

    // Quick Registration Verification
    quickRegistrationVerificationNotificationController.dispose();
    quickRegistrationVerificationEmailSubjectController.dispose();
    quickRegistrationVerificationEmailBodyController.dispose();

    // Phone Verification Code
    phoneVerificationCodeNotificationController.dispose();
    phoneVerificationCodeEmailSubjectController.dispose();
    phoneVerificationCodeEmailBodyController.dispose();

    // Phone Verification Resend
    phoneVerificationResendNotificationController.dispose();
    phoneVerificationResendEmailSubjectController.dispose();
    phoneVerificationResendEmailBodyController.dispose();

    // Password Reset Link
    passwordResetLinkNotificationController.dispose();
    passwordResetLinkEmailSubjectController.dispose();
    passwordResetLinkEmailBodyController.dispose();

    // Password Reset Success
    passwordResetSuccessNotificationController.dispose();
    passwordResetSuccessEmailSubjectController.dispose();
    passwordResetSuccessEmailBodyController.dispose();

    super.onClose();
  }

  /// Fetch settings from server
  Future<void> fetchSettings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await RegistrationAuthNotificationsService.fetchSettings();

      if (response.success && response.settings != null) {
        final settings = response.settings!;

        // Customer Welcome Messages
        customerWelcomeNotificationController.text = settings.customerWelcomeNotification;
        customerWelcomeEmailSubjectController.text = settings.customerWelcomeEmailSubject;
        customerWelcomeEmailBodyController.text = settings.customerWelcomeEmailBody;
        customerWelcomeSendBy.value = settings.customerWelcomeSendBy;

        // Vendor Welcome Messages
        vendorWelcomeNotificationController.text = settings.vendorWelcomeNotification;
        vendorWelcomeEmailSubjectController.text = settings.vendorWelcomeEmailSubject;
        vendorWelcomeEmailBodyController.text = settings.vendorWelcomeEmailBody;
        vendorWelcomeSendBy.value = settings.vendorWelcomeSendBy;

        // Customer Standard Email Verification
        customerEmailVerificationNotificationController.text = settings.customerEmailVerificationNotification;
        customerEmailVerificationEmailSubjectController.text = settings.customerEmailVerificationEmailSubject;
        customerEmailVerificationEmailBodyController.text = settings.customerEmailVerificationEmailBody;
        customerEmailVerificationSendBy.value = settings.customerEmailVerificationSendBy;

        // Vendor Email Verification
        vendorEmailVerificationNotificationController.text = settings.vendorEmailVerificationNotification;
        vendorEmailVerificationEmailSubjectController.text = settings.vendorEmailVerificationEmailSubject;
        vendorEmailVerificationEmailBodyController.text = settings.vendorEmailVerificationEmailBody;
        vendorEmailVerificationSendBy.value = settings.vendorEmailVerificationSendBy;

        // Customer Quick Registration Verification
        quickRegistrationVerificationNotificationController.text = settings.quickRegistrationVerificationNotification;
        quickRegistrationVerificationEmailSubjectController.text = settings.quickRegistrationVerificationEmailSubject;
        quickRegistrationVerificationEmailBodyController.text = settings.quickRegistrationVerificationEmailBody;
        quickRegistrationVerificationSendBy.value = settings.quickRegistrationVerificationSendBy;

        // Seller Phone Verification Code
        phoneVerificationCodeNotificationController.text = settings.phoneVerificationCodeNotification;
        phoneVerificationCodeEmailSubjectController.text = settings.phoneVerificationCodeEmailSubject;
        phoneVerificationCodeEmailBodyController.text = settings.phoneVerificationCodeEmailBody;
        phoneVerificationCodeSendBy.value = settings.phoneVerificationCodeSendBy;

        // Phone Verification Resend
        phoneVerificationResendNotificationController.text = settings.phoneVerificationResendNotification;
        phoneVerificationResendEmailSubjectController.text = settings.phoneVerificationResendEmailSubject;
        phoneVerificationResendEmailBodyController.text = settings.phoneVerificationResendEmailBody;
        phoneVerificationResendSendBy.value = settings.phoneVerificationResendSendBy;

        // Password Reset Link
        passwordResetLinkNotificationController.text = settings.passwordResetLinkNotification;
        passwordResetLinkEmailSubjectController.text = settings.passwordResetLinkEmailSubject;
        passwordResetLinkEmailBodyController.text = settings.passwordResetLinkEmailBody;
        passwordResetLinkSendBy.value = settings.passwordResetLinkSendBy;

        // Password Reset Success
        passwordResetSuccessNotificationController.text = settings.passwordResetSuccessNotification;
        passwordResetSuccessEmailSubjectController.text = settings.passwordResetSuccessEmailSubject;
        passwordResetSuccessEmailBodyController.text = settings.passwordResetSuccessEmailBody;
        passwordResetSuccessSendBy.value = settings.passwordResetSuccessSendBy;
      } else {
        errorMessage.value = response.error;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Enable all SMS notifications
  void enableAllSms() {
    customerWelcomeSendBy.value = 'sms';
    vendorWelcomeSendBy.value = 'sms';
    customerEmailVerificationSendBy.value = 'sms';
    vendorEmailVerificationSendBy.value = 'sms';
    quickRegistrationVerificationSendBy.value = 'sms';
    phoneVerificationCodeSendBy.value = 'sms';
    phoneVerificationResendSendBy.value = 'sms';
    passwordResetLinkSendBy.value = 'sms';
    passwordResetSuccessSendBy.value = 'sms';
  }

  /// Enable all Email notifications
  void enableAllEmail() {
    customerWelcomeSendBy.value = 'email';
    vendorWelcomeSendBy.value = 'email';
    customerEmailVerificationSendBy.value = 'email';
    vendorEmailVerificationSendBy.value = 'email';
    quickRegistrationVerificationSendBy.value = 'email';
    phoneVerificationCodeSendBy.value = 'email';
    phoneVerificationResendSendBy.value = 'email';
    passwordResetLinkSendBy.value = 'email';
    passwordResetSuccessSendBy.value = 'email';
  }

  /// Disable all notifications
  void disableAllNotifications() {
    customerWelcomeSendBy.value = 'off';
    vendorWelcomeSendBy.value = 'off';
    customerEmailVerificationSendBy.value = 'off';
    vendorEmailVerificationSendBy.value = 'off';
    quickRegistrationVerificationSendBy.value = 'off';
    phoneVerificationCodeSendBy.value = 'off';
    phoneVerificationResendSendBy.value = 'off';
    passwordResetLinkSendBy.value = 'off';
    passwordResetSuccessSendBy.value = 'off';
  }

  /// Save settings
  Future<bool> saveSettings() async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final settings = RegistrationAuthSettings(
        // Customer Welcome Messages
        customerWelcomeNotification: customerWelcomeNotificationController.text.trim(),
        customerWelcomeEmailSubject: customerWelcomeEmailSubjectController.text.trim(),
        customerWelcomeEmailBody: customerWelcomeEmailBodyController.text.trim(),
        customerWelcomeSendBy: customerWelcomeSendBy.value,

        // Vendor Welcome Messages
        vendorWelcomeNotification: vendorWelcomeNotificationController.text.trim(),
        vendorWelcomeEmailSubject: vendorWelcomeEmailSubjectController.text.trim(),
        vendorWelcomeEmailBody: vendorWelcomeEmailBodyController.text.trim(),
        vendorWelcomeSendBy: vendorWelcomeSendBy.value,

        // Customer Standard Email Verification
        customerEmailVerificationNotification: customerEmailVerificationNotificationController.text.trim(),
        customerEmailVerificationEmailSubject: customerEmailVerificationEmailSubjectController.text.trim(),
        customerEmailVerificationEmailBody: customerEmailVerificationEmailBodyController.text.trim(),
        customerEmailVerificationSendBy: customerEmailVerificationSendBy.value,

        // Vendor Email Verification
        vendorEmailVerificationNotification: vendorEmailVerificationNotificationController.text.trim(),
        vendorEmailVerificationEmailSubject: vendorEmailVerificationEmailSubjectController.text.trim(),
        vendorEmailVerificationEmailBody: vendorEmailVerificationEmailBodyController.text.trim(),
        vendorEmailVerificationSendBy: vendorEmailVerificationSendBy.value,

        // Customer Quick Registration Verification
        quickRegistrationVerificationNotification: quickRegistrationVerificationNotificationController.text.trim(),
        quickRegistrationVerificationEmailSubject: quickRegistrationVerificationEmailSubjectController.text.trim(),
        quickRegistrationVerificationEmailBody: quickRegistrationVerificationEmailBodyController.text.trim(),
        quickRegistrationVerificationSendBy: quickRegistrationVerificationSendBy.value,

        // Seller Phone Verification Code
        phoneVerificationCodeNotification: phoneVerificationCodeNotificationController.text.trim(),
        phoneVerificationCodeEmailSubject: phoneVerificationCodeEmailSubjectController.text.trim(),
        phoneVerificationCodeEmailBody: phoneVerificationCodeEmailBodyController.text.trim(),
        phoneVerificationCodeSendBy: phoneVerificationCodeSendBy.value,

        // Phone Verification Resend
        phoneVerificationResendNotification: phoneVerificationResendNotificationController.text.trim(),
        phoneVerificationResendEmailSubject: phoneVerificationResendEmailSubjectController.text.trim(),
        phoneVerificationResendEmailBody: phoneVerificationResendEmailBodyController.text.trim(),
        phoneVerificationResendSendBy: phoneVerificationResendSendBy.value,

        // Password Reset Link
        passwordResetLinkNotification: passwordResetLinkNotificationController.text.trim(),
        passwordResetLinkEmailSubject: passwordResetLinkEmailSubjectController.text.trim(),
        passwordResetLinkEmailBody: passwordResetLinkEmailBodyController.text.trim(),
        passwordResetLinkSendBy: passwordResetLinkSendBy.value,

        // Password Reset Success
        passwordResetSuccessNotification: passwordResetSuccessNotificationController.text.trim(),
        passwordResetSuccessEmailSubject: passwordResetSuccessEmailSubjectController.text.trim(),
        passwordResetSuccessEmailBody: passwordResetSuccessEmailBodyController.text.trim(),
        passwordResetSuccessSendBy: passwordResetSuccessSendBy.value,
      );

      final response = await RegistrationAuthNotificationsService.updateSettings(
        settings.toUpdatePayload(),
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save settings: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
