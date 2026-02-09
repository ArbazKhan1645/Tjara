import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals_analytics/controller/flash_deal_analytics_controller.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals_analytics/model/flash_deal_analytics_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class AnalyticsHistoryTable extends GetView<FlashDealAnalyticsController> {
  const AnalyticsHistoryTable({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'Past Flash Deals',
      icon: Icons.history,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilters(),
          const Divider(height: 1, color: AdminTheme.borderColor),
          _buildHistoryContent(),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('All', 'all'),
                const SizedBox(width: 8),
                _buildStatusChip('Purchased', 'sold'),
                const SizedBox(width: 8),
                _buildStatusChip('Skipped', 'skipped'),
                const SizedBox(width: 8),
                _buildStatusChip('Expired', 'expired'),
                const SizedBox(width: 8),
                _buildStatusChip('Completed', 'completed'),
                const SizedBox(width: 8),
                _buildStatusChip('Scheduled', 'scheduled'),
                const SizedBox(width: 8),
                _buildStatusChip('Active', 'active'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Date range row
          Row(
            children: [
              Expanded(child: _buildDatePicker('From', true)),
              const SizedBox(width: 10),
              Expanded(child: _buildDatePicker('To', false)),
              const SizedBox(width: 10),
              _buildFilterActions(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    return Obx(() {
      final isSelected = controller.historyStatus.value == value;
      return GestureDetector(
        onTap: () {
          controller.historyStatus.value = value;
          controller.applyHistoryFilters();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? _statusColor(value) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? _statusColor(value) : AdminTheme.borderColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AdminTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDatePicker(String label, bool isStart) {
    return Obx(() {
      final date =
          isStart ? controller.historyStartDate.value : controller.historyEndDate.value;
      final displayText =
          date != null ? DateFormat('MMM dd').format(date) : label;

      return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: Get.context!,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AdminTheme.primaryColor,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            if (isStart) {
              controller.historyStartDate.value = picked;
            } else {
              controller.historyEndDate.value = picked;
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminTheme.borderColor),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AdminTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    color:
                        date != null ? AdminTheme.textPrimary : AdminTheme.textMuted,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterActions() {
    return Row(
      children: [
        GestureDetector(
          onTap: controller.applyHistoryFilters,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AdminTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: controller.clearHistoryFilters,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminTheme.borderColor),
            ),
            child: const Icon(Icons.clear, color: AdminTheme.textMuted, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryContent() {
    return Obx(() {
      if (controller.isLoadingHistory.value) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AdminShimmer(
                  width: double.infinity,
                  height: 70,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        );
      }

      if (controller.historyError.value.isNotEmpty) {
        return _buildErrorState();
      }

      if (controller.historyItems.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: controller.historyItems.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AdminTheme.borderColor),
        itemBuilder: (context, index) {
          return _buildHistoryRow(controller.historyItems[index]);
        },
      );
    });
  }

  Widget _buildHistoryRow(FlashDealHistoryItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.productImage != null
                ? Image.network(
                    item.productImage!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(width: 10),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Price row
                Row(
                  children: [
                    if (item.originalPrice != null)
                      Text(
                        '\$${item.originalPrice}',
                        style: const TextStyle(
                          color: AdminTheme.textMuted,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    if (item.originalPrice != null) const SizedBox(width: 6),
                    if (item.dealPrice != null)
                      Text(
                        '\$${item.dealPrice}',
                        style: const TextStyle(
                          color: AdminTheme.successColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Meta row
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _statusBadge(item.status),
                    _metaChip(Icons.visibility, '${item.views}'),
                    _metaChip(Icons.touch_app, '${item.clicks}'),
                    if (item.shopName != null)
                      _metaChip(Icons.store, item.shopName!),
                  ],
                ),
                const SizedBox(height: 3),
                // Dates
                Text(
                  '${controller.formatDateTime(item.startedAt)} → ${controller.formatDateTime(item.endedAt)}',
                  style: const TextStyle(
                    color: AdminTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AdminTheme.primarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: AdminTheme.primaryColor, size: 20),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.capitalizeFirst ?? status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AdminTheme.textMuted),
        const SizedBox(width: 3),
        Text(
          text.length > 15 ? '${text.substring(0, 15)}...' : text,
          style: const TextStyle(color: AdminTheme.textMuted, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Obx(() {
      if (controller.totalItems.value == 0) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AdminTheme.borderColor, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.paginationInfo,
              style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
            ),
            Row(
              children: [
                _paginationButton(
                  Icons.chevron_left,
                  controller.currentPage.value > 1,
                  controller.loadPreviousPage,
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${controller.currentPage.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _paginationButton(
                  Icons.chevron_right,
                  controller.currentPage.value < controller.lastPage.value,
                  controller.loadNextPage,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _paginationButton(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AdminTheme.bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AdminTheme.textPrimary : AdminTheme.borderColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 40, color: AdminTheme.borderColor),
            SizedBox(height: 8),
            Text(
              'No flash deals found',
              style: TextStyle(
                color: AdminTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: AdminTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AdminTheme.errorColor, size: 36),
            const SizedBox(height: 8),
            Text(
              controller.historyError.value,
              style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => controller.fetchHistory(),
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
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'purchased':
      case 'sold':
        return AdminTheme.successColor;
      case 'skipped':
        return AdminTheme.warningColor;
      case 'expired':
        return AdminTheme.errorColor;
      case 'completed':
        return AdminTheme.successColor;
      case 'scheduled':
        return AdminTheme.accentColor;
      case 'active':
        return AdminTheme.primaryColor;
      default:
        return AdminTheme.textMuted;
    }
  }
}
