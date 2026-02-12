import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals_analytics/controller/flash_deal_analytics_controller.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/admin_ui_components.dart';

class AnalyticsStatCards extends GetView<FlashDealAnalyticsController> {
  const AnalyticsStatCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingAnalytics.value) {
        return _buildShimmer();
      }

      if (controller.analyticsError.value.isNotEmpty) {
        return _buildErrorState();
      }

      final data = controller.analytics.value;
      if (data == null) return const SizedBox.shrink();

      return Column(
        children: [
          // Row 1: Deal counts
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.flash_on,
                  label: 'Total Deals',
                  value: controller.formatNumber(data.totalDeals),
                  color: AdminTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.shopping_cart,
                  label: 'Purchased',
                  value: controller.formatNumber(data.purchasedCount),
                  color: AdminTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.skip_next,
                  label: 'Skipped',
                  value: controller.formatNumber(data.skippedCount),
                  color: AdminTheme.warningColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_off,
                  label: 'Expired',
                  value: controller.formatNumber(data.expiredCount),
                  color: AdminTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Revenue & rates
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money,
                  label: 'Total Revenue',
                  value: controller.formatCurrency(data.totalRevenue),
                  color: AdminTheme.successColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  label: 'Conversion',
                  value: controller.formatPercentage(data.conversionRate),
                  color: AdminTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.visibility,
                  label: 'Total Views',
                  value: controller.formatNumber(data.totalViews),
                  color: AdminTheme.primaryLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.touch_app,
                  label: 'Total Clicks',
                  value: controller.formatNumber(data.totalClicks),
                  color: AdminTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _StatCard(
            icon: Icons.block,
            label: 'Skip Rate',
            value: controller.formatPercentage(data.skipRate),
            color: AdminTheme.warningColor,
            fullWidth: true,
          ),
        ],
      );
    });
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const AdminShimmer(width: double.infinity, height: 80),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const AdminShimmer(width: double.infinity, height: 80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AdminTheme.errorColor,
            size: 40,
          ),
          const SizedBox(height: 8),
          const Text(
            'Failed to load analytics',
            style: TextStyle(
              color: AdminTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.analyticsError.value,
            style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: controller.fetchAnalytics,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AdminTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AdminTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
