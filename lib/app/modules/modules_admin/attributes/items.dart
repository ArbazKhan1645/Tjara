import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/product_attributes/products_attributes_model.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

// Service for Product Attribute Items
class ProductAttributeItemsService {
  final String baseUrl = 'https://api.libanbuy.com/api';
  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'X-Request-From': 'Application',
  };

  Future<ProductAttributes> getAttributeItems(String attributeId) async {
    final url = Uri.parse(
      '$baseUrl/product-attributes/$attributeId?limit=10000&_t=${DateTime.now().millisecondsSinceEpoch}',
    );

    try {
      final response = await http.get(url, headers: defaultHeaders);

      if (response.statusCode == 404) {
        throw Exception('No products Attibutes Items available');
      }

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

  // Create new attribute item
  Future<bool> createAttributeItem({
    required String attributeId,
    required String name,
    String? parentId,
    String? value,
  }) async {
    final url = Uri.parse(
      'https://api.libanbuy.com/api/product-attribute-items/insert',
    );

    try {
      final body = {
        'attribute_id': attributeId,
        'post_type': 'product',
        'name': name,
      };

      if (parentId != null && parentId.isNotEmpty) {
        body['parent_id'] = parentId;
      }

      if (value != null && value.isNotEmpty) {
        body['value'] = value;
      }

      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: json.encode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating attribute item: $e');
    }
  }

  // Update attribute item
  Future<bool> updateAttributeItem(
    String id,
    String name, {
    String? value,
  }) async {
    final url = Uri.parse('$baseUrl/product-attribute-items/$id/update');

    try {
      final body = {'name': name, 'post_type': 'product'};

      if (value != null && value.isNotEmpty) {
        body['value'] = value;
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Application',
        },
        body: json.encode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error updating attribute item: $e');
    }
  }

  // Delete attribute item
  Future<bool> deleteAttributeItem(String id) async {
    final url = Uri.parse('$baseUrl/product-attribute-items/$id/delete');

    try {
      final response = await http.delete(url, headers: defaultHeaders);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting attribute item: $e');
    }
  }
}

// Controller for Product Attribute Items
class ProductAttributeItemsController extends GetxController {
  final ProductAttributeItemsService _service = ProductAttributeItemsService();

  // Observable variables
  final RxList<ProductAttributeItems> attributeItems =
      <ProductAttributeItems>[].obs;
  final RxList<ProductAttributeItems> filteredItems =
      <ProductAttributeItems>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasLoadedData = false.obs; // Track if data has been loaded
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Current attribute info
  final RxString currentAttributeSlug = ''.obs;
  final RxString currentAttributeID = ''.obs;
  final RxString currentAttributeName = ''.obs;

  // Form state
  final RxBool isEditMode = false.obs;
  final Rx<ProductAttributeItems?> editingItem = Rx<ProductAttributeItems?>(
    null,
  );

  @override
  void onInit() {
    super.onInit();
    // Listen to search query changes
    ever(searchQuery, (String query) {
      filterItems(query);
    });
  }

  // Initialize with attribute data
  void initializeAttribute(
    String attributeId,
    String attributeName,
    String id,
  ) {
    currentAttributeSlug.value = attributeId;
    currentAttributeName.value = attributeName;
    currentAttributeID.value = id;

    // Only load if not already loaded
    if (!hasLoadedData.value) {
      loadAttributeItems();
    }
  }

  // Load all items for current attribute
  Future<void> loadAttributeItems() async {
    if (currentAttributeSlug.value.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _service.getAttributeItems(
        currentAttributeSlug.value,
      );

      // Handle null safety for attributeItems
      attributeItems.value =
          response.attributeItems?.productAttributeItems ?? [];

      // Update filtered items
      filteredItems.value = List.from(attributeItems);

      // Mark data as loaded
      hasLoadedData.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filter items based on search query
  void filterItems(String query) {
    try {
      if (query.isEmpty) {
        filteredItems.value = List.from(attributeItems);
      } else {
        filteredItems.value =
            attributeItems.where((item) {
              final itemName = item.name;
              if (itemName == null || itemName.isEmpty) return false;

              final queryLower = query.toLowerCase();
              final nameLower = itemName.toLowerCase();

              return nameLower.contains(queryLower);
            }).toList();
      }
    } catch (e) {
      print('Error filtering items: $e');
      filteredItems.value = List.from(attributeItems);
    }
  }

  // Get parent items for dropdown
  List<ProductAttributeItems> getParentItems() {
    try {
      return attributeItems.where((item) {
        if (item.parentId != null) return false;
        return true;
      }).toList();
    } catch (e) {
      print('Error getting parent items: $e');
      return [];
    }
  }

  // Create new attribute item
  Future<bool> createAttributeItem({
    required String name,
    String? parentId,
    String? value,
  }) async {
    try {
      isLoading.value = true;
      final success = await _service.createAttributeItem(
        attributeId: currentAttributeID.value,
        name: name,
        parentId: parentId,
        value: value,
      );

      if (success) {
        await loadAttributeItems();
        Get.snackbar(
          'Success',
          'Item created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update existing attribute item
  Future<bool> updateAttributeItem(
    String id,
    String name, {
    String? value,
  }) async {
    try {
      isLoading.value = true;
      final success = await _service.updateAttributeItem(
        id,
        name,
        value: value,
      );

      if (success) {
        await loadAttributeItems();
        Get.snackbar(
          'Success',
          'Item updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }

      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete attribute item
  Future<bool> deleteAttributeItem(String id) async {
    try {
      isLoading.value = true;
      final success = await _service.deleteAttributeItem(id);

      if (success) {
        await loadAttributeItems();
      }

      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Set edit mode
  void setEditMode(ProductAttributeItems item) {
    isEditMode.value = true;
    editingItem.value = item;
  }

  // Clear edit mode
  void clearEditMode() {
    isEditMode.value = false;
    editingItem.value = null;
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Check if attribute is color
  bool isColorAttribute() {
    return currentAttributeName.value.toLowerCase() == 'colors' ||
        currentAttributeName.value.toLowerCase() == 'colours';
  }
}

// Screen for managing attribute items
class ProductAttributeItemsScreen extends StatelessWidget {
  final String attributeSymbol;
  final String attributeId;
  final String attributeName;

  const ProductAttributeItemsScreen({
    super.key,
    required this.attributeSymbol,
    required this.attributeName,
    required this.attributeId,
  });

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.teal, Colors.teal],
    );
    final controller = Get.put(ProductAttributeItemsController());

    // Initialize controller with current attribute
    controller.initializeAttribute(attributeSymbol, attributeName, attributeId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // Gradient background for upper half
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        '$attributeName Items',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Add/Edit Form Card
                        _buildFormCard(controller),

                        const SizedBox(height: 20),

                        // Items List Card
                        _buildItemsListCard(controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(ProductAttributeItemsController controller) {
    final TextEditingController itemNameController = TextEditingController();
    final Rx<String?> selectedParentId = Rx<String?>(null);
    final Rx<Color> selectedColor = Rx<Color>(Colors.blue);

    return Obx(() {
      // Update form when editing
      if (controller.isEditMode.value && controller.editingItem.value != null) {
        itemNameController.text = controller.editingItem.value!.name ?? '';
        selectedParentId.value = controller.editingItem.value!.parentId;

        // Parse color if exists
        if (controller.editingItem.value!.value != null) {
          try {
            final colorValue = controller.editingItem.value!.value!.replaceAll(
              '#',
              '',
            );
            selectedColor.value = Color(int.parse('FF$colorValue', radix: 16));
          } catch (e) {
            selectedColor.value = Colors.blue;
          }
        }
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              controller.isEditMode.value ? 'UPDATE ITEM' : 'ADD ITEM',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),

            // Item Name
            Text(
              'Item Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: itemNameController,
              decoration: InputDecoration(
                hintText: 'Enter ${attributeName.toLowerCase()} name',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parent Item (Optional)
            Text(
              'Parent Item (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final parentItems = controller.getParentItems();
              return DropdownButtonFormField<String>(
                initialValue: selectedParentId.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('No Parent'),
                  ),
                  ...parentItems.map((parent) {
                    return DropdownMenuItem<String>(
                      value: parent.id,
                      child: Text(parent.name ?? 'Unknown'),
                    );
                  }),
                ],
                onChanged: (value) {
                  selectedParentId.value = value;
                },
              );
            }),

            // Color Picker (only for color attributes)
            if (controller.isColorAttribute()) ...[
              const SizedBox(height: 16),
              Text(
                'Color Value',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => GestureDetector(
                  onTap: () async {
                    final Color? result = await showDialog<Color>(
                      context: Get.context!,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Pick a color'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                color: selectedColor.value,
                                onColorChanged: (Color color) {
                                  selectedColor.value = color;
                                },
                                pickersEnabled: const <ColorPickerType, bool>{
                                  ColorPickerType.both: false,
                                  ColorPickerType.primary: true,
                                  ColorPickerType.accent: true,
                                  ColorPickerType.wheel: true,
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed:
                                    () => Navigator.of(
                                      context,
                                    ).pop(selectedColor.value),
                                child: const Text('Select'),
                              ),
                            ],
                          ),
                    );
                    if (result != null) {
                      selectedColor.value = result;
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: selectedColor.value,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        '#${selectedColor.value.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: TextStyle(
                          color:
                              selectedColor.value.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                if (controller.isEditMode.value) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        itemNameController.clear();
                        selectedParentId.value = null;
                        selectedColor.value = Colors.blue;
                        controller.clearEditMode();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = itemNameController.text.trim();
                      if (name.isNotEmpty) {
                        String? colorValue;
                        if (controller.isColorAttribute()) {
                          colorValue =
                              '#${selectedColor.value.value.toRadixString(16).substring(2)}';
                        }

                        bool success;
                        if (controller.isEditMode.value &&
                            controller.editingItem.value != null) {
                          success = await controller.updateAttributeItem(
                            controller.editingItem.value!.id ?? '',
                            name,
                            value: colorValue,
                          );
                        } else {
                          success = await controller.createAttributeItem(
                            name: name,
                            parentId: selectedParentId.value,
                            value: colorValue,
                          );
                        }

                        if (success) {
                          itemNameController.clear();
                          selectedParentId.value = null;
                          selectedColor.value = Colors.blue;
                          controller.clearEditMode();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      controller.isEditMode.value ? 'Update' : 'Submit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget _buildItemsListCard(ProductAttributeItemsController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => controller.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search Items...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.list, color: Colors.grey[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${attributeName.toUpperCase()} ITEMS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Parent',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Action',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              if (controller.isLoading.value &&
                  !controller.hasLoadedData.value) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  ),
                );
              }

              if (controller.filteredItems.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list, size: 64, color: Colors.grey[400]),
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
                  ),
                );
              }

              return Column(
                children:
                    controller.filteredItems.map((item) {
                      ProductAttributeItems? parentItem;
                      try {
                        parentItem = controller.attributeItems.firstWhereOrNull(
                          (p) => p.id != null && p.id == item.parentId,
                        );
                      } catch (e) {
                        parentItem = null;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Item (Avatar or Color)
                            Expanded(
                              flex: 1,
                              child: _buildItemAvatar(item, controller),
                            ),
                            // Name
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.name ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Parent
                            Expanded(
                              flex: 2,
                              child: Text(
                                parentItem?.name ?? 'No Parent',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            // Action
                            Expanded(
                              flex: 1,
                              child: PopupMenuButton<String>(
                                onSelected:
                                    (value) =>
                                        _handleAction(value, item, controller),
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 16),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                child: const Icon(Icons.more_horiz, size: 20),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItemAvatar(
    ProductAttributeItems item,
    ProductAttributeItemsController controller,
  ) {
    // If it's a color attribute and has a value, show the color
    if (controller.isColorAttribute() && item.value != null) {
      try {
        final colorValue = item.value!.replaceAll('#', '');
        final color = Color(int.parse('FF$colorValue', radix: 16));
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
        );
      } catch (e) {
        // Fallback to letter avatar
      }
    }

    // Default letter avatar
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFFE91E63),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getFirstLetter(item.name),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Helper method to safely get first letter
  String _getFirstLetter(String? name) {
    if (name == null || name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  void _handleAction(
    String action,
    ProductAttributeItems item,
    ProductAttributeItemsController controller,
  ) {
    switch (action) {
      case 'edit':
        controller.setEditMode(item);
        break;
      case 'delete':
        _showDeleteDialog(item, controller);
        break;
    }
  }

  void _showDeleteDialog(
    ProductAttributeItems item,
    ProductAttributeItemsController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to delete "${item.name ?? 'this item'}"?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (item.id != null) {
                final success = await controller.deleteAttributeItem(
                  item.id ?? '',
                );

                Get.back();

                if (success) {
                  Get.snackbar(
                    'Success',
                    'Item deleted successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
