import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_templates/model/template_model.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_templates/model/product_model.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_templates/service/template_api_service.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_promotion/views/widgets/custom_snackbar.dart';

class AdminTemplateController extends GetxController {
  final TemplateApiService _apiService = TemplateApiService();

  // Templates list
  final RxList<Template> templates = <Template>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isInitialLoading = true.obs;
  final RxString error = ''.obs;

  // Separate loading states
  final RxBool isSaving = false.obs;
  final Rxn<String> deletingTemplateId = Rxn<String>();

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rx<String> selectedStatus = 'active'.obs;

  // Product selection
  final RxList<Product> searchedProducts = <Product>[].obs;
  final RxList<Product> selectedProducts = <Product>[].obs;
  final RxList<String> selectedProductIds =
      <String>[].obs; // For template editing
  final RxBool isSearchingProducts = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final productSearchController = TextEditingController();

  // Edit mode
  final Rxn<Template> editingTemplate = Rxn<Template>();

  // Product name cache for existing templates
  final RxMap<String, String> productNameCache = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTemplates();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    productSearchController.dispose();
    super.onClose();
  }

  // Fetch templates
  Future<void> fetchTemplates() async {
    if (isInitialLoading.value) {
      isLoading.value = true;
    }
    error.value = '';
    try {
      final response = await _apiService.fetchTemplates();
      templates.value = response.templates.data;
    } on TemplateApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load templates';
    } finally {
      isLoading.value = false;
      isInitialLoading.value = false;
    }
  }

  // Refresh templates
  Future<void> refreshTemplates() async {
    error.value = '';
    try {
      final response = await _apiService.fetchTemplates();
      templates.value = response.templates.data;
    } on TemplateApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load templates';
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

  // Load initial products
  Future<void> loadInitialProducts() async {
    isLoadingProducts.value = true;
    try {
      searchedProducts.value = await _apiService.searchProducts();
      print(searchedProducts.length);
    } catch (e) {
      print(e);
      // Silent fail
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // Get product name by ID (for FutureBuilder)
  Future<String> getProductName(String productId) async {
    if (productNameCache.containsKey(productId)) {
      return productNameCache[productId]!;
    }
    try {
      final product = await _apiService.getProductById(productId);
      productNameCache[productId] = product.name;
      return product.name;
    } catch (e) {
      return 'Unknown Product';
    }
  }

  // Add product to selection
  void addProduct(Product product) {
    if (!selectedProducts.any((p) => p.id == product.id)) {
      selectedProducts.add(product);
    }
    if (!selectedProductIds.contains(product.id)) {
      selectedProductIds.add(product.id);
    }
    // Cache the product name
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

  // Reorder products (drag and drop)
  void reorderProducts(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    // Reorder IDs
    if (oldIndex < selectedProductIds.length) {
      final id = selectedProductIds.removeAt(oldIndex);
      selectedProductIds.insert(newIndex, id);
    }
    // Reorder products
    if (oldIndex < selectedProducts.length) {
      final product = selectedProducts.removeAt(oldIndex);
      selectedProducts.insert(newIndex, product);
    }
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedStatus.value = 'active';
    selectedProducts.clear();
    selectedProductIds.clear();
    productSearchController.clear();
    editingTemplate.value = null;
  }

  // Set form for editing (basic info only)
  void setEditingTemplateBasicInfo(Template template) {
    editingTemplate.value = template;
    nameController.text = template.name;
    descriptionController.text = template.description ?? '';
    selectedStatus.value = template.status;
  }

  // Set selected product IDs for editing template (uses FutureBuilder in UI)
  void setSelectedProductIds(Template template) {
    selectedProductIds.clear();
    selectedProductIds.addAll(template.productIdsList);
  }

  // Get product by ID (with caching)
  Future<Product> fetchProductById(String productId) async {
    // Check cache first
    if (productNameCache.containsKey(productId)) {
      return Product(id: productId, name: productNameCache[productId]!);
    }

    final product = await _apiService.getProductById(productId);
    productNameCache[productId] = product.name;
    return product;
  }

  // Add product from fetched data to selectedProducts
  void addFetchedProduct(Product product) {
    if (!selectedProducts.any((p) => p.id == product.id)) {
      selectedProducts.add(product);
    }
  }

  // Remove product by ID
  void removeProductById(String productId) {
    selectedProducts.removeWhere((p) => p.id == productId);
    selectedProductIds.remove(productId);
  }

  // Reorder products by ID
  void reorderProductIds(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final id = selectedProductIds.removeAt(oldIndex);
    selectedProductIds.insert(newIndex, id);

    // Also reorder selectedProducts if exists
    if (oldIndex < selectedProducts.length && selectedProducts.isNotEmpty) {
      final product = selectedProducts.removeAt(oldIndex);
      selectedProducts.insert(newIndex, product);
    }
  }

  // Validate form
  bool validateForm(BuildContext context) {
    if (nameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Template name is required');
      return false;
    }
    if (selectedProductIds.isEmpty) {
      CustomSnackbar.showError(context, 'Please select at least one product');
      return false;
    }
    return true;
  }

  // Create template
  Future<bool> createTemplate(BuildContext context) async {
    if (!validateForm(context)) return false;

    isSaving.value = true;
    try {
      final productIds = selectedProductIds.join(',');
      final payload = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'status': selectedStatus.value,
        'product_ids': productIds,
      };

      await _apiService.insertTemplate(payload);
      await refreshTemplates();
      clearForm();
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Template created successfully');
      }
      return true;
    } on TemplateApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to create template');
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Update template
  Future<bool> updateTemplate(BuildContext context) async {
    if (editingTemplate.value == null) return false;
    if (!validateForm(context)) return false;

    isSaving.value = true;
    try {
      final productIds = selectedProductIds.join(',');
      final payload = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'status': selectedStatus.value,
        'product_ids': productIds,
      };

      await _apiService.updateTemplate(editingTemplate.value!.id, payload);
      await refreshTemplates();
      clearForm();
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Template updated successfully');
      }
      return true;
    } on TemplateApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to update template');
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Delete template
  Future<bool> deleteTemplate(BuildContext context, String templateId) async {
    deletingTemplateId.value = templateId;
    try {
      await _apiService.deleteTemplate(templateId);
      templates.removeWhere((t) => t.id == templateId);
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Template deleted successfully');
      }
      return true;
    } on TemplateApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to delete template');
      }
      return false;
    } finally {
      deletingTemplateId.value = null;
    }
  }

  // Format date
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Check if deleting
  bool isDeleting(String templateId) {
    return deletingTemplateId.value == templateId;
  }
}
