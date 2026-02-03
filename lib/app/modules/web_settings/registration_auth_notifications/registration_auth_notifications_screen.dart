import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/registration_auth_notifications/registration_auth_notifications_controller.dart';

class RegistrationAuthNotificationsScreen extends StatelessWidget {
  const RegistrationAuthNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegistrationAuthNotificationsController());

    return Scaffold(
      backgroundColor: WebSettingsTheme.backgroundColor,
      appBar: WebSettingsAppBar(
        title: 'Registration & Auth',
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
                  title: 'Registration & Authentication',
                  description:
                      'Configure welcome messages, verification emails, phone verification, and password reset notifications.',
                  icon: Icons.person_add_alt_1_rounded,
                  badge: 'Optional',
                ),

                // ============================================
                // Registration Welcome Messages Section
                // ============================================
                _buildSectionHeader(
                  'Registration Welcome Messages',
                  'Configure welcome messages sent after successful registration. Use placeholders like {user_name}, {email}, {role} for dynamic content.',
                  Icons.celebration_rounded,
                ),

                // Customer Welcome Messages
                _NotificationCard(
                  title: 'Customer Welcome Messages',
                  icon: Icons.person_rounded,
                  helperText: 'Welcome message sent to customers after registration',
                  notificationController: controller.customerWelcomeNotificationController,
                  emailSubjectController: controller.customerWelcomeEmailSubjectController,
                  emailBodyController: controller.customerWelcomeEmailBodyController,
                  sendByValue: controller.customerWelcomeSendBy,
                  notificationOptions: controller.notificationOptions,
                  notificationLabel: 'Customer Welcome SMS/Notification',
                ),

                // Vendor Welcome Messages
                _NotificationCard(
                  title: 'Vendor Welcome Messages',
                  icon: Icons.store_rounded,
                  helperText: 'Welcome message sent to vendors after registration',
                  notificationController: controller.vendorWelcomeNotificationController,
                  emailSubjectController: controller.vendorWelcomeEmailSubjectController,
                  emailBodyController: controller.vendorWelcomeEmailBodyController,
                  sendByValue: controller.vendorWelcomeSendBy,
                  notificationOptions: controller.notificationOptions,
                  notificationLabel: 'Vendor Welcome SMS/Notification',
                ),

                // ============================================
                // Customer Email Verification Messages Section
                // ============================================
                _buildSectionHeader(
                  'Customer Email Verification Messages',
                  'Configure messages for email verification process.',
                  Icons.mark_email_read_rounded,
                ),

                // Customer Standard Email Verification
                _NotificationCard(
                  title: 'Customer Standard Email Verification',
                  icon: Icons.verified_user_rounded,
                  helperText: 'Verification message sent to customers',
                  notificationController: controller.customerEmailVerificationNotificationController,
                  emailSubjectController: controller.customerEmailVerificationEmailSubjectController,
                  emailBodyController: controller.customerEmailVerificationEmailBodyController,
                  sendByValue: controller.customerEmailVerificationSendBy,
                  notificationOptions: controller.notificationOptions,
                  notificationLabel: 'Customer Email Verification',
                ),

                // Vendor Email Verification
                _NotificationCard(
                  title: 'Vendor Email Verification',
                  icon: Icons.storefront_rounded,
                  helperText: 'Verification message sent to vendors',
                  notificationController: controller.vendorEmailVerificationNotificationController,
                  emailSubjectController: controller.vendorEmailVerificationEmailSubjectController,
                  emailBodyController: controller.vendorEmailVerificationEmailBodyController,
                  sendByValue: controller.vendorEmailVerificationSendBy,
                  notificationOptions: controller.notificationOptions,
                  notificationLabel: 'Vendor Email Verification',
                ),

                // Customer Quick Registration Verification
                _NotificationCard(
                  title: 'Customer Quick Registration Verification',
                  icon: Icons.flash_on_rounded,
                  helperText: 'Quick verification message with discount incentive',
                  notificationController: controller.quickRegistrationVerificationNotificationController,
                  emailSubjectController: controller.quickRegistrationVerificationEmailSubjectController,
                  emailBodyController: controller.quickRegistrationVerificationEmailBodyController,
                  sendByValue: controller.quickRegistrationVerificationSendBy,
                  notificationOptions: controller.notificationOptions,
                  notificationLabel: 'Quick Registration Verification',
                ),

                // ============================================
                // Seller Phone Verification Messages Section
                // ============================================
                _buildSectionHeader(
                  'Seller Phone Verification Messages',
                  'Configure messages for phone number verification.',
                  Icons.phone_android_rounded,
                ),

                // Phone Verification Code
                _NotificationCard(
                  title: 'Seller Phone Verification Code',
                  icon: Icons.pin_rounded,
                  helperText: 'Verification code message sent to user\'s phone',
                  notificationController: controller.phoneVerificationCodeNotificationController,
                  emailSubjectController: controller.phoneVerificationCodeEmailSubjectController,
                  emailBodyController: controller.phoneVerificationCodeEmailBodyController,
                  sendByValue: controller.phoneVerificationCodeSendBy,
                  notificationOptions: controller.notificationOptions,
                  notificationLabel: 'Phone Verification Code',
                ),

                // Phone Verification Resend
                _NotificationCard(
                  title: 'Phone Verification Resend',
                  icon: Icons.refresh_rounded,
                  helperText: 'Resend verification code message',
                  notificationController: controller.phoneVerificationResendNotificationController,
                  emailSubjectController: controller.phoneVerificationResendEmailSubjectController,
                  emailBodyController: controller.phoneVerificationResendEmailBodyController,
                  sendByValue: controller.phoneVerificationResendSendBy,
                  notificationOptions: controller.notificationOptions,
                  notificationLabel: 'Phone Verification Resend',
                ),

                // ============================================
                // Password Reset Messages Section
                // ============================================
                _buildSectionHeader(
                  'Password Reset Messages',
                  'Configure messages for password reset process.',
                  Icons.lock_reset_rounded,
                ),

                // Password Reset Link
                _NotificationCard(
                  title: 'Password Reset',
                  icon: Icons.link_rounded,
                  helperText: 'Password reset link message',
                  notificationController: controller.passwordResetLinkNotificationController,
                  emailSubjectController: controller.passwordResetLinkEmailSubjectController,
                  emailBodyController: controller.passwordResetLinkEmailBodyController,
                  sendByValue: controller.passwordResetLinkSendBy,
                  notificationOptions: controller.notificationOptions,
                  notificationLabel: 'Password Reset Link',
                ),

                // Password Reset Success
                _NotificationCard(
                  title: 'Password Reset Success',
                  icon: Icons.check_circle_rounded,
                  helperText: 'Password reset confirmation message',
                  notificationController: controller.passwordResetSuccessNotificationController,
                  emailSubjectController: controller.passwordResetSuccessEmailSubjectController,
                  emailBodyController: controller.passwordResetSuccessEmailBodyController,
                  sendByValue: controller.passwordResetSuccessSendBy,
                  notificationOptions: controller.notificationOptions,
                  notificationLabel: 'Password Reset Success',
                ),

                const SizedBox(height: 8),

                // Quick Actions
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

  Widget _buildSectionHeader(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WebSettingsTheme.primaryColor.withOpacity(0.08),
            WebSettingsTheme.primaryLight.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WebSettingsTheme.primaryColor.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: WebSettingsTheme.primaryDark,
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
                        color: WebSettingsTheme.textSecondary.withOpacity(0.1),
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: WebSettingsTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(RegistrationAuthNotificationsController controller) {
    return WebSettingsQuickActions(
      title: 'Quick Actions - Auth Notifications',
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

  Widget _buildPlaceholdersCard(RegistrationAuthNotificationsController controller) {
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

          // Grid layout for placeholders
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Common Placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Common:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WebSettingsTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.commonPlaceholders.map(
                      (p) => _buildPlaceholderItem(
                        p['placeholder']!,
                        p['description']!,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Verification:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WebSettingsTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.verificationPlaceholders.map(
                      (p) => _buildPlaceholderItem(
                        p['placeholder']!,
                        p['description']!,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Other Placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vendor:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WebSettingsTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.vendorPlaceholders.map(
                      (p) => _buildPlaceholderItem(
                        p['placeholder']!,
                        p['description']!,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Password Reset:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WebSettingsTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.passwordResetPlaceholders.map(
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

// ============================================
// Notification Card Widget
// ============================================
class _NotificationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String helperText;
  final TextEditingController notificationController;
  final TextEditingController emailSubjectController;
  final TextEditingController emailBodyController;
  final RxString sendByValue;
  final List<Map<String, String>> notificationOptions;
  final String notificationLabel;

  const _NotificationCard({
    required this.title,
    required this.icon,
    required this.helperText,
    required this.notificationController,
    required this.emailSubjectController,
    required this.emailBodyController,
    required this.sendByValue,
    required this.notificationOptions,
    required this.notificationLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: WebSettingsTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: WebSettingsTheme.primaryColor.withOpacity(0.1),
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

            // Notification/SMS Message
            _buildTextField(
              label: notificationLabel,
              controller: notificationController,
              hint: 'Enter notification/SMS message...',
              maxLines: 2,
            ),

            const SizedBox(height: 12),

            // Email Subject
            _buildTextField(
              label: 'Email Subject',
              controller: emailSubjectController,
              hint: 'Enter email subject...',
              maxLines: 1,
            ),

            const SizedBox(height: 12),

            // Email Body
            _buildTextField(
              label: 'Email Body',
              controller: emailBodyController,
              hint: 'Enter email body...',
              maxLines: 5,
            ),

            const SizedBox(height: 12),

            // Send By Radio Group
            Obx(
              () => WebSettingsRadioGroup(
                value: sendByValue.value,
                options: notificationOptions,
                onChanged: (value) => sendByValue.value = value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: WebSettingsTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }
}

// ============================================
// Shimmer Loading Widget
// ============================================
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
          const SizedBox(height: 20),
          // Section header shimmer
          Shimmer.fromColors(
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
          const SizedBox(height: 12),
          // Cards shimmer
          ...List.generate(
            6,
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
