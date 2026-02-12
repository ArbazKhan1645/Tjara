import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/analytics_reporting/analytics_reporting_service.dart';

class AnalyticsReportingController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isSearchingShops = false.obs;

  // Error message
  var errorMessage = Rxn<String>();

  // Settings
  var isEnabled = false.obs;
  var scope = 'all'.obs; // 'all' or 'specific_store'
  var storeId = ''.obs;
  var storeName = ''.obs;
  var frequency = 'daily'.obs;
  var time = '10:00'.obs;
  final recipientsController = TextEditingController();

  // Search results
  var shopSearchResults = <ShopItem>[].obs;

  // Debounce timer
  Timer? _shopSearchTimer;

  // Scope options
  final scopeOptions = [
    {'value': 'all', 'label': 'All Orders'},
    {'value': 'specific_store', 'label': 'Specific Store'},
  ];

  // Frequency options
  final frequencyOptions = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly (Mondays)'},
    {'value': 'monthly', 'label': 'Monthly'},
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
    super.onClose();
  }

  /// Fetch settings from server
  Future<void> fetchSettings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await AnalyticsReportingService.fetchSettings();

      if (response.success && response.settings != null) {
        final settings = response.settings!;
        isEnabled.value = settings.enabled;
        scope.value = settings.scope;
        storeId.value = settings.storeId;
        frequency.value = settings.frequency;
        time.value = settings.time;
        recipientsController.text = settings.recipients;

        // Load store name if specific store is selected
        if (settings.scope == 'specific_store' && settings.storeId.isNotEmpty) {
          await _loadStoreName(settings.storeId);
        }
      } else {
        errorMessage.value = response.error;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load store name for existing store ID
  Future<void> _loadStoreName(String id) async {
    final shops = await AnalyticsReportingService.searchShops();
    final shop = shops.firstWhereOrNull((s) => s.id == id);
    if (shop != null) {
      storeName.value = shop.name;
    }
  }

  /// Search shops with debounce
  void searchShops(String query) {
    _shopSearchTimer?.cancel();
    _shopSearchTimer = Timer(const Duration(milliseconds: 300), () async {
      isSearchingShops.value = true;
      try {
        final results = await AnalyticsReportingService.searchShops(
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

  /// Select store
  void selectStore(ShopItem? shop) {
    if (shop == null) {
      storeId.value = '';
      storeName.value = '';
    } else {
      storeId.value = shop.id;
      storeName.value = shop.name;
    }
  }

  /// Change scope
  void changeScope(String newScope) {
    scope.value = newScope;
    if (newScope == 'all') {
      storeId.value = '';
      storeName.value = '';
    }
  }

  /// Save settings
  Future<bool> saveSettings() async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      final settings = AnalyticsReportingSettings(
        enabled: isEnabled.value,
        scope: scope.value,
        storeId: storeId.value,
        frequency: frequency.value,
        time: time.value,
        recipients: recipientsController.text.trim(),
      );

      final response = await AnalyticsReportingService.updateSettings(
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

  /// Get frequency label
  String get frequencyLabel {
    final option = frequencyOptions.firstWhereOrNull(
      (o) => o['value'] == frequency.value,
    );
    return option?['label'] ?? frequency.value;
  }

  /// Get scope label
  String get scopeLabel {
    final option = scopeOptions.firstWhereOrNull(
      (o) => o['value'] == scope.value,
    );
    return option?['label'] ?? scope.value;
  }

  /// Get formatted time for display (12-hour format)
  String get formattedTime {
    final parts = time.value.split(':');
    final int hour24 = int.tryParse(parts[0]) ?? 10;
    final minutes = parts.length > 1 ? parts[1] : '00';

    String period;
    int hour12;

    if (hour24 == 0) {
      hour12 = 12;
      period = 'AM';
    } else if (hour24 < 12) {
      hour12 = hour24;
      period = 'AM';
    } else if (hour24 == 12) {
      hour12 = 12;
      period = 'PM';
    } else {
      hour12 = hour24 - 12;
      period = 'PM';
    }

    return '${hour12.toString().padLeft(2, '0')}:$minutes $period';
  }
}
