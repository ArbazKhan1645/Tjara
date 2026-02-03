import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/content_management/content_management_service.dart';

class WebSettingsController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;
  var errorMessage = Rxn<String>();

  // ============================================
  // Website Basic Info
  // ============================================
  final websiteNameController = TextEditingController();
  final websiteDescriptionController = TextEditingController();
  final whatsappNumberController = TextEditingController();
  final supportEmailController = TextEditingController();
  final salesEmailController = TextEditingController();

  // ============================================
  // App Store Links
  // ============================================
  final googlePlayLinkController = TextEditingController();
  final appleStoreLinkController = TextEditingController();

  // ============================================
  // Admin Settings
  // ============================================
  final adminCommissionController = TextEditingController();
  final minDiscountForDealsController = TextEditingController();
  final vendorsMaxProductsController = TextEditingController();
  final vendorsMaxCarsController = TextEditingController();

  // ============================================
  // Lebanon Tech Discount
  // ============================================
  var lebanonTechDiscountEnabled = false.obs;
  final lebanonTechMinAmountController = TextEditingController();
  final lebanonTechDiscountPercentController = TextEditingController();
  final lebanonTechReferralPercentController = TextEditingController();

  // ============================================
  // Flash Deals Settings
  // ============================================
  var flashDealsLimitEnabled = false.obs;
  final flashDealsLimitPerStoreController = TextEditingController();
  final flashDealsTimeLimitController = TextEditingController();

  // ============================================
  // Shipping Settings
  // ============================================
  var globalFreeShippingEnabled = false.obs;
  final libanpostShippingCostController = TextEditingController();
  final libanpostShippingDaysFromController = TextEditingController();
  final libanpostShippingDaysToController = TextEditingController();

  // ============================================
  // WhatsApp Icons
  // ============================================
  final carsPageWhatsappUrlController = TextEditingController();
  final carsPageWhatsappTextController = TextEditingController();
  final homePageWhatsappUrlController = TextEditingController();
  final homePageWhatsappTextController = TextEditingController();

  // ============================================
  // Toggles
  // ============================================
  var resellerRegistrationEnabled = false.obs;
  var firstOrderDiscountEnabled = false.obs;
  var autoCheckInventoryEnabled = false.obs;
  var contestWinnerSelectionEnabled = false.obs;
  final contestWinnerTimeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    // Dispose all controllers
    websiteNameController.dispose();
    websiteDescriptionController.dispose();
    whatsappNumberController.dispose();
    supportEmailController.dispose();
    salesEmailController.dispose();
    googlePlayLinkController.dispose();
    appleStoreLinkController.dispose();
    adminCommissionController.dispose();
    minDiscountForDealsController.dispose();
    vendorsMaxProductsController.dispose();
    vendorsMaxCarsController.dispose();
    lebanonTechMinAmountController.dispose();
    lebanonTechDiscountPercentController.dispose();
    lebanonTechReferralPercentController.dispose();
    flashDealsLimitPerStoreController.dispose();
    flashDealsTimeLimitController.dispose();
    libanpostShippingCostController.dispose();
    libanpostShippingDaysFromController.dispose();
    libanpostShippingDaysToController.dispose();
    carsPageWhatsappUrlController.dispose();
    carsPageWhatsappTextController.dispose();
    homePageWhatsappUrlController.dispose();
    homePageWhatsappTextController.dispose();
    contestWinnerTimeController.dispose();
    super.onClose();
  }

  Future<void> fetchSettings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await ContentManagementService.fetchRawSettings();

      if (response.success && response.options != null) {
        _populateFromOptions(response.options!);
      } else {
        errorMessage.value = response.error ?? 'Failed to load settings';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFromOptions(Map<String, dynamic> data) {
    // Website Basic Info
    websiteNameController.text = data['website_name']?.toString() ?? '';
    websiteDescriptionController.text =
        data['website_description']?.toString() ?? '';
    whatsappNumberController.text =
        data['website_whatsapp_number']?.toString() ?? '';
    supportEmailController.text = data['website_email']?.toString() ?? '';
    salesEmailController.text = data['website_sales_email']?.toString() ?? '';

    // App Store Links
    googlePlayLinkController.text =
        data['tjara_app_google_play_store_link']?.toString() ?? '';
    appleStoreLinkController.text =
        data['tjara_app_apple_app_store_link']?.toString() ?? '';

    // Admin Settings
    adminCommissionController.text =
        data['website_admin_commision']?.toString() ?? '10';
    minDiscountForDealsController.text =
        data['min_discount_for_deals']?.toString() ?? '30';
    vendorsMaxProductsController.text =
        data['vendors_max_products_limit']?.toString() ?? '10';
    vendorsMaxCarsController.text =
        data['vendors_max_cars_limit']?.toString() ?? '2';

    // Lebanon Tech Discount
    final ltEnabled = data['lebanon_tech_discount_enabled']?.toString() ?? '0';
    lebanonTechDiscountEnabled.value = ltEnabled == '1' || ltEnabled == 'true';
    lebanonTechMinAmountController.text =
        data['lebanon_tech_minimum_amount']?.toString() ?? '50';
    lebanonTechDiscountPercentController.text =
        data['lebanon_tech_discount_percent']?.toString() ?? '10';
    lebanonTechReferralPercentController.text =
        data['lebanon_tech_referral_percent']?.toString() ?? '10';

    // Flash Deals
    flashDealsLimitEnabled.value =
        data['flash_deals_purchase_limit_enabled']?.toString() == '1';
    flashDealsLimitPerStoreController.text =
        data['flash_deals_purchase_limit_per_store']?.toString() ?? '100';
    flashDealsTimeLimitController.text =
        data['flash_deals_time_limit_hours']?.toString() ?? '24';

    // Shipping
    globalFreeShippingEnabled.value =
        data['global_free_shipping_enabled']?.toString() == '1';
    libanpostShippingCostController.text =
        data['libanpost_default_shipping_cost']?.toString() ?? '4';
    libanpostShippingDaysFromController.text =
        data['libanpost_shipping_days_from']?.toString() ?? '1';
    libanpostShippingDaysToController.text =
        data['libanpost_shipping_days_to']?.toString() ?? '3';

    // WhatsApp Icons
    carsPageWhatsappUrlController.text =
        data['cars_page_whatsapp_icon_url']?.toString() ?? '';
    carsPageWhatsappTextController.text =
        data['cars_page_whatsapp_icon_text']?.toString() ?? '';
    homePageWhatsappUrlController.text =
        data['homepage_whatsapp_icon_url']?.toString() ?? '';
    homePageWhatsappTextController.text =
        data['homepage_whatsapp_icon_text']?.toString() ?? '';

    // Toggles
    resellerRegistrationEnabled.value =
        data['reseller_registration_enabled']?.toString() == '1';
    firstOrderDiscountEnabled.value =
        data['first_order_discount_enabled']?.toString() == '1';
    autoCheckInventoryEnabled.value =
        data['auto_check_mark_product_inventory_when_stock_is_updated']
            ?.toString() ==
        '1';
    contestWinnerSelectionEnabled.value =
        data['contest_winner_selection_enabled']?.toString() == '1';
    contestWinnerTimeController.text =
        data['contest_winner_selection_time']?.toString() ?? '';
  }

  Future<void> fetchAllSettings() async {
    // Just call fetchSettings which now uses raw options
    await fetchSettings();
  }

  Future<bool> saveSettings() async {
    if (isSaving.value) return false;

    isSaving.value = true;

    try {
      print(websiteNameController.text);
      final settings = {
        'website_name': websiteNameController.text.trim(),
        'website_description': websiteDescriptionController.text.trim(),
        'website_whatsapp_number': whatsappNumberController.text.trim(),
        'website_email': supportEmailController.text.trim(),
        'website_sales_email': salesEmailController.text.trim(),
        'tjara_app_google_play_store_link':
            googlePlayLinkController.text.trim(),
        'tjara_app_apple_app_store_link': appleStoreLinkController.text.trim(),
        'website_admin_commision': adminCommissionController.text.trim(),
        'min_discount_for_deals': minDiscountForDealsController.text.trim(),
        'vendors_max_products_limit': vendorsMaxProductsController.text.trim(),
        'vendors_max_cars_limit': vendorsMaxCarsController.text.trim(),
        'lebanon_tech_discount_enabled':
            lebanonTechDiscountEnabled.value ? '1' : '0',
        'lebanon_tech_minimum_amount':
            lebanonTechMinAmountController.text.trim(),
        'lebanon_tech_discount_percent':
            lebanonTechDiscountPercentController.text.trim(),
        'lebanon_tech_referral_percent':
            lebanonTechReferralPercentController.text.trim(),
        'flash_deals_purchase_limit_enabled':
            flashDealsLimitEnabled.value ? '1' : '0',
        'flash_deals_purchase_limit_per_store':
            flashDealsLimitPerStoreController.text.trim(),
        'flash_deals_time_limit_hours':
            flashDealsTimeLimitController.text.trim(),
        'global_free_shipping_enabled':
            globalFreeShippingEnabled.value ? '1' : '0',
        'libanpost_default_shipping_cost':
            libanpostShippingCostController.text.trim(),
        'libanpost_shipping_days_from':
            libanpostShippingDaysFromController.text.trim(),
        'libanpost_shipping_days_to':
            libanpostShippingDaysToController.text.trim(),
        'cars_page_whatsapp_icon_url':
            carsPageWhatsappUrlController.text.trim(),
        'cars_page_whatsapp_icon_text':
            carsPageWhatsappTextController.text.trim(),
        'homepage_whatsapp_icon_url': homePageWhatsappUrlController.text.trim(),
        'homepage_whatsapp_icon_text':
            homePageWhatsappTextController.text.trim(),
        'reseller_registration_enabled':
            resellerRegistrationEnabled.value ? '1' : '0',
        'first_order_discount_enabled':
            firstOrderDiscountEnabled.value ? '1' : '0',
        'auto_check_mark_product_inventory_when_stock_is_updated':
            autoCheckInventoryEnabled.value ? '1' : '0',
        'contest_winner_selection_enabled':
            contestWinnerSelectionEnabled.value ? '1' : '0',
        'contest_winner_selection_time':
            contestWinnerTimeController.text.trim(),
      };

      final response = await ContentManagementService.updateSettings(settings);

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
