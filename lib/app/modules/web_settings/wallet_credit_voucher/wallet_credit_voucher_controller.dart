import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/wallet_credit_voucher/wallet_credit_voucher_service.dart';

class WalletCreditVoucherController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isSearchingCoupons = false.obs;

  // Error message
  var errorMessage = Rxn<String>();

  // Settings
  var isEnabled = false.obs;
  var selectedCoupons = <SelectedCoupon>[].obs; // Selected coupons with names
  var notificationSendBy = 'off'.obs; // 'sms', 'email', 'off'

  // Text controllers
  final notificationTextController = TextEditingController();
  final emailSubjectController = TextEditingController();
  final emailBodyController = TextEditingController();

  // Search results
  var couponSearchResults = <CouponItem>[].obs;

  // Debounce timer
  Timer? _couponSearchTimer;

  // Notification type options
  final notificationOptions = [
    {'value': 'sms', 'label': 'SMS'},
    {'value': 'email', 'label': 'Email'},
    {'value': 'off', 'label': 'Off'},
  ];

  // Placeholders for info card
  final placeholders = [
    {'placeholder': '{coupon_code}', 'description': 'Applied voucher code'},
    {'placeholder': '{buyer_name}', 'description': 'Customer name'},
    {'placeholder': '{coupon_name}', 'description': 'Voucher name'},
    {'placeholder': '{{discount_amount}}', 'description': 'Discount amount'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    notificationTextController.dispose();
    emailSubjectController.dispose();
    emailBodyController.dispose();
    _couponSearchTimer?.cancel();
    super.onClose();
  }

  /// Fetch settings from server
  Future<void> fetchSettings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await WalletCreditVoucherService.fetchSettings();

      if (response.success && response.settings != null) {
        final settings = response.settings!;
        isEnabled.value = settings.enabled;
        notificationTextController.text = settings.notificationText;
        emailSubjectController.text = settings.emailSubject;
        emailBodyController.text = settings.emailBody;
        notificationSendBy.value = settings.notificationSendBy;

        // Load coupon names for selected IDs
        if (settings.couponIds.isNotEmpty) {
          await _loadSelectedCoupons(settings.couponIds);
        }
      } else {
        errorMessage.value = response.error;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load coupon details for selected IDs
  Future<void> _loadSelectedCoupons(List<String> ids) async {
    final coupons = <SelectedCoupon>[];

    // Fetch all coupons to find the ones we have selected
    final allCoupons = await WalletCreditVoucherService.searchCoupons();

    for (final id in ids) {
      final coupon = allCoupons.firstWhereOrNull((c) => c.id == id);
      if (coupon != null) {
        coupons.add(SelectedCoupon(
          id: coupon.id,
          name: coupon.name,
          displayName: coupon.displayName,
        ));
      } else {
        // Coupon not found in search, try to fetch by ID
        final fetched = await WalletCreditVoucherService.fetchCouponById(id);
        if (fetched != null) {
          coupons.add(SelectedCoupon(
            id: fetched.id,
            name: fetched.name,
            displayName: fetched.displayName,
          ));
        } else {
          // Keep the ID even if we can't find the name
          coupons.add(SelectedCoupon(
            id: id,
            name: 'Coupon #$id',
            displayName: 'Coupon #$id',
          ));
        }
      }
    }

    selectedCoupons.value = coupons;
  }

  /// Search coupons with debounce
  void searchCoupons(String query) {
    _couponSearchTimer?.cancel();
    _couponSearchTimer = Timer(const Duration(milliseconds: 300), () async {
      isSearchingCoupons.value = true;
      try {
        final results = await WalletCreditVoucherService.searchCoupons(
          search: query.isEmpty ? null : query,
        );
        couponSearchResults.value = results;
      } catch (e) {
        couponSearchResults.value = [];
      } finally {
        isSearchingCoupons.value = false;
      }
    });
  }

  /// Add coupon to selection
  void addCoupon(CouponItem coupon) {
    // Check if already selected
    if (selectedCoupons.any((c) => c.id == coupon.id)) {
      return;
    }

    selectedCoupons.add(SelectedCoupon(
      id: coupon.id,
      name: coupon.name,
      displayName: coupon.displayName,
    ));
  }

  /// Remove coupon from selection
  void removeCoupon(String id) {
    selectedCoupons.removeWhere((c) => c.id == id);
  }

  /// Check if coupon is selected
  bool isCouponSelected(String id) {
    return selectedCoupons.any((c) => c.id == id);
  }

  /// Save settings
  Future<bool> saveSettings() async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final settings = WalletCreditVoucherSettings(
        enabled: isEnabled.value,
        couponIds: selectedCoupons.map((c) => c.id).toList(),
        notificationText: notificationTextController.text.trim(),
        emailSubject: emailSubjectController.text.trim(),
        emailBody: emailBodyController.text.trim(),
        notificationSendBy: notificationSendBy.value,
      );

      final response = await WalletCreditVoucherService.updateSettings(
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

/// Model for selected coupon
class SelectedCoupon {
  final String id;
  final String name;
  final String displayName;

  SelectedCoupon({
    required this.id,
    required this.name,
    required this.displayName,
  });
}
