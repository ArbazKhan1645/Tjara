import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/coupens/coupens_model.dart';
import 'package:tjara/app/modules/modules_admin/coupens/controller.dart';
import 'package:tjara/app/modules/modules_admin/coupens/shimmer.dart';

class CouponScreen extends StatelessWidget {
  CouponScreen({super.key});

  final CouponController controller = Get.put(CouponController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: const [AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Coupon Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.navigateToAddCoupon,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Coupon',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildSortControls(),
            const SizedBox(height: 12),
            Expanded(child: _buildCouponList()),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search coupons...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              onSubmitted: controller.searchCoupons,
            ),
          ),
          Obx(
            () =>
                controller.searchQuery.value.isNotEmpty
                    ? InkWell(
                      onTap: controller.clearSearch,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.clear, color: Colors.grey[400], size: 18),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Text('Show: ', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(
              () => DropdownButton<int>(
                value: controller.perPage.value,
                underline: const SizedBox(),
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                items: [10, 25, 50, 100]
                    .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.changeItemsPerPage(v);
                },
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(
              () => DropdownButton<String>(
                value: controller.orderBy.value,
                underline: const SizedBox(),
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                items: const [
                  DropdownMenuItem(value: 'created_at', child: Text('Date')),
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(value: 'expiry_date', child: Text('Expiry')),
                  DropdownMenuItem(value: 'discount_value', child: Text('Value')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    controller.changeSortOrder(v, controller.order.value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 6),
          Obx(
            () => InkWell(
              onTap: () {
                final newOrder = controller.order.value == 'asc' ? 'desc' : 'asc';
                controller.changeSortOrder(controller.orderBy.value, newOrder);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Icon(
                  controller.order.value == 'asc'
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponList() {
    return Obx(() {
      if (controller.isLoading.value && controller.coupons.isEmpty) {
        return const CouponShimmerLoading();
      }

      if (controller.hasError.value && controller.coupons.isEmpty) {
        return _buildErrorWidget();
      }

      if (controller.coupons.isEmpty) {
        return _buildEmptyWidget();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshCoupons,
        color: Colors.teal,
        child: ListView.builder(
          itemCount: controller.coupons.length,
          itemBuilder: (context, index) {
            return _buildCouponCard(controller.coupons[index]);
          },
        ),
      );
    });
  }

  Widget _buildCouponCard(Coupon coupon) {
    final statusColor = controller.getStatusColor(coupon);
    final statusIcon = controller.getStatusIcon(coupon);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Icon + Name + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.local_offer_outlined, size: 18, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ID: ${coupon.meta.couponId}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 13, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        controller.getStatusText(coupon),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Row 2: Info chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  coupon.discountType == 'percentage' ? Icons.percent : Icons.attach_money,
                  controller.getDiscountText(coupon),
                ),
                _buildInfoChip(
                  coupon.isGlobal ? Icons.public : Icons.store_outlined,
                  coupon.isGlobal ? 'Global' : 'Specific',
                ),
                _buildInfoChip(
                  Icons.calendar_today,
                  controller.getValidityPeriod(coupon),
                ),
                if (coupon.daysRemaining > 0)
                  _buildInfoChip(
                    Icons.timer_outlined,
                    '${coupon.daysRemaining} days left',
                    color: const Color(0xFF22C55E),
                  ),
                if (coupon.daysRemaining < 0)
                  _buildInfoChip(
                    Icons.timer_off_outlined,
                    'Expired ${coupon.daysRemaining.abs()} days ago',
                    color: const Color(0xFFEF4444),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Row 3: Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => controller.navigateToEditCoupon(coupon),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    side: BorderSide(color: Colors.teal.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => controller.deleteCoupon(coupon.id),
                  icon: const Icon(Icons.delete_outline, size: 15),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    final chipColor = color ?? Colors.grey[600]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: chipColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Obx(() {
      if (controller.totalPages.value <= 1) return const SizedBox.shrink();

      final start = ((controller.currentPage.value - 1) * controller.perPage.value) + 1;
      final end = (controller.currentPage.value * controller.perPage.value > controller.totalCoupons.value)
          ? controller.totalCoupons.value
          : controller.currentPage.value * controller.perPage.value;

      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$start - $end of ${controller.totalCoupons.value}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                _buildPageButton(
                  icon: Icons.chevron_left,
                  enabled: controller.currentPage.value > 1,
                  onTap: () => controller.goToPage(controller.currentPage.value - 1),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${controller.currentPage.value} / ${controller.totalPages.value}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                _buildPageButton(
                  icon: Icons.chevron_right,
                  enabled: controller.currentPage.value < controller.totalPages.value,
                  onTap: () => controller.goToPage(controller.currentPage.value + 1),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: enabled ? Colors.grey[300]! : Colors.grey[200]!),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.teal : Colors.grey[350],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading coupons',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.errorMessage.value,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.refreshCoupons,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No coupons found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first coupon',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.navigateToAddCoupon,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Coupon'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
