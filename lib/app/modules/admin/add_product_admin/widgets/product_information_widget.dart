import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';
import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/admin/add_product_admin/views/add_product_admin_view.dart';
import 'package:tjara/app/modules/admin/categories_admin/controllers/categories_admin_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ProductInformationWidget extends StatelessWidget {
  final AddProductAdminController controller;
  final CategoriesAdminController categoryAdminController;
  const ProductInformationWidget({
    super.key,
    required this.controller,
    required this.categoryAdminController,
  });

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${controller.selectedProductgroup.value.isEmpty ? "Product" : controller.selectedProductgroup.value} Information",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Obx(() {
              final isCar =
                  (controller.selectedProductgroup.value.toLowerCase() ==
                          'car' ||
                      controller.selectedProductgroup.value.toLowerCase() ==
                          'cars');

              if (!isCar) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "${controller.selectedProductgroup.value.isEmpty ? "Product" : controller.selectedProductgroup.value} Name",
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.black,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const Text(
                          "*",
                          style: TextStyle(color: AppColors.red, fontSize: 20),
                        ),
                      ],
                    ),
                    Text(
                      "Enter the unique name of your ${controller.selectedProductgroup.value.isEmpty ? "Product" : controller.selectedProductgroup.value}. Make it descriptive and easy to remember for customers.",
                      style: const TextStyle(
                        color: AppColors.adminGreyColorText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SimpleTextFormFieldWidget(
                      textController: controller.productNameController,
                      hint:
                          '${controller.selectedProductgroup.value.isEmpty ? "Product" : controller.selectedProductgroup.value} name',
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
                      "Select the primary category for your product.",
                      style: TextStyle(color: AppColors.adminGreyColorText),
                    ),
                    const SizedBox(height: 10),
                    GetBuilder<AddProductAdminController>(
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
                                    ctrl.selectedCategoryName ??
                                        'Select Category',
                                    style: TextStyle(
                                      color:
                                          ctrl.selectedCategoryName == null
                                              ? Colors.grey[600]
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.search,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }

              // Car-specific: Name + Make + Year
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Car Name",
                        style: TextStyle(
                          color: AppColors.darkLightTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.buttonLightGreyColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5,
                          ),
                          child: Text(
                            "Required",
                            style: TextStyle(
                              color: AppColors.darkLightTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Enter the unique name of your car. Make it descriptive and easy to remember for customers.",
                    style: TextStyle(color: AppColors.adminGreyColorText),
                  ),
                  const SizedBox(height: 10),
                  SimpleTextFormFieldWidget(
                    textController: controller.productNameController,
                    hint: 'Car name',
                  ),
                  const SizedBox(height: 25),

                  // Car Make selection with dialog
                  const Row(
                    children: [
                      Text(
                        "Car Make",
                        style: TextStyle(
                          color: AppColors.darkLightTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Select the primary car make.",
                    style: TextStyle(color: AppColors.adminGreyColorText),
                  ),
                  const SizedBox(height: 10),
                  GetBuilder<AddProductAdminController>(
                    builder: (ctrl) {
                      return GestureDetector(
                        onTap: () => _showCarMakeSearchDialog(context, ctrl),
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
                                  ctrl.selectedCarMakeName ?? 'Select Make',
                                  style: TextStyle(
                                    color:
                                        ctrl.selectedCarMakeName == null
                                            ? Colors.grey[600]
                                            : Colors.black,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.search,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),
                  // Car Year selection with dialog
                  const Row(
                    children: [
                      Text(
                        "Car Year",
                        style: TextStyle(
                          color: AppColors.darkLightTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Select the model year.",
                    style: TextStyle(color: AppColors.adminGreyColorText),
                  ),
                  const SizedBox(height: 10),
                  GetBuilder<AddProductAdminController>(
                    builder: (ctrl) {
                      return GestureDetector(
                        onTap: () => _showCarYearSearchDialog(context, ctrl),
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
                                  ctrl.selectedCarYearName ?? 'Select Year',
                                  style: TextStyle(
                                    color:
                                        ctrl.selectedCarYearName == null
                                            ? Colors.grey[600]
                                            : Colors.black,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.search,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 25),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(
            //       "Category",
            //       style: TextStyle(
            //         color: AppColors.darkLightTextColor,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //     Text(
            //       "Select the primary category that best represents your ${controller.selectedProductgroup.value ?? "Product"}. This helps customers find your product more easily.",
            //       style: TextStyle(color: AppColors.adminGreyColorText),
            //     ),
            //     SizedBox(height: 10),
            //     GetBuilder<AddProductAdminController>(
            //       builder: (controller) {
            //         return CustomSearchDropdown(
            //           selectedItem: controller.selectedItem,
            //           hintText: 'Select Category',
            //           initialItemsLoader: () async {
            //             final args = controller.selectedProductgroup.value;
            //             String postType = 'product';

            //             postType = args;

            //             final NetworkRepository repository = NetworkRepository();
            //             final result = await repository.fetchData<CategoryModel>(
            //               url:
            //                   'https://api.libanbuy.com/api/product-attribute-items?hide_empty=True&limit=52&with=thumbnail&post_type=$postType&search=',
            //               fromJson: (json) => CategoryModel.fromJson(json),
            //               forceRefresh: true,
            //             );
            //             return result.productAttributeItems ?? [];
            //           },
            //           searchItemsLoader: (query) async {
            //             final args = controller.selectedProductgroup.value;
            //             String postType = 'product';

            //             postType = args;
            //             final NetworkRepository repository = NetworkRepository();
            //             final result = await repository.fetchData<CategoryModel>(
            //               url:
            //                   'https://api.libanbuy.com/api/product-attribute-items?hide_empty=True&limit=52&with=thumbnail&post_type=$postType&search=$query',
            //               fromJson: (json) => CategoryModel.fromJson(json),
            //               forceRefresh: true,
            //             );
            //             return result.productAttributeItems ?? [];
            //           },
            //           onChanged: (value) {
            //             controller.selectedItem = value;
            //             controller
            //                 .update(); // This will trigger GetBuilder to rebuild
            //           },
            //         );
            //       },
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  void _showCategorySearchDialog(
    BuildContext context,
    AddProductAdminController ctrl,
  ) async {
    // Show category search dialog with API search
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _CategorySearchDialog(
          title: 'Select Category',
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

  void _showCarMakeSearchDialog(
    BuildContext context,
    AddProductAdminController ctrl,
  ) async {
    // Show car make search dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _CategorySearchDialog(
          title: 'Select Car Make',
          onSearch: (query) => _searchCarMakes(query),
          onCategorySelected: (id, name) {
            ctrl.selectedCarMakeId = id;
            ctrl.selectedCarMakeName = name;
            ctrl.update();
            Navigator.of(dialogContext).pop();
          },
          selectedCategoryId: ctrl.selectedCarMakeId,
        );
      },
    );
  }

  void _showCarYearSearchDialog(
    BuildContext context,
    AddProductAdminController ctrl,
  ) async {
    // Show car year search dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _CategorySearchDialog(
          title: 'Select Car Year',
          onSearch: (query) => _searchCarYears(query),
          onCategorySelected: (id, name) {
            ctrl.selectedCarYearId = id;
            ctrl.selectedCarYearName = name;
            ctrl.update();
            Navigator.of(dialogContext).pop();
          },
          selectedCategoryId: ctrl.selectedCarYearId,
        );
      },
    );
  }

  Future<List<Map<String, String>>> _extractAttributeItems(dynamic data) async {
    final List<Map<String, String>> list = [];
    try {
      List items = [];
      if (data is Map && data['product_attribute'] != null) {
        final pa = data['product_attribute'];
        if (pa is Map && pa['attribute_items'] != null) {
          final ai = pa['attribute_items'];
          if (ai is Map && ai['product_attribute_items'] is List) {
            items = ai['product_attribute_items'];
          }
        }
      } else if (data is Map && data['data'] is List) {
        items = data['data'];
      }

      for (final it in items) {
        if (it is Map) {
          list.add({
            'id': (it['id'] ?? '').toString(),
            'name': (it['name'] ?? '').toString(),
          });
        }
      }
    } catch (_) {}
    return list;
  }

  Future<List<Map<String, String>>> _searchCategories(String query) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/product-attributes/categories?post_type=product&search=$query&order_by=name&order=ASC&limit=30',
        ),
        headers: {'X-Request-From': 'Dashboard'},
      );
      if (res.statusCode == 200) {
        return _extractAttributeItems(json.decode(res.body));
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, String>>> _searchCarMakes(String query) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/product-attributes/categories?post_type=car&search=$query&order_by=name&order=ASC&limit=30',
        ),
        headers: {'X-Request-From': 'Dashboard'},
      );
      if (res.statusCode == 200) {
        return _extractAttributeItems(json.decode(res.body));
      }
      final res2 = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/product-attributes/categories?post_type=car&search=$query&order_by=name&order=ASC&limit=30',
        ),
        headers: {'X-Request-From': 'Dashboard'},
      );
      if (res2.statusCode == 200) {
        return _extractAttributeItems(json.decode(res2.body));
      }
    } catch (_) {}
    return [];
  }

  Future<List<Map<String, String>>> _searchCarYears(String query) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/product-attributes/years?post_type=car&search=$query&order_by=name&order=DESC&limit=all',
        ),
        headers: {'X-Request-From': 'Dashboard'},
      );
      if (res.statusCode == 200) {
        return _extractAttributeItems(json.decode(res.body));
      }
      final res2 = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/product-attributes/years?post_type=car&search=$query&order_by=name&order=DESC&limit=all',
        ),
        headers: {'X-Request-From': 'Dashboard'},
      );
      if (res2.statusCode == 200) {
        return _extractAttributeItems(json.decode(res2.body));
      }
    } catch (_) {}
    return [];
  }
}

class _CategorySearchDialog extends StatefulWidget {
  final String title;
  final Future<List<Map<String, String>>> Function(String query) onSearch;
  final Function(String id, String name) onCategorySelected;
  final String? selectedCategoryId;

  const _CategorySearchDialog({
    required this.title,
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
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF97316),
                    ),
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
                  hintText: 'Search ${widget.title.toLowerCase()}...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFF97316),
                  ),
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
                  '${_categories.length} items found',
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
                              'No items found',
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
                                        ? const Color(
                                          0xFFF97316,
                                        ).withOpacity(0.1)
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
