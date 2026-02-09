import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals_analytics/controller/flash_deal_analytics_controller.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals_analytics/views/widgets/analytics_stat_cards.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals_analytics/views/widgets/analytics_charts.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals_analytics/views/widgets/analytics_history_table.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class FlashDealAnalyticsView extends GetView<FlashDealAnalyticsController> {
  const FlashDealAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeRangeChips(),
            const SizedBox(height: 16),
            const AnalyticsStatCards(),
            const SizedBox(height: 16),
            const AnalyticsCharts(),
            const SizedBox(height: 16),
            const AnalyticsHistoryTable(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AdminTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Flash Deal Analytics',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            controller.fetchAnalytics();
            controller.fetchHistory();
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildTimeRangeChips() {
    final ranges = [
      {'value': '7', 'label': '7 Days'},
      {'value': '30', 'label': '30 Days'},
      {'value': '90', 'label': '90 Days'},
      {'value': 'all', 'label': 'All Time'},
    ];

    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              ranges.map((range) {
                final isSelected =
                    controller.selectedTimeRange.value == range['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => controller.onTimeRangeChanged(range['value']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AdminTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AdminTheme.primaryColor
                                  : AdminTheme.borderColor,
                        ),
                      ),
                      child: Text(
                        range['label']!,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : AdminTheme.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
