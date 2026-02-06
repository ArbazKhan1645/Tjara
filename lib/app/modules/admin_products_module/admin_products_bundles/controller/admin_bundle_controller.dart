import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_bundles/model/bundle_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_bundles/service/bundle_api_service.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_templates/model/product_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/views/widgets/custom_snackbar.dart';
import 'package:tjara/main.dart';

class AdminBundleController extends GetxController {
  final BundleApiService _apiService = BundleApiService();

  // Bundles list
  final RxList<Bundle> bundles = <Bundle>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isInitialLoading = true.obs;
  final RxString error = ''.obs;

  // Separate loading states
  final RxBool isSaving = false.obs;
  final Rxn<String> deletingBundleId = Rxn<String>();
  final Rxn<String> duplicatingBundleId = Rxn<String>();

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountValueController = TextEditingController();
  final Rx<String> selectedStatus = 'active'.obs;
  final Rx<String> selectedDiscountType = 'none'.obs;
  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  // Thumbnail
  final Rxn<String> thumbnailId = Rxn<String>();
  final Rxn<String> thumbnailUrl = Rxn<String>();
  final Rxn<File> selectedImageFile = Rxn<File>();
  final RxBool isUploadingImage = false.obs;

  // Product selection
  final RxList<Product> searchedProducts = <Product>[].obs;
  final RxList<Product> selectedProducts = <Product>[].obs;
  final RxList<String> selectedProductIds = <String>[].obs;
  final RxBool isSearchingProducts = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final productSearchController = TextEditingController();

  // Edit mode
  final Rxn<Bundle> editingBundle = Rxn<Bundle>();

  // Product name cache
  final RxMap<String, String> productNameCache = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBundles();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    discountValueController.dispose();
    productSearchController.dispose();
    super.onClose();
  }

  // Fetch bundles
  Future<void> fetchBundles() async {
    if (isInitialLoading.value) {
      isLoading.value = true;
    }
    error.value = '';
    try {
      final response = await _apiService.fetchBundles();
      bundles.value = response.bundles.data;
    } on BundleApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load bundles';
    } finally {
      isLoading.value = false;
      isInitialLoading.value = false;
    }
  }

  // Refresh bundles
  Future<void> refreshBundles() async {
    error.value = '';
    try {
      final response = await _apiService.fetchBundles();
      bundles.value = response.bundles.data;
    } on BundleApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load bundles';
    }
  }

  // Load initial products
  Future<void> loadInitialProducts() async {
    isLoadingProducts.value = true;
    try {
      searchedProducts.value = await _apiService.searchProducts();
    } catch (e) {
      // Silent fail
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    isSearchingProducts.value = true;
    try {
      searchedProducts.value = await _apiService.searchProducts(query: query);
    } catch (e) {
      // Keep existing on error
    } finally {
      isSearchingProducts.value = false;
    }
  }

  // Get product by ID (with caching)
  Future<Product> fetchProductById(String productId) async {
    if (productNameCache.containsKey(productId)) {
      return Product(id: productId, name: productNameCache[productId]!);
    }

    final product = await _apiService.getProductById(productId);
    productNameCache[productId] = product.name;
    return product;
  }

  // Add product to selection
  void addProduct(Product product) {
    if (!selectedProducts.any((p) => p.id == product.id)) {
      selectedProducts.add(product);
    }
    if (!selectedProductIds.contains(product.id)) {
      selectedProductIds.add(product.id);
    }
    productNameCache[product.id] = product.name;
  }

  // Remove product from selection
  void removeProduct(String productId) {
    selectedProducts.removeWhere((p) => p.id == productId);
    selectedProductIds.remove(productId);
  }

  // Check if product is selected
  bool isProductSelected(String productId) {
    return selectedProductIds.contains(productId) ||
        selectedProducts.any((p) => p.id == productId);
  }

  // Reorder products
  void reorderProducts(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (oldIndex < selectedProductIds.length) {
      final id = selectedProductIds.removeAt(oldIndex);
      selectedProductIds.insert(newIndex, id);
    }
    if (oldIndex < selectedProducts.length) {
      final product = selectedProducts.removeAt(oldIndex);
      selectedProducts.insert(newIndex, product);
    }
  }

  // Upload image
  Future<void> uploadImage(File file) async {
    isUploadingImage.value = true;
    selectedImageFile.value = file;
    try {
      final mediaId = await uploadMedia([file]);
      if (mediaId.isNotEmpty) {
        thumbnailId.value = mediaId;
      }
    } catch (e) {
      // Handle error
    } finally {
      isUploadingImage.value = false;
    }
  }

  // Remove image
  void removeImage() {
    thumbnailId.value = null;
    thumbnailUrl.value = null;
    selectedImageFile.value = null;
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    discountValueController.clear();
    selectedStatus.value = 'active';
    selectedDiscountType.value = 'none';
    startDate.value = null;
    endDate.value = null;
    thumbnailId.value = null;
    thumbnailUrl.value = null;
    selectedImageFile.value = null;
    selectedProducts.clear();
    selectedProductIds.clear();
    productSearchController.clear();
    editingBundle.value = null;
  }

  // Set form for editing (basic info only)
  void setEditingBundleBasicInfo(Bundle bundle) {
    editingBundle.value = bundle;
    nameController.text = bundle.name;
    descriptionController.text = bundle.description ?? '';
    selectedStatus.value = bundle.status;
    selectedDiscountType.value = bundle.discountType;
    discountValueController.text = bundle.discountValue ?? '';
    startDate.value = bundle.startDate;
    endDate.value = bundle.endDate;
    thumbnailId.value = bundle.thumbnailId;
    thumbnailUrl.value = bundle.thumbnailUrl;
  }

  // Set selected product IDs for editing
  void setSelectedProductIds(Bundle bundle) {
    selectedProductIds.clear();
    selectedProductIds.addAll(bundle.productIdsList);
  }

  // Validate form
  bool validateForm(BuildContext context) {
    if (nameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Bundle name is required');
      return false;
    }
    if (selectedProductIds.isEmpty) {
      CustomSnackbar.showError(context, 'Please select at least one product');
      return false;
    }
    if (selectedDiscountType.value != 'none' &&
        discountValueController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter discount value');
      return false;
    }
    return true;
  }

  // Build payload
  Map<String, dynamic> _buildPayload() {
    return {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'status': selectedStatus.value,
      'discount_type': selectedDiscountType.value,
      'discount_value': selectedDiscountType.value != 'none'
          ? discountValueController.text.trim()
          : null,
      'product_ids': selectedProductIds.join(','),
      'thumbnail_id': thumbnailId.value,
      'start_date': startDate.value?.toIso8601String(),
      'end_date': endDate.value?.toIso8601String(),
      'bundle_price': null,
    };
  }

  // Create bundle
  Future<bool> createBundle(BuildContext context) async {
    if (!validateForm(context)) return false;

    isSaving.value = true;
    try {
      await _apiService.insertBundle(_buildPayload());
      await refreshBundles();
      clearForm();
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Bundle created successfully');
      }
      return true;
    } on BundleApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to create bundle');
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Update bundle
  Future<bool> updateBundle(BuildContext context) async {
    if (editingBundle.value == null) return false;
    if (!validateForm(context)) return false;

    isSaving.value = true;
    try {
      await _apiService.updateBundle(editingBundle.value!.id, _buildPayload());
      await refreshBundles();
      clearForm();
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Bundle updated successfully');
      }
      return true;
    } on BundleApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to update bundle');
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Delete bundle
  Future<bool> deleteBundle(BuildContext context, String bundleId) async {
    deletingBundleId.value = bundleId;
    try {
      await _apiService.deleteBundle(bundleId);
      bundles.removeWhere((b) => b.id == bundleId);
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Bundle deleted successfully');
      }
      return true;
    } on BundleApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to delete bundle');
      }
      return false;
    } finally {
      deletingBundleId.value = null;
    }
  }

  // Duplicate bundle
  Future<bool> duplicateBundle(BuildContext context, String bundleId) async {
    duplicatingBundleId.value = bundleId;
    try {
      await _apiService.duplicateBundle(bundleId);
      await refreshBundles();
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Bundle duplicated successfully');
      }
      return true;
    } on BundleApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to duplicate bundle');
      }
      return false;
    } finally {
      duplicatingBundleId.value = null;
    }
  }

  // Copy bundle URL
  void copyBundleUrl(BuildContext context, Bundle bundle) {
    Clipboard.setData(ClipboardData(text: bundle.bundleUrl));
    CustomSnackbar.showSuccess(context, 'Bundle URL copied to clipboard');
  }

  // Share bundle URL
  void shareBundleUrl(Bundle bundle) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Check out this bundle: ${bundle.name}\n${bundle.bundleUrl}',
        subject: bundle.name,
      ),
    );
  }

  // Format date
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Format discount
  String formatDiscount(Bundle bundle) {
    if (bundle.discountType == 'none' || bundle.discountValue == null) {
      return '';
    }
    if (bundle.discountType == 'percentage') {
      return '${bundle.discountValue}% OFF';
    }
    return '\$${bundle.discountValue} OFF';
  }

  // Check if deleting
  bool isDeleting(String bundleId) {
    return deletingBundleId.value == bundleId;
  }

  // Check if duplicating
  bool isDuplicating(String bundleId) {
    return duplicatingBundleId.value == bundleId;
  }
}
