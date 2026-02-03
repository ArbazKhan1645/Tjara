import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/inventory_reporting/inventory_reporting_service.dart';

class InventoryReportingController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isSearchingShops = false.obs;
  var isSearchingCategories = false.obs;

  // Error message
  var errorMessage = Rxn<String>();

  // Settings
  var isEnabled = false.obs;
  var frequency = 'daily'.obs;
  var time = '10:00'.obs;
  final recipientsController = TextEditingController();

  // Report configurations
  var reportConfigs = <ReportConfig>[].obs;

  // Search results
  var shopSearchResults = <ShopItem>[].obs;
  var categorySearchResults = <CategoryItem>[].obs;

  // Debounce timers
  Timer? _shopSearchTimer;
  Timer? _categorySearchTimer;

  // Frequency options
  final frequencyOptions = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
  ];

  // Time options
  final timeOptions = List.generate(24, (i) {
    final hour = i.toString().padLeft(2, '0');
    return {'value': '$hour:00', 'label': '$hour:00'};
  });

  // Category filter type options
  final categoryFilterTypes = [
    {'value': 'include', 'label': 'Include'},
    {'value': 'exclude', 'label': 'Exclude'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    recipientsController.dispose();
    _shopSearchTimer?.cancel();
    _categorySearchTimer?.cancel();
    super.onClose();
  }

  /// Fetch settings from server
  Future<void> fetchSettings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await InventoryReportingService.fetchSettings();

      if (response.success && response.settings != null) {
        final settings = response.settings!;
        isEnabled.value = settings.enabled;
        frequency.value = settings.frequency;
        time.value = settings.time;
        recipientsController.text = settings.recipients;
        reportConfigs.value = settings.reportConfigs;

        // Load display names for existing configs
        await _loadConfigDisplayNames();
      } else {
        errorMessage.value = response.error;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load display names for shop and category in configs
  Future<void> _loadConfigDisplayNames() async {
    for (var config in reportConfigs) {
      // Load shop name if not 'all'
      if (config.storeId != 'all') {
        final shops = await InventoryReportingService.searchShops();
        final shop = shops.firstWhereOrNull((s) => s.id == config.storeId);
        if (shop != null) {
          config.storeName = shop.name;
        }
      }

      // Load category name if not 'all'
      if (config.category != 'all') {
        final categories = await InventoryReportingService.searchCategories();
        final cat = categories.firstWhereOrNull((c) => c.id == config.category);
        if (cat != null) {
          config.categoryName = cat.name;
        }
      }
    }
    reportConfigs.refresh();
  }

  /// Search shops with debounce
  void searchShops(String query) {
    _shopSearchTimer?.cancel();
    _shopSearchTimer = Timer(const Duration(milliseconds: 300), () async {
      isSearchingShops.value = true;
      try {
        final results = await InventoryReportingService.searchShops(
          search: query.isEmpty ? null : query,
        );
        shopSearchResults.value = results;
      } catch (e) {
        shopSearchResults.value = [];
      } finally {
        isSearchingShops.value = false;
      }
    });
  }

  /// Search categories with debounce
  void searchCategories(String query) {
    _categorySearchTimer?.cancel();
    _categorySearchTimer = Timer(const Duration(milliseconds: 300), () async {
      isSearchingCategories.value = true;
      try {
        final results = await InventoryReportingService.searchCategories(
          search: query.isEmpty ? null : query,
        );
        categorySearchResults.value = results;
      } catch (e) {
        categorySearchResults.value = [];
      } finally {
        isSearchingCategories.value = false;
      }
    });
  }

  /// Add new report config
  void addReportConfig() {
    final newConfig = ReportConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Report ${reportConfigs.length + 1}',
      enabled: true,
      storeId: 'all',
      category: 'all',
      categoryFilterType: 'include',
      description: '',
    );
    reportConfigs.add(newConfig);
  }

  /// Remove report config
  void removeReportConfig(String id) {
    reportConfigs.removeWhere((c) => c.id == id);
  }

  /// Update report config
  void updateReportConfig(String id, ReportConfig updatedConfig) {
    final index = reportConfigs.indexWhere((c) => c.id == id);
    if (index != -1) {
      reportConfigs[index] = updatedConfig;
      reportConfigs.refresh();
    }
  }

  /// Toggle report config enabled
  void toggleReportConfig(String id, bool enabled) {
    final index = reportConfigs.indexWhere((c) => c.id == id);
    if (index != -1) {
      reportConfigs[index] = reportConfigs[index].copyWith(enabled: enabled);
      reportConfigs.refresh();
    }
  }

  /// Save settings
  Future<bool> saveSettings() async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final settings = InventoryReportingSettings(
        enabled: isEnabled.value,
        frequency: frequency.value,
        time: time.value,
        recipients: recipientsController.text.trim(),
        reportConfigs: reportConfigs.toList(),
      );

      final response = await InventoryReportingService.updateSettings(
        settings.toUpdatePayload(),
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save settings: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Get store display name
  String getStoreDisplayName(String storeId) {
    if (storeId == 'all') return 'All Stores';
    final config = reportConfigs.firstWhereOrNull((c) => c.storeId == storeId);
    return config?.storeName ?? 'Store #$storeId';
  }

  /// Get category display name
  String getCategoryDisplayName(String categoryId) {
    if (categoryId == 'all') return 'All Categories';
    final config = reportConfigs.firstWhereOrNull((c) => c.category == categoryId);
    return config?.categoryName ?? 'Category #$categoryId';
  }
}
