import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/helpers/api_exceptions.dart';
import 'package:tjara/app/models/website_settings/website_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/websettings_service/websetting_service.dart';

// Assuming WebsiteResponse and WebsiteOptions classes are imported from another file
// import 'models/website_model.dart';

// Assuming WebsiteResponse and WebsiteOptions classes are imported from another file
// import 'models/website_model.dart';

class WebsiteOptionsScreen extends StatefulWidget {
  const WebsiteOptionsScreen({super.key});

  @override
  State<WebsiteOptionsScreen> createState() => _WebsiteOptionsScreenState();
}

class _WebsiteOptionsScreenState extends State<WebsiteOptionsScreen> {
  final _formKey = GlobalKey<FormState>();
  late WebsiteOptions _websiteOptions;

  // Controllers for all text fields
  final _websiteNameController = TextEditingController();
  final _websiteDescriptionController = TextEditingController();
  final _websiteEmailController = TextEditingController();
  final _websiteWhatsappNumberController = TextEditingController();
  final _websiteAdminCommisionController = TextEditingController();
  final _websiteStatusController = TextEditingController();
  final _websiteDealsPercentageController = TextEditingController();

  // Lebanon Tech related controllers
  final _lebanonTechMinimumAmountController = TextEditingController();
  final _lebanonTechDiscountPercentageController = TextEditingController();
  bool _lebanonTechDiscountEnabled = false;

  // Vendor related controllers
  final _vendorsMaximumListingLimitController = TextEditingController();
  final _automaticResellerAccountCreationController = TextEditingController();

  // App store links
  final _tjaraAppGooglePlayStoreLinkController = TextEditingController();
  final _tjaraAppAppleAppStoreLinkController = TextEditingController();

  // Images and IDs
  final _websiteLogoUrlController = TextEditingController();
  final _websiteLogoIdController = TextEditingController();
  final _allCategoriesImageUrlController = TextEditingController();
  final _allCategoriesImageIdController = TextEditingController();

  // Popup related controllers
  final _websiteNewVisitorPopupTypeController = TextEditingController();
  final _websiteNewVisitorPopupStartDateController = TextEditingController();
  final _websiteNewVisitorPopupExpiryDateController = TextEditingController();
  final _websiteNewVisitorPopupBannerImageUrlController =
      TextEditingController();
  final _websiteNewVisitorPopupBannerImageIdController =
      TextEditingController();
  final _websiteNewVisitorPopupBannerImageLinkController =
      TextEditingController();

  // Feature promos
  final _websiteFeaturesPromo1Controller = TextEditingController();
  final _websiteFeaturesPromo2Controller = TextEditingController();
  final _websiteFeaturesPromo3Controller = TextEditingController();
  final _websiteFeaturesPromo4Controller = TextEditingController();
  final _websiteFeaturesPromoDirController = TextEditingController();

  // Sort orders
  final _headerStoriesSortOrderController = TextEditingController();
  final _featuredCarsSortOrderController = TextEditingController();
  final _featuredProductsSortOrderController = TextEditingController();
  final _saleProductsSortOrderController = TextEditingController();
  final _superDealsProductsSortOrderController = TextEditingController();

  // Notice related
  final _headerCategoriesController = TextEditingController();
  final _allProductsNoticeController = TextEditingController();
  final _allProductsNoticeDirController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with default values or values from the provided model
    fetchWeb();
    // _initializeControllers();
  }

  bool _hasChanges = false;
  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _attachChangeListenersToControllers() {
    final allControllers = [
      _websiteNameController,
      _websiteDescriptionController,
      _websiteEmailController,
      _websiteWhatsappNumberController,
      _websiteAdminCommisionController,
      _websiteStatusController,
      _websiteDealsPercentageController,
      _lebanonTechMinimumAmountController,
      _lebanonTechDiscountPercentageController,
      _vendorsMaximumListingLimitController,
      _automaticResellerAccountCreationController,
      _tjaraAppGooglePlayStoreLinkController,
      _tjaraAppAppleAppStoreLinkController,
      _websiteLogoUrlController,
      _websiteLogoIdController,
      _allCategoriesImageUrlController,
      _allCategoriesImageIdController,
      _websiteNewVisitorPopupTypeController,
      _websiteNewVisitorPopupStartDateController,
      _websiteNewVisitorPopupExpiryDateController,
      _websiteNewVisitorPopupBannerImageUrlController,
      _websiteNewVisitorPopupBannerImageIdController,
      _websiteNewVisitorPopupBannerImageLinkController,
      _websiteFeaturesPromo1Controller,
      _websiteFeaturesPromo2Controller,
      _websiteFeaturesPromo3Controller,
      _websiteFeaturesPromo4Controller,
      _websiteFeaturesPromoDirController,
      _headerStoriesSortOrderController,
      _featuredCarsSortOrderController,
      _featuredProductsSortOrderController,
      _saleProductsSortOrderController,
      _superDealsProductsSortOrderController,
      _headerCategoriesController,
      _allProductsNoticeController,
      _allProductsNoticeDirController,
    ];

    for (var controller in allControllers) {
      controller.addListener(_markAsChanged);
    }
  }

  Future<void> fetchWeb() async {
    final WebsiteOptionsService optionsService =
        Get.find<WebsiteOptionsService>();

    // Ensure website options are loaded
    if (optionsService.websiteOptions == null) {
      await optionsService.fetchWebsiteOptions();
    }

    setState(() {
      _websiteOptions = optionsService.websiteOptions ?? WebsiteOptions();
      _initializeControllers(); // Set controller values
      _attachChangeListenersToControllers(); // Listen for changes
    });
  }

  void _initializeControllers() {
    // Set values from model to controllers
    _websiteNameController.text = _websiteOptions.websiteName ?? '';
    _websiteDescriptionController.text =
        _websiteOptions.websiteDescription ?? '';
    _websiteEmailController.text = _websiteOptions.websiteEmail ?? '';
    _websiteWhatsappNumberController.text =
        _websiteOptions.websiteWhatsappNumber ?? '';
    _websiteAdminCommisionController.text =
        _websiteOptions.websiteAdminCommision ?? '10';
    _websiteStatusController.text = _websiteOptions.websiteStatus ?? '';
    _websiteDealsPercentageController.text =
        _websiteOptions.websiteDealsPercentage ?? '30';

    // Lebanon Tech
    _lebanonTechMinimumAmountController.text =
        _websiteOptions.lebanonTechMinimumAmount ?? '50';
    _lebanonTechDiscountPercentageController.text =
        _websiteOptions.lebanonTechDiscountPercentage ?? '10';
    _lebanonTechDiscountEnabled =
        _websiteOptions.lebanonTechDiscountEnabled?.toLowerCase() == 'true'
            ? true
            : false;

    // Vendor
    _vendorsMaximumListingLimitController.text =
        _websiteOptions.vendorsMaximumListingLimit ?? '5';
    _automaticResellerAccountCreationController.text =
        _websiteOptions.automaticResellerAccountCreation ?? '';

    // App store links
    _tjaraAppGooglePlayStoreLinkController.text =
        _websiteOptions.tjaraAppGooglePlayStoreLink ??
        'https://play.google.com/store/apps/details?id=com.wdp.www.tjaraapp&hl=en';
    _tjaraAppAppleAppStoreLinkController.text =
        _websiteOptions.tjaraAppAppleAppStoreLink ??
        'https://apps.apple.com/us/app/tjara/id1473913447';

    // Images and IDs
    _websiteLogoUrlController.text = _websiteOptions.websiteLogoUrl ?? '';
    _websiteLogoIdController.text = _websiteOptions.websiteLogoId ?? '';
    _allCategoriesImageUrlController.text =
        _websiteOptions.allCategoriesImageUrl ?? '';
    _allCategoriesImageIdController.text =
        _websiteOptions.allCategoriesImageId ?? '';

    // Popup related
    _websiteNewVisitorPopupTypeController.text =
        _websiteOptions.websiteNewVisitorPopupType ?? '';
    _websiteNewVisitorPopupStartDateController.text =
        _websiteOptions.websiteNewVisitorPopupStartDate ?? '';
    _websiteNewVisitorPopupExpiryDateController.text =
        _websiteOptions.websiteNewVisitorPopupExpiryDate ?? '';
    _websiteNewVisitorPopupBannerImageUrlController.text =
        _websiteOptions.websiteNewVisitorPopupBannerImageUrl ?? '';
    _websiteNewVisitorPopupBannerImageIdController.text =
        _websiteOptions.websiteNewVisitorPopupBannerImageId ?? '';
    _websiteNewVisitorPopupBannerImageLinkController.text =
        _websiteOptions.websiteNewVisitorPopupBannerImageLink ?? '';

    // Feature promos
    _websiteFeaturesPromo1Controller.text =
        _websiteOptions.websiteFeaturesPromo1 ?? '';
    _websiteFeaturesPromo2Controller.text =
        _websiteOptions.websiteFeaturesPromo2 ?? '';
    _websiteFeaturesPromo3Controller.text =
        _websiteOptions.websiteFeaturesPromo3 ?? '';
    _websiteFeaturesPromo4Controller.text =
        _websiteOptions.websiteFeaturesPromo4 ?? '';
    _websiteFeaturesPromoDirController.text =
        _websiteOptions.websiteFeaturesPromoDir ?? '';

    // Sort orders
    _headerStoriesSortOrderController.text =
        _websiteOptions.headerStoriesSortOrder ?? '';
    _featuredCarsSortOrderController.text =
        _websiteOptions.featuredCarsSortOrder ?? '';
    _featuredProductsSortOrderController.text =
        _websiteOptions.featuredProductsSortOrder ?? '';
    _saleProductsSortOrderController.text =
        _websiteOptions.saleProductsSortOrder ?? '';
    _superDealsProductsSortOrderController.text =
        _websiteOptions.superDealsProductsSortOrder ?? '';

    // Notice related
    _headerCategoriesController.text = _websiteOptions.headerCategories ?? '';
    _allProductsNoticeController.text = _websiteOptions.allProductsNotice ?? '';
    _allProductsNoticeDirController.text =
        _websiteOptions.allProductsNoticeDir ?? '';
  }

  @override
  void dispose() {
    // Dispose all controllers
    _websiteNameController.dispose();
    _websiteDescriptionController.dispose();
    _websiteEmailController.dispose();
    _websiteWhatsappNumberController.dispose();
    _websiteAdminCommisionController.dispose();
    _websiteStatusController.dispose();
    _websiteDealsPercentageController.dispose();

    _lebanonTechMinimumAmountController.dispose();
    _lebanonTechDiscountPercentageController.dispose();

    _vendorsMaximumListingLimitController.dispose();
    _automaticResellerAccountCreationController.dispose();

    _tjaraAppGooglePlayStoreLinkController.dispose();
    _tjaraAppAppleAppStoreLinkController.dispose();

    _websiteLogoUrlController.dispose();
    _websiteLogoIdController.dispose();
    _allCategoriesImageUrlController.dispose();
    _allCategoriesImageIdController.dispose();

    _websiteNewVisitorPopupTypeController.dispose();
    _websiteNewVisitorPopupStartDateController.dispose();
    _websiteNewVisitorPopupExpiryDateController.dispose();
    _websiteNewVisitorPopupBannerImageUrlController.dispose();
    _websiteNewVisitorPopupBannerImageIdController.dispose();
    _websiteNewVisitorPopupBannerImageLinkController.dispose();

    _websiteFeaturesPromo1Controller.dispose();
    _websiteFeaturesPromo2Controller.dispose();
    _websiteFeaturesPromo3Controller.dispose();
    _websiteFeaturesPromo4Controller.dispose();
    _websiteFeaturesPromoDirController.dispose();

    _headerStoriesSortOrderController.dispose();
    _featuredCarsSortOrderController.dispose();
    _featuredProductsSortOrderController.dispose();
    _saleProductsSortOrderController.dispose();
    _superDealsProductsSortOrderController.dispose();

    _headerCategoriesController.dispose();
    _allProductsNoticeController.dispose();
    _allProductsNoticeDirController.dispose();

    super.dispose();
  }

  bool _isLoading = false;
  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final body = {
      // Website General Info
      "website_name": _websiteNameController.text.trim(),
      "website_description": _websiteDescriptionController.text.trim(),
      "website_email": _websiteEmailController.text.trim(),
      "website_whatsapp_number": _websiteWhatsappNumberController.text.trim(),
      "website_admin_commision": _websiteAdminCommisionController.text.trim(),
      "website_status": _websiteStatusController.text.trim(),
      "website_deals_percentage": _websiteDealsPercentageController.text.trim(),

      // Lebanon Tech
      "lebanon_tech_minimum_amount":
          _lebanonTechMinimumAmountController.text.trim(),
      "lebanon_tech_discount_percentage":
          _lebanonTechDiscountPercentageController.text.trim(),
      "lebanon_tech_discount_enabled": _lebanonTechDiscountEnabled.toString(),

      // Vendor
      "vendors_maximum_listing_limit":
          _vendorsMaximumListingLimitController.text.trim(),
      "automatic_reseller_account_creation":
          _automaticResellerAccountCreationController.text.trim(),

      // App Store Links
      "tjara_app_google_play_store_link":
          _tjaraAppGooglePlayStoreLinkController.text.trim(),
      "tjara_app_apple_app_store_link":
          _tjaraAppAppleAppStoreLinkController.text.trim(),

      // Images
      "website_logo_url": _websiteLogoUrlController.text.trim(),
      "website_logo_id": _websiteLogoIdController.text.trim(),
      "all_categories_image_url": _allCategoriesImageUrlController.text.trim(),
      "all_categories_image_id": _allCategoriesImageIdController.text.trim(),

      // Popup
      "website_new_visitor_popup_type":
          _websiteNewVisitorPopupTypeController.text.trim(),
      "website_new_visitor_popup_start_date":
          _websiteNewVisitorPopupStartDateController.text.trim(),
      "website_new_visitor_popup_expiry_date":
          _websiteNewVisitorPopupExpiryDateController.text.trim(),
      "website_new_visitor_popup_banner_image_url":
          _websiteNewVisitorPopupBannerImageUrlController.text.trim(),
      "website_new_visitor_popup_banner_image_id":
          _websiteNewVisitorPopupBannerImageIdController.text.trim(),
      "website_new_visitor_popup_banner_image_link":
          _websiteNewVisitorPopupBannerImageLinkController.text.trim(),

      // Promos
      "website_features_promo1": _websiteFeaturesPromo1Controller.text.trim(),
      "website_features_promo2": _websiteFeaturesPromo2Controller.text.trim(),
      "website_features_promo3": _websiteFeaturesPromo3Controller.text.trim(),
      "website_features_promo4": _websiteFeaturesPromo4Controller.text.trim(),
      "website_features_promo_dir":
          _websiteFeaturesPromoDirController.text.trim(),

      // Sort Orders
      "header_stories_sort_order":
          _headerStoriesSortOrderController.text.trim(),
      "featured_cars_sort_order": _featuredCarsSortOrderController.text.trim(),
      "featured_products_sort_order":
          _featuredProductsSortOrderController.text.trim(),
      "sale_products_sort_order": _saleProductsSortOrderController.text.trim(),
      "super_deals_products_sort_order":
          _superDealsProductsSortOrderController.text.trim(),

      // Notices
      "header_categories": _headerCategoriesController.text.trim(),
      "all_products_notice": _allProductsNoticeController.text.trim(),
      "all_products_notice_dir": _allProductsNoticeDirController.text.trim(),
    };

    try {
      await putData(
        url: 'https://api.libanbuy.com/api/settings/update',
        body: body,
        fromJson: null,
      );

      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });
      Get.snackbar('Successful', 'Settings saved successfully!');
    } catch (e) {
      setState(() => _isLoading = false);

      Get.snackbar('Failed', 'Failed to save settings!');
    }
  }

  Future<T> putData<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    final fullUrl = url;

    try {
      final response = await http
          .put(
            Uri.parse(fullUrl).replace(queryParameters: queryParameters),
            headers: {
              'Content-Type': 'application/json',
              'X-Request-From': 'Application',
              'shop-id':
                  AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
              'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
            },
            body: json.encode(body),
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (fromJson == null || response.body.isEmpty) {
          return {} as T; // If no response body or mapping required
        }
        return fromJson(json.decode(response.body));
      } else {
        throw ApiException(
          'Failed to update data: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      throw ApiException('Request timed out');
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Website General Information Section
              _buildSectionHeader('Website General Information', true),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabeledTextField(
                        'Website Name',
                        _websiteNameController,
                        true,
                      ),
                      _buildLabeledTextField(
                        'Website Description',
                        _websiteDescriptionController,
                        false,
                        maxLines: 7,
                      ),
                      _buildLabeledTextField(
                        'Website Email',
                        _websiteEmailController,
                        true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildLabeledTextField(
                        'Website WhatsApp Number',
                        _websiteWhatsappNumberController,
                        false,
                      ),
                      _buildLabeledTextField(
                        'Website Status',
                        _websiteStatusController,
                        false,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Admin Commission Section
              _buildSectionHeader('Admin Commission', true),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The admin commission in percentage specified here will be deducted from each order created on the Tjara Platform.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _websiteAdminCommisionController,
                        keyboardType: TextInputType.number,
                        validator: _requiredValidator,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Lebanon Tech Discount Settings
              _buildSectionHeader('Lebanon Tech Discount Settings', true),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configure the special discount for Lebanon Tech products when customers shop at Tjara Store',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 16),

                      // Enable Lebanon Tech Discount Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _lebanonTechDiscountEnabled,
                            onChanged: (value) {
                              setState(() {
                                _lebanonTechDiscountEnabled = value ?? false;
                                _markAsChanged();
                              });
                            },
                            activeColor: const Color(0xFFF97316),
                          ),
                          const Text('Enable Lebanon Tech Discount'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Lebanon Tech Settings
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Minimum Purchase Amount at Tjara Store (\$)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _lebanonTechMinimumAmountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Discount Percentage (%)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller:
                                _lebanonTechDiscountPercentageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Minimum Discount Section
              _buildSectionHeader(
                'Minimum Discount in % on product for Deals Eligibility',
                true,
              ),
              const SizedBox(height: 8),
              _buildSectionDescription(
                'This sets the minimum percentage discount a product must have to be eligible for the deals section.',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _websiteDealsPercentageController,
                keyboardType: TextInputType.number,
                validator: _requiredValidator,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),

              // Vendors maximum listing limit
              _buildSectionHeader('Vendors maximum listing limit', true),
              const SizedBox(height: 8),
              _buildSectionDescription(
                'This sets the maximum number of listings a vendor can publish before verification.',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _vendorsMaximumListingLimitController,
                keyboardType: TextInputType.number,
                validator: _requiredValidator,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),

              // Automatic Reseller Account Creation
              _buildSectionHeader('Automatic Reseller Account Creation', false),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _automaticResellerAccountCreationController,
              ),
              const SizedBox(height: 24),

              // Tjara Google Play store link
              _buildSectionHeader('Tjara Google Play store link', true),
              const SizedBox(height: 8),
              _buildSectionDescription(
                'Add the google play store link of Tjara app here.',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _tjaraAppGooglePlayStoreLinkController,
                keyboardType: TextInputType.url,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 24),

              // Tjara Apple App store link
              _buildSectionHeader('Tjara Apple App store link', true),
              const SizedBox(height: 8),
              _buildSectionDescription(
                'Add the Apple app store link of Tjara app here.',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _tjaraAppAppleAppStoreLinkController,
                keyboardType: TextInputType.url,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 24),

              // Images Section
              _buildSectionHeader('Website Images', false),
              const SizedBox(height: 12),

              _buildLabeledTextField(
                'Website Logo URL',
                _websiteLogoUrlController,
                false,
              ),
              _buildLabeledTextField(
                'Website Logo ID',
                _websiteLogoIdController,
                false,
              ),
              _buildLabeledTextField(
                'All Categories Image URL',
                _allCategoriesImageUrlController,
                false,
              ),
              _buildLabeledTextField(
                'All Categories Image ID',
                _allCategoriesImageIdController,
                false,
              ),

              const SizedBox(height: 24),

              // Popup Settings
              _buildSectionHeader('New Visitor Popup Settings', false),
              const SizedBox(height: 12),

              _buildLabeledTextField(
                'Popup Type',
                _websiteNewVisitorPopupTypeController,
                false,
              ),
              _buildLabeledTextField(
                'Popup Start Date',
                _websiteNewVisitorPopupStartDateController,
                false,
              ),
              _buildLabeledTextField(
                'Popup Expiry Date',
                _websiteNewVisitorPopupExpiryDateController,
                false,
              ),
              _buildLabeledTextField(
                'Popup Banner Image URL',
                _websiteNewVisitorPopupBannerImageUrlController,
                false,
              ),
              _buildLabeledTextField(
                'Popup Banner Image ID',
                _websiteNewVisitorPopupBannerImageIdController,
                false,
              ),
              _buildLabeledTextField(
                'Popup Banner Image Link',
                _websiteNewVisitorPopupBannerImageLinkController,
                false,
              ),

              const SizedBox(height: 24),

              // Features Promo
              _buildSectionHeader('Website Features Promos', false),
              const SizedBox(height: 12),

              _buildLabeledTextField(
                'Features Promo 1',
                _websiteFeaturesPromo1Controller,
                false,
              ),
              _buildLabeledTextField(
                'Features Promo 2',
                _websiteFeaturesPromo2Controller,
                false,
              ),
              _buildLabeledTextField(
                'Features Promo 3',
                _websiteFeaturesPromo3Controller,
                false,
              ),
              _buildLabeledTextField(
                'Features Promo 4',
                _websiteFeaturesPromo4Controller,
                false,
              ),
              _buildLabeledTextField(
                'Features Promo Directory',
                _websiteFeaturesPromoDirController,
                false,
              ),

              const SizedBox(height: 24),

              // Sort Orders
              _buildSectionHeader('Sort Orders', false),
              const SizedBox(height: 12),

              _buildLabeledTextField(
                'Header Stories Sort Order',
                _headerStoriesSortOrderController,
                false,
              ),
              _buildLabeledTextField(
                'Featured Cars Sort Order',
                _featuredCarsSortOrderController,
                false,
              ),
              _buildLabeledTextField(
                'Featured Products Sort Order',
                _featuredProductsSortOrderController,
                false,
              ),
              _buildLabeledTextField(
                'Sale Products Sort Order',
                _saleProductsSortOrderController,
                false,
              ),
              _buildLabeledTextField(
                'Super Deals Products Sort Order',
                _superDealsProductsSortOrderController,
                false,
              ),

              const SizedBox(height: 24),

              // Notices
              _buildSectionHeader('Notices & Categories', false),
              const SizedBox(height: 12),

              _buildLabeledTextField(
                'Header Categories',
                _headerCategoriesController,
                false,
              ),
              _buildLabeledTextField(
                'All Products Notice',
                _allProductsNoticeController,
                false,
                maxLines: 3,
              ),
              _buildLabeledTextField(
                'All Products Notice Directory',
                _allProductsNoticeDirController,
                false,
              ),

              const SizedBox(height: 32),

              // Save Button
              if (_hasChanges)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      'Save Settings',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widgets
  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildSectionHeader(String text, bool isRequired) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Header (separate padded container inside card)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97316).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Required',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDescription(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF97316)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildLabeledTextField(
    String label,
    TextEditingController controller,
    bool isRequired, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: controller,
            keyboardType: keyboardType,
            validator: isRequired ? _requiredValidator : null,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }

  // Validators
  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
