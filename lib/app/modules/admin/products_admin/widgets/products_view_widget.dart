import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/core/widgets/buttons/gardient_button_with_left_arrow_and_text.dart';
import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/admin/products_admin/widgets/products_list_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.adminProductsService.updateSearchQuery(_searchController.text);
    });
    _idController.addListener(() {
      if (widget.adminProductsService.searchField.value == 'id') {
        widget.adminProductsService.updateSearchQuery(_idController.text);
      }
    });
    _skuController.addListener(() {
      if (widget.adminProductsService.searchField.value == 'sku') {
        widget.adminProductsService.updateSearchQuery(_skuController.text);
      }
    });
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
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Add New Product Button
                    GradientButtonWithLeftArrowAndText(
                      label: 'Add New Product',
                      icon: Icons.add,
                      onPressed: () {
                        Get.delete<AddProductAdminController>();
                        Get.offNamed(
                          Routes.ADD_PRODUCT_ADMIN_VIEW,
                          preventDuplicates: false,
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Filters and Search Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Section
                          _buildSearchSection(),
                          const SizedBox(height: 16),

                          // Filters Section
                          _buildFiltersSection(),
                          const SizedBox(height: 16),

                          // Active Filters Display
                          _buildActiveFilters(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Results Summary
                    _buildResultsSummary(),
                    const SizedBox(height: 8),

                    // Products List
                    AdminProductsList(
                      adminProductsService: widget.adminProductsService,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Products',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Search by Name
        _buildSearchField(
          controller: _searchController,
          label: 'Search by Name',
          hintText: 'Enter product name...',
          icon: Icons.search,
          onTap: () => widget.adminProductsService.updateSearchField('name'),
        ),
        const SizedBox(height: 12),

        // Search by ID and SKU in a Row
        Row(
          children: [
            Expanded(
              child: _buildSearchField(
                controller: _idController,
                label: 'Search by ID',
                hintText: 'Enter product ID...',
                icon: Icons.tag,
                onTap:
                    () => widget.adminProductsService.updateSearchField('id'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSearchField(
                controller: _skuController,
                label: 'Search by SKU',
                hintText: 'Enter SKU...',
                icon: Icons.qr_code,
                onTap:
                    () => widget.adminProductsService.updateSearchField('sku'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Status Filter
        _buildStatusFilter(),
        const SizedBox(height: 12),

        // Date Range Filter
        _buildDateRangeFilter(),
        const SizedBox(height: 12),

        // Predefined Filters
        _buildPredefinedFilters(),
        const SizedBox(height: 12),

        // Per Page Selection
        _buildPerPageSelector(),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                ProductStatus.values.map((status) {
                  final isSelected =
                      widget.adminProductsService.selectedStatus.value ==
                      status;
                  return FilterChip(
                    label: Text(status.name.capitalize ?? status.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      widget.adminProductsService.updateStatusFilter(status);
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.adminProductsService.startDate.value != null
                              ? DateFormat('MMM dd, yyyy').format(
                                widget.adminProductsService.startDate.value!,
                              )
                              : 'Start Date',
                          style: TextStyle(
                            color:
                                widget.adminProductsService.startDate.value !=
                                        null
                                    ? Colors.black87
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _selectEndDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.adminProductsService.endDate.value != null
                              ? DateFormat('MMM dd, yyyy').format(
                                widget.adminProductsService.endDate.value!,
                              )
                              : 'End Date',
                          style: TextStyle(
                            color:
                                widget.adminProductsService.endDate.value !=
                                        null
                                    ? Colors.black87
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  widget.adminProductsService.updateDateRange(null, null);
                },
                icon: const Icon(Icons.clear, color: Colors.red),
                tooltip: 'Clear Date Range',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredefinedFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Filters',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                widget.adminProductsService.getPredefinedFilters().map((
                  filter,
                ) {
                  final isActive = widget.adminProductsService.activeFilters
                      .any((f) => f.column == filter.column);
                  return FilterChip(
                    label: Text(filter.name),
                    selected: isActive,
                    onSelected: (selected) {
                      if (selected) {
                        widget.adminProductsService.addColumnFilter(filter);
                      } else {
                        widget.adminProductsService.removeColumnFilter(
                          filter.column,
                        );
                      }
                    },
                    selectedColor: Colors.green.shade100,
                    checkmarkColor: Colors.green,
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPerPageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items per page',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => DropdownButtonFormField<int>(
            initialValue: widget.adminProductsService.perPage.value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items:
                [10, 20, 40, 60, 100].map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value items'),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.adminProductsService.perPage.value = value;
                widget.adminProductsService.fetchProducts(refresh: true);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return Obx(() {
      final hasFilters =
          widget.adminProductsService.searchQuery.value.isNotEmpty ||
          widget.adminProductsService.selectedStatus.value !=
              ProductStatus.all ||
          widget.adminProductsService.activeFilters.isNotEmpty ||
          widget.adminProductsService.startDate.value != null;

      if (!hasFilters) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Filters',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  widget.adminProductsService.clearAllFilters();
                  _searchController.clear();
                  _idController.clear();
                  _skuController.clear();
                },
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              widget.adminProductsService.getFilterSummary(),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildResultsSummary() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${widget.adminProductsService.adminProducts.length} of ${widget.adminProductsService.totalItems.value} products',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: widget.adminProductsService.refreshProducts,
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Refresh',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                if (widget.adminProductsService.isRefreshing.value)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          widget.adminProductsService.startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Start Date',
    );
    if (picked != null) {
      widget.adminProductsService.updateDateRange(
        picked,
        widget.adminProductsService.endDate.value,
      );
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.adminProductsService.endDate.value ?? DateTime.now(),
      firstDate: widget.adminProductsService.startDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select End Date',
    );
    if (picked != null) {
      widget.adminProductsService.updateDateRange(
        widget.adminProductsService.startDate.value,
        picked,
      );
    }
  }
}

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
  final double width; // New parameter

  const OrderColumnWidget({
    super.key,
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textColor = Colors.black,
    this.hasIcon = false,
    this.icon = Icons.open_in_new,
    this.iconColor = Colors.red,
    this.hasImage = '',
    this.textAlign = TextAlign.left,
    this.width = 100, // Default width
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey), maxLines: 2),
          if (hasImage.isEmpty)
            SizedBox(
              child: Text(
                value,
                style: TextStyle(color: textColor),
                maxLines: 2,
                textAlign: textAlign,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (hasImage.isNotEmpty)
            CachedNetworkImage(
              imageUrl: value,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => SizedBox(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/icons/logo.png'),
                  ),
              errorWidget:
                  (context, url, error) => SizedBox(
                    height: 50,
                    width: 50,
                    child: Image.asset('assets/icons/logo.png'),
                  ),
            ),
        ],
      ),
    );
  }
}
