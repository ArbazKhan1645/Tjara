import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_attributes_group/model.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_attributes_group/service.dart';

class AttributeGroupController extends GetxController {
  final AttributeGroupService _service = AttributeGroupService();

  // Observable lists
  final RxList<AttributeGroupModel> attributeGroups =
      <AttributeGroupModel>[].obs;
  final RxList<AttributeGroupModel> filteredGroups =
      <AttributeGroupModel>[].obs;
  final RxList<ProductAttribute> productAttributes = <ProductAttribute>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingAttributes = false.obs;
  final RxBool isSaving = false.obs;

  // Search
  final RxString searchQuery = ''.obs;

  // Selected items for add/edit
  final RxSet<String> selectedItemIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttributeGroups();
  }

  // Fetch all attribute groups
  Future<void> fetchAttributeGroups() async {
    try {
      isLoading.value = true;
      final groups = await _service.getAttributeGroups();
      attributeGroups.value = groups;
      filteredGroups.value = groups;
    } catch (e) {
      _showErrorSnackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // Search attribute groups
  void searchGroups(String query) {
    searchQuery.value = query.toLowerCase();
    if (query.isEmpty) {
      filteredGroups.value = attributeGroups;
    } else {
      filteredGroups.value =
          attributeGroups.where((group) {
            return group.name.toLowerCase().contains(query) ||
                group.slug.toLowerCase().contains(query);
          }).toList();
    }
  }

  // Fetch product attributes for add/edit screen
  Future<void> fetchProductAttributes() async {
    try {
      isLoadingAttributes.value = true;
      final attributes = await _service.getProductAttributes(limit: 100);
      productAttributes.value = attributes;
    } catch (e) {
      _showErrorSnackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoadingAttributes.value = false;
    }
  }

  // Load existing group data for editing
  void loadGroupForEdit(AttributeGroupModel group) {
    selectedItemIds.clear();
    for (var attribute in group.attributes) {
      for (var item in attribute.items) {
        selectedItemIds.add(item.id);
      }
    }
  }

  // Toggle item selection
  void toggleItemSelection(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
  }

  // Select all items in an attribute
  void selectAllInAttribute(ProductAttribute attribute) {
    if (attribute.attributeItems?.items != null) {
      final allSelected = attribute.attributeItems!.items.every(
        (item) => selectedItemIds.contains(item.id),
      );

      if (allSelected) {
        // Deselect all
        for (var item in attribute.attributeItems!.items) {
          selectedItemIds.remove(item.id);
        }
      } else {
        // Select all
        for (var item in attribute.attributeItems!.items) {
          selectedItemIds.add(item.id);
        }
      }
    }
  }

  // Check if all items in attribute are selected
  bool areAllSelectedInAttribute(ProductAttribute attribute) {
    if (attribute.attributeItems?.items == null ||
        attribute.attributeItems!.items.isEmpty) {
      return false;
    }
    return attribute.attributeItems!.items.every(
      (item) => selectedItemIds.contains(item.id),
    );
  }

  // Check if some items in attribute are selected
  bool areSomeSelectedInAttribute(ProductAttribute attribute) {
    if (attribute.attributeItems?.items == null ||
        attribute.attributeItems!.items.isEmpty) {
      return false;
    }
    return attribute.attributeItems!.items.any(
      (item) => selectedItemIds.contains(item.id),
    );
  }

  // Create new attribute group
  Future<bool> createAttributeGroup(String name) async {
    if (name.trim().isEmpty) {
      _showErrorSnackbar('Error', 'Please enter a group name');
      return false;
    }

    if (selectedItemIds.isEmpty) {
      _showErrorSnackbar('Error', 'Please select at least one attribute item');
      return false;
    }

    try {
      isSaving.value = true;
      final success = await _service.createAttributeGroup(
        name: name.trim(),
        attributeItemIds: selectedItemIds.toList(),
      );

      if (success) {
        await fetchAttributeGroups();
        selectedItemIds.clear();
        return true;
      }
      return false;
    } catch (e) {
      _showErrorSnackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Update attribute group
  Future<bool> updateAttributeGroup(String slug, String name) async {
    if (name.trim().isEmpty) {
      _showErrorSnackbar('Error', 'Please enter a group name');
      return false;
    }

    if (selectedItemIds.isEmpty) {
      _showErrorSnackbar('Error', 'Please select at least one attribute item');
      return false;
    }

    try {
      isSaving.value = true;
      final success = await _service.updateAttributeGroup(
        slug: slug,
        name: name.trim(),
        attributeItemIds: selectedItemIds.toList(),
      );

      if (success) {
        await fetchAttributeGroups();
        selectedItemIds.clear();
        return true;
      }
      return false;
    } catch (e) {
      _showErrorSnackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Delete attribute group
  Future<void> deleteAttributeGroup(String slug, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$name"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _service.deleteAttributeGroup(slug);
        if (success) {
          _showSuccessSnackbar(
            'Success',
            'Attribute group deleted successfully',
          );
          await fetchAttributeGroups();
        }
      } catch (e) {
        _showErrorSnackbar('Error', e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  // Show success snackbar
  void _showSuccessSnackbar(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        backgroundColor: const Color(0xFF009688),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
        isDismissible: true,
      ),
    );
  }

  // Show error snackbar
  void _showErrorSnackbar(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 4),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
        isDismissible: true,
      ),
    );
  }
}
