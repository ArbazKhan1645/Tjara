import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/order_notifications/order_notifications_controller.dart';

class OrderNotificationsScreen extends StatelessWidget {
  const OrderNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderNotificationsController());

    return Scaffold(
      backgroundColor: WebSettingsTheme.backgroundColor,
      appBar: WebSettingsAppBar(
        title: 'Order Notifications',
        actions: [
          Obx(
            () => controller.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save_rounded),
                    onPressed: controller.saveSettings,
                    tooltip: 'Save Settings',
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _ShimmerLoading();
        }

        if (controller.errorMessage.value != null) {
          return WebSettingsErrorState(
            message: controller.errorMessage.value!,
            onRetry: controller.fetchSettings,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchSettings,
          color: WebSettingsTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                const WebSettingsHeaderCard(
                  title: 'Order Notifications',
                  description: 'Configure custom messages for order notifications and SMS. Use placeholders for dynamic content.',
                  icon: Icons.notifications_active_rounded,
                  badge: 'Optional',
                ),

                // Order Received Messages
                _buildSectionTitle('Order Received Messages'),
                _buildNotificationCard(
                  title: 'Customer - Order Received',
                  icon: Icons.person_rounded,
                  controller: controller.orderReceivedCustomerNotificationController,
                  sendBy: controller.orderReceivedCustomerSendBy,
                  helperText: 'Notification sent to customer when order is received',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Vendor - New Order',
                  icon: Icons.store_rounded,
                  controller: controller.orderReceivedVendorNotificationController,
                  sendBy: controller.orderReceivedVendorSendBy,
                  helperText: 'Notification sent to vendor when new order is placed',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Admin - New Order',
                  icon: Icons.admin_panel_settings_rounded,
                  controller: controller.orderReceivedAdminNotificationController,
                  sendBy: controller.orderReceivedAdminSendBy,
                  helperText: 'Notification sent to admin when new order is placed',
                  options: controller.notificationOptions,
                ),

                // Order Status Update Messages
                _buildSectionTitle('Order Status Update Messages'),
                _buildNotificationCard(
                  title: 'Order Reactivated - Customer',
                  icon: Icons.refresh_rounded,
                  controller: controller.orderReactivatedCustomerNotificationController,
                  sendBy: controller.orderReactivatedCustomerSendBy,
                  helperText: 'Notification sent when order is reactivated',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Order Cancelled with Cart - Customer',
                  icon: Icons.shopping_cart_rounded,
                  controller: controller.orderCancelledCartCustomerNotificationController,
                  sendBy: controller.orderCancelledCartCustomerSendBy,
                  helperText: 'Notification sent when order is cancelled and items returned to cart',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Order Cancelled - Customer',
                  icon: Icons.cancel_rounded,
                  controller: controller.orderCancelledCustomerNotificationController,
                  sendBy: controller.orderCancelledCustomerSendBy,
                  helperText: 'Notification sent when order is cancelled',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Order Completed - Customer',
                  icon: Icons.check_circle_rounded,
                  controller: controller.orderCompletedCustomerNotificationController,
                  sendBy: controller.orderCompletedCustomerSendBy,
                  helperText: 'Notification sent when order is completed',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Order Updated - Customer',
                  icon: Icons.edit_rounded,
                  controller: controller.orderUpdatedCustomerNotificationController,
                  sendBy: controller.orderUpdatedCustomerSendBy,
                  helperText: 'Notification sent when order is updated',
                  options: controller.notificationOptions,
                ),

                // Order Processing Messages
                _buildSectionTitle('Order Processing Messages'),
                _buildNotificationCard(
                  title: 'Order Processing - Customer',
                  icon: Icons.hourglass_empty_rounded,
                  controller: controller.orderProcessingCustomerNotificationController,
                  sendBy: controller.orderProcessingCustomerSendBy,
                  helperText: 'Notification sent when order enters processing stage',
                  options: controller.notificationOptions,
                ),

                // Order Shipping Messages
                _buildSectionTitle('Order Shipping Messages'),
                _buildNotificationCard(
                  title: 'Order Shipping - Customer',
                  icon: Icons.local_shipping_rounded,
                  controller: controller.orderShippingCustomerNotificationController,
                  sendBy: controller.orderShippingCustomerSendBy,
                  helperText: 'Notification sent when order enters shipping stage',
                  options: controller.notificationOptions,
                ),

                // Shipping Fee Update Messages
                _buildSectionTitle('Shipping Fee Update Messages'),
                _buildNotificationCard(
                  title: 'Shipping Fee Increased - Customer',
                  icon: Icons.trending_up_rounded,
                  controller: controller.shippingFeeIncreasedCustomerNotificationController,
                  sendBy: controller.shippingFeeIncreasedCustomerSendBy,
                  helperText: 'Notification sent when shipping fee is increased',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Shipping Fee Decreased - Customer',
                  icon: Icons.trending_down_rounded,
                  controller: controller.shippingFeeDecreasedCustomerNotificationController,
                  sendBy: controller.shippingFeeDecreasedCustomerSendBy,
                  helperText: 'Notification sent when shipping fee is decreased',
                  options: controller.notificationOptions,
                ),

                // Wallet & Payment Messages
                _buildSectionTitle('Wallet & Payment Messages'),
                _buildNotificationCard(
                  title: 'Wallet Credit Added - Customer',
                  icon: Icons.account_balance_wallet_rounded,
                  controller: controller.walletCreditAddedCustomerNotificationController,
                  sendBy: controller.walletCreditAddedCustomerSendBy,
                  helperText: 'Notification sent when wallet credit is added',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Wallet Payment Refunded - Customer',
                  icon: Icons.money_off_rounded,
                  controller: controller.walletPaymentRefundedCustomerNotificationController,
                  sendBy: controller.walletPaymentRefundedCustomerSendBy,
                  helperText: 'Notification sent when wallet payment is refunded',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Wallet Payment Reapplied - Customer',
                  icon: Icons.replay_rounded,
                  controller: controller.walletPaymentReappliedCustomerNotificationController,
                  sendBy: controller.walletPaymentReappliedCustomerSendBy,
                  helperText: 'Notification sent when wallet payment is reapplied',
                  options: controller.notificationOptions,
                ),

                // Order Item Change Messages
                _buildSectionTitle('Order Item Change Messages'),
                _buildNotificationCard(
                  title: 'Item Removed - Customer',
                  icon: Icons.remove_shopping_cart_rounded,
                  controller: controller.orderItemRemovedCustomerNotificationController,
                  sendBy: controller.orderItemRemovedCustomerSendBy,
                  helperText: 'Notification sent when item is removed from order',
                  options: controller.notificationOptions,
                ),
                _buildNotificationCard(
                  title: 'Items Added to Cart',
                  icon: Icons.add_shopping_cart_rounded,
                  controller: controller.itemsAddedToCartNotificationController,
                  sendBy: controller.itemsAddedToCartSendBy,
                  helperText: 'Notification sent when cancelled order items are added back to cart',
                  options: controller.notificationOptions,
                ),

                const SizedBox(height: 8),

                // Quick Actions
                _buildQuickActionsCard(controller),

                // Save Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(
                    () => WebSettingsPrimaryButton(
                      label: 'Save Changes',
                      icon: Icons.save_rounded,
                      isLoading: controller.isSaving.value,
                      onPressed: controller.saveSettings,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: WebSettingsTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: WebSettingsTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required RxString sendBy,
    required String helperText,
    required List<Map<String, String>> options,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: WebSettingsTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WebSettingsTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: WebSettingsTheme.primaryColor,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: WebSettingsTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            helperText,
            style: const TextStyle(
              fontSize: 11,
              color: WebSettingsTheme.textSecondary,
            ),
          ),
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter notification message...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: WebSettingsTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: WebSettingsTheme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: WebSettingsTheme.primaryColor,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Obx(
              () => WebSettingsRadioGroup(
                value: sendBy.value,
                options: options,
                onChanged: (value) => sendBy.value = value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(OrderNotificationsController controller) {
    return WebSettingsQuickActions(
      title: 'Quick Actions - Order Notifications',
      actions: [
        WebSettingsOutlinedButton(
          label: 'Enable All SMS',
          icon: Icons.sms_rounded,
          color: WebSettingsTheme.successColor,
          onPressed: controller.enableAllSms,
        ),
        WebSettingsOutlinedButton(
          label: 'Enable All Email',
          icon: Icons.email_rounded,
          color: WebSettingsTheme.primaryColor,
          onPressed: controller.enableAllEmail,
        ),
        WebSettingsOutlinedButton(
          label: 'Disable All',
          icon: Icons.notifications_off_rounded,
          color: WebSettingsTheme.textSecondary,
          onPressed: controller.disableAllNotifications,
        ),
      ],
    );
  }
}

/// Shimmer Loading Widget
class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Cards shimmer
          ...List.generate(
            8,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Button shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
