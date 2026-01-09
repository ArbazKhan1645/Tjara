import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/core/widgets/buttons/gardient_button_with_left_arrow_and_text.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/admin/auction_admin/widgets/products_list_widget.dart';
import 'package:tjara/app/routes/app_pages.dart';

import 'package:tjara/app/services/dashbopard_services/admin_auction_service.dart';

class EnhancedAuctionViewWidget extends StatefulWidget {
  final bool isAppBarExpanded;
  final AdminAuctionService adminAuctionService;

  const EnhancedAuctionViewWidget({
    super.key,
    required this.isAppBarExpanded,
    required this.adminAuctionService,
  });

  @override
  State<EnhancedAuctionViewWidget> createState() =>
      _EnhancedAuctionViewWidgetState();
}

class _EnhancedAuctionViewWidgetState extends State<EnhancedAuctionViewWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.adminAuctionService.updateSearchQuery(_searchController.text);
    });
    _idController.addListener(() {
      if (widget.adminAuctionService.searchField.value == 'id') {
        widget.adminAuctionService.updateSearchQuery(_idController.text);
      }
    });
    _skuController.addListener(() {
      if (widget.adminAuctionService.searchField.value == 'sku') {
        widget.adminAuctionService.updateSearchQuery(_skuController.text);
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
                      'Auctions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Add New Product Button
                    GradientButtonWithLeftArrowAndText(
                      label: 'Add New Auction',
                      icon: Icons.add,
                      onPressed: () {
                        Get.delete<AuctionAddProductAdminController>();
                        Get.toNamed(
                          Routes.ADD_AUCTION_PRODUCT_ADMIN_VIEW,
                          preventDuplicates: false,
                        )?.then((value) {
                          widget.adminAuctionService.refreshProducts();
                        });
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
                    AdminAuctionList(
                      adminProductsService: widget.adminAuctionService,
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
                // v: Radius.circular(12),
                left: Radius.circular(12),
              ),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 20),
          ),

          // Search Field
          Expanded(
            child: TextField(
              controller: _searchController,
              onTap: () => widget.adminAuctionService.updateSearchField('name'),
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

        // // Predefined Filters
        // _buildPredefinedFilters(),
        const SizedBox(height: 12),

        // Per Page Selection
        // _buildPerPageSelector(),
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
                      widget.adminAuctionService.selectedStatus.value == status;
                  return FilterChip(
                    label: Text(status.name.capitalize ?? status.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      widget.adminAuctionService.updateStatusFilter(status);
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: const Color(0xFF4A9B8E),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date Range',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (widget.adminAuctionService.startDate.value != null ||
                  widget.adminAuctionService.endDate.value != null)
                TextButton.icon(
                  onPressed: () {
                    widget.adminAuctionService.updateDateRange(null, null);
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                // Start Date
                _buildDatePickerTile(
                  label: 'From',
                  date: widget.adminAuctionService.startDate.value,
                  onTap: _selectStartDate,
                  icon: Icons.event_available,
                  isFirst: true,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                  indent: 16,
                  endIndent: 16,
                ),
                // End Date
                _buildDatePickerTile(
                  label: 'To',
                  date: widget.adminAuctionService.endDate.value,
                  onTap: _selectEndDate,
                  icon: Icons.event_busy,
                  isFirst: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
    required bool isFirst,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: !isFirst ? const Radius.circular(12) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      date != null
                          ? const Color(0xFF4A9B8E).withOpacity(0.1)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color:
                      date != null
                          ? const Color(0xFF4A9B8E)
                          : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date != null
                          ? DateFormat('EEEE, MMM dd, yyyy').format(date)
                          : 'Select ${label.toLowerCase()} date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            date != null
                                ? Colors.black87
                                : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
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
                widget.adminAuctionService.getPredefinedFilters().map((filter) {
                  final isActive = widget.adminAuctionService.activeFilters.any(
                    (f) => f.column == filter.column,
                  );
                  return FilterChip(
                    label: Text(filter.name),
                    selected: isActive,
                    onSelected: (selected) {
                      if (selected) {
                        widget.adminAuctionService.addColumnFilter(filter);
                      } else {
                        widget.adminAuctionService.removeColumnFilter(
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316), // Orange color matching the image
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: widget.adminAuctionService.perPage.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 24,
                ),
                dropdownColor: const Color(0xFFF97316),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                items:
                    [10, 20, 40, 60, 100].map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$value',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.adminAuctionService.perPage.value = value;
                    widget.adminAuctionService.fetchProducts(refresh: true);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    return Obx(() {
      final hasFilters =
          widget.adminAuctionService.searchQuery.value.isNotEmpty ||
          widget.adminAuctionService.selectedStatus.value !=
              ProductStatus.all ||
          widget.adminAuctionService.activeFilters.isNotEmpty ||
          widget.adminAuctionService.startDate.value != null;

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
                  widget.adminAuctionService.clearAllFilters();
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
              widget.adminAuctionService.getFilterSummary(),
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
              'Showing ${widget.adminAuctionService.adminProducts.length} of ${widget.adminAuctionService.totalItems.value} Auctions',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: widget.adminAuctionService.refreshProducts,
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Refresh',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                if (widget.adminAuctionService.isRefreshing.value)
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
      initialDate: widget.adminAuctionService.startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Start Date',
    );
    if (picked != null) {
      widget.adminAuctionService.updateDateRange(
        picked,
        widget.adminAuctionService.endDate.value,
      );
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.adminAuctionService.endDate.value ?? DateTime.now(),
      firstDate: widget.adminAuctionService.startDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select End Date',
    );
    if (picked != null) {
      widget.adminAuctionService.updateDateRange(
        widget.adminAuctionService.startDate.value,
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
