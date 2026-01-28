// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' as http;
// controllers/category_controller.dart
import 'package:get/get.dart';
import 'dart:io';
// views/category_management_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/main.dart';

// models/category_model.dart
class CategoryModel {
  final String id;
  final String attributeId;
  final String name;
  final String slug;
  final String? value;
  final String? parentId;
  final String? thumbnailId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CategoryParent? parent;

  CategoryModel({
    required this.id,
    required this.attributeId,
    required this.name,
    required this.slug,
    this.value,
    this.parentId,
    this.thumbnailId,
    this.createdAt,
    this.updatedAt,
    this.parent,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      attributeId: json['attribute_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      value: json['value'],
      parentId: json['parent_id'],
      thumbnailId: json['thumbnail_id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      parent:
          json['parent'] != null
              ? CategoryParent.fromJson(json['parent'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attribute_id': attributeId,
      'name': name,
      'slug': slug,
      'value': value,
      'parent_id': parentId,
      'thumbnail_id': thumbnailId,
    };
  }
}

class CategoryParent {
  final String id;
  final String name;

  CategoryParent({required this.id, required this.name});

  factory CategoryParent.fromJson(Map<String, dynamic> json) {
    return CategoryParent(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}

class CategoryResponse {
  final PostAttribute postAttribute;

  CategoryResponse({required this.postAttribute});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      postAttribute: PostAttribute.fromJson(json['post_attribute']),
    );
  }
}

class PostAttribute {
  final String id;
  final String name;
  final String slug;
  final List<CategoryModel> attributeItems;

  PostAttribute({
    required this.id,
    required this.name,
    required this.slug,
    required this.attributeItems,
  });

  factory PostAttribute.fromJson(Map<String, dynamic> json) {
    final itemsList = json['attribute_items']['post_attribute_items'] as List;
    final List<CategoryModel> items =
        itemsList.map((item) => CategoryModel.fromJson(item)).toList();

    return PostAttribute(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      attributeItems: items,
    );
  }
}

// services/category_service.dart

class CategoryService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  static Future<CategoryResponse> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/post-attributes/categories'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return CategoryResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  static Future<bool> insertCategory({
    required String name,
    String? parentId,
    String? thumbnailId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/post-attribute-items/insert'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
        body: json.encode({
          'name': name,
          'parent_id': parentId,
          'thumbnail_id': thumbnailId,
          'attribute_id': '0000c539-9857-1233-bc53-2bbdc1471h71',
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error inserting category: $e');
      return false;
    }
  }

  static Future<bool> updateCategory({
    required String id,
    required String name,
    String? parentId,
    String? thumbnailId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/post-attribute-items/$id/update'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
        body: json.encode({
          'name': name,
          'parent_id': parentId,
          'thumbnail_id': thumbnailId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  static Future<bool> deleteCategory(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/post-attribute-items/$id/delete'),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }
}

class CategoryController extends GetxController {
  var categories = <CategoryModel>[].obs;
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  final thumbnail = Rx<String?>(null);
  // Form fields
  var nameController = TextEditingController();
  var selectedParentId = Rxn<String>();
  var selectedImageFile = Rxn<File>();
  var isEditMode = false.obs;
  var editingCategoryId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await CategoryService.getCategories();
      categories.value = response.postAttribute.attributeItems;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitCategory() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Category name is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      bool success;

      if (isEditMode.value && editingCategoryId.value != null) {
        success = await CategoryService.updateCategory(
          id: editingCategoryId.value!,
          name: nameController.text.trim(),
          parentId: selectedParentId.value,
          thumbnailId: thumbnail.value,
        );
      } else {
        success = await CategoryService.insertCategory(
          name: nameController.text.trim(),
          parentId: selectedParentId.value,
          thumbnailId: thumbnail.value,
        );
      }

      if (success) {
        Get.snackbar(
          'Success',
          isEditMode.value
              ? 'Category updated successfully'
              : 'Category added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        clearForm();
        await fetchCategories();
      } else {
        Get.snackbar(
          'Error',
          isEditMode.value
              ? 'Failed to update category'
              : 'Failed to add category',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final success = await CategoryService.deleteCategory(id);
      if (success) {
        Get.snackbar(
          'Success',
          'Category deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchCategories();
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete category',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void editCategory(CategoryModel category) {
    isEditMode.value = true;
    editingCategoryId.value = category.id;
    nameController.text = category.name;
    selectedParentId.value = category.parentId;
  }

  void clearForm() {
    nameController.clear();
    selectedParentId.value = null;
    selectedImageFile.value = null;
    isEditMode.value = false;
    editingCategoryId.value = null;
  }

  void pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final File file = File(picked.path);
      selectedImageFile.value = file;
      uploadMedia([file]).then((mediaIds) {
        if (mediaIds.isNotEmpty) {
          thumbnail.value = mediaIds;
        }
      });
    }
  }

  List<CategoryModel> get parentCategories {
    return categories.where((cat) => cat.parentId == null).toList();
  }
}

class CategoryManagementScreen extends StatelessWidget {
  final CategoryController controller = Get.put(CategoryController());

  CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          ListView(
            children: [
              // Add Category Form
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Obx(
                            () => Text(
                              controller.isEditMode.value
                                  ? 'EDIT CATEGORY ITEM'
                                  : 'ADD CATEGORIES ITEM',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Name Field
                          const Text(
                            'Categories Item Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: controller.nameController,
                              decoration: InputDecoration(
                                hintText: 'Attribute Item Name',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFF97316),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Parent Categories Dropdown
                          const Text(
                            'Parent Categories',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Obx(
                              () => DropdownButtonFormField<String>(
                                initialValue: controller.selectedParentId.value,
                                decoration: InputDecoration(
                                  hintText: 'Select Parent',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFF97316),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('No Parent'),
                                  ),
                                  ...controller.parentCategories.map(
                                    (category) => DropdownMenuItem<String>(
                                      value: category.id,
                                      child: Text(category.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  controller.selectedParentId.value = value;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Image Upload
                          const Text(
                            'Categories Item Image',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: controller.pickImage,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 32,
                                    color: Color(0xFFF97316),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Upload a file or drag and drop',
                                    style: TextStyle(
                                      color: Color(0xFFF97316),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF97316),
                                          Color(0xFFF97316),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFF97316,
                                          ).withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed:
                                          controller.isSubmitting.value
                                              ? null
                                              : controller.submitCategory,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child:
                                          controller.isSubmitting.value
                                              ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                              : Text(
                                                controller.isEditMode.value
                                                    ? 'Update'
                                                    : 'Submit',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: controller.clearForm,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey[600],
                                    side: BorderSide(color: Colors.grey[300]!),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Categories List
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'CATEGORIES ITEMS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF97316),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    'Parent',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF97316),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    'Action',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF97316),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Categories List
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF97316),
                                ),
                              );
                            }

                            if (controller.categories.isEmpty) {
                              return Center(
                                child: Text(
                                  'No categories found',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.categories.length,
                              itemBuilder: (context, index) {
                                final category = controller.categories[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          category.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          category.parent?.name ?? 'None',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        child: PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            color: Color(0xFFF97316),
                                            size: 20,
                                          ),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              controller.editCategory(category);
                                            } else if (value == 'delete') {
                                              _showDeleteDialog(
                                                context,
                                                category,
                                              );
                                            }
                                          },
                                          itemBuilder:
                                              (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        size: 16,
                                                        color: Color(
                                                          0xFFF97316,
                                                        ),
                                                      ),
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
                                                      Text('Delete'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CategoryModel category) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteCategory(category.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
