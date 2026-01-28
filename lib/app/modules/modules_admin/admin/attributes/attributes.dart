import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/product_attributes/products_attributes_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/modules_admin/admin/attributes/items.dart';

class ProductAttributesService {
  final String baseUrl = 'https://api.libanbuy.com/api';
  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'X-Request-From': 'Application',
  };

  // Get all product attributes
  Future<ProductAttributesResponse> getProductAttributes() async {
    final url = Uri.parse(
      '$baseUrl/product-attributes?limit=10000&_t=${DateTime.now().millisecondsSinceEpoch}',
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

  // Create new attribute
  Future<bool> createAttribute(String name) async {
    final url = Uri.parse('$baseUrl/product-attributes/insert');

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: json.encode({'name': name}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating attribute: $e');
    }
  }

  // Update attribute
  Future<bool> updateAttribute(String id, String name) async {
    final url = Uri.parse('$baseUrl/product-attributes/$id/update');

    try {
      final response = await http.put(
        url,
        headers: defaultHeaders,
        body: json.encode({'name': name}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating attribute: $e');
    }
  }

  // Delete attribute
  Future<bool> deleteAttribute(String id) async {
    final url = Uri.parse('$baseUrl/product-attributes/$id/delete');

    try {
      final response = await http.delete(url, headers: defaultHeaders);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting attribute: $e');
    }
  }
}

class ProductAttributesController extends GetxController {
  final ProductAttributesService _service = ProductAttributesService();

  // Observable variables
  final RxList<ProductAttributes> attributes = <ProductAttributes>[].obs;
  final RxList<ProductAttributes> filteredAttributes =
      <ProductAttributes>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Temporary storage for API delay handling
  final RxList<ProductAttributes> _pendingCreations = <ProductAttributes>[].obs;
  final RxList<String> _pendingDeletions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAttributes();

    // Listen to search query changes
    ever(searchQuery, (String query) {
      filterAttributes(query);
    });
  }

  // Load all attributes from API
  Future<void> loadAttributes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _service.getProductAttributes();
      final apiAttributes = response.productAttributes ?? [];

      // Merge API data with pending changes
      _mergeAttributesWithPending(apiAttributes);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Merge API attributes with pending local changes
  void _mergeAttributesWithPending(List<ProductAttributes> apiAttributes) {
    // Start with API attributes
    final List<ProductAttributes> mergedAttributes = List.from(apiAttributes);

    // Remove any attributes that are pending deletion
    mergedAttributes.removeWhere((attr) => _pendingDeletions.contains(attr.id));

    // Add pending creations that aren't already in API response
    for (var pendingAttr in _pendingCreations) {
      final existsInApi = mergedAttributes.any(
        (attr) => attr.name?.toLowerCase() == pendingAttr.name?.toLowerCase(),
      );
      if (!existsInApi) {
        mergedAttributes.insert(0, pendingAttr); // Add at beginning
      }
    }

    // Clean up pending lists if items now exist in API
    _cleanupPendingLists(apiAttributes);

    attributes.value = mergedAttributes;
    filteredAttributes.value = mergedAttributes;
    filterAttributes(searchQuery.value); // Re-apply current search
  }

  // Clean up pending lists when items are confirmed in API
  void _cleanupPendingLists(List<ProductAttributes> apiAttributes) {
    // Remove from pending creations if now in API
    _pendingCreations.removeWhere(
      (pendingAttr) => apiAttributes.any(
        (apiAttr) =>
            apiAttr.name?.toLowerCase() == pendingAttr.name?.toLowerCase(),
      ),
    );

    // Remove from pending deletions if no longer in API
    _pendingDeletions.removeWhere(
      (pendingId) => !apiAttributes.any((apiAttr) => apiAttr.id == pendingId),
    );
  }

  // Filter attributes based on search query
  void filterAttributes(String query) {
    if (query.isEmpty) {
      filteredAttributes.value = attributes;
    } else {
      filteredAttributes.value =
          attributes
              .where(
                (attr) =>
                    attr.name?.toLowerCase().contains(query.toLowerCase()) ??
                    false,
              )
              .toList();
    }
  }

  // Create new attribute with immediate UI update
  Future<bool> createAttribute(String name) async {
    try {
      isLoading.value = true;

      // Create temporary attribute for immediate UI feedback
      final tempAttribute = ProductAttributes(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        slug: name.toLowerCase().replaceAll(' ', '-'),
      );

      // Add to pending creations and update UI immediately
      _pendingCreations.add(tempAttribute);
      _mergeAttributesWithPending(
        attributes.where((attr) => !attr.id!.startsWith('temp_')).toList(),
      );

      final success = await _service.createAttribute(name);

      if (success) {
        Get.snackbar(
          'Success',
          'Attribute created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Refresh data after a short delay to get updated API response
        Future.delayed(const Duration(seconds: 2), () => loadAttributes());
      } else {
        // Remove from pending if API call failed
        _pendingCreations.removeWhere((attr) => attr.id == tempAttribute.id);
        _mergeAttributesWithPending(
          attributes.where((attr) => !attr.id!.startsWith('temp_')).toList(),
        );
      }

      return success;
    } catch (e) {
      // Remove from pending if error occurred
      _pendingCreations.removeWhere((attr) => attr.name == name);
      _mergeAttributesWithPending(
        attributes.where((attr) => !attr.id!.startsWith('temp_')).toList(),
      );

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

  // Update existing attribute
  Future<bool> updateAttribute(String id, String name) async {
    try {
      isLoading.value = true;

      // Store original attribute for rollback if needed
      final originalAttr = attributes.firstWhere((attr) => attr.id == id);
      final originalName = originalAttr.name;

      // Update UI immediately
      final index = attributes.indexWhere((attr) => attr.id == id);
      if (index != -1) {
        attributes[index] = ProductAttributes(
          id: id,
          name: name,
          slug: name.toLowerCase().replaceAll(' ', '-'),
        );
        filterAttributes(searchQuery.value);
      }

      final success = await _service.updateAttribute(id, name);

      if (success) {
        // Refresh data after a short delay
        Future.delayed(const Duration(seconds: 0), () => loadAttributes());
      } else {
        // Rollback on failure
        if (index != -1) {
          attributes[index] = ProductAttributes(
            id: id,
            name: originalName,
            slug: originalName?.toLowerCase().replaceAll(' ', '-'),
          );
          filterAttributes(searchQuery.value);
        }
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

  // Delete attribute with immediate UI update
  Future<bool> deleteAttribute(String id) async {
    try {
      isLoading.value = true;

      // Remove from UI immediately
      attributes.removeWhere((attr) => attr.id == id);
      filteredAttributes.removeWhere((attr) => attr.id == id);

      // Add to pending deletions
      _pendingDeletions.add(id);

      // Call API in background
      final success = await _service.deleteAttribute(id);

      if (!success) {
        // If API call failed, revert the UI change
        loadAttributes(); // Reload original data
        return false;
      }

      // Refresh data after a short delay to sync with API
      Future.delayed(const Duration(seconds: 2), () => loadAttributes());

      return true;
    } catch (e) {
      // On error, reload original data
      loadAttributes();

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

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}

class ProductAttributesScreen extends StatelessWidget {
  const ProductAttributesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );
    final controller = Get.put(ProductAttributesController());
    final TextEditingController attributeNameController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'Product Attributes',
                        style: TextStyle(
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
                        // Add Attribute Card
                        Container(
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
                              // Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      'ADD ATTRIBUTE',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Form content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Attribute Name
                                    Text(
                                      'Attribute Name',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: attributeNameController,
                                      decoration: InputDecoration(
                                        hintText: 'Colors',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Create button
                                    Obx(
                                      () => SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed:
                                              controller.isLoading.value
                                                  ? null
                                                  : () async {
                                                    final name =
                                                        attributeNameController
                                                            .text
                                                            .trim();
                                                    if (name.isNotEmpty) {
                                                      final success =
                                                          await controller
                                                              .createAttribute(
                                                                name,
                                                              );
                                                      if (success) {
                                                        attributeNameController
                                                            .clear();
                                                      }
                                                    }
                                                  },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF0D9488,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            elevation: 0,
                                          ),
                                          child:
                                              controller.isLoading.value
                                                  ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                  : const Text(
                                                    'Create',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Attributes List Card
                        Container(
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
                                  onChanged:
                                      (value) =>
                                          controller.updateSearchQuery(value),
                                  decoration: InputDecoration(
                                    hintText: 'Search Attributes...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey[600],
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
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
                              // Padding(
                              //   padding: EdgeInsets.symmetric(horizontal: 16),
                              //   child: Row(
                              //     children: [
                              //       Icon(
                              //         Icons.category,
                              //         color: Colors.grey[700],
                              //         size: 20,
                              //       ),
                              //       SizedBox(width: 8),
                              //       Text(
                              //         'ATTRIBUTES',
                              //         style: TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w600,
                              //           color: Colors.grey[800],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              const SizedBox(height: 16),

                              // Table Header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xffF97316),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(
                                          'Item',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Expanded(
                                    //   flex: 2,
                                    //   child: Text(
                                    //     'Name',
                                    //     style: TextStyle(
                                    //       fontWeight: FontWeight.bold,
                                    //       fontSize: 12,
                                    //       color: Colors.white,
                                    //     ),
                                    //   ),
                                    // ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Slug',
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

                              // Attributes List
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Obx(() {
                                  if (controller.isLoading.value &&
                                      controller.attributes.isEmpty) {
                                    return const SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF4CAF50),
                                        ),
                                      ),
                                    );
                                  }

                                  if (controller.filteredAttributes.isEmpty) {
                                    return SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.category,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No attributes found',
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
                                        controller.filteredAttributes.map((
                                          attribute,
                                        ) {
                                          final isTemporary = attribute.id!
                                              .startsWith('temp_');
                                          return InkWell(
                                            onTap:
                                                isTemporary
                                                    ? null
                                                    : () {
                                                      Get.to(
                                                        () =>
                                                            ProductAttributeItemsScreen(
                                                              attributeId:
                                                                  attribute.id!,
                                                              attributeSymbol:
                                                                  attribute
                                                                      .slug!,
                                                              attributeName:
                                                                  attribute
                                                                      .name!,
                                                            ),
                                                      );
                                                    },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isTemporary
                                                        ? Colors.grey[50]
                                                        : null,
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Colors.grey[200]!,
                                                    width: 0.5,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Item (Avatar)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isTemporary
                                                                ? Colors
                                                                    .grey[400]
                                                                : const Color(
                                                                  0xFFE91E63,
                                                                ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          attribute.name
                                                                  ?.substring(
                                                                    0,
                                                                    1,
                                                                  )
                                                                  .toUpperCase() ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Name
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      attribute.name ?? '',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            isTemporary
                                                                ? Colors
                                                                    .grey[600]
                                                                : null,
                                                      ),
                                                    ),
                                                  ),
                                                  // Slug
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      attribute.slug ?? '',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ),
                                                  // Action
                                                  Expanded(
                                                    flex: 1,
                                                    child:
                                                        isTemporary
                                                            ? const SizedBox(
                                                              width: 20,
                                                            )
                                                            : PopupMenuButton<
                                                              String
                                                            >(
                                                              onSelected:
                                                                  (
                                                                    value,
                                                                  ) => _handleAction(
                                                                    value,
                                                                    attribute,
                                                                    controller,
                                                                    attributeNameController,
                                                                  ),
                                                              itemBuilder:
                                                                  (context) => [
                                                                    const PopupMenuItem(
                                                                      value:
                                                                          'edit',
                                                                      child: Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.edit,
                                                                            size:
                                                                                16,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                            'Edit',
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const PopupMenuItem(
                                                                      value:
                                                                          'delete',
                                                                      child: Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.delete,
                                                                            size:
                                                                                16,
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                8,
                                                                          ),
                                                                          Text(
                                                                            'Delete',
                                                                            style: TextStyle(
                                                                              color:
                                                                                  Colors.red,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                              child: const Icon(
                                                                Icons
                                                                    .more_horiz,
                                                                size: 20,
                                                              ),
                                                            ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
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

  void _handleAction(
    String action,
    ProductAttributes attribute,
    ProductAttributesController controller,
    TextEditingController attributeNameController,
  ) {
    switch (action) {
      case 'edit':
        _showEditAttributeDialog(
          attribute,
          controller,
          attributeNameController,
        );
        break;
      case 'delete':
        _showDeleteDialog(attribute, controller);
        break;
    }
  }

  void _showEditAttributeDialog(
    ProductAttributes attribute,
    ProductAttributesController controller,
    TextEditingController attributeNameController,
  ) {
    final editController = TextEditingController(text: attribute.name ?? '');

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('UPDATE ATTRIBUTE'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Attribute Name'),
            const SizedBox(height: 8),
            TextField(
              controller: editController,
              decoration: InputDecoration(
                hintText: 'Colors',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isLoading.value
                      ? null
                      : () async {
                        final name = editController.text.trim();
                        if (name.isNotEmpty) {
                          final success = await controller.updateAttribute(
                            attribute.id!,
                            name,
                          );
                          if (success) {
                            Get.back();
                          }
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
              ),
              child:
                  controller.isLoading.value
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text('Update'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    ProductAttributes attribute,
    ProductAttributesController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Attribute'),
        content: Text('Are you sure you want to delete "${attribute.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isLoading.value
                      ? null
                      : () async {
                        final success = await controller.deleteAttribute(
                          attribute.id!,
                        );

                        if (success) {
                          Get.back(); // Close dialog only on success
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child:
                  controller.isLoading.value
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }
}
