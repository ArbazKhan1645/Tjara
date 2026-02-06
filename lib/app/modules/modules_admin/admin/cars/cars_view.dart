import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/controllers/cars_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/widgets/action_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/widgets/cars_admin_theme.dart';

class CarsView extends GetView<CarsController> {
  const CarsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarsController>(
      init: CarsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: CarsAdminTheme.background,
          appBar: _buildAppBar(),
          body: _buildBody(context),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [CarsAdminTheme.primary, CarsAdminTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: const [AdminAppBarActionsSimple()],
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Row(
        children: [
          Text(
            'Cars Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      elevation: 0,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(context),
        vertical: CarsAdminTheme.spacingLg,
      ),
      child: ListView(
        children: [
          // Filter Section
          const CarsFilterWidget(),
          const SizedBox(height: CarsAdminTheme.spacingXl),

          // Table Section
          _buildTableContainer(),
        ],
      ),
    );
  }

  Widget _buildTableContainer() {
    return Container(
      decoration: CarsAdminTheme.elevatedCardDecoration,
      child: Column(
        children: [
          // Pagination (above table)
          Obx(() {
            if (controller.viewState.value == ViewState.success) {
              return const CarsPaginationWidget();
            }
            return const SizedBox.shrink();
          }),

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

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 32;
    if (width > 768) return 24;
    return 16;
  }
}

/// Cars Filter Widget
class CarsFilterWidget extends GetView<CarsController> {
  const CarsFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CarsAdminTheme.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(CarsAdminTheme.spacingLg),
            decoration: CarsAdminTheme.sectionHeaderDecoration,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(CarsAdminTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      CarsAdminTheme.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: CarsAdminTheme.spacingMd),
                const Expanded(
                  child: Text(
                    'Cars',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CarsAdminTheme.spacingMd,
                      vertical: CarsAdminTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        CarsAdminTheme.radiusXl,
                      ),
                    ),
                    child: Text(
                      '${controller.totalItems.value} items',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters Content
          Padding(
            padding: const EdgeInsets.all(CarsAdminTheme.spacingXl),
            child: _buildFilterFields(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterFields() {
    return Column(
      children: [
        _buildDateRangeField(),
        SizedBox(height: 4),
        _buildSearchField(
          controller: controller.titleController,
          hint: 'Search by title',
          icon: Icons.search_rounded,
          onChanged: controller.onSearchChanged,
        ),
        SizedBox(height: 4),
        _buildSearchField(
          controller: controller.idController,
          hint: 'Search by ID',
          icon: Icons.tag_rounded,
          onChanged: controller.onSearchChanged,
        ),
        SizedBox(height: 4),
        _buildSearchField(
          controller: controller.skuController,
          hint: 'Search by SKU',
          icon: Icons.qr_code_rounded,
          onChanged: controller.onSearchChanged,
        ),

        const SizedBox(height: CarsAdminTheme.spacingMd),

        // Sort and SKU Toggle
        _buildGroupByToggle(),
        const SizedBox(height: CarsAdminTheme.spacingMd),

        // Status and Shop Filter
        Row(
          children: [
            Expanded(child: _buildStatusFilter()),
            const SizedBox(width: CarsAdminTheme.spacingMd),
            Expanded(child: _buildShopFilter()),
          ],
        ),
        const SizedBox(height: CarsAdminTheme.spacingMd),

        // Make Filter
        Row(
          children: [
            Expanded(child: _buildMakeFilter()),
            const SizedBox(width: CarsAdminTheme.spacingMd),
            Expanded(child: _buildSortDropdown()),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: CarsAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        border: Border.all(color: CarsAdminTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: CarsAdminTheme.secondary,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(CarsAdminTheme.radiusMd - 1),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: CarsAdminTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: CarsAdminTheme.textTertiary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: CarsAdminTheme.spacingLg,
                  vertical: CarsAdminTheme.spacingMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeField() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showDateRangePicker,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: CarsAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
            border: Border.all(color: CarsAdminTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: CarsAdminTheme.secondary,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(CarsAdminTheme.radiusMd - 1),
                  ),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarsAdminTheme.spacingLg,
                  ),
                  child: Obx(
                    () => Text(
                      controller.selectedDateRange.value.isEmpty
                          ? 'Select date range'
                          : controller.selectedDateRange.value,
                      style: TextStyle(
                        color:
                            controller.selectedDateRange.value.isEmpty
                                ? CarsAdminTheme.textTertiary
                                : CarsAdminTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: CarsAdminTheme.spacingLg),
      decoration: BoxDecoration(
        color: CarsAdminTheme.surface,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        border: Border.all(color: CarsAdminTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value:
                controller.selectedSort.value.isEmpty
                    ? null
                    : controller.selectedSort.value,
            hint: const Text(
              'Sort by',
              style: TextStyle(
                color: CarsAdminTheme.textTertiary,
                fontSize: 14,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: CarsAdminTheme.textSecondary,
            ),
            items: const [
              DropdownMenuItem(value: 'Default', child: Text('Default')),
              DropdownMenuItem(
                value: 'Price: Low to High',
                child: Text('Price: Low to High'),
              ),
              DropdownMenuItem(
                value: 'Price: High to Low',
                child: Text('Price: High to Low'),
              ),
              DropdownMenuItem(
                value: 'Recently Updated',
                child: Text('Recently Updated'),
              ),
              DropdownMenuItem(
                value: 'Most Viewed',
                child: Text('Most Viewed'),
              ),
            ],
            onChanged: controller.onSortChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupByToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: CarsAdminTheme.spacingLg),
      decoration: BoxDecoration(
        color: CarsAdminTheme.surface,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        border: Border.all(color: CarsAdminTheme.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_rounded,
            color: CarsAdminTheme.textSecondary,
            size: 18,
          ),
          const SizedBox(width: CarsAdminTheme.spacingSm),
          const Text(
            'Group by SKU',
            style: TextStyle(color: CarsAdminTheme.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Obx(
            () => Switch(
              value: controller.groupBySku.value,
              onChanged: controller.toggleGroupBySku,
              activeThumbColor: CarsAdminTheme.secondary,
              activeTrackColor: CarsAdminTheme.secondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: CarsAdminTheme.spacingLg),
      decoration: BoxDecoration(
        color: CarsAdminTheme.surface,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        border: Border.all(color: CarsAdminTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedStatus.value,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: CarsAdminTheme.textSecondary,
            ),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              DropdownMenuItem(value: '', child: Text('All Status')),
            ],
            onChanged: controller.onStatusChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildShopFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: CarsAdminTheme.spacingLg),
      decoration: BoxDecoration(
        color: CarsAdminTheme.surface,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        border: Border.all(color: CarsAdminTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value:
                controller.selectedShop.value.isEmpty
                    ? null
                    : controller.selectedShop.value,
            hint: const Text(
              'Filter by shop',
              style: TextStyle(
                color: CarsAdminTheme.textTertiary,
                fontSize: 14,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: CarsAdminTheme.textSecondary,
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('All Shops')),
              ...((controller.shops.value.shops?.data ?? []).where(
                (shop) => shop.id != null,
              )).map(
                (shop) => DropdownMenuItem(
                  value: shop.id,
                  child: Text(
                    shop.name ?? '',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: controller.onShopChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildMakeFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: CarsAdminTheme.spacingLg),
      decoration: BoxDecoration(
        color: CarsAdminTheme.surface,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        border: Border.all(color: CarsAdminTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value:
                controller.selectedMake.value.isEmpty
                    ? null
                    : controller.selectedMake.value,
            hint: const Text(
              'Filter by make',
              style: TextStyle(
                color: CarsAdminTheme.textTertiary,
                fontSize: 14,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: CarsAdminTheme.textSecondary,
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('All Makes')),
              ...(controller
                          .carMAKES
                          .value
                          .attributeItems
                          ?.productAttributeItems ??
                      [])
                  .map(
                    (ele) => DropdownMenuItem(
                      value: ele.id,
                      child: Text(
                        ele.name ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
            ],
            onChanged: controller.onMakeChanged,
          ),
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CarsAdminTheme.primary,
              onPrimary: Colors.white,
              surface: CarsAdminTheme.surface,
              onSurface: CarsAdminTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.onDateRangeSelected(
        picked.start.toIso8601String().split('T')[0],
        picked.end.toIso8601String().split('T')[0],
      );
    }
  }
}

/// Cars Loading Widget
class CarsLoadingWidget extends StatelessWidget {
  const CarsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CarsAdminTheme.border,
      highlightColor: CarsAdminTheme.surfaceSecondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(CarsAdminTheme.spacingXl),
        itemCount: 8,
        itemBuilder: (context, index) {
          return _buildShimmerRow();
        },
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: CarsAdminTheme.spacingLg),
      padding: const EdgeInsets.all(CarsAdminTheme.spacingMd),
      decoration: BoxDecoration(
        color: CarsAdminTheme.surface,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
      ),
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
          const SizedBox(width: CarsAdminTheme.spacingLg),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
            ),
          ),
          const SizedBox(width: CarsAdminTheme.spacingLg),
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
                const SizedBox(height: CarsAdminTheme.spacingSm),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
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

/// Cars Empty Widget
class CarsEmptyWidget extends StatelessWidget {
  const CarsEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(CarsAdminTheme.spacingXl),
            decoration: const BoxDecoration(
              color: CarsAdminTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: CarsAdminTheme.primary,
            ),
          ),
          const SizedBox(height: CarsAdminTheme.spacingXl),
          const Text(
            'No Cars Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CarsAdminTheme.textPrimary,
            ),
          ),
          const SizedBox(height: CarsAdminTheme.spacingSm),
          const Text(
            'Try adjusting your search filters',
            style: TextStyle(fontSize: 14, color: CarsAdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Cars Error Widget
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
          Container(
            padding: const EdgeInsets.all(CarsAdminTheme.spacingXl),
            decoration: const BoxDecoration(
              color: CarsAdminTheme.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: CarsAdminTheme.error,
            ),
          ),
          const SizedBox(height: CarsAdminTheme.spacingXl),
          const Text(
            'Something Went Wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CarsAdminTheme.textPrimary,
            ),
          ),
          const SizedBox(height: CarsAdminTheme.spacingSm),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: CarsAdminTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: CarsAdminTheme.spacingXl),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CarsAdminTheme.spacingXl,
                  vertical: CarsAdminTheme.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: CarsAdminTheme.primary,
                  borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
                  boxShadow: CarsAdminTheme.shadowColored(
                    CarsAdminTheme.primary,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: CarsAdminTheme.spacingSm),
                    Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
