import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/order_discount_coupon/order_discount_coupon_service.dart';

class OrderDiscountCouponController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isSearchingCoupons = false.obs;

  // Error message
  var errorMessage = Rxn<String>();

  // Settings
  var isEnabled = false.obs;
  var targetOrderStatus = 'delivered'.obs;
  var selectedCoupons = <SelectedCoupon>[].obs;
  var notificationSendBy = 'off'.obs;

  // Text controllers
  final sendingDelayController = TextEditingController();
  final notificationTextController = TextEditingController();
  final emailSubjectController = TextEditingController();
  final emailBodyController = TextEditingController();

  // Search results
  var couponSearchResults = <CouponItem>[].obs;

  // Debounce timer
  Timer? _couponSearchTimer;

  // Order status options
  final orderStatusOptions = [
    {'value': 'on_hold', 'label': 'On Hold'},
    {'value': 'awaiting_payment', 'label': 'Awaiting Payment'},
    {'value': 'cancelled', 'label': 'Cancelled'},
    {'value': 'refunded', 'label': 'Refunded'},
    {'value': 'processing', 'label': 'Processing'},
    {'value': 'awaiting_fulfillment', 'label': 'Awaiting Fulfillment'},
    {'value': 'awaiting_pickup', 'label': 'Awaiting Pickup'},
    {'value': 'shipping', 'label': 'Shipping'},
    {'value': 'delivered', 'label': 'Delivered'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'returned', 'label': 'Returned'},
    {'value': 'reshipping', 'label': 'Reshipping'},
    {'value': 'reshipped', 'label': 'Reshipped'},
    {'value': 'failed', 'label': 'Failed'},
  ];

  // Notification type options
  final notificationOptions = [
    {'value': 'sms', 'label': 'SMS'},
    {'value': 'email', 'label': 'Email'},
    {'value': 'off', 'label': 'Off'},
  ];

  // Placeholders for info card
  final placeholders = [
    {'placeholder': '{coupon_code}', 'description': 'Applied coupon code'},
    {'placeholder': '{buyer_name}', 'description': 'Customer name'},
    {'placeholder': '{coupon_name}', 'description': 'Coupon name'},
    {'placeholder': '{{discount_amount}}', 'description': 'Discount amount'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    sendingDelayController.dispose();
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
      final response = await OrderDiscountCouponService.fetchSettings();

      if (response.success && response.settings != null) {
        final settings = response.settings!;
        isEnabled.value = settings.enabled;
        targetOrderStatus.value = settings.targetOrderStatus;
        sendingDelayController.text = settings.sendingDelay;
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
    final allCoupons = await OrderDiscountCouponService.searchCoupons();

    for (final id in ids) {
      final coupon = allCoupons.firstWhereOrNull((c) => c.id == id);
      if (coupon != null) {
        coupons.add(SelectedCoupon(
          id: coupon.id,
          name: coupon.name,
          displayName: coupon.displayName,
        ));
      } else {
        coupons.add(SelectedCoupon(
          id: id,
          name: 'Coupon #$id',
          displayName: 'Coupon #$id',
        ));
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
        final results = await OrderDiscountCouponService.searchCoupons(
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

  /// Get order status label
  String getOrderStatusLabel(String value) {
    final option = orderStatusOptions.firstWhereOrNull((o) => o['value'] == value);
    return option?['label'] ?? value;
  }

  /// Save settings
  Future<bool> saveSettings() async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final settings = OrderDiscountCouponSettings(
        enabled: isEnabled.value,
        targetOrderStatus: targetOrderStatus.value,
        couponIds: selectedCoupons.map((c) => c.id).toList(),
        sendingDelay: sendingDelayController.text.trim(),
        notificationText: notificationTextController.text.trim(),
        emailSubject: emailSubjectController.text.trim(),
        emailBody: emailBodyController.text.trim(),
        notificationSendBy: notificationSendBy.value,
      );

      final response = await OrderDiscountCouponService.updateSettings(
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
