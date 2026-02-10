import 'dart:async';

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
  final TextEditingController _shopSearchController = TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();

  Timer? _shopSearchDebounce;
  Timer? _categorySearchDebounce;

  AdminProductsService get _service => widget.adminProductsService;

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

        // Date range and main search in row
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(child: _buildDateRangeFilter()),
                  const SizedBox(width: AdminProductsTheme.spacingMd),
                  Expanded(
                    child: _buildSearchField(
                      controller: _searchController,
                      hintText: 'Search by product name...',
                      icon: Icons.search,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _buildDateRangeFilter(),
                const SizedBox(height: AdminProductsTheme.spacingMd),
                _buildSearchField(
                  controller: _searchController,
                  hintText: 'Search by product name...',
                  icon: Icons.search,
                ),
              ],
            );
          },
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
              ),
            ),
            const SizedBox(width: AdminProductsTheme.spacingMd),
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
      style: AdminProductsTheme.bodyLarge,
      decoration: AdminProductsTheme.inputDecoration(
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

        // Row: Sort + Shop
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(child: _buildSortDropdown()),
                  const SizedBox(width: AdminProductsTheme.spacingMd),
                  Expanded(child: _buildShopSearchDropdown()),
                ],
              );
            }
            return Column(
              children: [
                _buildSortDropdown(),
                const SizedBox(height: AdminProductsTheme.spacingMd),
                _buildShopSearchDropdown(),
              ],
            );
          },
        ),
        const SizedBox(height: AdminProductsTheme.spacingMd),

        // Row: Featured + Exclude/Include + Category
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Expanded(child: _buildFeaturedDropdown()),
                  const SizedBox(width: AdminProductsTheme.spacingMd),
                  SizedBox(width: 130, child: _buildCategoryOperatorDropdown()),
                  const SizedBox(width: AdminProductsTheme.spacingMd),
                  Expanded(child: _buildCategorySearchDropdown()),
                ],
              );
            }
            return Column(
              children: [
                _buildFeaturedDropdown(),
                const SizedBox(height: AdminProductsTheme.spacingMd),
                Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: _buildCategoryOperatorDropdown(),
                    ),
                    const SizedBox(width: AdminProductsTheme.spacingMd),
                    Expanded(child: _buildCategorySearchDropdown()),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AdminProductsTheme.spacingLg),

        // Row: Group By SKU toggle + Inventory Updated toggle
        _buildToggleFiltersRow(),
        const SizedBox(height: AdminProductsTheme.spacingMd),

        // Row: Inventory Updated date range + Status dropdown
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInventoryDateRange()),
                  const SizedBox(width: AdminProductsTheme.spacingMd),
                  Expanded(child: _buildStatusDropdown()),
                ],
              );
            }
            return Column(
              children: [
                _buildInventoryDateRange(),
                const SizedBox(height: AdminProductsTheme.spacingMd),
                _buildStatusDropdown(),
              ],
            );
          },
        ),
        const SizedBox(height: AdminProductsTheme.spacingMd),

        // Row: Flash Deals Added toggle + Flash Deals date range
        _buildFlashDealsRow(),
        const SizedBox(height: AdminProductsTheme.spacingMd),

        // Analytics date range
        _buildAnalyticsDateRange(),
        const SizedBox(height: AdminProductsTheme.spacingLg),

        // Per Page + Quick Filters
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildQuickFilters()),
                  const SizedBox(width: AdminProductsTheme.spacingXl),
                  SizedBox(width: 200, child: _buildPerPageSelector()),
                ],
              );
            }
            return Column(
              children: [
                _buildQuickFilters(),
                const SizedBox(height: AdminProductsTheme.spacingLg),
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
        const Text('SORT BY : COLUMNS', style: AdminProductsTheme.labelMedium),
        const SizedBox(height: AdminProductsTheme.spacingSm),
        Obx(() {
          final currentSort = _service.sortOrder.value;
          final displayName =
              AdminProductsService.getSortOrderDisplayName(currentSort);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSortBottomSheet(context),
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminProductsTheme.spacingMd,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AdminProductsTheme.surface,
                  borderRadius:
                      BorderRadius.circular(AdminProductsTheme.radiusMd),
                  border: Border.all(
                    color:
                        currentSort != SortOrder.none
                            ? AdminProductsTheme.primary
                            : AdminProductsTheme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: AdminProductsTheme.bodyLarge.copyWith(
                          color:
                              currentSort != SortOrder.none
                                  ? AdminProductsTheme.primary
                                  : null,
                          fontWeight:
                              currentSort != SortOrder.none
                                  ? FontWeight.w600
                                  : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AdminProductsTheme.textSecondary,
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
    final sortCategories = <String, List<SortOrder>>{
      'Price & Date': [
        SortOrder.priceAsc,
        SortOrder.priceDesc,
        SortOrder.recentUpdatedAll,
        SortOrder.recentUpdatedPrice,
        SortOrder.recentUpdatedSalePrice,
        SortOrder.recentUpdatedStock,
      ],
      'Analytics - Views': [SortOrder.mostViews, SortOrder.leastViews],
      'Analytics - Cart': [
        SortOrder.mostAddedToCart,
        SortOrder.leastAddedToCart,
      ],
      'Analytics - Engagement': [
        SortOrder.mostEnquired,
        SortOrder.leastEnquired,
        SortOrder.mostAddedToWishlist,
        SortOrder.leastAddedToWishlist,
      ],
      'Analytics - Contact': [
        SortOrder.mostCalled,
        SortOrder.leastCalled,
        SortOrder.mostWhatsAppContacted,
        SortOrder.leastWhatsAppContacted,
      ],
      'Analytics - Performance': [
        SortOrder.mostTotalInteractions,
        SortOrder.leastTotalInteractions,
        SortOrder.bestConversionRate,
        SortOrder.worstConversionRate,
        SortOrder.bestContactRate,
        SortOrder.worstContactRate,
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
                        if (currentSort != SortOrder.none)
                          TextButton(
                            onPressed: () {
                              _service.updateSortOrder(SortOrder.none);
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
                                color: AdminProductsTheme.primary,
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
                                  AdminProductsTheme.primary.withValues(
                                    alpha: 0.08,
                                  ),
                              title: Text(
                                AdminProductsService
                                    .getSortOrderDisplayName(order),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                  color:
                                      isSelected
                                          ? AdminProductsTheme.primary
                                          : AdminProductsTheme.textPrimary,
                                ),
                              ),
                              trailing:
                                  isSelected
                                      ? const Icon(
                                        Icons.check,
                                        color: AdminProductsTheme.primary,
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
        const Text('SHOP', style: AdminProductsTheme.labelMedium),
        const SizedBox(height: AdminProductsTheme.spacingSm),
        Obx(() {
          final selectedName = _service.selectedShopName.value;
          return Column(
            children: [
              TextField(
                controller: _shopSearchController,
                style: AdminProductsTheme.bodyLarge,
                decoration: AdminProductsTheme.inputDecoration(
                  hintText:
                      selectedName.isNotEmpty
                          ? selectedName
                          : 'Search shop...',
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
                              color: AdminProductsTheme.textTertiary,
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
                    color: AdminProductsTheme.primary,
                  ),
                ),
              if (_service.shopSearchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusMd,
                    ),
                    border: Border.all(color: AdminProductsTheme.border),
                    boxShadow: AdminProductsTheme.shadowSm,
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
                          style: AdminProductsTheme.bodyMedium,
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
        const Text('FEATURED', style: AdminProductsTheme.labelMedium),
        const SizedBox(height: AdminProductsTheme.spacingSm),
        Obx(() {
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
              child: DropdownButton<FeaturedFilter>(
                value: _service.featuredFilter.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AdminProductsTheme.textSecondary,
                ),
                style: AdminProductsTheme.bodyLarge,
                items: const [
                  DropdownMenuItem(
                    value: FeaturedFilter.all,
                    child: Text('All'),
                  ),
                  DropdownMenuItem(
                    value: FeaturedFilter.featured,
                    child: Text('Featured'),
                  ),
                  DropdownMenuItem(
                    value: FeaturedFilter.notFeatured,
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
        const Text('OPERATOR', style: AdminProductsTheme.labelMedium),
        const SizedBox(height: AdminProductsTheme.spacingSm),
        Obx(() {
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
              child: DropdownButton<String>(
                value: _service.categoryOperator.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AdminProductsTheme.textSecondary,
                ),
                style: AdminProductsTheme.bodyLarge,
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
        const Text('CATEGORY', style: AdminProductsTheme.labelMedium),
        const SizedBox(height: AdminProductsTheme.spacingSm),
        Obx(() {
          final selectedName = _service.selectedCategoryName.value;
          return Column(
            children: [
              TextField(
                controller: _categorySearchController,
                style: AdminProductsTheme.bodyLarge,
                decoration: AdminProductsTheme.inputDecoration(
                  hintText:
                      selectedName.isNotEmpty
                          ? selectedName
                          : 'Search category...',
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
                              color: AdminProductsTheme.textTertiary,
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
                    color: AdminProductsTheme.primary,
                  ),
                ),
              if (_service.categorySearchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusMd,
                    ),
                    border: Border.all(color: AdminProductsTheme.border),
                    boxShadow: AdminProductsTheme.shadowSm,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _service.categorySearchResults.length,
                    itemBuilder: (context, index) {
                      final cat = _service.categorySearchResults[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          cat.name,
                          style: AdminProductsTheme.bodyMedium,
                        ),
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
        spacing: AdminProductsTheme.spacingXl,
        runSpacing: AdminProductsTheme.spacingMd,
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
                    ? AdminProductsTheme.textPrimary
                    : AdminProductsTheme.textSecondary,
          ),
        ),
        const SizedBox(width: AdminProductsTheme.spacingSm),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AdminProductsTheme.primary.withValues(alpha: 0.5),
          activeThumbColor: AdminProductsTheme.primary,
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
            style: AdminProductsTheme.labelMedium,
          ),
          const SizedBox(height: AdminProductsTheme.spacingSm),
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
                const SizedBox(width: AdminProductsTheme.spacingSm),
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
        const Text('STATUS', style: AdminProductsTheme.labelMedium),
        const SizedBox(height: AdminProductsTheme.spacingSm),
        Obx(() {
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
              child: DropdownButton<ProductStatus>(
                value: _service.selectedStatus.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AdminProductsTheme.textSecondary,
                ),
                style: AdminProductsTheme.bodyLarge,
                items:
                    ProductStatus.values.map((status) {
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
                const SizedBox(width: AdminProductsTheme.spacingLg),
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
              if (range != null) {
                _service.updateFlashDealsDateRange(range.start, range.end);
              }
            },
          ),
        ),
        if (startDate != null || endDate != null) ...[
          const SizedBox(width: AdminProductsTheme.spacingSm),
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
            style: AdminProductsTheme.labelMedium,
          ),
          const SizedBox(height: AdminProductsTheme.spacingSm),
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
                const SizedBox(width: AdminProductsTheme.spacingSm),
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
                      ? DateFormat('d MMM, yyyy').format(date)
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

  Widget _buildClearDateButton({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AdminProductsTheme.errorLight,
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
          ),
          child: const Icon(
            Icons.close,
            size: 16,
            color: AdminProductsTheme.error,
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
          final skuFilter = _service.skuFilter.value;
          return Wrap(
            spacing: AdminProductsTheme.spacingSm,
            runSpacing: AdminProductsTheme.spacingSm,
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
                  color: AdminProductsTheme.secondary,
                );
              }),
              _buildFilterChip(
                label: 'Existing SKU',
                isSelected: skuFilter == SkuFilter.existing,
                onTap: () {
                  _service.updateSkuFilter(
                    skuFilter == SkuFilter.existing
                        ? SkuFilter.all
                        : SkuFilter.existing,
                  );
                },
                color: AdminProductsTheme.secondary,
              ),
              _buildFilterChip(
                label: 'Without SKU',
                isSelected: skuFilter == SkuFilter.withoutSku,
                onTap: () {
                  _service.updateSkuFilter(
                    skuFilter == SkuFilter.withoutSku
                        ? SkuFilter.all
                        : SkuFilter.withoutSku,
                  );
                },
                color: AdminProductsTheme.secondary,
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
          _service.searchName.value.isNotEmpty ||
          _service.searchId.value.isNotEmpty ||
          _service.searchSku.value.isNotEmpty ||
          _service.selectedStatus.value != ProductStatus.all ||
          _service.activeFilters.isNotEmpty ||
          _service.startDate.value != null ||
          _service.sortOrder.value != SortOrder.none ||
          _service.selectedShopId.value.isNotEmpty ||
          _service.featuredFilter.value != FeaturedFilter.all ||
          _service.selectedCategoryId.value.isNotEmpty ||
          _service.groupBySku.value ||
          _service.inventoryUpdatedEnabled.value ||
          _service.flashDealsAddedEnabled.value ||
          _service.analyticsStartDate.value != null ||
          _service.skuFilter.value != SkuFilter.all;

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
