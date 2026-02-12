// screens/coupon_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/coupens/coupens_model.dart';
import 'package:tjara/app/modules/modules_admin/coupens/add_coupen.dart';
import 'package:tjara/app/modules/modules_admin/coupens/controller.dart';
import 'package:tjara/app/modules/modules_admin/coupens/edit_controller.dart';
import 'package:tjara/app/modules/modules_admin/coupens/shimmer.dart';

class CouponScreen extends StatelessWidget {
  CouponScreen({super.key});

  final CouponController controller = Get.put(CouponController());

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.teal, Colors.teal],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // Search and Filters Container
                const Row(
                  children: [
                    Text(
                      'Coupon Management ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSearchContainer(),

                const SizedBox(height: 10),

                // Data Table Container
                Expanded(child: _buildTableContainer()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Fields Row
          Row(
            children: [
              // Search by Name/Code
              Expanded(
                flex: 3,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search coupons by name or code',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      suffixIcon: Obx(
                        () =>
                            controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                  onPressed: controller.clearSearch,
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey[400],
                                    size: 18,
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onSubmitted: controller.searchCoupons,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Search by ID
              Expanded(
                flex: 2,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: controller.searchByIdController,
                    decoration: InputDecoration(
                      hintText: 'Search by ID...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.tag,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onSubmitted: controller.searchCouponsById,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header with controls
          _buildTableHeader(),

          // Data Table
          Expanded(child: _buildDataTable()),

          // Pagination Footer
          _buildPaginationFooter(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Entries per page
          Row(
            children: [
              const Text(
                'Show: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Obx(
                  () => DropdownButton<int>(
                    value: controller.perPage.value,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                    items:
                        [10, 25, 50, 100]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value'),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeItemsPerPage(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // Right side - Sort controls
          Row(
            children: [
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Obx(
                  () => DropdownButton<String>(
                    value: controller.orderBy.value,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'created_at',
                        child: Text('Created Date'),
                      ),
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(
                        value: 'expiry_date',
                        child: Text('Expiry Date'),
                      ),
                      DropdownMenuItem(
                        value: 'discount_value',
                        child: Text('Discount Value'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeSortOrder(
                          value,
                          controller.order.value,
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => IconButton(
                  onPressed: () {
                    final newOrder =
                        controller.order.value == 'asc' ? 'desc' : 'asc';
                    controller.changeSortOrder(
                      controller.orderBy.value,
                      newOrder,
                    );
                  },
                  icon: Icon(
                    controller.order.value == 'asc'
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
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

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: RefreshIndicator(
          onRefresh: controller.refreshCoupons,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(Get.context!).size.width * 3,
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 20,
                headingRowHeight: 50,
                dataRowHeight: 65,
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF97316),
                ),
                dividerThickness: 1,
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Coupon Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Type',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Validity Period',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Scope',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Value',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
                rows: [
                  ...controller.coupons.map((coupon) => _buildDataRow(coupon)),
                  if (controller.isLoadingMore.value)
                    const DataRow(
                      cells: [
                        DataCell(LoadMoreShimmer()),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  DataRow _buildDataRow(Coupon coupon) {
    return DataRow(
      cells: [
        // Coupon Details
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  coupon.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${coupon.meta.couponId}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (coupon.description != null &&
                    coupon.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      coupon.description!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Type
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Discount',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF1D4ED8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Validity Period
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Start: ${controller.formatDate(coupon.startDate)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 2),
              Text(
                'End: ${controller.formatDate(coupon.expiryDate)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
              ),
              if (coupon.daysRemaining != 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    coupon.daysRemaining > 0
                        ? '${coupon.daysRemaining} days left'
                        : 'Expired ${coupon.daysRemaining.abs()} days ago',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          coupon.daysRemaining > 0
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Scope
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  coupon.isGlobal
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              coupon.isGlobal ? 'Global' : 'Specific',
              style: TextStyle(
                fontSize: 11,
                color:
                    coupon.isGlobal
                        ? const Color(0xFF065F46)
                        : const Color(0xFF92400E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Value
        DataCell(
          Text(
            controller.getDiscountText(coupon),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF111827),
            ),
          ),
        ),

        // Status
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(coupon),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              controller.getStatusText(coupon),
              style: TextStyle(
                fontSize: 11,
                color: _getStatusTextColor(coupon),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  Get.delete<EditCouponController>(force: true);
                  final result = await Get.to(
                    () => AddCouponPage(),
                    arguments: coupon,
                  );
                  if (result == true) {
                    controller.fetchCoupons(refresh: true);
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                tooltip: 'Edit',
                color: const Color(0xFFF97316),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: () => controller.deleteCoupon(coupon.id),
                icon: const Icon(Icons.delete_outline, size: 16),
                tooltip: 'Delete',
                color: const Color(0xFFEF4444),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusBackgroundColor(Coupon coupon) {
    if (coupon.isExpired) {
      return const Color(0xFFFEE2E2);
    } else if (coupon.isActiveNow) {
      return const Color(0xFFD1FAE5);
    } else {
      return const Color(0xFFFEF3C7);
    }
  }

  Color _getStatusTextColor(Coupon coupon) {
    if (coupon.isExpired) {
      return const Color(0xFFDC2626);
    } else if (coupon.isActiveNow) {
      return const Color(0xFF059669);
    } else {
      return const Color(0xFF92400E);
    }
  }

  Widget _buildPaginationFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - showing info
          Obx(
            () => Text(
              'Showing ${controller.coupons.length} of ${controller.totalCoupons.value} coupons',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Right side - pagination
          Row(
            children: [
              Obx(
                () => Text(
                  'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap:
                          controller.currentPage.value > 1
                              ? () {
                                controller.currentPage.value--;
                                controller.fetchCoupons();
                              }
                              : null,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color:
                              controller.currentPage.value > 1
                                  ? Colors.white
                                  : Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          size: 16,
                          color:
                              controller.currentPage.value > 1
                                  ? const Color(0xFFF97316)
                                  : Colors.grey[400],
                        ),
                      ),
                    ),
                    Container(width: 1, height: 28, color: Colors.grey[300]),
                    InkWell(
                      onTap:
                          controller.currentPage.value <
                                  controller.totalPages.value
                              ? () {
                                controller.currentPage.value++;
                                controller.fetchCoupons();
                              }
                              : null,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color:
                              controller.currentPage.value <
                                      controller.totalPages.value
                                  ? Colors.white
                                  : Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          size: 16,
                          color:
                              controller.currentPage.value <
                                      controller.totalPages.value
                                  ? const Color(0xFFF97316)
                                  : Colors.grey[400],
                        ),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
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
            ElevatedButton(
              onPressed: controller.refreshCoupons,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first coupon',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add coupon screen
                Get.snackbar(
                  'Info',
                  'Add coupon feature will be implemented later',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Coupon'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
