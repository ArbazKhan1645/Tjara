// ==================================================
// FILE 2: Updated cars_view.dart
// ==================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/admin/cars/controllers/cars_controller.dart';
import 'package:tjara/app/modules/admin/cars/widgets/action_widget.dart';

class CarsView extends GetView<CarsController> {
  const CarsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarsController>(
      init: CarsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(),
          body: _buildBody(context),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF97316),
      actions: const [AdminAppBarActionsSimple()],
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Cars Dashboard',
        style: TextStyle(color: Colors.white),
      ),
      elevation: 0,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(context),
        vertical: 16,
      ),
      child: ListView(
        children: [
          // Filter Section
          const CarsFilterWidget(),
          const SizedBox(height: 20),

          // Table Section
          _buildTableContainer(),
        ],
      ),
    );
  }

  Widget _buildTableContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Debug info for pagination
          // Container(
          //   padding: const EdgeInsets.all(8),
          //   color: Colors.yellow.shade100,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Obx(
          //         () => Text(
          //           "DEBUG: totalPages=${controller.totalPages.value}, currentPage=${controller.currentPage.value}, totalItems=${controller.totalItems.value}, products=${controller.products.length}",
          //           style: const TextStyle(fontSize: 10, color: Colors.black),
          //         ),
          //       ),
          //       const SizedBox(height: 4),
          //       Row(
          //         children: [
          //           ElevatedButton(
          //             onPressed: () => controller.goToPreviousPage(),
          //             child: const Text("Prev", style: TextStyle(fontSize: 10)),
          //           ),
          //           const SizedBox(width: 8),
          //           ElevatedButton(
          //             onPressed: () => controller.goToNextPage(),
          //             child: const Text("Next", style: TextStyle(fontSize: 10)),
          //           ),
          //           const SizedBox(width: 8),
          //           ElevatedButton(
          //             onPressed: () => controller.goToPage(2),
          //             child: const Text(
          //               "Page 2",
          //               style: TextStyle(fontSize: 10),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 8),

          // Pagination (moved above table)
          Obx(() {
            if (controller.viewState.value == ViewState.success) {
              return const CarsPaginationWidget();
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 16),

          // Table Body with State Management
          Obx(() {
            switch (controller.viewState.value) {
              case ViewState.loading:
                return const SizedBox(height: 400, child: CarsLoadingWidget());
              case ViewState.empty:
                return const SizedBox(height: 300, child: CarsEmptyWidget());
              case ViewState.error:
                return SizedBox(
                  height: 400,
                  child: CarsErrorWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.retryLoadData,
                  ),
                );
              case ViewState.success:
                return const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: CarsTableWidget(),
                );
            }
          }),
        ],
      ),
    );
  }

  // Responsive helper methods
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 32;
    if (width > 768) return 24;
    return 16;
  }
}

// cars_filter_widget.dart
class CarsFilterWidget extends GetView<CarsController> {
  const CarsFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildFilterFields(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.directions_car, color: Color(0xFF1e3c72), size: 28),
        const SizedBox(width: 12),
        const Text(
          'Cars',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1e3c72).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Obx(
            () => Text(
              '${controller.totalItems.value} items',
              style: const TextStyle(
                color: Color(0xFF1e3c72),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterFields(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildDesktopFilters();
      },
    );
  }

  Widget _buildDateRangeField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Calendar Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF4A9B8E), // Same teal color
              borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
          ),

          // Date Field
          Expanded(
            child: TextField(
              readOnly: true,
              onTap: () => _showDateRangePicker(),
              controller: TextEditingController(
                text: controller.selectedDateRange.value,
              ),
              decoration: InputDecoration(
                hintText: "Select date range",
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value:
                controller.selectedShop.value.isEmpty
                    ? null
                    : controller.selectedShop.value,
            hint: Text(
              "Filter by:Columns",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            items: [
              const DropdownMenuItem(
                value: "",
                child: Text("All Shops", style: TextStyle(fontSize: 14)),
              ),
              ...((controller.shops.value.shops?.data ?? []).where(
                (shop) => shop.id != null,
              )).map(
                (shop) => DropdownMenuItem(
                  value: shop.id,
                  child: Text(shop.name ?? '', style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
            onChanged: controller.onShopChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedStatus.value,
            hint: Text(
              "Filter by:Product",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            items: [
              const DropdownMenuItem(
                value: "active",
                child: Text("Active", style: TextStyle(fontSize: 14)),
              ),
              const DropdownMenuItem(
                value: "inactive",
                child: Text("Inactive", style: TextStyle(fontSize: 14)),
              ),
              const DropdownMenuItem(
                value: "",
                child: Text("All Status", style: TextStyle(fontSize: 14)),
              ),
            ],
            onChanged: controller.onStatusChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildMakeFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value:
                controller.selectedMake.value.isEmpty
                    ? null
                    : controller.selectedMake.value,
            hint: Text(
              "Filter by:Make",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            items: [
              const DropdownMenuItem(
                value: "",
                child: Text("All Makes", style: TextStyle(fontSize: 14)),
              ),
              ...(controller
                          .carMAKES
                          .value
                          .attributeItems
                          ?.productAttributeItems ??
                      [])
                  .map((ele) {
                    return DropdownMenuItem(
                      value: ele.id,
                      child: Text(
                        ele.name ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }),
            ],
            onChanged: controller.onMakeChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupByToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            "SKU",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const Spacer(),
          Obx(
            () => Switch(
              value: controller.groupBySku.value,
              onChanged: controller.toggleGroupBySku,
              activeThumbColor: const Color(0xFF4A9B8E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdownUpdated() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value:
                controller.selectedSort.value.isEmpty
                    ? null
                    : controller.selectedSort.value,
            hint: Text(
              "Sort by:Columns",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            items: [
              const DropdownMenuItem(
                value: "Default",
                child: Text("Default", style: TextStyle(fontSize: 14)),
              ),
              const DropdownMenuItem(
                value: "Price: Low to High",
                child: Text(
                  "Price: Low to High",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const DropdownMenuItem(
                value: "Price: High to Low",
                child: Text(
                  "Price: High to Low",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const DropdownMenuItem(
                value: "Recently Updated",
                child: Text("Recently Updated", style: TextStyle(fontSize: 14)),
              ),
              const DropdownMenuItem(
                value: "Most Viewed",
                child: Text("Most Viewed", style: TextStyle(fontSize: 14)),
              ),
            ],
            onChanged: controller.onSortChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Column(
      children: [
        // First Row
        Column(
          children: [
            _buildDateRangeField(),
            const SizedBox(height: 12),
            _buildSearchField(
              controller: controller.titleController,
              hint: "Search by : Title",
              icon: Icons.search,
              onChanged: controller.onSearchChanged,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildSearchField(
              controller: controller.idController,
              hint: "Search by : ID...",
              icon: Icons.tag,
              onChanged: controller.onSearchChanged,
            ),
            const SizedBox(height: 12),
            _buildSearchField(
              controller: controller.skuController,
              hint: "Search by : Sku",
              icon: Icons.qr_code,
              onChanged: controller.onSearchChanged,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second Row
        Row(
          children: [
            Expanded(child: _buildSortDropdownUpdated()),
            const SizedBox(width: 12),
            Expanded(child: _buildGroupByToggle()),
          ],
        ),
        const SizedBox(height: 12),
        // Third Row
        Row(
          children: [
            Expanded(child: _buildStatusFilter()),
            const SizedBox(width: 12),
            Expanded(child: _buildShopFilter()),
          ],
        ),
        const SizedBox(height: 12),
        // Fourth Row
        Row(
          children: [
            Expanded(child: _buildMakeFilter()),
            const SizedBox(width: 12),
            Expanded(child: Container()), // Empty space for balance
          ],
        ),
      ],
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      controller.onDateRangeSelected(
        picked.start.toIso8601String().split('T')[0],
        picked.end.toIso8601String().split('T')[0],
      );
    }
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    // Special styling for the first search field (Title search) to match image
    if (icon == Icons.search) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Search Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF4A9B8E), // Teal color matching the image
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),

            // Search Field
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Styled prefix icon for other search fields (ID, SKU)
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF4A9B8E), // Same teal color
              borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),

          // Search Field
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// cars_loading_widget.dart
class CarsLoadingWidget extends StatelessWidget {
  const CarsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildShimmerRow();
        },
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

// cars_empty_widget.dart
class CarsEmptyWidget extends StatelessWidget {
  const CarsEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No cars found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your search filters",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// cars_error_widget.dart
class CarsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CarsErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1e3c72),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
