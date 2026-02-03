import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/reseller_referral_notifications/reseller_referral_notifications_controller.dart';

class ResellerReferralNotificationsScreen extends StatelessWidget {
  const ResellerReferralNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResellerReferralNotificationsController());

    return Scaffold(
      backgroundColor: WebSettingsTheme.backgroundColor,
      appBar: WebSettingsAppBar(
        title: 'Reseller & Referral',
        actions: [
          Obx(
            () =>
                controller.isSaving.value
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
                  title: 'Reseller & Referral Notifications',
                  description:
                      'Configure notifications for reseller bonus, referral earnings, and level upgrades.',
                  icon: Icons.people_alt_rounded,
                  badge: 'Optional',
                ),

                // Reseller Bonus Messages Section
                _buildNotificationSection(
                  title: 'Reseller Bonus Messages',
                  icon: Icons.monetization_on_rounded,
                  description:
                      'Configure notifications for reseller bonus earnings.',
                  sectionTitle: 'Bonus Earned Messages',
                  notificationController:
                      controller.bonusEarnedNotificationTextController,
                  emailSubjectController:
                      controller.bonusEarnedEmailSubjectController,
                  emailBodyController:
                      controller.bonusEarnedEmailBodyController,
                  sendByValue: controller.bonusEarnedSendBy,
                  notificationOptions: controller.notificationOptions,
                  helperText:
                      'Notification sent when reseller earns bonus from an order',
                ),

                // Referral Earnings Section
                _buildNotificationSection(
                  title: 'Referral Earnings Messages',
                  icon: Icons.share_rounded,
                  description:
                      'Configure notifications for referral earnings when referred users place orders.',
                  sectionTitle: 'Referral Earnings',
                  notificationController:
                      controller.referralEarningsNotificationTextController,
                  emailSubjectController:
                      controller.referralEarningsEmailSubjectController,
                  emailBodyController:
                      controller.referralEarningsEmailBodyController,
                  sendByValue: controller.referralEarningsSendBy,
                  notificationOptions: controller.notificationOptions,
                  helperText:
                      'Notification sent when earning from referred user\'s order',
                ),

                // Level Upgrade Section
                _buildNotificationSection(
                  title: 'Level Upgrade Messages',
                  icon: Icons.trending_up_rounded,
                  description:
                      'Configure notifications for when resellers achieve new levels.',
                  sectionTitle: 'Level Achievement',
                  notificationController:
                      controller.levelUpgradeNotificationTextController,
                  emailSubjectController:
                      controller.levelUpgradeEmailSubjectController,
                  emailBodyController:
                      controller.levelUpgradeEmailBodyController,
                  sendByValue: controller.levelUpgradeSendBy,
                  notificationOptions: controller.notificationOptions,
                  helperText:
                      'Notification sent when reseller achieves a new level',
                ),

                // Quick Actions Section
                _buildQuickActionsSection(controller),

                // Placeholders Info Card
                _buildPlaceholdersCard(controller),

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

  Widget _buildNotificationSection({
    required String title,
    required IconData icon,
    required String description,
    required String sectionTitle,
    required TextEditingController notificationController,
    required TextEditingController emailSubjectController,
    required TextEditingController emailBodyController,
    required RxString sendByValue,
    required List<Map<String, String>> notificationOptions,
    required String helperText,
  }) {
    return WebSettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: WebSettingsTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: WebSettingsTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: WebSettingsTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: WebSettingsTheme.textSecondary.withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 10,
                              color: WebSettingsTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WebSettingsTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Notification Content Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WebSettingsTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WebSettingsTheme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: WebSettingsTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Notification Message
                WebSettingsTextField(
                  label: 'Notification Message',
                  controller: notificationController,
                  hint: 'Enter notification message...',
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Email Subject
                WebSettingsTextField(
                  label: 'Email Subject',
                  controller: emailSubjectController,
                  hint: 'Enter email subject...',
                ),

                const SizedBox(height: 16),

                // Email Body
                WebSettingsTextField(
                  label: 'Email Body',
                  controller: emailBodyController,
                  hint: 'Enter email body...',
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Notification Type
                Obx(
                  () => WebSettingsRadioGroup(
                    label: 'Send Notification Via',
                    value: sendByValue.value,
                    options: notificationOptions,
                    onChanged: (value) => sendByValue.value = value,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  helperText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(
    ResellerReferralNotificationsController controller,
  ) {
    return WebSettingsQuickActions(
      title: 'Quick Actions - Reseller Notifications',
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

  Widget _buildPlaceholdersCard(
    ResellerReferralNotificationsController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebSettingsTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WebSettingsTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: WebSettingsTheme.primaryColor,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Available Placeholders',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: WebSettingsTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Two columns layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reseller Placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reseller Placeholders:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WebSettingsTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.resellerPlaceholders.map(
                      (p) => _buildPlaceholderItem(
                        p['placeholder']!,
                        p['description']!,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Referral Placeholders:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WebSettingsTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.referralPlaceholders.map(
                      (p) => _buildPlaceholderItem(
                        p['placeholder']!,
                        p['description']!,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderItem(String placeholder, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: WebSettingsTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              placeholder,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: WebSettingsTheme.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 10,
                color: WebSettingsTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
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
          // Section cards shimmer
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 280,
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
