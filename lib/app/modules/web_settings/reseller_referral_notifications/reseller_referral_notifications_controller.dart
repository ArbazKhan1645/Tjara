import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/reseller_referral_notifications/reseller_referral_notifications_service.dart';

class ResellerReferralNotificationsController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;

  // Error message
  var errorMessage = Rxn<String>();

  // Reseller Bonus Earned
  final bonusEarnedNotificationTextController = TextEditingController();
  final bonusEarnedEmailSubjectController = TextEditingController();
  final bonusEarnedEmailBodyController = TextEditingController();
  var bonusEarnedSendBy = 'off'.obs;

  // Referral Earnings
  final referralEarningsNotificationTextController = TextEditingController();
  final referralEarningsEmailSubjectController = TextEditingController();
  final referralEarningsEmailBodyController = TextEditingController();
  var referralEarningsSendBy = 'off'.obs;

  // Level Upgrade
  final levelUpgradeNotificationTextController = TextEditingController();
  final levelUpgradeEmailSubjectController = TextEditingController();
  final levelUpgradeEmailBodyController = TextEditingController();
  var levelUpgradeSendBy = 'off'.obs;

  // Notification type options
  final notificationOptions = [
    {'value': 'sms', 'label': 'SMS'},
    {'value': 'email', 'label': 'Email'},
    {'value': 'off', 'label': 'Off'},
  ];

  // Reseller Placeholders
  final resellerPlaceholders = [
    {'placeholder': '{bonus_amount}', 'description': 'Bonus amount earned'},
    {'placeholder': '{order_number}', 'description': 'Related order number'},
    {'placeholder': '{reseller_level}', 'description': 'Current reseller level'},
    {'placeholder': '{new_level}', 'description': 'Newly achieved level'},
    {'placeholder': '{total_spent}', 'description': 'Total amount spent to date'},
    {'placeholder': '{level_benefits}', 'description': 'Benefits of current level'},
  ];

  // Referral Placeholders
  final referralPlaceholders = [
    {'placeholder': '{earnings_amount}', 'description': 'Referral earnings amount'},
    {'placeholder': '{referred_user_name}', 'description': 'Name of referred user'},
    {'placeholder': '{referral_percentage}', 'description': 'Referral earning percentage'},
    {'placeholder': '{total_referrals}', 'description': 'Total number of referrals'},
    {'placeholder': '{total_referral_earnings}', 'description': 'Total earnings from referrals'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    bonusEarnedNotificationTextController.dispose();
    bonusEarnedEmailSubjectController.dispose();
    bonusEarnedEmailBodyController.dispose();
    referralEarningsNotificationTextController.dispose();
    referralEarningsEmailSubjectController.dispose();
    referralEarningsEmailBodyController.dispose();
    levelUpgradeNotificationTextController.dispose();
    levelUpgradeEmailSubjectController.dispose();
    levelUpgradeEmailBodyController.dispose();
    super.onClose();
  }

  /// Fetch settings from server
  Future<void> fetchSettings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await ResellerReferralNotificationsService.fetchSettings();

      if (response.success && response.settings != null) {
        final settings = response.settings!;

        // Reseller Bonus Earned
        bonusEarnedNotificationTextController.text = settings.bonusEarnedNotificationText;
        bonusEarnedEmailSubjectController.text = settings.bonusEarnedEmailSubject;
        bonusEarnedEmailBodyController.text = settings.bonusEarnedEmailBody;
        bonusEarnedSendBy.value = settings.bonusEarnedSendBy;

        // Referral Earnings
        referralEarningsNotificationTextController.text = settings.referralEarningsNotificationText;
        referralEarningsEmailSubjectController.text = settings.referralEarningsEmailSubject;
        referralEarningsEmailBodyController.text = settings.referralEarningsEmailBody;
        referralEarningsSendBy.value = settings.referralEarningsSendBy;

        // Level Upgrade
        levelUpgradeNotificationTextController.text = settings.levelUpgradeNotificationText;
        levelUpgradeEmailSubjectController.text = settings.levelUpgradeEmailSubject;
        levelUpgradeEmailBodyController.text = settings.levelUpgradeEmailBody;
        levelUpgradeSendBy.value = settings.levelUpgradeSendBy;
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
    bonusEarnedSendBy.value = 'sms';
    referralEarningsSendBy.value = 'sms';
    levelUpgradeSendBy.value = 'sms';
  }

  /// Enable all Email notifications
  void enableAllEmail() {
    bonusEarnedSendBy.value = 'email';
    referralEarningsSendBy.value = 'email';
    levelUpgradeSendBy.value = 'email';
  }

  /// Disable all notifications
  void disableAllNotifications() {
    bonusEarnedSendBy.value = 'off';
    referralEarningsSendBy.value = 'off';
    levelUpgradeSendBy.value = 'off';
  }

  /// Save settings
  Future<bool> saveSettings() async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final settings = ResellerReferralSettings(
        // Reseller Bonus Earned
        bonusEarnedNotificationText: bonusEarnedNotificationTextController.text.trim(),
        bonusEarnedEmailSubject: bonusEarnedEmailSubjectController.text.trim(),
        bonusEarnedEmailBody: bonusEarnedEmailBodyController.text.trim(),
        bonusEarnedSendBy: bonusEarnedSendBy.value,

        // Referral Earnings
        referralEarningsNotificationText: referralEarningsNotificationTextController.text.trim(),
        referralEarningsEmailSubject: referralEarningsEmailSubjectController.text.trim(),
        referralEarningsEmailBody: referralEarningsEmailBodyController.text.trim(),
        referralEarningsSendBy: referralEarningsSendBy.value,

        // Level Upgrade
        levelUpgradeNotificationText: levelUpgradeNotificationTextController.text.trim(),
        levelUpgradeEmailSubject: levelUpgradeEmailSubjectController.text.trim(),
        levelUpgradeEmailBody: levelUpgradeEmailBodyController.text.trim(),
        levelUpgradeSendBy: levelUpgradeSendBy.value,
      );

      final response = await ResellerReferralNotificationsService.updateSettings(
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
