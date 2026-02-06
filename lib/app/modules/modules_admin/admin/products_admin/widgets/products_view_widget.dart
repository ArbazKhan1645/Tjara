import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/admin_products_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/products_list_widget.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';

class EnhancedProductsViewWidget extends StatefulWidget {
  final bool isAppBarExpanded;
  final AdminProductsService adminProductsService;

  const EnhancedProductsViewWidget({
    super.key,
    required this.isAppBarExpanded,
    required this.adminProductsService,
  });

  @override
  State<EnhancedProductsViewWidget> createState() =>
      _EnhancedProductsViewWidgetState();
}

class _EnhancedProductsViewWidgetState
    extends State<EnhancedProductsViewWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();

  AdminProductsService get _service => widget.adminProductsService;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _idController.addListener(_onIdChanged);
    _skuController.addListener(_onSkuChanged);
  }

  void _onSearchChanged() {
    _service.updateSearchQuery(_searchController.text);
  }

  void _onIdChanged() {
    if (_service.searchField.value == 'id') {
      _service.updateSearchQuery(_idController.text);
    }
  }

  void _onSkuChanged() {
    if (_service.searchField.value == 'sku') {
      _service.updateSearchQuery(_skuController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _idController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        AdminSliverAppBarWidget(
          title: 'Dashboard',
          isAppBarExpanded: widget.isAppBarExpanded,
          actions: const [AdminAppBarActions()],
        ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              AdminHeaderAnimatedBackgroundWidget(
                isAppBarExpanded: widget.isAppBarExpanded,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminProductsTheme.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AdminProductsTheme.spacingLg),
                    _buildFiltersCard(),
                    const SizedBox(height: AdminProductsTheme.spacingLg),
                    _buildResultsSummary(),
                    const SizedBox(height: AdminProductsTheme.spacingSm),
                    AdminProductsList(adminProductsService: _service),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        _buildAddProductButton(),
      ],
    );
  }

  Widget _buildAddProductButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.delete<AddProductAdminController>();
          Get.offNamed(Routes.ADD_PRODUCT_ADMIN_VIEW, preventDuplicates: false);
        },
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminProductsTheme.spacingLg,
            vertical: AdminProductsTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusMd),
            boxShadow: AdminProductsTheme.shadowMd,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AdminProductsTheme.primary,
                  borderRadius: BorderRadius.circular(
                    AdminProductsTheme.radiusSm,
                  ),
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
              const SizedBox(width: AdminProductsTheme.spacingSm),
              const Text(
                'Add New Product',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AdminProductsTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(AdminProductsTheme.spacingXl),
      decoration: AdminProductsTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchSection(),
          const SizedBox(height: AdminProductsTheme.spacingXl),
          _buildFiltersSection(),
          _buildActiveFilters(),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: AdminProductsTheme.primary,
            ),
            const SizedBox(width: AdminProductsTheme.spacingSm),
            Text(
              'Search Products',
              style: AdminProductsTheme.headingSmall.copyWith(
                color: AdminProductsTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminProductsTheme.spacingMd),

        // Main search field
        _buildSearchField(
          controller: _searchController,
          hintText: 'Search by product name...',
          icon: Icons.search,
          onTap: () => _service.updateSearchField('name'),
        ),
        const SizedBox(height: AdminProductsTheme.spacingMd),

        // ID and SKU search in row
        Row(
          children: [
            Expanded(
              child: _buildSearchField(
                controller: _idController,
                hintText: 'Search by ID',
                icon: Icons.tag,
                onTap: () => _service.updateSearchField('id'),
              ),
            ),
            const SizedBox(width: AdminProductsTheme.spacingMd),
            Expanded(
              child: _buildSearchField(
                controller: _skuController,
                hintText: 'Search by SKU',
                icon: Icons.qr_code_2,
                onTap: () => _service.updateSearchField('sku'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      onTap: onTap,
      style: AdminProductsTheme.bodyLarge,
      decoration: AdminProductsTheme.inputDecoration(
        hintText: hintText,
        prefixIcon: icon,
        suffix:
            controller.text.isNotEmpty
                ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    _service.updateSearchQuery('');
                  },
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AdminProductsTheme.textTertiary,
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.filter_list_rounded,
              size: 20,
              color: AdminProductsTheme.primary,
            ),
            const SizedBox(width: AdminProductsTheme.spacingSm),
            Text(
              'Filters',
              style: AdminProductsTheme.headingSmall.copyWith(
                color: AdminProductsTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminProductsTheme.spacingMd),

        // Status Filter
        _buildStatusFilter(),
        const SizedBox(height: AdminProductsTheme.spacingLg),

        // Date Range and Per Page in row
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildDateRangeFilter()),
                  const SizedBox(width: AdminProductsTheme.spacingXl),
                  SizedBox(width: 200, child: _buildPerPageSelector()),
                ],
              );
            }
            return Column(
              children: [
                _buildDateRangeFilter(),
                const SizedBox(height: AdminProductsTheme.spacingLg),
                _buildPerPageSelector(),
              ],
            );
          },
        ),
        const SizedBox(height: AdminProductsTheme.spacingLg),

        // Quick Filters
        _buildQuickFilters(),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Obx(() {
      final selectedStatus = _service.selectedStatus.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STATUS', style: AdminProductsTheme.labelMedium),
          const SizedBox(height: AdminProductsTheme.spacingSm),
          Wrap(
            spacing: AdminProductsTheme.spacingSm,
            runSpacing: AdminProductsTheme.spacingSm,
            children:
                ProductStatus.values.map((status) {
                  final isSelected = selectedStatus == status;
                  return _buildFilterChip(
                    label: _formatStatusLabel(status.name),
                    isSelected: isSelected,
                    onTap: () => _service.updateStatusFilter(status),
                    color: _getStatusColor(status),
                  );
                }).toList(),
          ),
        ],
      );
    });
  }

  String _formatStatusLabel(String name) {
    return name.substring(0, 1).toUpperCase() + name.substring(1);
  }

  Color _getStatusColor(ProductStatus status) {
    switch (status) {
      case ProductStatus.all:
        return AdminProductsTheme.primary;
      case ProductStatus.active:
        return AdminProductsTheme.success;
      case ProductStatus.inactive:
        return AdminProductsTheme.error;
      case ProductStatus.deleted:
        return AdminProductsTheme.textTertiary;
    }
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AdminProductsTheme.spacingMd,
            vertical: AdminProductsTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? color.withValues(alpha: 0.1)
                    : AdminProductsTheme.surface,
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
            border: Border.all(
              color: isSelected ? color : AdminProductsTheme.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(Icons.check, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? color : AdminProductsTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Obx(() {
      final startDate = _service.startDate.value;
      final endDate = _service.endDate.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DATE RANGE', style: AdminProductsTheme.labelMedium),
          const SizedBox(height: AdminProductsTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Start Date',
                  date: startDate,
                  onTap: _selectStartDate,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AdminProductsTheme.spacingSm,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AdminProductsTheme.textTertiary,
                ),
              ),
              Expanded(
                child: _buildDateButton(
                  label: 'End Date',
                  date: endDate,
                  onTap: _selectEndDate,
                ),
              ),
              if (startDate != null || endDate != null) ...[
                const SizedBox(width: AdminProductsTheme.spacingSm),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _service.updateDateRange(null, null),
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdminProductsTheme.errorLight,
                        borderRadius: BorderRadius.circular(
                          AdminProductsTheme.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AdminProductsTheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminProductsTheme.spacingMd,
            vertical: AdminProductsTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: AdminProductsTheme.surface,
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusMd),
            border: Border.all(
              color:
                  date != null
                      ? AdminProductsTheme.primary
                      : AdminProductsTheme.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color:
                    date != null
                        ? AdminProductsTheme.primary
                        : AdminProductsTheme.textTertiary,
              ),
              const SizedBox(width: AdminProductsTheme.spacingSm),
              Expanded(
                child: Text(
                  date != null
                      ? DateFormat('MMM dd, yyyy').format(date)
                      : label,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        date != null
                            ? AdminProductsTheme.textPrimary
                            : AdminProductsTheme.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK FILTERS', style: AdminProductsTheme.labelMedium),
        const SizedBox(height: AdminProductsTheme.spacingSm),
        Obx(() {
          final filters = _service.getPredefinedFilters();
          return Wrap(
            spacing: AdminProductsTheme.spacingSm,
            runSpacing: AdminProductsTheme.spacingSm,
            children:
                filters.map((filter) {
                  final isActive = _service.activeFilters.any(
                    (f) => f.column == filter.column,
                  );
                  return _buildFilterChip(
                    label: filter.name,
                    isSelected: isActive,
                    onTap: () {
                      if (isActive) {
                        _service.removeColumnFilter(filter.column);
                      } else {
                        _service.addColumnFilter(filter);
                      }
                    },
                    color: AdminProductsTheme.secondary,
                  );
                }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPerPageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ITEMS PER PAGE', style: AdminProductsTheme.labelMedium),
        const SizedBox(height: AdminProductsTheme.spacingSm),
        Obx(() {
          final perPage = _service.perPage.value;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminProductsTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AdminProductsTheme.surface,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusMd),
              border: Border.all(color: AdminProductsTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: perPage,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AdminProductsTheme.textSecondary,
                ),
                style: AdminProductsTheme.bodyLarge,
                items:
                    [10, 20, 40, 60, 100].map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value items'),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _service.perPage.value = value;
                    _service.fetchProducts(refresh: true);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return Obx(() {
      final hasFilters =
          _service.searchQuery.value.isNotEmpty ||
          _service.selectedStatus.value != ProductStatus.all ||
          _service.activeFilters.isNotEmpty ||
          _service.startDate.value != null;

      if (!hasFilters) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: AdminProductsTheme.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      size: 18,
                      color: AdminProductsTheme.primary,
                    ),
                    SizedBox(width: AdminProductsTheme.spacingSm),
                    Text(
                      'Active Filters',
                      style: AdminProductsTheme.headingSmall,
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AdminProductsTheme.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AdminProductsTheme.spacingMd,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminProductsTheme.spacingSm),
            Container(
              padding: const EdgeInsets.all(AdminProductsTheme.spacingMd),
              decoration: BoxDecoration(
                color: AdminProductsTheme.primaryLight,
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusMd,
                ),
                border: Border.all(
                  color: AdminProductsTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AdminProductsTheme.primary,
                  ),
                  const SizedBox(width: AdminProductsTheme.spacingSm),
                  Expanded(
                    child: Text(
                      _service.getFilterSummary(),
                      style: AdminProductsTheme.bodySmall.copyWith(
                        color: AdminProductsTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _clearAllFilters() {
    _service.clearAllFilters();
    _searchController.clear();
    _idController.clear();
    _skuController.clear();
  }

  Widget _buildResultsSummary() {
    return Obx(() {
      final productCount = _service.adminProducts.length;
      final totalItems = _service.totalItems.value;
      final isRefreshing = _service.isRefreshing.value;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminProductsTheme.spacingLg,
          vertical: AdminProductsTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: AdminProductsTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(AdminProductsTheme.radiusMd),
          border: Border.all(color: AdminProductsTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.primaryLight,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: AdminProductsTheme.primary,
                  ),
                ),
                const SizedBox(width: AdminProductsTheme.spacingMd),
                RichText(
                  text: TextSpan(
                    style: AdminProductsTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Showing '),
                      TextSpan(
                        text: '$productCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AdminProductsTheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' of '),
                      TextSpan(
                        text: '$totalItems',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' products'),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (isRefreshing)
                  const Padding(
                    padding: EdgeInsets.only(
                      right: AdminProductsTheme.spacingSm,
                    ),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AdminProductsTheme.primary,
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _service.refreshProducts,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusSm,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdminProductsTheme.surface,
                        borderRadius: BorderRadius.circular(
                          AdminProductsTheme.radiusSm,
                        ),
                        border: Border.all(color: AdminProductsTheme.border),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: AdminProductsTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Future<void> _selectStartDate() async {
    final startDate = _service.startDate.value;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Start Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminProductsTheme.primary,
              onPrimary: Colors.white,
              surface: AdminProductsTheme.surface,
              onSurface: AdminProductsTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _service.updateDateRange(picked, _service.endDate.value);
    }
  }

  Future<void> _selectEndDate() async {
    final startDate = _service.startDate.value;
    final endDate = _service.endDate.value;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select End Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminProductsTheme.primary,
              onPrimary: Colors.white,
              surface: AdminProductsTheme.surface,
              onSurface: AdminProductsTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _service.updateDateRange(_service.startDate.value, picked);
    }
  }
}

/// Reusable column widget for product data display
class OrderColumnWidget extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final Color textColor;
  final bool hasIcon;
  final IconData icon;
  final Color iconColor;
  final String hasImage;
  final TextAlign textAlign;
  final double width;

  const OrderColumnWidget({
    super.key,
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textColor = AdminProductsTheme.textPrimary,
    this.hasIcon = false,
    this.icon = Icons.open_in_new,
    this.iconColor = AdminProductsTheme.error,
    this.hasImage = '',
    this.textAlign = TextAlign.left,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            label.toUpperCase(),
            style: AdminProductsTheme.labelMedium.copyWith(
              fontSize: 10,
              letterSpacing: 0.5,
              color: AdminProductsTheme.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          if (hasImage.isEmpty)
            Text(
              value,
              style: AdminProductsTheme.bodyMedium.copyWith(color: textColor),
              maxLines: 2,
              textAlign: textAlign,
              overflow: TextOverflow.ellipsis,
            ),
          if (hasImage.isNotEmpty)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusSm,
                ),
                border: Border.all(color: AdminProductsTheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AdminProductsTheme.radiusSm - 1,
                ),
                child: CachedNetworkImage(
                  imageUrl: value,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: AdminProductsTheme.surfaceSecondary,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 20,
                            color: AdminProductsTheme.textTertiary,
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: AdminProductsTheme.surfaceSecondary,
                        child: Image.asset(
                          'assets/icons/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
