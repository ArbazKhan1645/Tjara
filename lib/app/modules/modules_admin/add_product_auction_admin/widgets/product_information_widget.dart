import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/widgets/auction_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/categories_admin/controllers/categories_admin_controller.dart';

class AuctionProductInformationWidget extends StatelessWidget {
  final AuctionAddProductAdminController controller;
  final CategoriesAdminController categoryAdminController;

  const AuctionProductInformationWidget({
    super.key,
    required this.controller,
    required this.categoryAdminController,
  });

  void _showCategorySearchDialog(
    BuildContext context,
    AuctionAddProductAdminController ctrl,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => _CategorySearchDialog(
            onSearch: _searchCategories,
            onCategorySelected: (id, name) {
              ctrl.selectedCategoryId = id;
              ctrl.selectedCategoryName = name;
              ctrl.update();
              Navigator.of(dialogContext).pop();
            },
            selectedCategoryId: ctrl.selectedCategoryId,
          ),
    );
  }

  Future<List<Map<String, String>>> _searchCategories(String query) async {
    try {
      final url =
          'https://api.libanbuy.com/api/product-attributes/categories?post_type=product&search=$query&order_by=name&order=ASC&limit=30';

      final res = await http.get(
        Uri.parse(url),
        headers: {'X-Request-From': 'Dashboard'},
      );

      if (res.statusCode == 200) {
        return _extractAttributeItems(json.decode(res.body));
      }
    } catch (e) {
      debugPrint('Error searching categories: $e');
    }
    return [];
  }

  List<Map<String, String>> _extractAttributeItems(Map<String, dynamic> body) {
    try {
      final productAttribute = body['product_attribute'];

      if (productAttribute != null && productAttribute is Map) {
        final attributeItems = productAttribute['attribute_items'];

        if (attributeItems != null && attributeItems is Map) {
          final productAttributeItems =
              attributeItems['product_attribute_items'];

          if (productAttributeItems is List) {
            return productAttributeItems
                .map(
                  (item) => {
                    'id': (item['id'] ?? '').toString(),
                    'name': (item['name'] ?? '').toString(),
                  },
                )
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Error extracting categories: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return AuctionFormCard(
      title: 'Auction Information',
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auction Name Field
          const FieldLabel(
            label: 'Auction Name',
            isRequired: true,
            description:
                'Enter the unique name of your auction. Make it descriptive and easy to remember for customers.',
          ),
          TextField(
            controller: controller.productNameController,
            style: AuctionAdminTheme.bodyLarge,
            decoration: AuctionAdminTheme.inputDecoration(
              hintText: 'Enter auction name',
              prefixIcon: Icons.gavel_rounded,
            ),
          ),
          const SizedBox(height: AuctionAdminTheme.spacingXl),

          // Category Selection
          const FieldLabel(
            label: 'Category',
            description: 'Select the primary category for your auction.',
          ),
          GetBuilder<AuctionAddProductAdminController>(
            builder:
                (ctrl) => _CategorySelector(
                  selectedCategoryName: ctrl.selectedCategoryName,
                  onTap: () => _showCategorySearchDialog(context, ctrl),
                ),
          ),
        ],
      ),
    );
  }
}

/// Category Selector Button
class _CategorySelector extends StatelessWidget {
  final String? selectedCategoryName;
  final VoidCallback onTap;

  const _CategorySelector({
    required this.selectedCategoryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedCategoryName != null;

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
            color: AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            border: Border.all(
              color:
                  hasSelection
                      ? AuctionAdminTheme.accent
                      : AuctionAdminTheme.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.category_rounded,
                size: 20,
                color:
                    hasSelection
                        ? AuctionAdminTheme.accent
                        : AuctionAdminTheme.textTertiary,
              ),
              const SizedBox(width: AuctionAdminTheme.spacingMd),
              Expanded(
                child: Text(
                  selectedCategoryName ?? 'Select Category',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        hasSelection
                            ? AuctionAdminTheme.textPrimary
                            : AuctionAdminTheme.textTertiary,
                  ),
                ),
              ),
              const Icon(
                Icons.search_rounded,
                size: 20,
                color: AuctionAdminTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category Search Dialog
class _CategorySearchDialog extends StatefulWidget {
  final Future<List<Map<String, String>>> Function(String query) onSearch;
  final Function(String id, String name) onCategorySelected;
  final String? selectedCategoryId;

  const _CategorySearchDialog({
    required this.onSearch,
    required this.onCategorySelected,
    this.selectedCategoryId,
  });

  @override
  State<_CategorySearchDialog> createState() => _CategorySearchDialogState();
}

class _CategorySearchDialogState extends State<_CategorySearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _categories = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final results = await widget.onSearch('');
    if (mounted) {
      setState(() {
        _categories = results;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final results = await widget.onSearch(query);
    if (mounted) {
      setState(() {
        _categories = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusLg),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AuctionAdminTheme.accentLight,
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.category_rounded,
                    color: AuctionAdminTheme.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AuctionAdminTheme.spacingMd),
                const Expanded(
                  child: Text(
                    'Select Category',
                    style: AuctionAdminTheme.headingMedium,
                  ),
                ),
                Material(
                  color: AuctionAdminTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(
                    AuctionAdminTheme.radiusSm,
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusSm,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(AuctionAdminTheme.spacingSm),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AuctionAdminTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AuctionAdminTheme.spacingLg),

            // Search Field
            TextField(
              controller: _searchController,
              style: AuctionAdminTheme.bodyLarge,
              decoration: AuctionAdminTheme.inputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icons.search_rounded,
                suffix:
                    _searchController.text.isNotEmpty
                        ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                          child: const Icon(
                            Icons.clear_rounded,
                            size: 18,
                            color: AuctionAdminTheme.textTertiary,
                          ),
                        )
                        : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AuctionAdminTheme.spacingMd),

            // Results Count
            if (!_isLoading)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_categories.length} categories found',
                  style: AuctionAdminTheme.bodySmall,
                ),
              ),
            const SizedBox(height: AuctionAdminTheme.spacingSm),

            // Category List
            Expanded(
              child:
                  _isLoading
                      ? const _LoadingState()
                      : _categories.isEmpty
                      ? const _EmptyState()
                      : _CategoryList(
                        categories: _categories,
                        selectedCategoryId: widget.selectedCategoryId,
                        onCategorySelected: widget.onCategorySelected,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading State Widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AuctionAdminTheme.accent,
              ),
            ),
          ),
          const SizedBox(height: AuctionAdminTheme.spacingLg),
          Text(
            'Searching...',
            style: AuctionAdminTheme.bodyMedium.copyWith(
              color: AuctionAdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty State Widget
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
            decoration: const BoxDecoration(
              color: AuctionAdminTheme.surfaceSecondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AuctionAdminTheme.textTertiary,
            ),
          ),
          const SizedBox(height: AuctionAdminTheme.spacingLg),
          const Text(
            'No categories found',
            style: AuctionAdminTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Category List Widget
class _CategoryList extends StatelessWidget {
  final List<Map<String, String>> categories;
  final String? selectedCategoryId;
  final Function(String id, String name) onCategorySelected;

  const _CategoryList({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final id = category['id'] ?? '';
        final name = category['name'] ?? '';
        final isSelected = id == selectedCategoryId;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onCategorySelected(id, name),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AuctionAdminTheme.spacingLg,
                vertical: AuctionAdminTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AuctionAdminTheme.primaryLight
                        : Colors.transparent,
                border: const Border(
                  bottom: BorderSide(color: AuctionAdminTheme.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color:
                            isSelected
                                ? AuctionAdminTheme.accent
                                : AuctionAdminTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AuctionAdminTheme.accent,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
