import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderNotificationsService {
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
          settings: OrderNotificationsSettings.fromJson(options),
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

/// Order Notifications Settings - Contains all notification groups
class OrderNotificationsSettings {
  // Order Received - Customer
  final String orderReceivedCustomerNotification;
  final String orderReceivedCustomerSms;
  final String orderReceivedCustomerSendBy;

  // Order Received - Vendor
  final String orderReceivedVendorNotification;
  final String orderReceivedVendorSms;
  final String orderReceivedVendorSendBy;

  // Order Received - Admin
  final String orderReceivedAdminNotification;
  final String orderReceivedAdminSms;
  final String orderReceivedAdminSendBy;

  // Order Reactivated - Customer
  final String orderReactivatedCustomerNotification;
  final String orderReactivatedCustomerSms;
  final String orderReactivatedCustomerSendBy;

  // Order Cancelled with Cart - Customer
  final String orderCancelledCartCustomerNotification;
  final String orderCancelledCartCustomerSms;
  final String orderCancelledCartCustomerSendBy;

  // Order Cancelled - Customer
  final String orderCancelledCustomerNotification;
  final String orderCancelledCustomerSms;
  final String orderCancelledCustomerSendBy;

  // Order Completed - Customer
  final String orderCompletedCustomerNotification;
  final String orderCompletedCustomerSms;
  final String orderCompletedCustomerSendBy;

  // Order Updated - Customer
  final String orderUpdatedCustomerNotification;
  final String orderUpdatedCustomerSms;
  final String orderUpdatedCustomerSendBy;

  // Order Processing - Customer
  final String orderProcessingCustomerNotification;
  final String orderProcessingCustomerSms;
  final String orderProcessingCustomerSendBy;

  // Order Shipping - Customer
  final String orderShippingCustomerNotification;
  final String orderShippingCustomerSendBy;

  // Shipping Fee Increased - Customer
  final String shippingFeeIncreasedCustomerNotification;
  final String shippingFeeIncreasedCustomerSms;
  final String shippingFeeIncreasedCustomerSendBy;

  // Shipping Fee Decreased - Customer
  final String shippingFeeDecreasedCustomerNotification;
  final String shippingFeeDecreasedCustomerSms;
  final String shippingFeeDecreasedCustomerSendBy;

  // Wallet Credit Added - Customer
  final String walletCreditAddedCustomerNotification;
  final String walletCreditAddedCustomerSms;
  final String walletCreditAddedCustomerSendBy;

  // Wallet Payment Refunded - Customer
  final String walletPaymentRefundedCustomerNotification;
  final String walletPaymentRefundedCustomerSms;
  final String walletPaymentRefundedCustomerSendBy;

  // Wallet Payment Reapplied - Customer
  final String walletPaymentReappliedCustomerNotification;
  final String walletPaymentReappliedCustomerSms;
  final String walletPaymentReappliedCustomerSendBy;

  // Item Removed - Customer
  final String orderItemRemovedCustomerNotification;
  final String orderItemRemovedCustomerSms;
  final String orderItemRemovedCustomerSendBy;

  // Items Added to Cart
  final String itemsAddedToCartNotification;
  final String itemsAddedToCartSendBy;

  OrderNotificationsSettings({
    required this.orderReceivedCustomerNotification,
    required this.orderReceivedCustomerSms,
    required this.orderReceivedCustomerSendBy,
    required this.orderReceivedVendorNotification,
    required this.orderReceivedVendorSms,
    required this.orderReceivedVendorSendBy,
    required this.orderReceivedAdminNotification,
    required this.orderReceivedAdminSms,
    required this.orderReceivedAdminSendBy,
    required this.orderReactivatedCustomerNotification,
    required this.orderReactivatedCustomerSms,
    required this.orderReactivatedCustomerSendBy,
    required this.orderCancelledCartCustomerNotification,
    required this.orderCancelledCartCustomerSms,
    required this.orderCancelledCartCustomerSendBy,
    required this.orderCancelledCustomerNotification,
    required this.orderCancelledCustomerSms,
    required this.orderCancelledCustomerSendBy,
    required this.orderCompletedCustomerNotification,
    required this.orderCompletedCustomerSms,
    required this.orderCompletedCustomerSendBy,
    required this.orderUpdatedCustomerNotification,
    required this.orderUpdatedCustomerSms,
    required this.orderUpdatedCustomerSendBy,
    required this.orderProcessingCustomerNotification,
    required this.orderProcessingCustomerSms,
    required this.orderProcessingCustomerSendBy,
    required this.orderShippingCustomerNotification,
    required this.orderShippingCustomerSendBy,
    required this.shippingFeeIncreasedCustomerNotification,
    required this.shippingFeeIncreasedCustomerSms,
    required this.shippingFeeIncreasedCustomerSendBy,
    required this.shippingFeeDecreasedCustomerNotification,
    required this.shippingFeeDecreasedCustomerSms,
    required this.shippingFeeDecreasedCustomerSendBy,
    required this.walletCreditAddedCustomerNotification,
    required this.walletCreditAddedCustomerSms,
    required this.walletCreditAddedCustomerSendBy,
    required this.walletPaymentRefundedCustomerNotification,
    required this.walletPaymentRefundedCustomerSms,
    required this.walletPaymentRefundedCustomerSendBy,
    required this.walletPaymentReappliedCustomerNotification,
    required this.walletPaymentReappliedCustomerSms,
    required this.walletPaymentReappliedCustomerSendBy,
    required this.orderItemRemovedCustomerNotification,
    required this.orderItemRemovedCustomerSms,
    required this.orderItemRemovedCustomerSendBy,
    required this.itemsAddedToCartNotification,
    required this.itemsAddedToCartSendBy,
  });

  factory OrderNotificationsSettings.fromJson(Map<String, dynamic> json) {
    return OrderNotificationsSettings(
      // Order Received - Customer
      orderReceivedCustomerNotification:
          json['order_received_customer_notification_text']?.toString() ??
          json['order_received_customer_notification']?.toString() ??
          '',
      orderReceivedCustomerSms:
          json['order_received_customer_sms']?.toString() ?? '',
      orderReceivedCustomerSendBy:
          json['order_received_customer_notification_send_by']?.toString() ??
          'off',

      // Order Received - Vendor
      orderReceivedVendorNotification:
          json['order_received_vendor_notification_text']?.toString() ??
          json['order_received_vendor_notification']?.toString() ??
          '',
      orderReceivedVendorSms:
          json['order_received_vendor_sms']?.toString() ?? '',
      orderReceivedVendorSendBy:
          json['order_received_vendor_notification_send_by']?.toString() ??
          'off',

      // Order Received - Admin
      orderReceivedAdminNotification:
          json['order_received_admin_notification_text']?.toString() ?? '',
      orderReceivedAdminSms: json['order_received_admin_sms']?.toString() ?? '',
      orderReceivedAdminSendBy:
          json['order_received_admin_notification_send_by']?.toString() ??
          'off',

      // Order Reactivated - Customer
      orderReactivatedCustomerNotification:
          json['order_reactivated_customer_notification_text']?.toString() ??
          '',
      orderReactivatedCustomerSms:
          json['order_reactivated_customer_sms']?.toString() ?? '',
      orderReactivatedCustomerSendBy:
          json['order_reactivated_customer_notification_send_by']?.toString() ??
          'off',

      // Order Cancelled with Cart - Customer
      orderCancelledCartCustomerNotification:
          json['order_cancelled_cart_customer_notification_text']?.toString() ??
          '',
      orderCancelledCartCustomerSms:
          json['order_cancelled_cart_customer_sms']?.toString() ?? '',
      orderCancelledCartCustomerSendBy:
          json['order_cancelled_cart_customer_notification_send_by']
              ?.toString() ??
          'off',

      // Order Cancelled - Customer
      orderCancelledCustomerNotification:
          json['order_cancelled_customer_notification_text']?.toString() ?? '',
      orderCancelledCustomerSms:
          json['order_cancelled_customer_sms']?.toString() ?? '',
      orderCancelledCustomerSendBy:
          json['order_cancelled_customer_notification_send_by']?.toString() ??
          'off',

      // Order Completed - Customer
      orderCompletedCustomerNotification:
          json['order_completed_customer_notification_text']?.toString() ?? '',
      orderCompletedCustomerSms:
          json['order_completed_customer_sms']?.toString() ?? '',
      orderCompletedCustomerSendBy:
          json['order_completed_customer_notification_send_by']?.toString() ??
          'off',

      // Order Updated - Customer
      orderUpdatedCustomerNotification:
          json['order_updated_customer_notification_text']?.toString() ?? '',
      orderUpdatedCustomerSms:
          json['order_updated_customer_sms']?.toString() ?? '',
      orderUpdatedCustomerSendBy:
          json['order_updated_customer_notification_send_by']?.toString() ??
          'off',

      // Order Processing - Customer
      orderProcessingCustomerNotification:
          json['order_processing_customer_notification_text']?.toString() ??
          json['order_processing_customer_notification']?.toString() ??
          '',
      orderProcessingCustomerSms:
          json['order_processing_customer_sms']?.toString() ?? '',
      orderProcessingCustomerSendBy:
          json['order_processing_customer_notification_send_by']?.toString() ??
          'off',

      // Order Shipping - Customer
      orderShippingCustomerNotification:
          json['order_shipping_customer_notification_text']?.toString() ?? '',
      orderShippingCustomerSendBy:
          json['order_shipping_customer_notification_send_by']?.toString() ??
          'off',

      // Shipping Fee Increased - Customer
      shippingFeeIncreasedCustomerNotification:
          json['shipping_fee_increased_customer_notification_text']
              ?.toString() ??
          '',
      shippingFeeIncreasedCustomerSms:
          json['shipping_fee_increased_customer_sms']?.toString() ?? '',
      shippingFeeIncreasedCustomerSendBy:
          json['shipping_fee_increased_customer_notification_send_by']
              ?.toString() ??
          'off',

      // Shipping Fee Decreased - Customer
      shippingFeeDecreasedCustomerNotification:
          json['shipping_fee_decreased_customer_notification_text']
              ?.toString() ??
          '',
      shippingFeeDecreasedCustomerSms:
          json['shipping_fee_decreased_customer_sms']?.toString() ?? '',
      shippingFeeDecreasedCustomerSendBy:
          json['shipping_fee_decreased_customer_notification_send_by']
              ?.toString() ??
          'off',

      // Wallet Credit Added - Customer
      walletCreditAddedCustomerNotification:
          json['wallet_credit_added_customer_notification_text']?.toString() ??
          json['wallet_credit_added_notification']?.toString() ??
          '',
      walletCreditAddedCustomerSms:
          json['wallet_credit_added_customer_sms']?.toString() ?? '',
      walletCreditAddedCustomerSendBy:
          json['wallet_credit_added_customer_notification_send_by']
              ?.toString() ??
          'off',

      // Wallet Payment Refunded - Customer
      walletPaymentRefundedCustomerNotification:
          json['wallet_payment_refunded_customer_notification_text']
              ?.toString() ??
          json['wallet_payment_refunded_notification']?.toString() ??
          '',
      walletPaymentRefundedCustomerSms:
          json['wallet_payment_refunded_customer_sms']?.toString() ?? '',
      walletPaymentRefundedCustomerSendBy:
          json['wallet_payment_refunded_customer_notification_send_by']
              ?.toString() ??
          'off',

      // Wallet Payment Reapplied - Customer
      walletPaymentReappliedCustomerNotification:
          json['wallet_payment_reapplied_customer_notification_text']
              ?.toString() ??
          json['wallet_payment_reapplied_notification']?.toString() ??
          '',
      walletPaymentReappliedCustomerSms:
          json['wallet_payment_reapplied_customer_sms']?.toString() ?? '',
      walletPaymentReappliedCustomerSendBy:
          json['wallet_payment_reapplied_customer_notification_send_by']
              ?.toString() ??
          'off',

      // Item Removed - Customer
      orderItemRemovedCustomerNotification:
          json['order_item_removed_customer_notification_text']?.toString() ??
          '',
      orderItemRemovedCustomerSms:
          json['order_item_removed_customer_sms']?.toString() ?? '',
      orderItemRemovedCustomerSendBy:
          json['order_item_removed_customer_notification_send_by']
              ?.toString() ??
          'off',

      // Items Added to Cart
      itemsAddedToCartNotification:
          json['items_added_to_cart_notification_text']?.toString() ??
          json['items_added_to_cart_notification']?.toString() ??
          '',
      itemsAddedToCartSendBy:
          json['items_added_to_cart_notification_send_by']?.toString() ?? 'off',
    );
  }

  Map<String, String> toUpdatePayload() {
    return {
      // Order Received - Customer
      'order_received_customer_notification_text':
          orderReceivedCustomerNotification,
      'order_received_customer_sms': orderReceivedCustomerSms,
      'order_received_customer_notification_send_by':
          orderReceivedCustomerSendBy,

      // Order Received - Vendor
      'order_received_vendor_notification_text':
          orderReceivedVendorNotification,
      'order_received_vendor_sms': orderReceivedVendorSms,
      'order_received_vendor_notification_send_by': orderReceivedVendorSendBy,

      // Order Received - Admin
      'order_received_admin_notification_text': orderReceivedAdminNotification,
      'order_received_admin_sms': orderReceivedAdminSms,
      'order_received_admin_notification_send_by': orderReceivedAdminSendBy,

      // Order Reactivated - Customer
      'order_reactivated_customer_notification_text':
          orderReactivatedCustomerNotification,
      'order_reactivated_customer_sms': orderReactivatedCustomerSms,
      'order_reactivated_customer_notification_send_by':
          orderReactivatedCustomerSendBy,

      // Order Cancelled with Cart - Customer
      'order_cancelled_cart_customer_notification_text':
          orderCancelledCartCustomerNotification,
      'order_cancelled_cart_customer_sms': orderCancelledCartCustomerSms,
      'order_cancelled_cart_customer_notification_send_by':
          orderCancelledCartCustomerSendBy,

      // Order Cancelled - Customer
      'order_cancelled_customer_notification_text':
          orderCancelledCustomerNotification,
      'order_cancelled_customer_sms': orderCancelledCustomerSms,
      'order_cancelled_customer_notification_send_by':
          orderCancelledCustomerSendBy,

      // Order Completed - Customer
      'order_completed_customer_notification_text':
          orderCompletedCustomerNotification,
      'order_completed_customer_sms': orderCompletedCustomerSms,
      'order_completed_customer_notification_send_by':
          orderCompletedCustomerSendBy,

      // Order Updated - Customer
      'order_updated_customer_notification_text':
          orderUpdatedCustomerNotification,
      'order_updated_customer_sms': orderUpdatedCustomerSms,
      'order_updated_customer_notification_send_by': orderUpdatedCustomerSendBy,

      // Order Processing - Customer
      'order_processing_customer_notification_text':
          orderProcessingCustomerNotification,
      'order_processing_customer_sms': orderProcessingCustomerSms,
      'order_processing_customer_notification_send_by':
          orderProcessingCustomerSendBy,

      // Order Shipping - Customer
      'order_shipping_customer_notification_text':
          orderShippingCustomerNotification,
      'order_shipping_customer_notification_send_by':
          orderShippingCustomerSendBy,

      // Shipping Fee Increased - Customer
      'shipping_fee_increased_customer_notification_text':
          shippingFeeIncreasedCustomerNotification,
      'shipping_fee_increased_customer_sms': shippingFeeIncreasedCustomerSms,
      'shipping_fee_increased_customer_notification_send_by':
          shippingFeeIncreasedCustomerSendBy,

      // Shipping Fee Decreased - Customer
      'shipping_fee_decreased_customer_notification_text':
          shippingFeeDecreasedCustomerNotification,
      'shipping_fee_decreased_customer_sms': shippingFeeDecreasedCustomerSms,
      'shipping_fee_decreased_customer_notification_send_by':
          shippingFeeDecreasedCustomerSendBy,

      // Wallet Credit Added - Customer
      'wallet_credit_added_customer_notification_text':
          walletCreditAddedCustomerNotification,
      'wallet_credit_added_customer_sms': walletCreditAddedCustomerSms,
      'wallet_credit_added_customer_notification_send_by':
          walletCreditAddedCustomerSendBy,

      // Wallet Payment Refunded - Customer
      'wallet_payment_refunded_customer_notification_text':
          walletPaymentRefundedCustomerNotification,
      'wallet_payment_refunded_customer_sms': walletPaymentRefundedCustomerSms,
      'wallet_payment_refunded_customer_notification_send_by':
          walletPaymentRefundedCustomerSendBy,

      // Wallet Payment Reapplied - Customer
      'wallet_payment_reapplied_customer_notification_text':
          walletPaymentReappliedCustomerNotification,
      'wallet_payment_reapplied_customer_sms':
          walletPaymentReappliedCustomerSms,
      'wallet_payment_reapplied_customer_notification_send_by':
          walletPaymentReappliedCustomerSendBy,

      // Item Removed - Customer
      'order_item_removed_customer_notification_text':
          orderItemRemovedCustomerNotification,
      'order_item_removed_customer_sms': orderItemRemovedCustomerSms,
      'order_item_removed_customer_notification_send_by':
          orderItemRemovedCustomerSendBy,

      // Items Added to Cart
      'items_added_to_cart_notification_text': itemsAddedToCartNotification,
      'items_added_to_cart_notification_send_by': itemsAddedToCartSendBy,
    };
  }
}

// ============================================
// Response Models
// ============================================

class SettingsResponse {
  final bool success;
  final OrderNotificationsSettings? settings;
  final String? error;

  SettingsResponse({required this.success, this.settings, this.error});
}

class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}
