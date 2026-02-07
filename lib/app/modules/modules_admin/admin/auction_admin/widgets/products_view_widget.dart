import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/auction_admin/widgets/products_list_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.adminAuctionService.updateSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                  horizontal: AuctionAdminTheme.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _AuctionHeader(
                      onAddAuction: () {
                        Get.delete<AuctionAddProductAdminController>();
                        Get.toNamed(
                          Routes.ADD_AUCTION_PRODUCT_ADMIN_VIEW,
                          preventDuplicates: false,
                        )?.then((value) {
                          widget.adminAuctionService.refreshProducts();
                        });
                      },
                    ),
                    const SizedBox(height: AuctionAdminTheme.spacingMd),

                    // Filters Card
                    _FiltersCard(
                      searchController: _searchController,
                      adminAuctionService: widget.adminAuctionService,
                      onSelectStartDate: _selectStartDate,
                      onSelectEndDate: _selectEndDate,
                    ),
                    const SizedBox(height: AuctionAdminTheme.spacingLg),

                    // Results Summary
                    _ResultsSummary(
                      adminAuctionService: widget.adminAuctionService,
                      onClearFilters: () {
                        widget.adminAuctionService.clearAllFilters();
                        _searchController.clear();
                      },
                    ),
                    const SizedBox(height: AuctionAdminTheme.spacingSm),

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

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.adminAuctionService.startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Start Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AuctionAdminTheme.accent,
              onPrimary: Colors.white,
              surface: AuctionAdminTheme.surface,
              onSurface: AuctionAdminTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AuctionAdminTheme.accent,
              onPrimary: Colors.white,
              surface: AuctionAdminTheme.surface,
              onSurface: AuctionAdminTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.adminAuctionService.updateDateRange(
        widget.adminAuctionService.startDate.value,
        picked,
      );
    }
  }
}

/// Auction Header Widget
class _AuctionHeader extends StatelessWidget {
  final VoidCallback onAddAuction;

  const _AuctionHeader({required this.onAddAuction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auctions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        _AddAuctionButton(onTap: onAddAuction),
      ],
    );
  }
}

/// Add Auction Button Widget
class _AddAuctionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAuctionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AuctionAdminTheme.spacingLg,
            vertical: AuctionAdminTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AuctionAdminTheme.primary,
                AuctionAdminTheme.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            boxShadow: AuctionAdminTheme.shadowColored(
              AuctionAdminTheme.primary,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              SizedBox(width: AuctionAdminTheme.spacingSm),
              Text(
                'Add Auction',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Filters Card Widget
class _FiltersCard extends StatelessWidget {
  final TextEditingController searchController;
  final AdminAuctionService adminAuctionService;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;

  const _FiltersCard({
    required this.searchController,
    required this.adminAuctionService,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AuctionAdminTheme.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
            decoration: AuctionAdminTheme.sectionHeaderDecoration,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AuctionAdminTheme.spacingMd),
                const Expanded(
                  child: Text(
                    'Search & Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                _SearchField(
                  controller: searchController,
                  adminAuctionService: adminAuctionService,
                ),
                const SizedBox(height: AuctionAdminTheme.spacingXl),

                // Status Filter
                _StatusFilter(adminAuctionService: adminAuctionService),
                const SizedBox(height: AuctionAdminTheme.spacingXl),

                // Date Range Filter
                _DateRangeFilter(
                  adminAuctionService: adminAuctionService,
                  onSelectStartDate: onSelectStartDate,
                  onSelectEndDate: onSelectEndDate,
                ),
                const SizedBox(height: AuctionAdminTheme.spacingLg),

                // Active Filters Display
                _ActiveFiltersDisplay(
                  adminAuctionService: adminAuctionService,
                  searchController: searchController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Search Field Widget
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final AdminAuctionService adminAuctionService;

  const _SearchField({
    required this.controller,
    required this.adminAuctionService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Search Auctions',
          description: 'Find auctions by name, ID, or SKU',
        ),
        Container(
          decoration: BoxDecoration(
            color: AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            border: Border.all(color: AuctionAdminTheme.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
                decoration: const BoxDecoration(
                  color: AuctionAdminTheme.accent,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AuctionAdminTheme.radiusMd - 1),
                  ),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onTap: () => adminAuctionService.updateSearchField('name'),
                  style: AuctionAdminTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Search auctions...',
                    hintStyle: TextStyle(
                      color: AuctionAdminTheme.textTertiary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AuctionAdminTheme.spacingLg,
                      vertical: AuctionAdminTheme.spacingMd,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Status Filter Widget
class _StatusFilter extends StatelessWidget {
  final AdminAuctionService adminAuctionService;

  const _StatusFilter({required this.adminAuctionService});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.infoLight,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: AuctionAdminTheme.info,
                size: 16,
              ),
            ),
            const SizedBox(width: AuctionAdminTheme.spacingMd),
            const Text('Status Filter', style: AuctionAdminTheme.headingSmall),
          ],
        ),
        const SizedBox(height: AuctionAdminTheme.spacingMd),
        Obx(
          () => Wrap(
            spacing: AuctionAdminTheme.spacingSm,
            runSpacing: AuctionAdminTheme.spacingSm,
            children:
                ProductStatus.values.map((status) {
                  final isSelected =
                      adminAuctionService.selectedStatus.value == status;
                  return _StatusChip(
                    label: status.name.capitalize ?? status.name,
                    isSelected: isSelected,
                    onTap: () => adminAuctionService.updateStatusFilter(status),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Status Chip Widget
class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AuctionAdminTheme.spacingMd,
            vertical: AuctionAdminTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AuctionAdminTheme.accent.withValues(alpha: 0.1)
                    : AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            border: Border.all(
              color:
                  isSelected
                      ? AuctionAdminTheme.accent
                      : AuctionAdminTheme.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(
                  Icons.check_circle_rounded,
                  color: AuctionAdminTheme.accent,
                  size: 16,
                ),
                const SizedBox(width: AuctionAdminTheme.spacingXs),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? AuctionAdminTheme.accent
                          : AuctionAdminTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date Range Filter Widget
class _DateRangeFilter extends StatelessWidget {
  final AdminAuctionService adminAuctionService;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;

  const _DateRangeFilter({
    required this.adminAuctionService,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.primaryLight,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              ),
              child: const Icon(
                Icons.date_range_rounded,
                color: AuctionAdminTheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: AuctionAdminTheme.spacingMd),
            const Expanded(
              child: Text('Date Range', style: AuctionAdminTheme.headingSmall),
            ),
            Obx(() {
              final hasDateFilter =
                  adminAuctionService.startDate.value != null ||
                  adminAuctionService.endDate.value != null;
              if (!hasDateFilter) return const SizedBox.shrink();

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => adminAuctionService.updateDateRange(null, null),
                  borderRadius: BorderRadius.circular(
                    AuctionAdminTheme.radiusSm,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuctionAdminTheme.spacingSm,
                      vertical: AuctionAdminTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: AuctionAdminTheme.errorLight,
                      borderRadius: BorderRadius.circular(
                        AuctionAdminTheme.radiusSm,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear_rounded,
                          color: AuctionAdminTheme.error,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AuctionAdminTheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: AuctionAdminTheme.spacingMd),
        Container(
          decoration: BoxDecoration(
            color: AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            border: Border.all(color: AuctionAdminTheme.border),
          ),
          child: Obx(
            () => Column(
              children: [
                _DatePickerTile(
                  label: 'From',
                  date: adminAuctionService.startDate.value,
                  onTap: onSelectStartDate,
                  icon: Icons.event_available_rounded,
                  isFirst: true,
                  accentColor: AuctionAdminTheme.success,
                ),
                const Divider(
                  height: 1,
                  color: AuctionAdminTheme.border,
                  indent: AuctionAdminTheme.spacingLg,
                  endIndent: AuctionAdminTheme.spacingLg,
                ),
                _DatePickerTile(
                  label: 'To',
                  date: adminAuctionService.endDate.value,
                  onTap: onSelectEndDate,
                  icon: Icons.event_busy_rounded,
                  isFirst: false,
                  accentColor: AuctionAdminTheme.error,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Date Picker Tile Widget
class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final IconData icon;
  final bool isFirst;
  final Color accentColor;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onTap,
    required this.icon,
    required this.isFirst,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top:
              isFirst
                  ? const Radius.circular(AuctionAdminTheme.radiusMd)
                  : Radius.zero,
          bottom:
              !isFirst
                  ? const Radius.circular(AuctionAdminTheme.radiusMd)
                  : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AuctionAdminTheme.spacingLg,
            vertical: AuctionAdminTheme.spacingMd,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
                decoration: BoxDecoration(
                  color:
                      hasDate
                          ? accentColor.withValues(alpha: 0.1)
                          : AuctionAdminTheme.surface,
                  borderRadius: BorderRadius.circular(
                    AuctionAdminTheme.radiusSm,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: hasDate ? accentColor : AuctionAdminTheme.textTertiary,
                ),
              ),
              const SizedBox(width: AuctionAdminTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AuctionAdminTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDate
                          ? DateFormat('EEEE, MMM dd, yyyy').format(date!)
                          : 'Select ${label.toLowerCase()} date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: hasDate ? FontWeight.w500 : FontWeight.w400,
                        color:
                            hasDate
                                ? AuctionAdminTheme.textPrimary
                                : AuctionAdminTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: hasDate ? accentColor : AuctionAdminTheme.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Active Filters Display Widget
class _ActiveFiltersDisplay extends StatelessWidget {
  final AdminAuctionService adminAuctionService;
  final TextEditingController searchController;

  const _ActiveFiltersDisplay({
    required this.adminAuctionService,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasFilters =
          adminAuctionService.searchQuery.value.isNotEmpty ||
          adminAuctionService.selectedStatus.value != ProductStatus.all ||
          adminAuctionService.activeFilters.isNotEmpty ||
          adminAuctionService.startDate.value != null;

      if (!hasFilters) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
        decoration: BoxDecoration(
          color: AuctionAdminTheme.accentLight,
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          border: Border.all(
            color: AuctionAdminTheme.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.filter_alt_rounded,
              size: 16,
              color: AuctionAdminTheme.accent,
            ),
            const SizedBox(width: AuctionAdminTheme.spacingSm),
            Expanded(
              child: Text(
                adminAuctionService.getFilterSummary(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AuctionAdminTheme.textPrimary,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  adminAuctionService.clearAllFilters();
                  searchController.clear();
                },
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuctionAdminTheme.spacingSm,
                    vertical: AuctionAdminTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AuctionAdminTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusSm,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.clear_all_rounded,
                        size: 14,
                        color: AuctionAdminTheme.error,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AuctionAdminTheme.error,
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
    });
  }
}

/// Results Summary Widget
class _ResultsSummary extends StatelessWidget {
  final AdminAuctionService adminAuctionService;
  final VoidCallback onClearFilters;

  const _ResultsSummary({
    required this.adminAuctionService,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AuctionAdminTheme.spacingLg,
          vertical: AuctionAdminTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: AuctionAdminTheme.surface,
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
          border: Border.all(color: AuctionAdminTheme.border),
          boxShadow: AuctionAdminTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.accentLight,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 16,
                color: AuctionAdminTheme.accent,
              ),
            ),
            const SizedBox(width: AuctionAdminTheme.spacingMd),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AuctionAdminTheme.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Showing '),
                    TextSpan(
                      text: '${adminAuctionService.adminProducts.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AuctionAdminTheme.accent,
                      ),
                    ),
                    const TextSpan(text: ' of '),
                    TextSpan(
                      text: '${adminAuctionService.totalItems.value}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AuctionAdminTheme.textPrimary,
                      ),
                    ),
                    const TextSpan(text: ' auctions'),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                if (adminAuctionService.isRefreshing.value)
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(
                      right: AuctionAdminTheme.spacingSm,
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AuctionAdminTheme.accent,
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: adminAuctionService.refreshProducts,
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusSm,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(
                        AuctionAdminTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: AuctionAdminTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(
                          AuctionAdminTheme.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: AuctionAdminTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
