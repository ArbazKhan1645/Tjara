// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class CategoriesAdminController extends GetxController {
  static CategoriesAdminController get instance =>
      Get.find<CategoriesAdminController>();

  // New categories endpoint (parent-aware)
  final String _fetchCategoriesApiUrl =
      'https://api.libanbuy.com/api/product-attributes/categories';
  final String _insertCategoryApiUrl =
      'https://api.libanbuy.com/api/product-attribute-items/insert';
  final String _updateCategoryApiUrl =
      'https://api.libanbuy.com/api/product-attribute-items';
  final String _deleteCategoryApiUrl =
      'https://api.libanbuy.com/api/product-attribute-items';

  final categoriesList = <ProductAttributeItems>[].obs;
  final filteredList = <ProductAttributeItems>[].obs;
  final attributeItem = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxString thumbnailId = ''.obs;
  RxBool loadingButton = false.obs;
  RxBool isUpdating = false.obs;
  RxBool isDeleting = false.obs;
  RxString currentSearchQuery = ''.obs;

  // Add cache buster to all requests
  String get _cacheBuster => '_t=${DateTime.now().millisecondsSinceEpoch}';

  // Get common headers with cache buster
  Map<String, String> get _commonHeaders => {
    'X-Request-From': 'Application',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0',
  };

  Future<void> fetchCategories({
    required bool loaderType,
    String? searchQuery,
  }) async {
    if (searchQuery != null && searchQuery.isNotEmpty) {
      isSearching.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final LoginResponse? current = AuthService.instance.authCustomer;

      if (current?.user?.id == null) {
        return;
      }

      // Build URL for new endpoint with query params
      final qp = <String, String>{
        'with': 'parent',
        'post_type': (Get.arguments as String?) ?? 'product',
        'search': searchQuery ?? '',
        'limit': '50',
      };
      // Add cache buster as a separate parameter
      final queryString = qp.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      final String url = '$_fetchCategoriesApiUrl?$queryString';
      print('===============================--=$queryString');
      final uri = Uri.parse(url);
      final response = await http.get(
        uri,
        headers: {
          'X-Request-From': 'Dashboard',
          'Cache-Control': 'private, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '-1',
          'content-type': 'application/json',
          'accept': 'application/json, text/plain, */*',
        },
      );

      print('Fetch Categories URL: $url');
      print('Fetch Categories Status: ${response.statusCode}');
      print('Fetch Categories Response: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        print('Decoded response: $decoded');

        // Support multiple shapes: {categories: []}, {product_attribute_items: []}, or {data: []}
        final Map<String, dynamic> data =
            decoded is Map<String, dynamic>
                ? decoded
                : <String, dynamic>{'data': decoded};
        print('Data keys: ${data.keys.toList()}');

        final List listRaw =
            (data['categories'] as List?) ??
            (data['product_attribute_items'] as List?) ??
            (data['product_attribute'] != null
                ? ((data['product_attribute']
                                as Map<String, dynamic>)['attribute_items']
                            as Map<String, dynamic>?)
                        ?.cast<String, dynamic>()
                        .putIfAbsent('product_attribute_items', () => [])
                    as List?
                : null) ??
            (data['data'] as List?) ??
            <dynamic>[];
        print('Raw list length: ${listRaw.length}');

        final List<ProductAttributeItems> fetchedCategories =
            listRaw
                .map((category) => ProductAttributeItems.fromJson(category))
                .toList();
        print('Fetched categories length: ${fetchedCategories.length}');
        if (fetchedCategories.isNotEmpty) {
          final preview = fetchedCategories
              .take(5)
              .map((c) => '${c.id}:${c.name}')
              .join(', ');
          print('Fetched categories preview (first up to 5): $preview');
        } else {
          print('Fetched categories is empty.');
        }

        if (searchQuery != null && searchQuery.isNotEmpty) {
          // For search results, update filtered list only
          filteredList.assignAll(fetchedCategories);
          currentSearchQuery.value = searchQuery;
        } else {
          // For normal fetch, update both lists
          categoriesList.assignAll(fetchedCategories);
          filteredList.assignAll(fetchedCategories);
          currentSearchQuery.value = '';
        }

        isLoading.value = false;
        isSearching.value = false;
      } else {
        isLoading.value = false;
        isSearching.value = false;
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      isLoading.value = false;
      isSearching.value = false;
      print('Error fetching categories: $e');
    }
  }

  TextEditingController textEditingController = TextEditingController();

  Future<void> searchCategories(String query) async {
    if (query.isEmpty) {
      // If search is cleared, reload original categories
      currentSearchQuery.value = '';
      filteredList.assignAll(categoriesList);
      return;
    }
    filteredList.clear();
    print('Searching for: $query');

    await fetchCategories(loaderType: true, searchQuery: query);
  }

  // Method to clear search and show all categories
  Future<void> clearSearch() async {
    currentSearchQuery.value = '';
    filteredList.assignAll(categoriesList);
  }

  // Method to refresh categories (useful after add/update/delete operations)
  Future<void> refreshCategories() async {
    if (currentSearchQuery.value.isNotEmpty) {
      // If there's an active search, refresh search results
      await fetchCategories(
        loaderType: false,
        searchQuery: currentSearchQuery.value,
      );
    } else {
      // Otherwise, refresh all categories
      await fetchCategories(loaderType: false);
    }
  }

  Future<void> addCategory({
    required String name,
    required String thumbnailId,
    int? parentId,
    required BuildContext context,
  }) async {
    loadingButton.value = true;
    final url = Uri.parse('$_insertCategoryApiUrl?$_cacheBuster');

    try {
      final response = await http.post(
        url,
        headers: _commonHeaders,
        body: jsonEncode({
          'name': name,
          'parent_id': parentId,
          "attribute_id": "000b1e1d-8627-4260-a107-1cb1f1echy73",
          'post_type': Get.arguments ?? 'product',
          'thumbnail_id': thumbnailId,
        }),
      );

      loadingButton.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        NotificationHelper.showSuccess(
          context,
          'Success',
          'Category uploaded successfully',
        );

        // Clear form
        files.value = [];
        attributeItem.text = '';

        // Refresh the categories list to get the new item
        await refreshCategories();
      } else {
        loadingButton.value = false;
        NotificationHelper.showError(
          context,
          'Error',
          'Failed to post category. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      loadingButton.value = false;
      NotificationHelper.showError(
        context,
        'Error',
        'Error occurred while posting category: $e',
      );
    }
  }

  Future<void> updateCategory({
    required String categoryId,
    required String name,
    required String thumbnailId,
    String? parentId,
    required BuildContext context,
  }) async {
    isUpdating.value = true;
    final url = Uri.parse(
      '$_updateCategoryApiUrl/$categoryId/update?$_cacheBuster',
    );

    try {
      final response = await http.put(
        url,
        headers: _commonHeaders,
        body: jsonEncode({
          'name': name,
          'post_type': Get.arguments ?? 'product',
          "attribute_id": "000b1e1d-8627-4260-a107-1cb1f1echy73",
          'parent_id': parentId,
          'thumbnail_id': thumbnailId,
        }),
      );

      print('Update Category Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        NotificationHelper.showSuccess(
          context,
          'Success',
          'Category updated successfully',
        );

        // Optimistically update local lists immediately
        _updateLocalCategory(categoryId, name, thumbnailId, parentId);

        // Then refresh from server to ensure data consistency
        await refreshCategories();

        isUpdating.value = false;
      } else {
        isUpdating.value = false;
        NotificationHelper.showError(
          context,
          'Error',
          'Failed to update category. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      isUpdating.value = false;
      NotificationHelper.showError(
        context,
        'Error',
        'Error occurred while updating category: $e',
      );
    }
  }

  // Helper method to update local category data
  void _updateLocalCategory(
    String categoryId,
    String name,
    String thumbnailId,
    String? parentId,
  ) {
    // Update in main categories list
    final mainIndex = categoriesList.indexWhere(
      (item) => item.id == categoryId,
    );
    if (mainIndex != -1) {
      categoriesList[mainIndex] = categoriesList[mainIndex].copyWith(
        name: name,
        thumbnailId: thumbnailId,
        parentId: parentId,
      );
      categoriesList.refresh();
    }

    // Update in filtered list
    final filteredIndex = filteredList.indexWhere(
      (item) => item.id == categoryId,
    );
    if (filteredIndex != -1) {
      filteredList[filteredIndex] = filteredList[filteredIndex].copyWith(
        name: name,
        thumbnailId: thumbnailId,
        parentId: parentId,
      );
      filteredList.refresh();
    }
  }

  Future<void> deleteCategory({
    required String categoryId,
    required BuildContext context,
  }) async {
    isDeleting.value = true;
    final url = Uri.parse(
      '$_deleteCategoryApiUrl/$categoryId/delete?$_cacheBuster',
    );

    try {
      final response = await http.delete(url, headers: _commonHeaders);

      print('Delete Category Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        NotificationHelper.showSuccess(
          context,
          'Success',
          'Category deleted successfully',
        );

        // Optimistically remove from local lists
        _removeLocalCategory(categoryId);

        // Then refresh to ensure data consistency
        await refreshCategories();

        isDeleting.value = false;
      } else {
        isDeleting.value = false;
        NotificationHelper.showError(
          context,
          'Error',
          'Failed to delete category. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      isDeleting.value = false;
      NotificationHelper.showError(
        context,
        'Error',
        'Error occurred while deleting category: $e',
      );
    }
  }

  // Helper method to remove category from local lists
  void _removeLocalCategory(String categoryId) {
    categoriesList.removeWhere((item) => item.id == categoryId);
    filteredList.removeWhere((item) => item.id == categoryId);
  }

  Future<void> showDeleteConfirmation({
    required String categoryId,
    required String categoryName,
    required BuildContext context,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "$categoryName"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Obx(
              () => TextButton(
                onPressed:
                    isDeleting.value
                        ? null
                        : () {
                          Navigator.of(context).pop();
                          deleteCategory(
                            categoryId: categoryId,
                            context: context,
                          );
                        },
                child:
                    isDeleting.value
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
              ),
            ),
          ],
        );
      },
    );
  }

  RxList<File> files = <File>[].obs;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      files.value = [File(image.path)];
      await uploadMedia(files);
    }
  }

  Future<void> uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    final uri = Uri.parse(
      'https://api.libanbuy.com/api/media/insert?$_cacheBuster',
    );

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'X-Request-From': 'Application',
      'Accept': 'application/json',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    });

    // Add media files
    for (var file in files) {
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      final multipartFile = http.MultipartFile(
        'media[]',
        stream,
        length,
        filename: path.basename(file.path),
      );

      request.files.add(multipartFile);
    }

    // Add optional parameters
    if (directory != null) {
      request.fields['directory'] = directory;
    }

    if (width != null) {
      request.fields['width'] = width.toString();
    }

    if (height != null) {
      request.fields['height'] = height.toString();
    }

    try {
      // Send request
      final response = await request.send();

      // Handle redirect manually
      if (response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          await uploadMedia(
            files,
            directory: directory,
            width: width,
            height: height,
          );
          return;
        }
      }

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseBody);
        thumbnailId.value = jsonData[0]['id'];
        print(
          'Media uploaded successfully. Thumbnail ID: ${thumbnailId.value}',
        );
      } else {
        print(
          'Failed to upload media. Status code: ${response.statusCode} Response body: ${await response.stream.bytesToString()}',
        );
      }
    } catch (e) {
      print('Error uploading media: $e');
    }
  }

  // Helper method to clear form data
  void clearForm() {
    attributeItem.clear();
    files.value = [];
    thumbnailId.value = '';
  }

  // Helper method to populate form for editing
  void populateFormForEdit(ProductAttributeItems item) {
    attributeItem.text = item.name ?? '';
    thumbnailId.value = item.thumbnailId ?? '';
    // You might want to load the image file as well if needed
  }

  @override
  void onClose() {
    attributeItem.dispose();
    textEditingController.dispose();
    super.onClose();
  }
}
