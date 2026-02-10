import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/model/promotion_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/model/shop_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/model/category_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/model/store_product_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/service/promotion_api_service.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_promotion/views/widgets/custom_snackbar.dart';

class AdminPromotionController extends GetxController {
  final PromotionApiService _apiService = PromotionApiService();

  // Tab controller for switching tabs
  TabController? _tabController;

  // Promotions list
  final RxList<Promotion> promotions = <Promotion>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isInitialLoading = true.obs;
  final RxString error = ''.obs;

  // Separate loading states
  final RxBool isSaving = false.obs;
  final Rxn<String> deletingPromotionId = Rxn<String>();

  // Form controllers for create/edit
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountValueController = TextEditingController();
  final Rx<String> selectedDiscountType = 'percentage'.obs;
  final Rx<String> selectedStatus = 'active'.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 7)).obs;

  // Edit mode
  final Rxn<Promotion> editingPromotion = Rxn<Promotion>();

  // Apply promotion
  final RxList<Shop> shops = <Shop>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final Rxn<Shop> selectedShop = Rxn<Shop>();
  final Rxn<Category> selectedCategory = Rxn<Category>();
  final RxString applyToOption = 'shop'.obs;
  final RxList<String> selectedPromotionIds = <String>[].obs;
  final RxBool isLoadingShops = true.obs;
  final RxBool isLoadingCategories = true.obs;
  final RxBool isSearchingShops = false.obs;
  final RxBool isSearchingCategories = false.obs;
  final RxBool isApplying = false.obs;

  // Selected products of store
  final RxList<String> selectedStoreProductIds = <String>[].obs;
  final RxBool isLoadingStoreProducts = false.obs;
  final RxBool storeProductsFetched = false.obs;
  final RxList<StoreProduct> searchedProducts = <StoreProduct>[].obs;
  final RxBool isSearchingProducts = false.obs;

  // Search controllers
  final shopSearchController = TextEditingController();
  final categorySearchController = TextEditingController();
  final productSearchController = TextEditingController();

  // Context for snackbar
  BuildContext? _context;

  void setTabController(TabController tabController) {
    _tabController = tabController;
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void _switchToAllPromotionsTab() {
    if (_tabController != null) {
      _tabController!.animateTo(0);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([fetchPromotions(), _initShops(), _initCategories()]);
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    discountValueController.dispose();
    shopSearchController.dispose();
    categorySearchController.dispose();
    productSearchController.dispose();
    super.onClose();
  }

  // Fetch promotions
  Future<void> fetchPromotions() async {
    if (isInitialLoading.value) {
      isLoading.value = true;
    }
    error.value = '';
    try {
      final response = await _apiService.fetchPromotions();
      promotions.value = response.promotions.data;
    } on PromotionApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load promotions';
    } finally {
      isLoading.value = false;
      isInitialLoading.value = false;
    }
  }

  // Refresh promotions (for pull to refresh)
  Future<void> refreshPromotions() async {
    error.value = '';
    try {
      final response = await _apiService.fetchPromotions();
      promotions.value = response.promotions.data;
    } on PromotionApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load promotions';
    }
  }

  // Initialize shops
  Future<void> _initShops() async {
    isLoadingShops.value = true;
    try {
      shops.value = await _apiService.searchShops();
    } catch (e) {
      // Silent fail for initial load
    } finally {
      isLoadingShops.value = false;
    }
  }

  // Initialize categories
  Future<void> _initCategories() async {
    isLoadingCategories.value = true;
    try {
      categories.value = await _apiService.searchCategories();
    } catch (e) {
      // Silent fail for initial load
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Search shops
  Future<void> searchShops(String query) async {
    isSearchingShops.value = true;
    try {
      shops.value = await _apiService.searchShops(query: query);
    } catch (e) {
      // Keep existing shops on error
    } finally {
      isSearchingShops.value = false;
    }
  }

  // Search categories
  Future<void> searchCategories(String query) async {
    isSearchingCategories.value = true;
    try {
      categories.value = await _apiService.searchCategories(query: query);
    } catch (e) {
      // Keep existing categories on error
    } finally {
      isSearchingCategories.value = false;
    }
  }

  // Select shop
  void selectShop(Shop shop) {
    selectedShop.value = shop;
    shopSearchController.text = shop.name;
    // Reset store products when shop changes
    selectedStoreProductIds.clear();
    searchedProducts.clear();
    productSearchController.clear();
    storeProductsFetched.value = false;
  }

  // Search products for selected store
  Future<void> searchStoreProducts(String query) async {
    if (selectedShop.value == null) return;
    isSearchingProducts.value = true;
    try {
      final products = await _apiService.fetchStoreProducts(
        shopId: selectedShop.value!.id,
        search: query,
      );
      searchedProducts.value = products;
    } catch (e) {
      searchedProducts.clear();
    } finally {
      isSearchingProducts.value = false;
    }
  }

  // Toggle product selection
  void toggleProductSelection(String productId) {
    if (selectedStoreProductIds.contains(productId)) {
      selectedStoreProductIds.remove(productId);
    } else {
      selectedStoreProductIds.add(productId);
    }
  }

  // Called when applyToOption changes
  void onApplyToOptionChanged(String value) {
    applyToOption.value = value;
    if (value != 'selected_products') {
      selectedStoreProductIds.clear();
      searchedProducts.clear();
      productSearchController.clear();
      storeProductsFetched.value = false;
    }
  }

  // Select category
  void selectCategory(Category category) {
    selectedCategory.value = category;
    categorySearchController.text = category.name;
  }

  // Toggle promotion selection
  void togglePromotionSelection(String promotionId) {
    if (selectedPromotionIds.contains(promotionId)) {
      selectedPromotionIds.remove(promotionId);
    } else {
      selectedPromotionIds.add(promotionId);
    }
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    discountValueController.clear();
    selectedDiscountType.value = 'percentage';
    selectedStatus.value = 'active';
    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(const Duration(days: 7));
    editingPromotion.value = null;
  }

  // Set form for editing
  void setEditingPromotion(Promotion promotion) {
    editingPromotion.value = promotion;
    nameController.text = promotion.name;
    descriptionController.text = promotion.description ?? '';
    discountValueController.text = promotion.discountValue;
    selectedDiscountType.value = promotion.discountType;
    selectedStatus.value = promotion.status;
    startDate.value = promotion.startDate;
    endDate.value = promotion.endDate;
  }

  // Validate form
  bool validateForm(BuildContext context) {
    if (nameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Name is required');
      return false;
    }
    if (discountValueController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Discount value is required');
      return false;
    }
    final discountValue = double.tryParse(discountValueController.text);
    if (discountValue == null || discountValue <= 0) {
      CustomSnackbar.showError(context, 'Invalid discount value');
      return false;
    }
    if (endDate.value.isBefore(startDate.value)) {
      CustomSnackbar.showError(context, 'End date must be after start date');
      return false;
    }
    return true;
  }

  // Create promotion
  Future<bool> createPromotion(BuildContext context) async {
    if (!validateForm(context)) return false;

    isSaving.value = true;
    try {
      final payload = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'discount_type': selectedDiscountType.value,
        'discount_value': discountValueController.text.trim(),
        'start_date': _formatDateTime(startDate.value),
        'end_date': _formatDateTime(endDate.value),
        'status': selectedStatus.value,
      };

      await _apiService.insertPromotion(payload);
      await refreshPromotions();
      clearForm();
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Promotion created successfully');
      }
      return true;
    } on PromotionApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to create promotion');
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Update promotion
  Future<bool> updatePromotion(BuildContext context) async {
    if (editingPromotion.value == null) return false;
    if (!validateForm(context)) return false;

    isSaving.value = true;
    try {
      final payload = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'discount_type': selectedDiscountType.value,
        'discount_value': discountValueController.text.trim(),
        'start_date': _formatDateTime(startDate.value),
        'end_date': _formatDateTime(endDate.value),
        'status': selectedStatus.value,
      };

      await _apiService.updatePromotion(editingPromotion.value!.id, payload);
      await refreshPromotions();
      clearForm();
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Promotion updated successfully');
      }
      return true;
    } on PromotionApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to update promotion');
      }
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Delete promotion
  Future<bool> deletePromotion(BuildContext context, String promotionId) async {
    deletingPromotionId.value = promotionId;
    try {
      await _apiService.deletePromotion(promotionId);
      promotions.removeWhere((p) => p.id == promotionId);
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Promotion deleted successfully');
      }
      return true;
    } on PromotionApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to delete promotion');
      }
      return false;
    } finally {
      deletingPromotionId.value = null;
    }
  }

  // Apply promotions
  Future<bool> applyPromotions(BuildContext context) async {
    if (selectedShop.value == null) {
      CustomSnackbar.showError(context, 'Please select a shop');
      return false;
    }
    if (selectedPromotionIds.isEmpty) {
      CustomSnackbar.showError(context, 'Please select at least one promotion');
      return false;
    }
    if (applyToOption.value == 'selected_category' &&
        selectedCategory.value == null) {
      CustomSnackbar.showError(context, 'Please select a category');
      return false;
    }
    // Validation for selected_products option
    if (applyToOption.value == 'selected_products') {
      if (selectedStoreProductIds.isEmpty) {
        CustomSnackbar.showError(context, 'Please select at least one product');
        return false;
      }
    }

    isApplying.value = true;
    try {
      await _apiService.applyPromotions(
        promotionIds: selectedPromotionIds.toList(),
        applyTo: applyToOption.value,
        shopId: selectedShop.value!.id,
        categoryId:
            applyToOption.value == 'selected_category'
                ? selectedCategory.value?.id
                : null,
        productIds:
            applyToOption.value == 'selected_products'
                ? selectedStoreProductIds.toList()
                : null,
      );

      // Clear selections and refresh
      clearApplyForm();
      await refreshPromotions();

      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Promotions applied successfully');
      }

      // Switch to All Promotions tab after successful apply
      _switchToAllPromotionsTab();

      return true;
    } on PromotionApiException catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, e.message);
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to apply promotions');
      }
      return false;
    } finally {
      isApplying.value = false;
    }
  }

  // Clear apply promotion form
  void clearApplyForm() {
    selectedShop.value = null;
    selectedCategory.value = null;
    selectedPromotionIds.clear();
    applyToOption.value = 'shop';
    shopSearchController.clear();
    categorySearchController.clear();
    // Clear store products state
    selectedStoreProductIds.clear();
    searchedProducts.clear();
    productSearchController.clear();
    storeProductsFetched.value = false;
    isLoadingStoreProducts.value = false;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}T${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String formatDiscount(Promotion promotion) {
    if (promotion.discountType == 'percentage') {
      return '${promotion.discountValue}%';
    }
    return '\$${promotion.discountValue}';
  }

  bool isDeleting(String promotionId) {
    return deletingPromotionId.value == promotionId;
  }
}
