import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/order_notifications/order_notifications_service.dart';

class OrderNotificationsController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;

  // Error message
  var errorMessage = Rxn<String>();

  // ============================================
  // Order Received - Customer
  // ============================================
  final orderReceivedCustomerNotificationController = TextEditingController();
  var orderReceivedCustomerSendBy = 'off'.obs;

  // ============================================
  // Order Received - Vendor
  // ============================================
  final orderReceivedVendorNotificationController = TextEditingController();
  var orderReceivedVendorSendBy = 'off'.obs;

  // ============================================
  // Order Received - Admin
  // ============================================
  final orderReceivedAdminNotificationController = TextEditingController();
  var orderReceivedAdminSendBy = 'off'.obs;

  // ============================================
  // Order Reactivated - Customer
  // ============================================
  final orderReactivatedCustomerNotificationController = TextEditingController();
  var orderReactivatedCustomerSendBy = 'off'.obs;

  // ============================================
  // Order Cancelled with Cart - Customer
  // ============================================
  final orderCancelledCartCustomerNotificationController = TextEditingController();
  var orderCancelledCartCustomerSendBy = 'off'.obs;

  // ============================================
  // Order Cancelled - Customer
  // ============================================
  final orderCancelledCustomerNotificationController = TextEditingController();
  var orderCancelledCustomerSendBy = 'off'.obs;

  // ============================================
  // Order Completed - Customer
  // ============================================
  final orderCompletedCustomerNotificationController = TextEditingController();
  var orderCompletedCustomerSendBy = 'off'.obs;

  // ============================================
  // Order Updated - Customer
  // ============================================
  final orderUpdatedCustomerNotificationController = TextEditingController();
  var orderUpdatedCustomerSendBy = 'off'.obs;

  // ============================================
  // Order Processing - Customer
  // ============================================
  final orderProcessingCustomerNotificationController = TextEditingController();
  var orderProcessingCustomerSendBy = 'off'.obs;

  // ============================================
  // Order Shipping - Customer
  // ============================================
  final orderShippingCustomerNotificationController = TextEditingController();
  var orderShippingCustomerSendBy = 'off'.obs;

  // ============================================
  // Shipping Fee Increased - Customer
  // ============================================
  final shippingFeeIncreasedCustomerNotificationController = TextEditingController();
  var shippingFeeIncreasedCustomerSendBy = 'off'.obs;

  // ============================================
  // Shipping Fee Decreased - Customer
  // ============================================
  final shippingFeeDecreasedCustomerNotificationController = TextEditingController();
  var shippingFeeDecreasedCustomerSendBy = 'off'.obs;

  // ============================================
  // Wallet Credit Added - Customer
  // ============================================
  final walletCreditAddedCustomerNotificationController = TextEditingController();
  var walletCreditAddedCustomerSendBy = 'off'.obs;

  // ============================================
  // Wallet Payment Refunded - Customer
  // ============================================
  final walletPaymentRefundedCustomerNotificationController = TextEditingController();
  var walletPaymentRefundedCustomerSendBy = 'off'.obs;

  // ============================================
  // Wallet Payment Reapplied - Customer
  // ============================================
  final walletPaymentReappliedCustomerNotificationController = TextEditingController();
  var walletPaymentReappliedCustomerSendBy = 'off'.obs;

  // ============================================
  // Item Removed - Customer
  // ============================================
  final orderItemRemovedCustomerNotificationController = TextEditingController();
  var orderItemRemovedCustomerSendBy = 'off'.obs;

  // ============================================
  // Items Added to Cart
  // ============================================
  final itemsAddedToCartNotificationController = TextEditingController();
  var itemsAddedToCartSendBy = 'off'.obs;

  // Notification type options
  final notificationOptions = [
    {'value': 'sms', 'label': 'SMS'},
    {'value': 'email', 'label': 'Email'},
    {'value': 'off', 'label': 'Off'},
  ];

  // All send_by observables for quick actions
  List<RxString> get allSendByValues => [
    orderReceivedCustomerSendBy,
    orderReceivedVendorSendBy,
    orderReceivedAdminSendBy,
    orderReactivatedCustomerSendBy,
    orderCancelledCartCustomerSendBy,
    orderCancelledCustomerSendBy,
    orderCompletedCustomerSendBy,
    orderUpdatedCustomerSendBy,
    orderProcessingCustomerSendBy,
    orderShippingCustomerSendBy,
    shippingFeeIncreasedCustomerSendBy,
    shippingFeeDecreasedCustomerSendBy,
    walletCreditAddedCustomerSendBy,
    walletPaymentRefundedCustomerSendBy,
    walletPaymentReappliedCustomerSendBy,
    orderItemRemovedCustomerSendBy,
    itemsAddedToCartSendBy,
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    orderReceivedCustomerNotificationController.dispose();
    orderReceivedVendorNotificationController.dispose();
    orderReceivedAdminNotificationController.dispose();
    orderReactivatedCustomerNotificationController.dispose();
    orderCancelledCartCustomerNotificationController.dispose();
    orderCancelledCustomerNotificationController.dispose();
    orderCompletedCustomerNotificationController.dispose();
    orderUpdatedCustomerNotificationController.dispose();
    orderProcessingCustomerNotificationController.dispose();
    orderShippingCustomerNotificationController.dispose();
    shippingFeeIncreasedCustomerNotificationController.dispose();
    shippingFeeDecreasedCustomerNotificationController.dispose();
    walletCreditAddedCustomerNotificationController.dispose();
    walletPaymentRefundedCustomerNotificationController.dispose();
    walletPaymentReappliedCustomerNotificationController.dispose();
    orderItemRemovedCustomerNotificationController.dispose();
    itemsAddedToCartNotificationController.dispose();
    super.onClose();
  }

  /// Fetch settings from server
  Future<void> fetchSettings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await OrderNotificationsService.fetchSettings();

      if (response.success && response.settings != null) {
        final s = response.settings!;

        // Order Received - Customer
        orderReceivedCustomerNotificationController.text = s.orderReceivedCustomerNotification;
        orderReceivedCustomerSendBy.value = s.orderReceivedCustomerSendBy;

        // Order Received - Vendor
        orderReceivedVendorNotificationController.text = s.orderReceivedVendorNotification;
        orderReceivedVendorSendBy.value = s.orderReceivedVendorSendBy;

        // Order Received - Admin
        orderReceivedAdminNotificationController.text = s.orderReceivedAdminNotification;
        orderReceivedAdminSendBy.value = s.orderReceivedAdminSendBy;

        // Order Reactivated - Customer
        orderReactivatedCustomerNotificationController.text = s.orderReactivatedCustomerNotification;
        orderReactivatedCustomerSendBy.value = s.orderReactivatedCustomerSendBy;

        // Order Cancelled with Cart - Customer
        orderCancelledCartCustomerNotificationController.text = s.orderCancelledCartCustomerNotification;
        orderCancelledCartCustomerSendBy.value = s.orderCancelledCartCustomerSendBy;

        // Order Cancelled - Customer
        orderCancelledCustomerNotificationController.text = s.orderCancelledCustomerNotification;
        orderCancelledCustomerSendBy.value = s.orderCancelledCustomerSendBy;

        // Order Completed - Customer
        orderCompletedCustomerNotificationController.text = s.orderCompletedCustomerNotification;
        orderCompletedCustomerSendBy.value = s.orderCompletedCustomerSendBy;

        // Order Updated - Customer
        orderUpdatedCustomerNotificationController.text = s.orderUpdatedCustomerNotification;
        orderUpdatedCustomerSendBy.value = s.orderUpdatedCustomerSendBy;

        // Order Processing - Customer
        orderProcessingCustomerNotificationController.text = s.orderProcessingCustomerNotification;
        orderProcessingCustomerSendBy.value = s.orderProcessingCustomerSendBy;

        // Order Shipping - Customer
        orderShippingCustomerNotificationController.text = s.orderShippingCustomerNotification;
        orderShippingCustomerSendBy.value = s.orderShippingCustomerSendBy;

        // Shipping Fee Increased - Customer
        shippingFeeIncreasedCustomerNotificationController.text = s.shippingFeeIncreasedCustomerNotification;
        shippingFeeIncreasedCustomerSendBy.value = s.shippingFeeIncreasedCustomerSendBy;

        // Shipping Fee Decreased - Customer
        shippingFeeDecreasedCustomerNotificationController.text = s.shippingFeeDecreasedCustomerNotification;
        shippingFeeDecreasedCustomerSendBy.value = s.shippingFeeDecreasedCustomerSendBy;

        // Wallet Credit Added - Customer
        walletCreditAddedCustomerNotificationController.text = s.walletCreditAddedCustomerNotification;
        walletCreditAddedCustomerSendBy.value = s.walletCreditAddedCustomerSendBy;

        // Wallet Payment Refunded - Customer
        walletPaymentRefundedCustomerNotificationController.text = s.walletPaymentRefundedCustomerNotification;
        walletPaymentRefundedCustomerSendBy.value = s.walletPaymentRefundedCustomerSendBy;

        // Wallet Payment Reapplied - Customer
        walletPaymentReappliedCustomerNotificationController.text = s.walletPaymentReappliedCustomerNotification;
        walletPaymentReappliedCustomerSendBy.value = s.walletPaymentReappliedCustomerSendBy;

        // Item Removed - Customer
        orderItemRemovedCustomerNotificationController.text = s.orderItemRemovedCustomerNotification;
        orderItemRemovedCustomerSendBy.value = s.orderItemRemovedCustomerSendBy;

        // Items Added to Cart
        itemsAddedToCartNotificationController.text = s.itemsAddedToCartNotification;
        itemsAddedToCartSendBy.value = s.itemsAddedToCartSendBy;
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
    for (final sendBy in allSendByValues) {
      sendBy.value = 'sms';
    }
  }

  /// Enable all Email notifications
  void enableAllEmail() {
    for (final sendBy in allSendByValues) {
      sendBy.value = 'email';
    }
  }

  /// Disable all notifications
  void disableAllNotifications() {
    for (final sendBy in allSendByValues) {
      sendBy.value = 'off';
    }
  }

  /// Save settings
  Future<bool> saveSettings() async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final settings = OrderNotificationsSettings(
        // Order Received - Customer
        orderReceivedCustomerNotification: orderReceivedCustomerNotificationController.text.trim(),
        orderReceivedCustomerSms: '', // SMS text is same as notification
        orderReceivedCustomerSendBy: orderReceivedCustomerSendBy.value,

        // Order Received - Vendor
        orderReceivedVendorNotification: orderReceivedVendorNotificationController.text.trim(),
        orderReceivedVendorSms: '',
        orderReceivedVendorSendBy: orderReceivedVendorSendBy.value,

        // Order Received - Admin
        orderReceivedAdminNotification: orderReceivedAdminNotificationController.text.trim(),
        orderReceivedAdminSms: '',
        orderReceivedAdminSendBy: orderReceivedAdminSendBy.value,

        // Order Reactivated - Customer
        orderReactivatedCustomerNotification: orderReactivatedCustomerNotificationController.text.trim(),
        orderReactivatedCustomerSms: '',
        orderReactivatedCustomerSendBy: orderReactivatedCustomerSendBy.value,

        // Order Cancelled with Cart - Customer
        orderCancelledCartCustomerNotification: orderCancelledCartCustomerNotificationController.text.trim(),
        orderCancelledCartCustomerSms: '',
        orderCancelledCartCustomerSendBy: orderCancelledCartCustomerSendBy.value,

        // Order Cancelled - Customer
        orderCancelledCustomerNotification: orderCancelledCustomerNotificationController.text.trim(),
        orderCancelledCustomerSms: '',
        orderCancelledCustomerSendBy: orderCancelledCustomerSendBy.value,

        // Order Completed - Customer
        orderCompletedCustomerNotification: orderCompletedCustomerNotificationController.text.trim(),
        orderCompletedCustomerSms: '',
        orderCompletedCustomerSendBy: orderCompletedCustomerSendBy.value,

        // Order Updated - Customer
        orderUpdatedCustomerNotification: orderUpdatedCustomerNotificationController.text.trim(),
        orderUpdatedCustomerSms: '',
        orderUpdatedCustomerSendBy: orderUpdatedCustomerSendBy.value,

        // Order Processing - Customer
        orderProcessingCustomerNotification: orderProcessingCustomerNotificationController.text.trim(),
        orderProcessingCustomerSms: '',
        orderProcessingCustomerSendBy: orderProcessingCustomerSendBy.value,

        // Order Shipping - Customer
        orderShippingCustomerNotification: orderShippingCustomerNotificationController.text.trim(),
        orderShippingCustomerSendBy: orderShippingCustomerSendBy.value,

        // Shipping Fee Increased - Customer
        shippingFeeIncreasedCustomerNotification: shippingFeeIncreasedCustomerNotificationController.text.trim(),
        shippingFeeIncreasedCustomerSms: '',
        shippingFeeIncreasedCustomerSendBy: shippingFeeIncreasedCustomerSendBy.value,

        // Shipping Fee Decreased - Customer
        shippingFeeDecreasedCustomerNotification: shippingFeeDecreasedCustomerNotificationController.text.trim(),
        shippingFeeDecreasedCustomerSms: '',
        shippingFeeDecreasedCustomerSendBy: shippingFeeDecreasedCustomerSendBy.value,

        // Wallet Credit Added - Customer
        walletCreditAddedCustomerNotification: walletCreditAddedCustomerNotificationController.text.trim(),
        walletCreditAddedCustomerSms: '',
        walletCreditAddedCustomerSendBy: walletCreditAddedCustomerSendBy.value,

        // Wallet Payment Refunded - Customer
        walletPaymentRefundedCustomerNotification: walletPaymentRefundedCustomerNotificationController.text.trim(),
        walletPaymentRefundedCustomerSms: '',
        walletPaymentRefundedCustomerSendBy: walletPaymentRefundedCustomerSendBy.value,

        // Wallet Payment Reapplied - Customer
        walletPaymentReappliedCustomerNotification: walletPaymentReappliedCustomerNotificationController.text.trim(),
        walletPaymentReappliedCustomerSms: '',
        walletPaymentReappliedCustomerSendBy: walletPaymentReappliedCustomerSendBy.value,

        // Item Removed - Customer
        orderItemRemovedCustomerNotification: orderItemRemovedCustomerNotificationController.text.trim(),
        orderItemRemovedCustomerSms: '',
        orderItemRemovedCustomerSendBy: orderItemRemovedCustomerSendBy.value,

        // Items Added to Cart
        itemsAddedToCartNotification: itemsAddedToCartNotificationController.text.trim(),
        itemsAddedToCartSendBy: itemsAddedToCartSendBy.value,
      );

      final response = await OrderNotificationsService.updateSettings(
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
