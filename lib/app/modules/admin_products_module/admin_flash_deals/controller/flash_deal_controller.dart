import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/model/flash_deal_model.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/service/flash_deal_api_service.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class FlashDealController extends GetxController {
  final FlashDealApiService _apiService = FlashDealApiService();

  // Timer for real-time settings fetch
  Timer? _settingsTimer;
  static const Duration _refreshInterval = Duration(seconds: 10);

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  // Flag to track if form fields have been initialized (prevents auto-update after first load)
  bool _isFormFieldsInitialized = false;

  // Settings
  final Rxn<FlashDealSettings> settings = Rxn<FlashDealSettings>();

  // Form values
  final RxBool flashDealsEnabled = false.obs;
  final RxString activeTimeValue = '1'.obs;
  final RxString activeTimeUnit = 'minutes'.obs;
  final RxString intervalTimeValue = '30'.obs;
  final RxString intervalTimeUnit = 'seconds'.obs;
  final RxString schedulingMode = 'live'.obs;
  final Rxn<DateTime> scheduledStartTime = Rxn<DateTime>();
  final RxString timeLimitHours = '24'.obs;
  final RxBool purchaseLimitEnabled = false.obs;
  final RxString purchaseLimitPerStore = '2'.obs;
  final RxString lockDuration = '5'.obs;

  // Text controllers
  final activeTimeController = TextEditingController();
  final intervalTimeController = TextEditingController();
  final timeLimitController = TextEditingController();
  final purchaseLimitController = TextEditingController();
  final lockDurationController = TextEditingController();

  // Products lists
  final RxList<FlashDealProduct> activeProducts = <FlashDealProduct>[].obs;
  final RxList<FlashDealProduct> skippedProducts = <FlashDealProduct>[].obs;
  final RxList<FlashDealProduct> expiredProducts = <FlashDealProduct>[].obs;
  final RxList<FlashDealProduct> soldProducts = <FlashDealProduct>[].obs;

  // Product IDs lists (for sorting)
  final RxList<String> activeProductIds = <String>[].obs;
  final RxList<String> skippedProductIds = <String>[].obs;
  final RxList<String> expiredProductIds = <String>[].obs;
  final RxList<String> soldProductIds = <String>[].obs;

  // Product search
  final RxList<FlashDealProduct> searchedProducts = <FlashDealProduct>[].obs;
  final RxBool isSearchingProducts = false.obs;
  final productSearchController = TextEditingController();

  // Product cache
  final RxMap<String, FlashDealProduct> productCache =
      <String, FlashDealProduct>{}.obs;

  // Tab index
  final RxInt selectedTabIndex = 0.obs;

  // Loading states for individual actions
  final Rxn<String> skippingProductId = Rxn<String>();
  final Rxn<String> restoringProductId = Rxn<String>();
  final Rxn<String> removingProductId = Rxn<String>();

  // Time units options
  final List<String> timeUnits = ['seconds', 'minutes', 'hours'];

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _fetchInitialData();
    _startSettingsTimer();
  }

  @override
  void onClose() {
    _stopSettingsTimer();
    _disposeControllers();
    super.onClose();
  }

  void _initControllers() {
    activeTimeController.text = '1';
    intervalTimeController.text = '30';
    timeLimitController.text = '24';
    purchaseLimitController.text = '2';
    lockDurationController.text = '5';
  }

  void _disposeControllers() {
    activeTimeController.dispose();
    intervalTimeController.dispose();
    timeLimitController.dispose();
    purchaseLimitController.dispose();
    lockDurationController.dispose();
    productSearchController.dispose();
  }

  void _startSettingsTimer() {
    _settingsTimer = Timer.periodic(_refreshInterval, (_) {
      _refreshSettings();
    });
  }

  void _stopSettingsTimer() {
    _settingsTimer?.cancel();
    _settingsTimer = null;
  }

  // Fetch initial data
  Future<void> _fetchInitialData() async {
    isLoading.value = true;
    error.value = '';

    try {
      final response = await _apiService.fetchSettings();
      settings.value = response.flashDealSettings;
      _updateFormFromSettings(response.flashDealSettings);
      await _loadProductsFromSettings(response.flashDealSettings);
    } on FlashDealApiException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = 'Failed to load settings';
    } finally {
      isLoading.value = false;
      isInitialLoading.value = false;
    }
  }

  // Refresh settings (called by timer)
  Future<void> _refreshSettings() async {
    if (isSaving.value) return; // Don't refresh while saving

    try {
      final response = await _apiService.fetchSettings();
      final newSettings = response.flashDealSettings;

      // Check if product lists changed
      final activeChanged =
          newSettings.flashDealsProductsSortOrder !=
          settings.value?.flashDealsProductsSortOrder;
      final skippedChanged =
          newSettings.skippedDealsProductsSortOrder !=
          settings.value?.skippedDealsProductsSortOrder;
      final expiredChanged =
          newSettings.expiredDealsProductsSortOrder !=
          settings.value?.expiredDealsProductsSortOrder;
      final soldChanged =
          newSettings.soldDealsProductsSortOrder !=
          settings.value?.soldDealsProductsSortOrder;

      settings.value = newSettings;

      // Only reload products if lists changed
      if (activeChanged || skippedChanged || expiredChanged || soldChanged) {
        await _loadProductsFromSettings(newSettings);
      }

      // Update form values
      _updateFormFromSettings(newSettings);
    } catch (e) {
      // Silent fail for background refresh
    }
  }

  void _updateFormFromSettings(FlashDealSettings s) {
    // Always update these reactive values (for display purposes)
    flashDealsEnabled.value = s.flashDealsEnabled;
    purchaseLimitEnabled.value = s.purchaseLimitEnabled;

    // Update product IDs (always keep in sync)
    activeProductIds.value = s.activeProductIds;
    skippedProductIds.value = s.skippedProductIds;
    expiredProductIds.value = s.expiredProductIds;
    soldProductIds.value = s.soldProductIds;

    // Only initialize text field values on first load
    // This prevents overwriting user input when API refreshes
    if (!_isFormFieldsInitialized) {
      activeTimeValue.value = s.activeTimeValue;
      activeTimeUnit.value = s.activeTimeUnit;
      intervalTimeValue.value = s.intervalTimeValue;
      intervalTimeUnit.value = s.intervalTimeUnit;
      schedulingMode.value = s.schedulingMode;
      timeLimitHours.value = s.timeLimitHours ?? '24';
      purchaseLimitPerStore.value = s.purchaseLimitPerStore ?? '2';
      lockDuration.value = s.lockDuration ?? '5';

      // Parse start time
      if (s.startTime != null && s.startTime!.isNotEmpty) {
        try {
          scheduledStartTime.value = DateTime.parse(s.startTime!);
        } catch (e) {
          scheduledStartTime.value = null;
        }
      }

      // Update text controllers only on first init
      activeTimeController.text = s.activeTimeValue;
      intervalTimeController.text = s.intervalTimeValue;
      timeLimitController.text = s.timeLimitHours ?? '24';
      purchaseLimitController.text = s.purchaseLimitPerStore ?? '2';
      lockDurationController.text = s.lockDuration ?? '5';

      // Mark as initialized so future API refreshes won't overwrite user input
      _isFormFieldsInitialized = true;
    }
  }

  Future<void> _loadProductsFromSettings(FlashDealSettings s) async {
    // Load all products in parallel
    final results = await Future.wait([
      _loadProductsForIds(s.activeProductIds),
      _loadProductsForIds(s.skippedProductIds),
      _loadProductsForIds(s.expiredProductIds),
      _loadProductsForIds(s.soldProductIds),
    ]);

    activeProducts.value = results[0];
    skippedProducts.value = results[1];
    expiredProducts.value = results[2];
    soldProducts.value = results[3];
  }

  Future<List<FlashDealProduct>> _loadProductsForIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final List<FlashDealProduct> products = [];
    for (final id in ids) {
      // Check cache first
      if (productCache.containsKey(id)) {
        products.add(productCache[id]!);
      } else {
        try {
          final product = await _apiService.getProductById(id);
          productCache[id] = product;
          products.add(product);
        } catch (e) {
          // Add placeholder if product not found
          products.add(
            FlashDealProduct(
              id: id,
              name: 'Product #${id.substring(0, 8)}...',
              is_deal: '1',
            ),
          );
        }
      }
    }
    return products;
  }

  // Toggle flash deals enabled
  Future<void> toggleFlashDealsEnabled(bool value) async {
    flashDealsEnabled.value = value;
    await _updateSettingsField('flash_deals_enabled', value ? '1' : '0');
  }

  // Update active time
  void updateActiveTimeValue(String value) {
    activeTimeValue.value = value;
    update();
  }

  void updateActiveTimeUnit(String value) {
    activeTimeUnit.value = value;
  }

  // Update interval time
  void updateIntervalTimeValue(String value) {
    intervalTimeValue.value = value;
  }

  void updateIntervalTimeUnit(String value) {
    intervalTimeUnit.value = value;
  }

  // Update scheduling mode
  void updateSchedulingMode(String mode) {
    schedulingMode.value = mode;
    if (mode == 'live') {
      scheduledStartTime.value = DateTime.now();
    }
  }

  // Update scheduled start time
  void updateScheduledStartTime(DateTime dateTime) {
    // Validate future time - compare in UTC to avoid timezone issues
    if (dateTime.toUtc().isBefore(DateTime.now().toUtc())) {
      AdminSnackbar.warning(
        'Invalid Time',
        'Please select a future date and time',
      );
      return;
    }
    scheduledStartTime.value = dateTime;
  }

  // Update single setting field immediately
  Future<void> _updateSettingsField(String key, String value) async {
    try {
      await _apiService.updateSettings({key: value});
    } catch (e) {
      // Silent fail for immediate updates
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

  // Load initial products for search
  Future<void> loadInitialProducts() async {
    isSearchingProducts.value = true;
    try {
      searchedProducts.value = await _apiService.searchProducts();
    } catch (e) {
      // Silent fail
    } finally {
      isSearchingProducts.value = false;
    }
  }

  // Check if product exists in any tab
  bool isProductInAnyTab(String productId) {
    return activeProductIds.contains(productId) ||
        skippedProductIds.contains(productId) ||
        expiredProductIds.contains(productId) ||
        soldProductIds.contains(productId);
  }

  // Add product to active deals
  Future<void> addProductToActiveDeals(FlashDealProduct product) async {
    // Check if product exists in any tab
    if (isProductInAnyTab(product.id)) {
      String tabName = 'flash deals';
      if (activeProductIds.contains(product.id)) {
        tabName = 'active deals';
      } else if (skippedProductIds.contains(product.id)) {
        tabName = 'skipped deals';
      } else if (expiredProductIds.contains(product.id)) {
        tabName = 'expired deals';
      } else if (soldProductIds.contains(product.id)) {
        tabName = 'sold deals';
      }
      AdminSnackbar.warning(
        'Already Exists',
        'This product is already in $tabName',
      );
      return;
    }

    // Add to local lists
    activeProductIds.add(product.id);
    activeProducts.add(product);
    productCache[product.id] = product;

    // Update settings immediately
    await _updateSortOrderSettings();
  }

  // Remove product from any tab
  Future<void> removeProduct(String productId, int tabIndex) async {
    removingProductId.value = productId;

    try {
      switch (tabIndex) {
        case 0: // Active
          activeProductIds.remove(productId);
          activeProducts.removeWhere((p) => p.id == productId);
          break;
        case 1: // Skipped
          skippedProductIds.remove(productId);
          skippedProducts.removeWhere((p) => p.id == productId);
          break;
        case 2: // Expired
          expiredProductIds.remove(productId);
          expiredProducts.removeWhere((p) => p.id == productId);
          break;
        case 3: // Sold
          soldProductIds.remove(productId);
          soldProducts.removeWhere((p) => p.id == productId);
          break;
      }

      await _updateSortOrderSettings();
    } finally {
      removingProductId.value = null;
    }
  }

  // Skip a deal (Active -> Skipped)
  Future<void> skipDeal(String productId) async {
    skippingProductId.value = productId;

    try {
      await _apiService.skipFlashDeal(productId);

      // Move locally
      final product = activeProducts.firstWhere((p) => p.id == productId);
      activeProductIds.remove(productId);
      activeProducts.remove(product);

      skippedProductIds.add(productId);
      skippedProducts.add(product);

      AdminSnackbar.success('Deal Skipped', 'Product moved to skipped deals');
    } on FlashDealApiException catch (e) {
      AdminSnackbar.error('Error', e.message);
    } catch (e) {
      AdminSnackbar.error('Error', 'Failed to skip deal');
    } finally {
      skippingProductId.value = null;
    }
  }

  // Restore a deal (Skipped -> Active)
  Future<void> restoreDeal(String productId) async {
    restoringProductId.value = productId;

    try {
      await _apiService.restoreFlashDeal(productId);

      // Move locally
      final product = skippedProducts.firstWhere((p) => p.id == productId);
      skippedProductIds.remove(productId);
      skippedProducts.remove(product);

      activeProductIds.add(productId);
      activeProducts.add(product);

      AdminSnackbar.success('Deal Restored', 'Product moved to active deals');
    } on FlashDealApiException catch (e) {
      AdminSnackbar.error('Error', e.message);
    } catch (e) {
      AdminSnackbar.error('Error', 'Failed to restore deal');
    } finally {
      restoringProductId.value = null;
    }
  }

  // Reorder products in a tab
  void reorderProducts(int tabIndex, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    switch (tabIndex) {
      case 0: // Active
        final id = activeProductIds.removeAt(oldIndex);
        activeProductIds.insert(newIndex, id);
        final product = activeProducts.removeAt(oldIndex);
        activeProducts.insert(newIndex, product);
        break;
      case 1: // Skipped
        final id = skippedProductIds.removeAt(oldIndex);
        skippedProductIds.insert(newIndex, id);
        final product = skippedProducts.removeAt(oldIndex);
        skippedProducts.insert(newIndex, product);
        break;
      case 2: // Expired
        final id = expiredProductIds.removeAt(oldIndex);
        expiredProductIds.insert(newIndex, id);
        final product = expiredProducts.removeAt(oldIndex);
        expiredProducts.insert(newIndex, product);
        break;
      case 3: // Sold
        final id = soldProductIds.removeAt(oldIndex);
        soldProductIds.insert(newIndex, id);
        final product = soldProducts.removeAt(oldIndex);
        soldProducts.insert(newIndex, product);
        break;
    }

    // Update settings with new order
    _updateSortOrderSettings();
  }

  // Update sort order settings
  Future<void> _updateSortOrderSettings() async {
    try {
      await _apiService.updateSettings({
        'flash_deals_products_sort_order': activeProductIds.join(','),
        'skipped_deals_products_sort_order': skippedProductIds.join(','),
        'expired_deals_products_sort_order': expiredProductIds.join(','),
        'sold_deals_products_sort_order': soldProductIds.join(','),
      });
    } catch (e) {
      // Silent fail
    }
  }

  // Main save function
  Future<void> saveFlashDealSettings() async {
    isSaving.value = true;

    try {
      // Validate
      if (schedulingMode.value == 'schedule' &&
          scheduledStartTime.value == null) {
        AdminSnackbar.warning(
          'Validation Error',
          'Please select a start date and time',
        );
        return;
      }

      // Compare in UTC to avoid timezone issues
      if (schedulingMode.value == 'schedule' &&
          scheduledStartTime.value!.toUtc().isBefore(DateTime.now().toUtc())) {
        AdminSnackbar.warning(
          'Validation Error',
          'Start time must be in the future',
        );
        return;
      }

      // Calculate duration and interval in seconds
      final durationSeconds = _calculateSeconds(
        activeTimeController.text,
        activeTimeUnit.value,
      );
      final intervalSecs = _calculateSeconds(
        intervalTimeController.text,
        intervalTimeUnit.value,
      );

      // Get start time
      final startTime =
          schedulingMode.value == 'live'
              ? DateTime.now().toUtc()
              : scheduledStartTime.value!.toUtc();

      // Call flash-deal-products API
      await _apiService.saveFlashDealProducts(
        productIds: activeProductIds.toList(),
        scheduledStart: startTime.toIso8601String(),
        dealDurationSeconds: durationSeconds,
        intervalSeconds: intervalSecs,
      );

      // Build settings payload
      final settingsPayload = _buildSettingsPayload(startTime);

      // Update settings
      await _apiService.updateSettings(settingsPayload);

      AdminSnackbar.success(
        'Success',
        'Flash deal settings saved successfully',
      );
    } on FlashDealApiException catch (e) {
      AdminSnackbar.error('Error', e.message);
    } catch (e) {
      AdminSnackbar.error('Error', 'Failed to save settings');
    } finally {
      isSaving.value = false;
    }
  }

  int _calculateSeconds(String value, String unit) {
    final numValue = int.tryParse(value) ?? 1;
    switch (unit.toLowerCase()) {
      case 'seconds':
        return numValue;
      case 'minutes':
        return numValue * 60;
      case 'hours':
        return numValue * 3600;
      default:
        return numValue * 60;
    }
  }

  Map<String, dynamic> _buildSettingsPayload(DateTime startTime) {
    return {
      'flash_deals_enabled': flashDealsEnabled.value ? '1' : '0',
      'flash_deals_active_time_value': activeTimeController.text,
      'flash_deals_active_time_unit': activeTimeUnit.value,
      'flash_deals_interval_time_value': intervalTimeController.text,
      'flash_deals_interval_time_unit': intervalTimeUnit.value,
      'flash_deals_scheduling_mode': schedulingMode.value,
      'flash_deals_start_time': startTime.toIso8601String(),
      'flash_deals_time_limit_hours': timeLimitController.text,
      'flash_deals_purchase_limit_enabled':
          purchaseLimitEnabled.value ? '1' : '0',
      'flash_deals_purchase_limit_per_store': purchaseLimitController.text,
      'flash_deal_lock_duration': lockDurationController.text,
      'flash_deals_products_sort_order': activeProductIds.join(','),
      'skipped_deals_products_sort_order': skippedProductIds.join(','),
      'expired_deals_products_sort_order': expiredProductIds.join(','),
      'sold_deals_products_sort_order': soldProductIds.join(','),
      'deal_sequence_reset': true,
      'deal_schedule_time': startTime.toIso8601String(),
      'current_deal_start_time': startTime.toIso8601String(),
      'current_deal_end_time':
          startTime
              .add(
                Duration(
                  seconds: _calculateSeconds(
                    activeTimeController.text,
                    activeTimeUnit.value,
                  ),
                ),
              )
              .toIso8601String(),
      'current_deal_product_id':
          activeProductIds.isNotEmpty ? activeProductIds.first : null,
    };
  }

  // Helper getters
  // Helper getters - use reactive values so Obx rebuilds properly
  String get durationDisplay {
    final value = activeTimeValue.value.isEmpty ? '0' : activeTimeValue.value;
    final seconds = _calculateSeconds(value, activeTimeUnit.value);
    return 'Total Duration: $value ${activeTimeUnit.value} ($seconds seconds)';
  }

  String get intervalDisplay {
    final value =
        intervalTimeValue.value.isEmpty ? '0' : intervalTimeValue.value;
    final seconds = _calculateSeconds(value, intervalTimeUnit.value);
    return 'Interval Duration: $value ${intervalTimeUnit.value} ($seconds seconds)';
  }

  String get startTimeDisplay {
    if (schedulingMode.value == 'live') {
      return 'Current Setting: Live Now';
    }
    if (scheduledStartTime.value == null) {
      return 'Current Setting: Not set';
    }
    // Get the stored value
    final storedTime = scheduledStartTime.value!;
    // Convert to local and UTC properly
    final localTime = storedTime.isUtc ? storedTime.toLocal() : storedTime;
    final utcTime = storedTime.isUtc ? storedTime : storedTime.toUtc();

    return 'Local Time: ${_formatDateTime(localTime)}\nUTC Time: ${_formatDateTime(utcTime)}';
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year, $hour:$minute';
  }

  // Check if product is being processed
  bool isSkipping(String productId) => skippingProductId.value == productId;
  bool isRestoring(String productId) => restoringProductId.value == productId;
  bool isRemoving(String productId) => removingProductId.value == productId;
}
