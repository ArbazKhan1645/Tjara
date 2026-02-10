import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/widgets/car_products_list_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/widgets/cars_admin_theme.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/dashbopard_services/admin_cars_service.dart';

class EnhancedCarsViewWidget extends StatefulWidget {
  final bool isAppBarExpanded;
  final AdminCarsService adminCarsService;

  const EnhancedCarsViewWidget({
    super.key,
    required this.isAppBarExpanded,
    required this.adminCarsService,
  });

  @override
  State<EnhancedCarsViewWidget> createState() => _EnhancedCarsViewWidgetState();
}

class _EnhancedCarsViewWidgetState extends State<EnhancedCarsViewWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _shopSearchController = TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();

  Timer? _shopSearchDebounce;
  Timer? _categorySearchDebounce;

  AdminCarsService get _service => widget.adminCarsService;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _idController.addListener(_onIdChanged);
    _skuController.addListener(_onSkuChanged);
  }

  void _onSearchChanged() {
    _service.updateSearchName(_searchController.text);
  }

  void _onIdChanged() {
    _service.updateSearchId(_idController.text);
  }

  void _onSkuChanged() {
    _service.updateSearchSku(_skuController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _idController.dispose();
    _skuController.dispose();
    _shopSearchController.dispose();
    _categorySearchController.dispose();
    _shopSearchDebounce?.cancel();
    _categorySearchDebounce?.cancel();
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
                  horizontal: CarsAdminTheme.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: CarsAdminTheme.spacingLg),
                    _buildFiltersCard(),
                    const SizedBox(height: CarsAdminTheme.spacingLg),
                    _buildResultsSummary(),
                    const SizedBox(height: CarsAdminTheme.spacingSm),
                    AdminCarsList(adminCarsService: _service),
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
              'Cars',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        _buildAddCarButton(),
      ],
    );
  }

  Widget _buildAddCarButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.toNamed(
            Routes.ADD_PRODUCT_ADMIN_VIEW,
            preventDuplicates: false,
            arguments: 'car',
          )?.then((value) {
            _service.refreshProducts();
          });
        },
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CarsAdminTheme.spacingLg,
            vertical: CarsAdminTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
            boxShadow: CarsAdminTheme.shadowMd,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CarsAdminTheme.accent,
                  borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
              const SizedBox(width: CarsAdminTheme.spacingSm),
              const Text(
                'Add New Car',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CarsAdminTheme.textPrimary,
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
      padding: const EdgeInsets.all(CarsAdminTheme.spacingXl),
      decoration: CarsAdminTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchSection(),
          const SizedBox(height: CarsAdminTheme.spacingXl),
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
              color: CarsAdminTheme.accent,
            ),
            const SizedBox(width: CarsAdminTheme.spacingSm),
            Text(
              'Search Cars',
              style: CarsAdminTheme.headingSmall.copyWith(
                color: CarsAdminTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: CarsAdminTheme.spacingMd),

        // Date range and main search in row
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(child: _buildDateRangeFilter()),
                  const SizedBox(width: CarsAdminTheme.spacingMd),
                  Expanded(
                    child: _buildSearchField(
                      controller: _searchController,
                      hintText: 'Search by car name...',
                      icon: Icons.search,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _buildDateRangeFilter(),
                const SizedBox(height: CarsAdminTheme.spacingMd),
                _buildSearchField(
                  controller: _searchController,
                  hintText: 'Search by car name...',
                  icon: Icons.search,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: CarsAdminTheme.spacingMd),

        // ID and SKU search in row
        Row(
          children: [
            Expanded(
              child: _buildSearchField(
                controller: _idController,
                hintText: 'Search by ID',
                icon: Icons.tag,
              ),
            ),
            const SizedBox(width: CarsAdminTheme.spacingMd),
            Expanded(
              child: _buildSearchField(
                controller: _skuController,
                hintText: 'Search by SKU',
                icon: Icons.qr_code_2,
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
  }) {
    return TextField(
      controller: controller,
      style: CarsAdminTheme.bodyLarge,
      decoration: CarsAdminTheme.inputDecoration(
        hintText: hintText,
        prefixIcon: icon,
        suffix:
            controller.text.isNotEmpty
                ? GestureDetector(
                  onTap: () {
                    controller.clear();
                  },
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: CarsAdminTheme.textTertiary,
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
              color: CarsAdminTheme.accent,
            ),
            const SizedBox(width: CarsAdminTheme.spacingSm),
            Text(
              'Filters',
              style: CarsAdminTheme.headingSmall.copyWith(
                color: CarsAdminTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: CarsAdminTheme.spacingMd),

        // Row: Sort + Shop
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(child: _buildSortDropdown()),
                  const SizedBox(width: CarsAdminTheme.spacingMd),
                  Expanded(child: _buildShopSearchDropdown()),
                ],
              );
            }
            return Column(
              children: [
                _buildSortDropdown(),
                const SizedBox(height: CarsAdminTheme.spacingMd),
                _buildShopSearchDropdown(),
              ],
            );
          },
        ),
        const SizedBox(height: CarsAdminTheme.spacingMd),

        // Row: Featured + Exclude/Include + Category
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(child: _buildFeaturedDropdown()),
                  const SizedBox(width: CarsAdminTheme.spacingMd),
                  SizedBox(width: 130, child: _buildCategoryOperatorDropdown()),
                  const SizedBox(width: CarsAdminTheme.spacingMd),
                  Expanded(child: _buildCategorySearchDropdown()),
                ],
              );
            }
            return Column(
              children: [
                _buildFeaturedDropdown(),
                const SizedBox(height: CarsAdminTheme.spacingMd),
                Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: _buildCategoryOperatorDropdown(),
                    ),
                    const SizedBox(width: CarsAdminTheme.spacingMd),
                    Expanded(child: _buildCategorySearchDropdown()),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: CarsAdminTheme.spacingLg),

        // Row: Group By SKU toggle + Inventory Updated toggle
        _buildToggleFiltersRow(),
        const SizedBox(height: CarsAdminTheme.spacingMd),

        // Row: Inventory Updated date range + Status dropdown
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInventoryDateRange()),
                  const SizedBox(width: CarsAdminTheme.spacingMd),
                  Expanded(child: _buildStatusDropdown()),
                ],
              );
            }
            return Column(
              children: [
                _buildInventoryDateRange(),
                const SizedBox(height: CarsAdminTheme.spacingMd),
                _buildStatusDropdown(),
              ],
            );
          },
        ),
        const SizedBox(height: CarsAdminTheme.spacingMd),

        // Row: Flash Deals Added toggle + Flash Deals date range
        _buildFlashDealsRow(),
        const SizedBox(height: CarsAdminTheme.spacingMd),

        // Analytics date range
        _buildAnalyticsDateRange(),
        const SizedBox(height: CarsAdminTheme.spacingLg),

        // Per Page + Quick Filters
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildQuickFilters()),
                  const SizedBox(width: CarsAdminTheme.spacingXl),
                  SizedBox(width: 200, child: _buildPerPageSelector()),
                ],
              );
            }
            return Column(
              children: [
                _buildQuickFilters(),
                const SizedBox(height: CarsAdminTheme.spacingLg),
                _buildPerPageSelector(),
              ],
            );
          },
        ),
      ],
    );
  }

  // Sort dropdown - opens bottom sheet with categorized options
  Widget _buildSortDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SORT BY : COLUMNS', style: CarsAdminTheme.labelMedium),
        const SizedBox(height: CarsAdminTheme.spacingSm),
        Obx(() {
          final currentSort = _service.sortOrder.value;
          final displayName =
              AdminCarsService.getSortOrderDisplayName(currentSort);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSortBottomSheet(context),
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: CarsAdminTheme.spacingMd,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: CarsAdminTheme.surface,
                  borderRadius:
                      BorderRadius.circular(CarsAdminTheme.radiusMd),
                  border: Border.all(
                    color:
                        currentSort != CarSortOrder.none
                            ? CarsAdminTheme.accent
                            : CarsAdminTheme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: CarsAdminTheme.bodyLarge.copyWith(
                          color:
                              currentSort != CarSortOrder.none
                                  ? CarsAdminTheme.accent
                                  : null,
                          fontWeight:
                              currentSort != CarSortOrder.none
                                  ? FontWeight.w600
                                  : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: CarsAdminTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final sortCategories = <String, List<CarSortOrder>>{
      'Price & Date': [
        CarSortOrder.priceAsc,
        CarSortOrder.priceDesc,
        CarSortOrder.recentUpdatedAll,
        CarSortOrder.recentUpdatedPrice,
        CarSortOrder.recentUpdatedSalePrice,
        CarSortOrder.recentUpdatedStock,
      ],
      'Analytics - Views': [CarSortOrder.mostViews, CarSortOrder.leastViews],
      'Analytics - Cart': [
        CarSortOrder.mostAddedToCart,
        CarSortOrder.leastAddedToCart,
      ],
      'Analytics - Engagement': [
        CarSortOrder.mostEnquired,
        CarSortOrder.leastEnquired,
        CarSortOrder.mostAddedToWishlist,
        CarSortOrder.leastAddedToWishlist,
      ],
      'Analytics - Contact': [
        CarSortOrder.mostCalled,
        CarSortOrder.leastCalled,
        CarSortOrder.mostWhatsAppContacted,
        CarSortOrder.leastWhatsAppContacted,
      ],
      'Analytics - Performance': [
        CarSortOrder.mostTotalInteractions,
        CarSortOrder.leastTotalInteractions,
        CarSortOrder.bestConversionRate,
        CarSortOrder.worstConversionRate,
        CarSortOrder.bestContactRate,
        CarSortOrder.worstContactRate,
      ],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Obx(() {
              final currentSort = _service.sortOrder.value;
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sort by : Columns',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (currentSort != CarSortOrder.none)
                          TextButton(
                            onPressed: () {
                              _service.updateSortOrder(CarSortOrder.none);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Reset'),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        for (final entry in sortCategories.entries) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: CarsAdminTheme.accent,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          ...entry.value.map((order) {
                            final isSelected = currentSort == order;
                            return ListTile(
                              dense: true,
                              selected: isSelected,
                              selectedTileColor:
                                  CarsAdminTheme.accent.withValues(
                                    alpha: 0.08,
                                  ),
                              title: Text(
                                AdminCarsService
                                    .getSortOrderDisplayName(order),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                  color:
                                      isSelected
                                          ? CarsAdminTheme.accent
                                          : CarsAdminTheme.textPrimary,
                                ),
                              ),
                              trailing:
                                  isSelected
                                      ? const Icon(
                                        Icons.check,
                                        color: CarsAdminTheme.accent,
                                        size: 20,
                                      )
                                      : null,
                              onTap: () {
                                _service.updateSortOrder(order);
                                Navigator.pop(ctx);
                              },
                            );
                          }),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            });
          },
        );
      },
    );
  }

  // Shop search dropdown
  Widget _buildShopSearchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SHOP', style: CarsAdminTheme.labelMedium),
        const SizedBox(height: CarsAdminTheme.spacingSm),
        Obx(() {
          final selectedName = _service.selectedShopName.value;
          return Column(
            children: [
              TextField(
                controller: _shopSearchController,
                style: CarsAdminTheme.bodyLarge,
                decoration: CarsAdminTheme.inputDecoration(
                  hintText:
                      selectedName.isNotEmpty ? selectedName : 'Search shop...',
                  prefixIcon: Icons.store,
                  suffix:
                      selectedName.isNotEmpty
                          ? GestureDetector(
                            onTap: () {
                              _shopSearchController.clear();
                              _service.selectShop(null);
                            },
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: CarsAdminTheme.textTertiary,
                            ),
                          )
                          : null,
                ),
                onChanged: (query) {
                  _shopSearchDebounce?.cancel();
                  _shopSearchDebounce = Timer(
                    const Duration(milliseconds: 400),
                    () => _service.searchShops(query),
                  );
                },
              ),
              if (_service.isSearchingShops.value)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: CarsAdminTheme.accent,
                  ),
                ),
              if (_service.shopSearchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: CarsAdminTheme.surface,
                    borderRadius: BorderRadius.circular(
                      CarsAdminTheme.radiusMd,
                    ),
                    border: Border.all(color: CarsAdminTheme.border),
                    boxShadow: CarsAdminTheme.shadowSm,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _service.shopSearchResults.length,
                    itemBuilder: (context, index) {
                      final shop = _service.shopSearchResults[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          shop.name,
                          style: CarsAdminTheme.bodyMedium,
                        ),
                        onTap: () {
                          _service.selectShop(shop);
                          _shopSearchController.text = shop.name;
                          _service.shopSearchResults.clear();
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // Featured dropdown
  Widget _buildFeaturedDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('FEATURED', style: CarsAdminTheme.labelMedium),
        const SizedBox(height: CarsAdminTheme.spacingSm),
        Obx(() {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CarsAdminTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: CarsAdminTheme.surface,
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
              border: Border.all(color: CarsAdminTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CarFeaturedFilter>(
                value: _service.featuredFilter.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: CarsAdminTheme.textSecondary,
                ),
                style: CarsAdminTheme.bodyLarge,
                items: const [
                  DropdownMenuItem(
                    value: CarFeaturedFilter.all,
                    child: Text('All'),
                  ),
                  DropdownMenuItem(
                    value: CarFeaturedFilter.featured,
                    child: Text('Featured'),
                  ),
                  DropdownMenuItem(
                    value: CarFeaturedFilter.notFeatured,
                    child: Text('Not Featured'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _service.updateFeaturedFilter(value);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // Category operator dropdown (Include/Exclude)
  Widget _buildCategoryOperatorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('OPERATOR', style: CarsAdminTheme.labelMedium),
        const SizedBox(height: CarsAdminTheme.spacingSm),
        Obx(() {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CarsAdminTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: CarsAdminTheme.surface,
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
              border: Border.all(color: CarsAdminTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _service.categoryOperator.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: CarsAdminTheme.textSecondary,
                ),
                style: CarsAdminTheme.bodyLarge,
                items: const [
                  DropdownMenuItem(value: '=', child: Text('Include')),
                  DropdownMenuItem(value: '!=', child: Text('Exclude')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _service.updateCategoryOperator(value);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // Category search dropdown
  Widget _buildCategorySearchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MAKE', style: CarsAdminTheme.labelMedium),
        const SizedBox(height: CarsAdminTheme.spacingSm),
        Obx(() {
          final selectedName = _service.selectedCategoryName.value;
          return Column(
            children: [
              TextField(
                controller: _categorySearchController,
                style: CarsAdminTheme.bodyLarge,
                decoration: CarsAdminTheme.inputDecoration(
                  hintText:
                      selectedName.isNotEmpty ? selectedName : 'Search make...',
                  prefixIcon: Icons.category,
                  suffix:
                      selectedName.isNotEmpty
                          ? GestureDetector(
                            onTap: () {
                              _categorySearchController.clear();
                              _service.selectCategory(null);
                            },
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: CarsAdminTheme.textTertiary,
                            ),
                          )
                          : null,
                ),
                onChanged: (query) {
                  _categorySearchDebounce?.cancel();
                  _categorySearchDebounce = Timer(
                    const Duration(milliseconds: 400),
                    () => _service.searchCategories(query),
                  );
                },
              ),
              if (_service.isSearchingCategories.value)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: CarsAdminTheme.accent,
                  ),
                ),
              if (_service.categorySearchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: CarsAdminTheme.surface,
                    borderRadius: BorderRadius.circular(
                      CarsAdminTheme.radiusMd,
                    ),
                    border: Border.all(color: CarsAdminTheme.border),
                    boxShadow: CarsAdminTheme.shadowSm,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _service.categorySearchResults.length,
                    itemBuilder: (context, index) {
                      final cat = _service.categorySearchResults[index];
                      return ListTile(
                        dense: true,
                        title: Text(cat.name, style: CarsAdminTheme.bodyMedium),
                        onTap: () {
                          _service.selectCategory(cat);
                          _categorySearchController.text = cat.name;
                          _service.categorySearchResults.clear();
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // Toggle filters row: Group By SKU + Inventory Updated
  Widget _buildToggleFiltersRow() {
    return Obx(() {
      return Wrap(
        spacing: CarsAdminTheme.spacingXl,
        runSpacing: CarsAdminTheme.spacingMd,
        children: [
          _buildToggleSwitch(
            label: 'Group By SKU',
            value: _service.groupBySku.value,
            onChanged: (val) => _service.toggleGroupBySku(val),
          ),
          _buildToggleSwitch(
            label: 'Inventory Updated',
            value: _service.inventoryUpdatedEnabled.value,
            onChanged: (val) => _service.toggleInventoryUpdated(val),
          ),
        ],
      );
    });
  }

  Widget _buildToggleSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: value ? FontWeight.w600 : FontWeight.w400,
            color:
                value
                    ? CarsAdminTheme.textPrimary
                    : CarsAdminTheme.textSecondary,
          ),
        ),
        const SizedBox(width: CarsAdminTheme.spacingSm),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: CarsAdminTheme.accent.withValues(alpha: 0.5),
          activeThumbColor: CarsAdminTheme.accent,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  // Inventory Updated date range
  Widget _buildInventoryDateRange() {
    return Obx(() {
      if (!_service.inventoryUpdatedEnabled.value) {
        return const SizedBox.shrink();
      }

      final startDate = _service.inventoryStartDate.value;
      final endDate = _service.inventoryEndDate.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INVENTORY UPDATED RANGE',
            style: CarsAdminTheme.labelMedium,
          ),
          const SizedBox(height: CarsAdminTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Start Date',
                  date: startDate,
                  onTap: () async {
                    final picked = await _pickDate(
                      initial: startDate,
                      helpText: 'Inventory Start Date',
                    );
                    if (picked != null) {
                      _service.updateInventoryDateRange(picked, endDate);
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: CarsAdminTheme.spacingSm,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: CarsAdminTheme.textTertiary,
                ),
              ),
              Expanded(
                child: _buildDateButton(
                  label: 'End Date',
                  date: endDate,
                  onTap: () async {
                    final picked = await _pickDate(
                      initial: endDate,
                      firstDate: startDate,
                      helpText: 'Inventory End Date',
                    );
                    if (picked != null) {
                      _service.updateInventoryDateRange(startDate, picked);
                    }
                  },
                ),
              ),
              if (startDate != null || endDate != null) ...[
                const SizedBox(width: CarsAdminTheme.spacingSm),
                _buildClearDateButton(
                  onTap: () => _service.updateInventoryDateRange(null, null),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }

  // Status dropdown
  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STATUS', style: CarsAdminTheme.labelMedium),
        const SizedBox(height: CarsAdminTheme.spacingSm),
        Obx(() {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CarsAdminTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: CarsAdminTheme.surface,
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
              border: Border.all(color: CarsAdminTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CarProductStatus>(
                value: _service.selectedStatus.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: CarsAdminTheme.textSecondary,
                ),
                style: CarsAdminTheme.bodyLarge,
                items:
                    CarProductStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_formatStatusLabel(status.name)),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _service.updateStatusFilter(value);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // Flash Deals row
  Widget _buildFlashDealsRow() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildToggleSwitch(
                label: 'Flash Deals Added',
                value: _service.flashDealsAddedEnabled.value,
                onChanged: (val) => _service.toggleFlashDealsAdded(val),
              ),
              if (_service.flashDealsAddedEnabled.value) ...[
                const SizedBox(width: CarsAdminTheme.spacingLg),
                Expanded(child: _buildFlashDealsDateRange()),
              ],
            ],
          ),
        ],
      );
    });
  }

  Widget _buildFlashDealsDateRange() {
    final startDate = _service.flashDealsStartDate.value;
    final endDate = _service.flashDealsEndDate.value;

    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            label: 'Select date or date range',
            date: startDate,
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange:
                    startDate != null && endDate != null
                        ? DateTimeRange(start: startDate, end: endDate)
                        : null,
                helpText: 'Flash Deals Date Range',
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: CarsAdminTheme.accent,
                        onPrimary: Colors.white,
                        surface: CarsAdminTheme.surface,
                        onSurface: CarsAdminTheme.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (range != null) {
                _service.updateFlashDealsDateRange(range.start, range.end);
              }
            },
          ),
        ),
        if (startDate != null || endDate != null) ...[
          const SizedBox(width: CarsAdminTheme.spacingSm),
          _buildClearDateButton(
            onTap: () => _service.updateFlashDealsDateRange(null, null),
          ),
        ],
      ],
    );
  }

  // Analytics date range
  Widget _buildAnalyticsDateRange() {
    return Obx(() {
      final startDate = _service.analyticsStartDate.value;
      final endDate = _service.analyticsEndDate.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ANALYTICS DATE RANGE',
            style: CarsAdminTheme.labelMedium,
          ),
          const SizedBox(height: CarsAdminTheme.spacingSm),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Start Date',
                  date: startDate,
                  onTap: () async {
                    final picked = await _pickDate(
                      initial: startDate,
                      helpText: 'Analytics Start Date',
                    );
                    if (picked != null) {
                      _service.updateAnalyticsDateRange(picked, endDate);
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: CarsAdminTheme.spacingSm,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: CarsAdminTheme.textTertiary,
                ),
              ),
              Expanded(
                child: _buildDateButton(
                  label: 'End Date',
                  date: endDate,
                  onTap: () async {
                    final picked = await _pickDate(
                      initial: endDate,
                      firstDate: startDate,
                      helpText: 'Analytics End Date',
                    );
                    if (picked != null) {
                      _service.updateAnalyticsDateRange(startDate, picked);
                    }
                  },
                ),
              ),
              if (startDate != null || endDate != null) ...[
                const SizedBox(width: CarsAdminTheme.spacingSm),
                _buildClearDateButton(
                  onTap: () => _service.updateAnalyticsDateRange(null, null),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }

  String _formatStatusLabel(String name) {
    return name.substring(0, 1).toUpperCase() + name.substring(1);
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
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: CarsAdminTheme.spacingMd,
            vertical: CarsAdminTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? color.withValues(alpha: 0.1)
                    : CarsAdminTheme.surface,
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusLg),
            border: Border.all(
              color: isSelected ? color : CarsAdminTheme.border,
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
                  color: isSelected ? color : CarsAdminTheme.textSecondary,
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
          const Text('DATE RANGE', style: CarsAdminTheme.labelMedium),
          const SizedBox(height: CarsAdminTheme.spacingSm),
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
                  horizontal: CarsAdminTheme.spacingSm,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: CarsAdminTheme.textTertiary,
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
                const SizedBox(width: CarsAdminTheme.spacingSm),
                _buildClearDateButton(
                  onTap: () => _service.updateDateRange(null, null),
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
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CarsAdminTheme.spacingMd,
            vertical: CarsAdminTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: CarsAdminTheme.surface,
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
            border: Border.all(
              color:
                  date != null ? CarsAdminTheme.accent : CarsAdminTheme.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color:
                    date != null
                        ? CarsAdminTheme.accent
                        : CarsAdminTheme.textTertiary,
              ),
              const SizedBox(width: CarsAdminTheme.spacingSm),
              Expanded(
                child: Text(
                  date != null ? DateFormat('d MMM, yyyy').format(date) : label,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        date != null
                            ? CarsAdminTheme.textPrimary
                            : CarsAdminTheme.textTertiary,
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

  Widget _buildClearDateButton({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CarsAdminTheme.errorLight,
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
          ),
          child: const Icon(Icons.close, size: 16, color: CarsAdminTheme.error),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK FILTERS', style: CarsAdminTheme.labelMedium),
        const SizedBox(height: CarsAdminTheme.spacingSm),
        Obx(() {
          final filters = _service.getPredefinedFilters();
          final skuFilter = _service.skuFilter.value;
          return Wrap(
            spacing: CarsAdminTheme.spacingSm,
            runSpacing: CarsAdminTheme.spacingSm,
            children: [
              ...filters.map((filter) {
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
                  color: CarsAdminTheme.accent,
                );
              }),
              _buildFilterChip(
                label: 'Existing SKU',
                isSelected: skuFilter == CarSkuFilter.existing,
                onTap: () {
                  _service.updateSkuFilter(
                    skuFilter == CarSkuFilter.existing
                        ? CarSkuFilter.all
                        : CarSkuFilter.existing,
                  );
                },
                color: CarsAdminTheme.accent,
              ),
              _buildFilterChip(
                label: 'Without SKU',
                isSelected: skuFilter == CarSkuFilter.withoutSku,
                onTap: () {
                  _service.updateSkuFilter(
                    skuFilter == CarSkuFilter.withoutSku
                        ? CarSkuFilter.all
                        : CarSkuFilter.withoutSku,
                  );
                },
                color: CarsAdminTheme.accent,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPerPageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ITEMS PER PAGE', style: CarsAdminTheme.labelMedium),
        const SizedBox(height: CarsAdminTheme.spacingSm),
        Obx(() {
          final perPage = _service.perPage.value;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CarsAdminTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: CarsAdminTheme.surface,
              borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
              border: Border.all(color: CarsAdminTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: perPage,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: CarsAdminTheme.textSecondary,
                ),
                style: CarsAdminTheme.bodyLarge,
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
          _service.searchName.value.isNotEmpty ||
          _service.searchId.value.isNotEmpty ||
          _service.searchSku.value.isNotEmpty ||
          _service.selectedStatus.value != CarProductStatus.all ||
          _service.activeFilters.isNotEmpty ||
          _service.startDate.value != null ||
          _service.sortOrder.value != CarSortOrder.none ||
          _service.selectedShopId.value.isNotEmpty ||
          _service.featuredFilter.value != CarFeaturedFilter.all ||
          _service.selectedCategoryId.value.isNotEmpty ||
          _service.groupBySku.value ||
          _service.inventoryUpdatedEnabled.value ||
          _service.flashDealsAddedEnabled.value ||
          _service.analyticsStartDate.value != null ||
          _service.skuFilter.value != CarSkuFilter.all;

      if (!hasFilters) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: CarsAdminTheme.spacingXl),
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
                      color: CarsAdminTheme.accent,
                    ),
                    SizedBox(width: CarsAdminTheme.spacingSm),
                    Text('Active Filters', style: CarsAdminTheme.headingSmall),
                  ],
                ),
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: CarsAdminTheme.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: CarsAdminTheme.spacingMd,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: CarsAdminTheme.spacingSm),
            Container(
              padding: const EdgeInsets.all(CarsAdminTheme.spacingMd),
              decoration: BoxDecoration(
                color: CarsAdminTheme.accentLight,
                borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
                border: Border.all(
                  color: CarsAdminTheme.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: CarsAdminTheme.accent,
                  ),
                  const SizedBox(width: CarsAdminTheme.spacingSm),
                  Expanded(
                    child: Text(
                      _service.getFilterSummary(),
                      style: CarsAdminTheme.bodySmall.copyWith(
                        color: CarsAdminTheme.textPrimary,
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
    _shopSearchController.clear();
    _categorySearchController.clear();
  }

  Widget _buildResultsSummary() {
    return Obx(() {
      final productCount = _service.adminProducts.length;
      final totalItems = _service.totalItems.value;
      final isRefreshing = _service.isRefreshing.value;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CarsAdminTheme.spacingLg,
          vertical: CarsAdminTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: CarsAdminTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
          border: Border.all(color: CarsAdminTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CarsAdminTheme.accentLight,
                    borderRadius: BorderRadius.circular(
                      CarsAdminTheme.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 16,
                    color: CarsAdminTheme.accent,
                  ),
                ),
                const SizedBox(width: CarsAdminTheme.spacingMd),
                RichText(
                  text: TextSpan(
                    style: CarsAdminTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Showing '),
                      TextSpan(
                        text: '$productCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CarsAdminTheme.accent,
                        ),
                      ),
                      const TextSpan(text: ' of '),
                      TextSpan(
                        text: '$totalItems',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' cars'),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (isRefreshing)
                  const Padding(
                    padding: EdgeInsets.only(right: CarsAdminTheme.spacingSm),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CarsAdminTheme.accent,
                      ),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _service.refreshProducts,
                    borderRadius: BorderRadius.circular(
                      CarsAdminTheme.radiusSm,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CarsAdminTheme.surface,
                        borderRadius: BorderRadius.circular(
                          CarsAdminTheme.radiusSm,
                        ),
                        border: Border.all(color: CarsAdminTheme.border),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: CarsAdminTheme.textSecondary,
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

  Future<DateTime?> _pickDate({
    DateTime? initial,
    DateTime? firstDate,
    String helpText = 'Select Date',
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: DateTime(2100),
      helpText: helpText,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CarsAdminTheme.accent,
              onPrimary: Colors.white,
              surface: CarsAdminTheme.surface,
              onSurface: CarsAdminTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await _pickDate(
      initial: _service.startDate.value,
      helpText: 'Select Start Date',
    );
    if (picked != null) {
      _service.updateDateRange(picked, _service.endDate.value);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await _pickDate(
      initial: _service.endDate.value,
      firstDate: _service.startDate.value,
      helpText: 'Select End Date',
    );
    if (picked != null) {
      _service.updateDateRange(_service.startDate.value, picked);
    }
  }
}
