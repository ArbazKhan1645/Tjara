import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';
import 'package:tjara/app/modules/admin/add_product_admin/views/add_product_admin_view.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/admin/categories_admin/controllers/categories_admin_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
  ) async {
    // Show category search dialog with API search
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _CategorySearchDialog(
          onSearch: (query) => _searchCategories(query),
          onCategorySelected: (id, name) {
            ctrl.selectedCategoryId = id;
            ctrl.selectedCategoryName = name;
            ctrl.update();
            Navigator.of(dialogContext).pop();
          },
          selectedCategoryId: ctrl.selectedCategoryId,
        );
      },
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
        final categories = _extractAttributeItems(json.decode(res.body));
        return categories;
      }
    } catch (e) {
      print('❌ Error searching categories: $e');
    }
    return [];
  }

  List<Map<String, String>> _extractAttributeItems(Map<String, dynamic> body) {
    try {
      // The response structure is: product_attribute -> attribute_items -> product_attribute_items
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
      print('❌ Error extracting categories: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ProductFieldsCardCustomWidget(
        column: Column(
          children: [
            Container(
              height: 45.88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF97316),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Auction Information",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Auction Name
            const Row(
              children: [
                Text(
                  "Auction Name",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text("*", style: TextStyle(color: AppColors.red, fontSize: 20)),
              ],
            ),
            const Text(
              "Enter the unique name of your auction. Make it descriptive and easy to remember for customers.",
              style: TextStyle(color: AppColors.adminGreyColorText),
            ),
            const SizedBox(height: 10),
            SimpleTextFormFieldWidget(
              textController: controller.productNameController,
              hint: 'Auction name',
            ),
            const SizedBox(height: 25),

            // Category selection with dialog
            const Row(
              children: [
                Text(
                  "Category",
                  style: TextStyle(
                    color: AppColors.darkLightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Text(
              "Select the primary category for your auction.",
              style: TextStyle(color: AppColors.adminGreyColorText),
            ),
            const SizedBox(height: 10),
            GetBuilder<AuctionAddProductAdminController>(
              builder: (ctrl) {
                return GestureDetector(
                  onTap: () => _showCategorySearchDialog(context, ctrl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.lightGreyBorderColor,
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ctrl.selectedCategoryName ?? 'Select Category',
                            style: TextStyle(
                              color:
                                  ctrl.selectedCategoryName == null
                                      ? Colors.grey[600]
                                      : Colors.black,
                            ),
                          ),
                        ),
                        Icon(Icons.search, color: Colors.grey[600], size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

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
    setState(() {
      _categories = results;
      _isLoading = false;
    });
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
    setState(() {
      _categories = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF97316),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFF97316)),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),

            // Results count
            if (!_isLoading)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_categories.length} categories found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            const SizedBox(height: 8),

            // Category list
            Expanded(
              child:
                  _isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFF97316),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Searching...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                      : _categories.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No categories found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final id = category['id'] ?? '';
                          final name = category['name'] ?? '';
                          final isSelected = id == widget.selectedCategoryId;

                          return InkWell(
                            onTap: () => widget.onCategorySelected(id, name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(0xFFF97316).withOpacity(0.1)
                                        : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                        color:
                                            isSelected
                                                ? const Color(0xFFF97316)
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFF97316),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
