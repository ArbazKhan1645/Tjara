import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/web_settings/web_settings_screen.dart';
import 'package:tjara/app/modules/web_settings/web_settings_dashboard/web_settings_dashboard_controller.dart';

// Import all child screens
import 'package:tjara/app/modules/web_settings/inventory_reporting/inventory_reporting_screen.dart';
import 'package:tjara/app/modules/web_settings/analytics_reporting/analytics_reporting_screen.dart';
import 'package:tjara/app/modules/web_settings/wallet_credit_voucher/wallet_credit_voucher_screen.dart';
import 'package:tjara/app/modules/web_settings/order_discount_coupon/order_discount_coupon_screen.dart';
import 'package:tjara/app/modules/web_settings/reseller_referral_notifications/reseller_referral_notifications_screen.dart';
import 'package:tjara/app/modules/web_settings/order_notifications/order_notifications_screen.dart';
import 'package:tjara/app/modules/web_settings/api_throttle/api_throttle_screen.dart';
import 'package:tjara/app/modules/web_settings/log_monitor/log_monitor_screen.dart';
import 'package:tjara/app/modules/web_settings/roles_management/roles_management_screen.dart';
import 'package:tjara/app/modules/web_settings/registration_auth_notifications/registration_auth_notifications_screen.dart';
import 'package:tjara/app/modules/web_settings/content_management/content_management_screen.dart';

class WebSettingsDashboardScreen extends StatelessWidget {
  const WebSettingsDashboardScreen({super.key});

  // Primary theme color
  static const Color primaryColor = Colors.teal;
  static const Color primaryDarkColor = Colors.teal;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WebSettingsDashboardController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.errorMessage.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value!,
                  style: TextStyle(color: Colors.red.shade400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchAllData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAllData,
          color: primaryColor,
          child: CustomScrollView(
            slivers: [
              // Elegant Header
              SliverToBoxAdapter(child: _buildHeader(controller)),

              // Module Cards Grid
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  delegate: SliverChildListDelegate(_buildModuleCards(context)),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(WebSettingsDashboardController controller) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryDarkColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Expanded(
                    child: Text(
                      'Web Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Obx(
                    () =>
                        controller.isSaving.value
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: controller.fetchAllData,
                            ),
                  ),
                ],
              ),
            ),

            // Logo and Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo with change option
                  _buildLogoSection(controller),
                  const SizedBox(width: 20),

                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Website Name
                        Obx(
                          () => Text(
                            controller.websiteName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Status Badge
                        _buildStatusSection(controller),
                        const SizedBox(height: 12),

                        // Server Time
                        _buildServerTimeSection(controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(WebSettingsDashboardController controller) {
    return GestureDetector(
      onTap: controller.pickAndUploadLogo,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Obx(() {
                if (controller.isUploadingLogo.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }
                if (controller.websiteLogoUrl.value.isNotEmpty) {
                  return Image.network(
                    controller.websiteLogoUrl.value,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildDefaultLogo(),
                  );
                }
                return _buildDefaultLogo();
              }),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: primaryColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.store, size: 48, color: primaryColor),
    );
  }

  Widget _buildStatusSection(WebSettingsDashboardController controller) {
    return Row(
      children: [
        const Icon(Icons.circle, color: Colors.white54, size: 12),
        const SizedBox(width: 8),
        const Text(
          'Status:',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Obx(() {
          final isActive = controller.websiteStatus.value == 'active';
          return GestureDetector(
            onTap: () => _showStatusPicker(controller),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Colors.green.shade300 : Colors.red.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color:
                          isActive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color:
                        isActive ? Colors.green.shade100 : Colors.red.shade100,
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showStatusPicker(WebSettingsDashboardController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Website Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...controller.statusOptions.map((option) {
              final isSelected =
                  controller.websiteStatus.value == option['value'];
              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        option['value'] == 'active' ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(option['label']!),
                trailing:
                    isSelected
                        ? const Icon(Icons.check, color: primaryColor)
                        : null,
                onTap: () {
                  Get.back();
                  if (!isSelected) {
                    controller.updateStatus(option['value']!);
                  }
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildServerTimeSection(WebSettingsDashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  controller.formattedServerTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Obx(
                () => Text(
                  controller.formattedServerDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildModuleCards(BuildContext context) {
    final modules = [
      {
        'title': 'Website Settings',
        'subtitle': 'website configs & crediental',
        'icon': Icons.web_outlined,
        'color': const Color.fromARGB(255, 31, 124, 201),
        'screen': WebSettingsScreen(),
      },
      {
        'title': 'Content Management',
        'subtitle': 'Promos, categories & discounts',
        'icon': Icons.web_outlined,
        'color': Colors.green,
        'screen': ContentManagementScreen(),
      },
      {
        'title': 'Order Notifications',
        'subtitle': 'SMS & email messages',
        'icon': Icons.notifications_outlined,
        'color': Colors.pink,
        'screen': const OrderNotificationsScreen(),
      },
      {
        'title': 'Reseller Notifications',
        'subtitle': 'Referral & bonus messages',
        'icon': Icons.people_outline,
        'color': Colors.indigo,
        'screen': const ResellerReferralNotificationsScreen(),
      },
      {
        'title': 'Discount Coupons',
        'subtitle': 'Order discount settings',
        'icon': Icons.discount_outlined,
        'color': Colors.orange,
        'screen': const OrderDiscountCouponScreen(),
      },

      {
        'title': 'Wallet Vouchers',
        'subtitle': 'Credit voucher settings',
        'icon': Icons.account_balance_wallet_outlined,
        'color': Colors.teal,
        'screen': const WalletCreditVoucherScreen(),
      },
      {
        'title': 'Analytics Reporting',
        'subtitle': 'Order analytics settings',
        'icon': Icons.analytics_outlined,
        'color': Colors.purple,
        'screen': const AnalyticsReportingScreen(),
      },
      {
        'title': 'Inventory Reporting',
        'subtitle': 'Configure inventory reports',
        'icon': Icons.inventory_2_outlined,
        'color': Colors.blue,
        'screen': const InventoryReportingScreen(),
      },

      {
        'title': 'Roles Management',
        'subtitle': 'User roles & permissions',
        'icon': Icons.admin_panel_settings_outlined,
        'color': Colors.cyan,
        'screen': const RolesManagementScreen(),
      },
      {
        'title': 'Realtime Log Monitor',
        'subtitle': 'System logs & errors',
        'icon': Icons.bug_report_outlined,
        'color': Colors.brown,
        'screen': const LogMonitorScreen(),
      },
      {
        'title': 'API Throttle',
        'subtitle': 'Rate limiting settings',
        'icon': Icons.speed_outlined,
        'color': Colors.red,
        'screen': const ApiThrottleScreen(),
      },
      {
        'title': 'Auth Notifications',
        'subtitle': 'Registration & password',
        'icon': Icons.person_add_alt_1_outlined,
        'color': Colors.deepPurple,
        'screen': const RegistrationAuthNotificationsScreen(),
      },
    ];

    return modules.map((module) {
      return _buildModuleCard(
        title: module['title'] as String,
        subtitle: module['subtitle'] as String,
        icon: module['icon'] as IconData,
        color: module['color'] as Color,
        onTap: () => Get.to(() => module['screen'] as Widget),
      );
    }).toList();
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer loading widget
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Shimmer Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryDarkColor],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // App Bar Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        const Expanded(
                          child: Text(
                            'Web Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Shimmer Logo and Info Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo shimmer
                        Shimmer.fromColors(
                          baseColor: Colors.white.withOpacity(0.3),
                          highlightColor: Colors.white.withOpacity(0.6),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Info shimmer
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Website name shimmer
                              Shimmer.fromColors(
                                baseColor: Colors.white.withOpacity(0.3),
                                highlightColor: Colors.white.withOpacity(0.6),
                                child: Container(
                                  height: 28,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Status shimmer
                              Shimmer.fromColors(
                                baseColor: Colors.white.withOpacity(0.3),
                                highlightColor: Colors.white.withOpacity(0.6),
                                child: Container(
                                  height: 24,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Server time shimmer
                              Shimmer.fromColors(
                                baseColor: Colors.white.withOpacity(0.3),
                                highlightColor: Colors.white.withOpacity(0.6),
                                child: Container(
                                  height: 50,
                                  width: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Shimmer Grid Cards
          Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
              ),
              itemCount: 11,
              itemBuilder: (context, index) => _buildShimmerCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
            // Title shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 11,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Arrow shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
