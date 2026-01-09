import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/models/product_attributes/products_attributes_model.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/main.dart';

class AttributesManage extends StatefulWidget {
  const AttributesManage({super.key});

  @override
  State<AttributesManage> createState() => _AttributesManageState();
}

class _AttributesManageState extends State<AttributesManage> {
  final String baseUrl = 'https://api.libanbuy.com/api';
  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'X-Request-From': 'Application',
  };

  // Loading states
  bool isLoadingAttributes = true;
  bool isLoadingAttributeItems = false;

  // Data states
  ProductAttributesResponse productsAttributes = ProductAttributesResponse();
  List<ProductAttributes>? attributes = [];
  ProductAttributes? selectedAttribute;
  List<ProductAttributeItems> selectedAttributesItems = [];
  List<ProductAttributeItems> selectedItems = [];

  final AddProductAdminController variantController = Get.put(
    AddProductAdminController(),
  );

  // Secondary attribute items cache
  Map<String, List<ProductAttributeItems>> secondaryAttributeItemsCache = {};

  @override
  void initState() {
    super.initState();
    onInit();
  }

  Future<ProductAttributesResponse> getProductAttributes() async {
    final url = Uri.parse(
      '$baseUrl/product-attributes?_t=${DateTime.now().millisecondsSinceEpoch}',
    );

    try {
      final response = await http.get(url, headers: defaultHeaders);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load product attributes: ${response.reasonPhrase}',
        );
      }

      final data = json.decode(response.body);
      return ProductAttributesResponse.fromJson(data);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ProductAttributes> getAttributeItems(String attributeId) async {
    final url = Uri.parse(
      '$baseUrl/product-attributes/$attributeId?limit=10000&_t=${DateTime.now().millisecondsSinceEpoch}',
    );

    try {
      final response = await http.get(url, headers: defaultHeaders);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load attribute items: ${response.reasonPhrase}',
        );
      }

      final data = json.decode(response.body);
      return ProductAttributes.fromJson(data['product_attribute']);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  onInit() async {
    try {
      setState(() {
        isLoadingAttributes = true;
      });

      productsAttributes = await getProductAttributes();
      attributes = productsAttributes.productAttributes;

      setState(() {
        isLoadingAttributes = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAttributes = false;
      });
      print('Error loading attributes: $e');
    }
  }

  fetchAttributesItems(ProductAttributes attr) async {
    try {
      setState(() {
        isLoadingAttributeItems = true;
        selectedAttribute = attr;
      });

      final attributeData = await getAttributeItems(attr.slug ?? '');
      selectedAttributesItems =
          attributeData.attributeItems?.productAttributeItems ?? [];

      setState(() {
        isLoadingAttributeItems = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAttributeItems = false;
      });
      print('Error loading attribute items: $e');
    }
  }

  addItemToList(ProductAttributeItems item) {
    if (!selectedItems.contains(item)) {
      selectedItems.add(item);

      final newVariantData = VariantData(
        item: item,
        primaryAttribute: selectedAttribute!,
        price: 0.0,
        stock: 0,
        salePrice: 0.0,
        sku: '',
        upcCode: '', // Add UPC code if needed
      );

      variantController.addVariant(newVariantData);
      setState(() {});
    }
  }

  removeItemFromList(ProductAttributeItems item) {
    selectedItems.remove(item);
    variantController.variants.removeWhere(
      (variant) => variant.item.id == item.id,
    );
    setState(() {});
  }

  void updateVariantData(int index, VariantData updatedData) {
    // Get the current variant data
    final currentVariant = variantController.variants[index];

    // Create a new variant with all current values plus updates
    final newVariant = currentVariant.copyWith(
      price: updatedData.price,
      primaryAttribute: updatedData.primaryAttribute,
      stock: updatedData.stock,
      salePrice: updatedData.salePrice,
      sku: updatedData.sku,
      upcCode: updatedData.upcCode,
      thumbnailId: updatedData.thumbnailId,
      secondaryAttribute: updatedData.secondaryAttribute,
      secondaryAttributeItem: updatedData.secondaryAttributeItem,
      showSecondaryAttributeDropdown:
          updatedData.showSecondaryAttributeDropdown,
    );

    variantController.updateVariant(index, newVariant);
    setState(() {});
  }

  // Fetch secondary attribute items
  Future<List<ProductAttributeItems>> fetchSecondaryAttributeItems(
    ProductAttributes attribute,
  ) async {
    // Check cache first
    if (secondaryAttributeItemsCache.containsKey(attribute.slug)) {
      return secondaryAttributeItemsCache[attribute.slug]!;
    }

    try {
      final attributeData = await getAttributeItems(attribute.slug ?? '');
      final items = attributeData.attributeItems?.productAttributeItems ?? [];

      // Cache the result
      secondaryAttributeItemsCache[attribute.slug ?? ''] = items;

      return items;
    } catch (e) {
      print('Error loading secondary attribute items: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,

      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Variation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Attributes Dropdown
            _buildAttributesDropdown(),
            const SizedBox(height: 20),

            // Available Items Section
            if (selectedAttribute != null) ...[
              _buildAvailableItemsSection(),
              const SizedBox(height: 20),
            ],

            // Selected Variants Section
            if (selectedItems.isNotEmpty) ...[_buildSelectedVariantsSection()],
            ElevatedButton(
              onPressed: () {
                final variations = variantController.getVariantsJson();
                print(variations);
                // Now you can use this data to send to your API
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributesDropdown() {
    if (isLoadingAttributes) {
      return _buildShimmerDropdown();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Primary Attribute',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<ProductAttributes>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: 'Choose an attribute',
            ),
            initialValue: selectedAttribute,
            items:
                attributes?.map((attribute) {
                  return DropdownMenuItem<ProductAttributes>(
                    value: attribute,
                    child: Text(
                      attribute.name ?? 'Unnamed Attribute',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList() ??
                [],
            onChanged: (ProductAttributes? value) {
              if (value != null) {
                // Clear previous selections
                selectedItems.clear();
                selectedAttributesItems.clear();
                variantController.variants.clear();

                fetchAttributesItems(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),

        if (isLoadingAttributeItems)
          _buildShimmerChips()
        else if (selectedAttributesItems.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                selectedAttributesItems.map((item) {
                  final isSelected = selectedItems.contains(item);
                  return FilterChip(
                    label: Text(
                      item.name ?? '',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        addItemToList(item);
                      } else {
                        removeItemFromList(item);
                      }
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey[100],
                    elevation: isSelected ? 4 : 2,
                    avatar: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  );
                }).toList(),
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Text(
                'No items available for this attribute',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedVariantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Selected Variants (${selectedItems.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: variantController.variants.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildVariantCard(
                variantController.variants[index],
                index,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVariantCard(VariantData variantData, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Variant Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.label,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        variantData.item.name ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => removeItemFromList(variantData.item),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, size: 20),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (pickedFile != null) {
                      final File file = File(pickedFile.path);

                      // You can now send this file to uploadMedia
                      final imageId = await uploadMedia([
                        file,
                      ]); // assuming your uploadMedia takes a List<File>

                      final updatedData = variantData.copyWith(
                        thumbnailId: imageId,
                      );
                      updateVariantData(index, updatedData);
                      setState(() {});
                    }
                  },
                ),
                if (variantData.thumbnailId != null) ...[
                  Container(
                    height: 60,
                    width: 150,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red,
                    ),
                    child: Stack(
                      children: [
                        const Center(child: Text('Image Selected')),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              final updatedData = variantData.copyWith(
                                thumbnailId: null,
                              );
                              updateVariantData(index, updatedData);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Form Fields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Price',
                    value: variantData.price.toString(),
                    onChanged: (value) {
                      final updatedData = variantData.copyWith(
                        price: double.tryParse(value) ?? 0.0,
                      );
                      updateVariantData(index, updatedData);
                    },
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'Stock',
                    value: variantData.stock.toString(),
                    onChanged: (value) {
                      final updatedData = variantData.copyWith(
                        stock: int.tryParse(value) ?? 0,
                      );
                      updateVariantData(index, updatedData);
                    },
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.inventory,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Sale Price',
                    value: variantData.salePrice.toString(),
                    onChanged: (value) {
                      final updatedData = variantData.copyWith(
                        salePrice: double.tryParse(value) ?? 0.0,
                      );
                      updateVariantData(index, updatedData);
                    },
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.local_offer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: 'SKU',
                    value: variantData.sku,
                    onChanged: (value) {
                      final updatedData = variantData.copyWith(sku: value);

                      updateVariantData(index, updatedData);
                    },
                    prefixIcon: Icons.qr_code,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'UPC Code',
              value: variantData.upcCode,
              onChanged: (value) {
                final updatedData = variantData.copyWith(upcCode: value);
                updateVariantData(index, updatedData);
              },
              prefixIcon: Icons.barcode_reader,
            ),

            const SizedBox(height: 16),

            // Secondary Attribute Section
            _buildSecondaryAttributeSection(variantData, index),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            initialValue: value == '0' || value == '0.0' ? '' : value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              prefixIcon:
                  prefixIcon != null
                      ? Icon(prefixIcon, size: 16, color: Colors.grey[600])
                      : null,
              hintText: 'Enter $label',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryAttributeSection(VariantData variantData, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (variantData.secondaryAttribute != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Secondary: ${variantData.secondaryAttribute!.name}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.green),
                  onPressed: () {
                    final updatedData = variantData.copyWith(
                      secondaryAttribute: null,
                      clearSecondaryAttribute: true,
                    );
                    updateVariantData(index, updatedData);
                  },
                ),
              ],
            ),
          ),
        ] else if (variantData.showSecondaryAttributeDropdown) ...[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonFormField<ProductAttributes>(
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                hintText: 'Select secondary attribute',
                hintStyle: TextStyle(fontSize: 12),
              ),
              items:
                  attributes
                      ?.where((attr) => attr.id != selectedAttribute?.id)
                      .map((attribute) {
                        return DropdownMenuItem<ProductAttributes>(
                          value: attribute,
                          child: Text(
                            attribute.name ?? 'Unnamed Attribute',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      })
                      .toList() ??
                  [],
              onChanged: (ProductAttributes? value) {
                if (value != null) {
                  final updatedData = variantData.copyWith(
                    secondaryAttribute: value,
                    showSecondaryAttributeDropdown: false,
                  );
                  updateVariantData(index, updatedData);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  final updatedData = variantData.copyWith(
                    showSecondaryAttributeDropdown: false,
                  );
                  updateVariantData(index, updatedData);
                },
                child: const Text('Cancel', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ] else ...[
          TextButton.icon(
            onPressed: () {
              final updatedData = variantData.copyWith(
                showSecondaryAttributeDropdown: true,
              );
              updateVariantData(index, updatedData);
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'Add Secondary Attribute',
              style: TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ],
    );
  }

  // Shimmer Loading Widgets
  Widget _buildShimmerDropdown() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildShimmerEffect(),
    );
  }

  Widget _buildShimmerChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        5,
        (index) => Container(
          height: 32,
          width: 80 + (index * 20),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: _buildShimmerEffect(),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// Data model for variant data
class VariantData {
  final ProductAttributeItems item;
  final ProductAttributes primaryAttribute;
  final double price;
  final int stock;
  final double salePrice;
  final String sku;
  final String upcCode;
  final String? thumbnailId; // Add this field
  final ProductAttributes? secondaryAttribute;
  final ProductAttributeItems? secondaryAttributeItem;
  final List<ProductAttributeItems>? secondaryAttributeItems;
  final bool showSecondaryAttributeDropdown;
  final bool isLoadingSecondaryItems;

  VariantData({
    required this.item,
    required this.primaryAttribute,
    this.price = 0.0,
    this.stock = 0,
    this.salePrice = 0.0,
    this.sku = '',
    this.upcCode = '',
    this.thumbnailId, // Initialize it as nullable
    this.secondaryAttribute,
    this.secondaryAttributeItem,
    this.secondaryAttributeItems,
    this.showSecondaryAttributeDropdown = false,
    this.isLoadingSecondaryItems = false,
  });

  VariantData copyWith({
    ProductAttributeItems? item,
    ProductAttributes? primaryAttribute,
    double? price,
    int? stock,
    double? salePrice,
    String? sku,
    String? upcCode,
    String? thumbnailId,
    ProductAttributes? secondaryAttribute,
    ProductAttributeItems? secondaryAttributeItem,
    List<ProductAttributeItems>? secondaryAttributeItems,
    bool? showSecondaryAttributeDropdown,
    bool? isLoadingSecondaryItems,
    bool clearSecondaryAttribute = false,
  }) {
    return VariantData(
      item: item ?? this.item,
      primaryAttribute: primaryAttribute ?? this.primaryAttribute,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      salePrice: salePrice ?? this.salePrice,
      sku: sku ?? this.sku,
      upcCode: upcCode ?? this.upcCode,
      thumbnailId: thumbnailId ?? this.thumbnailId, // Include in copyWith
      secondaryAttribute:
          clearSecondaryAttribute
              ? null
              : (secondaryAttribute ?? this.secondaryAttribute),
      secondaryAttributeItem:
          clearSecondaryAttribute
              ? null
              : (secondaryAttributeItem ?? this.secondaryAttributeItem),
      secondaryAttributeItems:
          clearSecondaryAttribute
              ? null
              : (secondaryAttributeItems ?? this.secondaryAttributeItems),
      showSecondaryAttributeDropdown:
          showSecondaryAttributeDropdown ?? this.showSecondaryAttributeDropdown,
      isLoadingSecondaryItems:
          isLoadingSecondaryItems ?? this.isLoadingSecondaryItems,
    );
  }

  Map<String, dynamic> toJson() {
    final attributes = [
      {"attributeId": primaryAttribute.id, "attributeItemId": item.id},
    ];

    if (secondaryAttribute != null && secondaryAttributeItem != null) {
      attributes.add({
        "attributeId": secondaryAttribute!.id,
        "attributeItemId": secondaryAttributeItem!.id,
      });
    }

    return {
      "price": price,
      "stock": stock,
      "sale_price": salePrice,
      "sku": sku,
      "upc_code": upcCode,
      "thumbnail_id": thumbnailId, // Include in JSON
      "attributes": attributes,
    };
  }
}
