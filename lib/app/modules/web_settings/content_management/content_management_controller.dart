import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/modules/web_settings/content_management/content_management_service.dart';

class ContentManagementController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isUploadingImage = false.obs;
  var isLoadingCategories = false.obs;
  var isSearchingShops = false.obs;

  // Error message
  var errorMessage = Rxn<String>();

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // ============================================
  // All Categories Image
  // ============================================
  var allCategoriesImageUrl = ''.obs;
  var allCategoriesImageId = ''.obs;

  // ============================================
  // Website Features Promos
  // ============================================
  final promo1Controller = TextEditingController();
  final promo2Controller = TextEditingController();
  final promo3Controller = TextEditingController();
  final promo4Controller = TextEditingController();
  var promoDirection = 'rtl'.obs;

  // ============================================
  // All Products Notice
  // ============================================
  final allProductsNoticeController = TextEditingController();
  var allProductsNoticeDir = 'ltr'.obs;

  // ============================================
  // Header Categories
  // ============================================
  var headerCategoryIds = <String>[].obs;
  var allCategories = <CategoryItem>[].obs;
  var categorySearchQuery = ''.obs;

  // Cached filtered categories for performance
  var _cachedFilteredCategories = <CategoryItem>[];
  String _lastCategorySearchQuery = '';
  int _lastHeaderCategoryIdsLength = 0;

  // ============================================
  // Shop Discounts
  // ============================================
  var shopDiscounts = <ShopDiscount>[].obs;

  /// Stores every ShopItem we have fetched so far (by search OR by id).
  /// Used only to resolve shopId → name in the UI.
  var allShops = <ShopItem>[].obs;

  /// Live search results shown in the shop-picker dropdown.
  var shopSearchResults = <ShopItem>[].obs;

  // Discount range options
  final discountRangeOptions = [
    '5%',
    '10%',
    '15%',
    '20%',
    '25%',
    '30%',
    '5-10',
    '10-15',
    '15-20',
    '20-25',
    '25-30',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  @override
  void onClose() {
    promo1Controller.dispose();
    promo2Controller.dispose();
    promo3Controller.dispose();
    promo4Controller.dispose();
    allProductsNoticeController.dispose();
    super.onClose();
  }

  // ============================================
  // Initial Data Load
  // ============================================

  /// Fetch settings + categories in parallel.
  /// Shops are NOT fetched here — they are search-only.
  Future<void> fetchAllData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final results = await Future.wait([
        ContentManagementService.fetchSettings(),
        ContentManagementService.fetchCategories(),
      ]);

      final settingsResponse = results[0] as SettingsResponse;
      final categoriesResponse = results[1] as CategoriesResponse;

      // ---------- Settings ----------
      if (settingsResponse.success && settingsResponse.settings != null) {
        final s = settingsResponse.settings!;

        allCategoriesImageUrl.value = s.allCategoriesImageUrl;
        allCategoriesImageId.value = s.allCategoriesImageId;

        promo1Controller.text = s.websiteFeaturesPromo1;
        promo2Controller.text = s.websiteFeaturesPromo2;
        promo3Controller.text = s.websiteFeaturesPromo3;
        promo4Controller.text = s.websiteFeaturesPromo4;
        promoDirection.value = s.websiteFeaturesPromoDir;

        allProductsNoticeController.text = s.allProductsNotice;
        allProductsNoticeDir.value = s.allProductsNoticeDir;

        if (s.headerCategories.isNotEmpty) {
          headerCategoryIds.value =
              s.headerCategories
                  .split(',')
                  .where((id) => id.isNotEmpty)
                  .toList();
        }

        // Parse saved shop discounts
        if (s.shopDiscounts.isNotEmpty && s.shopDiscounts != '[]') {
          try {
            final discountsJson = jsonDecode(s.shopDiscounts) as List;
            shopDiscounts.value =
                discountsJson
                    .map(
                      (d) => ShopDiscount.fromJson(d as Map<String, dynamic>),
                    )
                    .toList();
          } catch (_) {
            shopDiscounts.value = [];
          }
        }

        // For every shopId already saved in discounts, fetch its name by ID
        // so getShopName() can display it without a search.
        await _fetchShopNamesForExistingDiscounts();
      } else {
        errorMessage.value = settingsResponse.error;
      }

      // ---------- Categories ----------
      // Parse categories in isolate to prevent UI freeze with 5000+ items
      if (categoriesResponse.success && categoriesResponse.rawBody != null) {
        final parsedCategories = await compute(
          ContentManagementService.parseCategoriesFromJson,
          categoriesResponse.rawBody!,
        );
        allCategories.value = parsedCategories;
        _clearCategoryFilterCache();
      } else if (categoriesResponse.success) {
        allCategories.value = categoriesResponse.categories;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// For every unique shopId already present in shopDiscounts,
  /// call fetchShopById and cache the result in allShops.
  Future<void> _fetchShopNamesForExistingDiscounts() async {
    final uniqueIds =
        shopDiscounts.map((d) => d.shopId).where((id) => id.isNotEmpty).toSet();

    // Fetch all in parallel
    await Future.wait(
      uniqueIds.map((id) async {
        final shop = await ContentManagementService.fetchShopById(id);
        if (shop != null) {
          _cacheShop(shop);
        }
      }),
    );
  }

  /// Add a ShopItem to allShops if not already present (by id).
  void _cacheShop(ShopItem shop) {
    if (!allShops.any((s) => s.id == shop.id)) {
      allShops.add(shop);
    }
  }

  // ============================================
  // All Categories Image Methods
  // ============================================

  Future<void> pickAndUploadCategoriesImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image == null) return;

      isUploadingImage.value = true;

      final file = File(image.path);
      final response = await ContentManagementService.uploadMediaAndGetUrl(
        [file],
        directory: 'settings',
        width: 200,
        height: 200,
      );

      if (response.success && response.url != null) {
        final updateResponse = await ContentManagementService.updateSettings({
          'all_categories_image_url': response.url!,
          if (response.id != null) 'all_categories_image_id': response.id!,
        });

        if (updateResponse.success) {
          allCategoriesImageUrl.value = response.url!;
          if (response.id != null) {
            allCategoriesImageId.value = response.id!;
          }
          _showSuccess('Image updated successfully');
        } else {
          _showError(updateResponse.message);
        }
      } else {
        _showError(response.error ?? 'Failed to upload image');
      }
    } catch (e) {
      _showError('Failed to pick/upload image: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> removeCategoriesImage() async {
    if (isSaving.value) return;

    isSaving.value = true;
    try {
      final response = await ContentManagementService.updateSettings({
        'all_categories_image_url': '',
        'all_categories_image_id': '',
      });

      if (response.success) {
        allCategoriesImageUrl.value = '';
        allCategoriesImageId.value = '';
        _showSuccess('Image removed successfully');
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Failed to remove image: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================
  // Header Categories Methods
  // ============================================

  String getCategoryName(String id) {
    final category = allCategories.firstWhereOrNull((c) => c.id == id);
    return category?.name ?? 'Unknown';
  }

  /// Optimized filtered categories with caching
  /// Returns max 50 items to prevent UI lag with 5000+ categories
  List<CategoryItem> get filteredCategories {
    final query = categorySearchQuery.value;
    final headerIdsLength = headerCategoryIds.length;

    // Return cached result if inputs haven't changed
    if (query == _lastCategorySearchQuery &&
        headerIdsLength == _lastHeaderCategoryIdsLength &&
        _cachedFilteredCategories.isNotEmpty) {
      return _cachedFilteredCategories;
    }

    // Update cache keys
    _lastCategorySearchQuery = query;
    _lastHeaderCategoryIdsLength = headerIdsLength;

    // Create a Set for O(1) lookup instead of O(n) list.contains
    final headerIdsSet = headerCategoryIds.toSet();
    final queryLower = query.toLowerCase();

    // Use efficient filtering with early termination
    final List<CategoryItem> result = [];
    const maxResults = 50; // Limit results to prevent UI lag

    for (final category in allCategories) {
      if (result.length >= maxResults) break;

      if (headerIdsSet.contains(category.id)) continue;

      if (query.isEmpty || category.name.toLowerCase().contains(queryLower)) {
        result.add(category);
      }
    }

    _cachedFilteredCategories = result;
    return result;
  }

  /// Clear category filter cache when categories are modified
  void _clearCategoryFilterCache() {
    _cachedFilteredCategories = [];
    _lastCategorySearchQuery = '';
    _lastHeaderCategoryIdsLength = 0;
  }

  Future<void> addCategory(String categoryId) async {
    if (headerCategoryIds.contains(categoryId)) return;
    headerCategoryIds.add(categoryId);
    _clearCategoryFilterCache();
    await _saveHeaderCategories();
  }

  Future<void> removeCategory(String categoryId) async {
    headerCategoryIds.remove(categoryId);
    _clearCategoryFilterCache();
    await _saveHeaderCategories();
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = headerCategoryIds.removeAt(oldIndex);
    headerCategoryIds.insert(newIndex, item);
    await _saveHeaderCategories();
  }

  Future<void> _saveHeaderCategories() async {
    try {
      await ContentManagementService.updateSettings({
        'header_categories': headerCategoryIds.join(','),
      });
    } catch (e) {
      _showError('Failed to save categories: $e');
    }
  }

  // ============================================
  // Shop Search (used by the shop-picker in UI)
  // ============================================

  /// Call this whenever the user types in the shop search box.
  /// Results are stored in [shopSearchResults].
  Future<void> searchShops(String query) async {
    if (query.trim().isEmpty) {
      shopSearchResults.value = [];
      return;
    }

    isSearchingShops.value = true;
    try {
      final response = await ContentManagementService.searchShops(query.trim());
      if (response.success) {
        shopSearchResults.value = response.shops;
        // Cache every returned shop so getShopName() works after selection
        for (final shop in response.shops) {
          _cacheShop(shop);
        }
      } else {
        shopSearchResults.value = [];
      }
    } catch (e) {
      shopSearchResults.value = [];
      _showError('Failed to search shops: $e');
    } finally {
      isSearchingShops.value = false;
    }
  }

  /// Clear the live search dropdown (e.g. after a shop is picked).
  void clearShopSearch() {
    shopSearchResults.value = [];
  }

  // ============================================
  // Shop Discounts Methods
  // ============================================

  /// Resolve shopId → display name from the local cache.
  String getShopName(String id) {
    final shop = allShops.firstWhereOrNull((s) => s.id == id);
    return shop?.name ?? 'Unknown Shop';
  }

  /// Cache for shop details futures to avoid duplicate API calls
  final Map<String, Future<ShopItem?>> _shopDetailsFutureCache = {};

  /// Get shop details by ID - first checks cache, then fetches from API
  Future<ShopItem?> getShopDetails(String id) async {
    if (id.isEmpty) return null;

    // Check if already in allShops cache
    final cached = allShops.firstWhereOrNull((s) => s.id == id);
    if (cached != null) return cached;

    // Check if we already have a pending future for this ID
    if (_shopDetailsFutureCache.containsKey(id)) {
      return _shopDetailsFutureCache[id];
    }

    // Create new future and cache it
    final future = ContentManagementService.fetchShopById(id).then((shop) {
      if (shop != null) {
        _cacheShop(shop);
      }
      return shop;
    });

    _shopDetailsFutureCache[id] = future;
    return future;
  }

  /// Add a new (empty) discount row.
  void addShopDiscount() {
    shopDiscounts.add(
      ShopDiscount(
        shopId: '', // user must pick via search
        categoryId: '',
        discountRange: '5-10',
        tooltipText: '',
        shippingText: '',
      ),
    );
  }

  void removeShopDiscount(int index) {
    if (index >= 0 && index < shopDiscounts.length) {
      shopDiscounts.removeAt(index);
    }
  }

  void updateShopDiscount(
    int index, {
    String? shopId,
    String? categoryId,
    String? discountRange,
    String? tooltipText,
    String? shippingText,
  }) {
    if (index >= 0 && index < shopDiscounts.length) {
      final discount = shopDiscounts[index];
      if (shopId != null) discount.shopId = shopId;
      if (categoryId != null) discount.categoryId = categoryId;
      if (discountRange != null) discount.discountRange = discountRange;
      if (tooltipText != null) discount.tooltipText = tooltipText;
      if (shippingText != null) discount.shippingText = shippingText;
      shopDiscounts.refresh();
    }
  }

  // ============================================
  // Save All Settings
  // ============================================

  Future<bool> saveSettings() async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final discountsJson = jsonEncode(
        shopDiscounts.map((d) => d.toJson()).toList(),
      );

      final response = await ContentManagementService.updateSettings({
        'website_features_promo1': promo1Controller.text.trim(),
        'website_features_promo2': promo2Controller.text.trim(),
        'website_features_promo3': promo3Controller.text.trim(),
        'website_features_promo4': promo4Controller.text.trim(),
        'website_features_promo_dir': promoDirection.value,
        'all_products_notice': allProductsNoticeController.text.trim(),
        'all_products_notice_dir': allProductsNoticeDir.value,
        'header_categories': headerCategoryIds.join(','),
        'shop_discounts': discountsJson,
      });

      if (response.success) {
        _showSuccess(response.message);
        return true;
      } else {
        _showError(response.message);
        return false;
      }
    } catch (e) {
      _showError('Failed to save settings: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================
  // Helper Methods
  // ============================================

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}
