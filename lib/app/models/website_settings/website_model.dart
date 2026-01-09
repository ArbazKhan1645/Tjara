class WebsiteResponse {
  final WebsiteOptions options;

  WebsiteResponse({
    required this.options,
  });

  factory WebsiteResponse.fromJson(Map<String, dynamic> json) {
    return WebsiteResponse(
      options: WebsiteOptions.fromJson(json['options'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'options': options.toJson(),
    };
  }
}

class WebsiteOptions {
  final String? websiteNewVisitorPopupBannerImageUrl;
  final String? allCategoriesImageUrl;
  final String? allCategoriesImageId;
  final String? automaticResellerAccountCreation;
  final String? websiteName;
  final String? lebanonTechDiscountPercentage;
  final String? websiteFeaturesPromo3;
  final String? headerStoriesSortOrder;
  final String? websiteDealsPercentage;
  final String? lebanonTechDiscountEnabled;
  final String? featuredCarsSortOrder;
  final String? websiteNewVisitorPopupBannerImageId;
  final String? websiteFeaturesPromo1;
  final String? vendorsMaximumListingLimit;
  final String? featuredProductsSortOrder;
  final String? saleProductsSortOrder;
  final String? websiteNewVisitorPopupType;
  final String? websiteNewVisitorPopupStartDate;
  final String? websiteFeaturesPromoDir;
  final String? websiteLogoUrl;
  final String? superDealsProductsSortOrder;
  final String? allProductsNoticeDir;
  final String? websiteDescription;
  final String? websiteFeaturesPromo4;
  final String? websiteNewVisitorPopupExpiryDate;
  final String? tjaraAppAppleAppStoreLink;
  final String? lebanonTechMinimumAmount;
  final String? tjaraAppGooglePlayStoreLink;
  final String? websiteAdminCommision;
  final String? allProductsNotice;
  final String? websiteLogoId;
  final String? websiteWhatsappNumber;
  final String? headerCategories;
  final String? websiteEmail;
  final String? websiteNewVisitorPopupBannerImageLink;
  final String? websiteFeaturesPromo2;
  final String? websiteStatus;

  WebsiteOptions({
    this.websiteNewVisitorPopupBannerImageUrl,
    this.allCategoriesImageUrl,
    this.allCategoriesImageId,
    this.automaticResellerAccountCreation,
    this.websiteName,
    this.lebanonTechDiscountPercentage,
    this.websiteFeaturesPromo3,
    this.headerStoriesSortOrder,
    this.websiteDealsPercentage,
    this.lebanonTechDiscountEnabled,
    this.featuredCarsSortOrder,
    this.websiteNewVisitorPopupBannerImageId,
    this.websiteFeaturesPromo1,
    this.vendorsMaximumListingLimit,
    this.featuredProductsSortOrder,
    this.saleProductsSortOrder,
    this.websiteNewVisitorPopupType,
    this.websiteNewVisitorPopupStartDate,
    this.websiteFeaturesPromoDir,
    this.websiteLogoUrl,
    this.superDealsProductsSortOrder,
    this.allProductsNoticeDir,
    this.websiteDescription,
    this.websiteFeaturesPromo4,
    this.websiteNewVisitorPopupExpiryDate,
    this.tjaraAppAppleAppStoreLink,
    this.lebanonTechMinimumAmount,
    this.tjaraAppGooglePlayStoreLink,
    this.websiteAdminCommision,
    this.allProductsNotice,
    this.websiteLogoId,
    this.websiteWhatsappNumber,
    this.headerCategories,
    this.websiteEmail,
    this.websiteNewVisitorPopupBannerImageLink,
    this.websiteFeaturesPromo2,
    this.websiteStatus,
  });

  factory WebsiteOptions.fromJson(Map<String, dynamic> json) {
    return WebsiteOptions(
      websiteNewVisitorPopupBannerImageUrl:
          json['website_new_visitor_popup_banner_image_url'],
      allCategoriesImageUrl: json['all_categories_image_url'],
      allCategoriesImageId: json['all_categories_image_id'],
      automaticResellerAccountCreation:
          json['automatic_reseller_account_creation'],
      websiteName: json['website_name'],
      lebanonTechDiscountPercentage: json['lebanon_tech_discount_percentage'],
      websiteFeaturesPromo3: json['website_features_promo3'],
      headerStoriesSortOrder: json['header_stories_sort_order'],
      websiteDealsPercentage: json['website_deals_percentage'],
      lebanonTechDiscountEnabled: json['lebanon_tech_discount_enabled'],
      featuredCarsSortOrder: json['featured_cars_sort_order'],
      websiteNewVisitorPopupBannerImageId:
          json['website_new_visitor_popup_banner_image_id'],
      websiteFeaturesPromo1: json['website_features_promo1'],
      vendorsMaximumListingLimit: json['vendors_maximum_listing_limit'],
      featuredProductsSortOrder: json['featured_products_sort_order'],
      saleProductsSortOrder: json['sale_products_sort_order'],
      websiteNewVisitorPopupType: json['website_new_visitor_popup_type'],
      websiteNewVisitorPopupStartDate:
          json['website_new_visitor_popup_start_date'],
      websiteFeaturesPromoDir: json['website_features_promo_dir'],
      websiteLogoUrl: json['website_logo_url'],
      superDealsProductsSortOrder: json['super_deals_products_sort_order'],
      allProductsNoticeDir: json['all_products_notice_dir'],
      websiteDescription: json['website_description'],
      websiteFeaturesPromo4: json['website_features_promo4'],
      websiteNewVisitorPopupExpiryDate:
          json['website_new_visitor_popup_expiry_date'],
      tjaraAppAppleAppStoreLink: json['tjara_app_apple_app_store_link'],
      lebanonTechMinimumAmount: json['lebanon_tech_minimum_amount'],
      tjaraAppGooglePlayStoreLink: json['tjara_app_google_play_store_link'],
      websiteAdminCommision: json['website_admin_commision'],
      allProductsNotice: json['all_products_notice'],
      websiteLogoId: json['website_logo_id'],
      websiteWhatsappNumber: json['website_whatsapp_number'],
      headerCategories: json['header_categories'],
      websiteEmail: json['website_email'],
      websiteNewVisitorPopupBannerImageLink:
          json['website_new_visitor_popup_banner_image_link'],
      websiteFeaturesPromo2: json['website_features_promo2'],
      websiteStatus: json['website_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'website_new_visitor_popup_banner_image_url':
          websiteNewVisitorPopupBannerImageUrl,
      'all_categories_image_url': allCategoriesImageUrl,
      'all_categories_image_id': allCategoriesImageId,
      'automatic_reseller_account_creation': automaticResellerAccountCreation,
      'website_name': websiteName,
      'lebanon_tech_discount_percentage': lebanonTechDiscountPercentage,
      'website_features_promo3': websiteFeaturesPromo3,
      'header_stories_sort_order': headerStoriesSortOrder,
      'website_deals_percentage': websiteDealsPercentage,
      'lebanon_tech_discount_enabled': lebanonTechDiscountEnabled,
      'featured_cars_sort_order': featuredCarsSortOrder,
      'website_new_visitor_popup_banner_image_id':
          websiteNewVisitorPopupBannerImageId,
      'website_features_promo1': websiteFeaturesPromo1,
      'vendors_maximum_listing_limit': vendorsMaximumListingLimit,
      'featured_products_sort_order': featuredProductsSortOrder,
      'sale_products_sort_order': saleProductsSortOrder,
      'website_new_visitor_popup_type': websiteNewVisitorPopupType,
      'website_new_visitor_popup_start_date': websiteNewVisitorPopupStartDate,
      'website_features_promo_dir': websiteFeaturesPromoDir,
      'website_logo_url': websiteLogoUrl,
      'super_deals_products_sort_order': superDealsProductsSortOrder,
      'all_products_notice_dir': allProductsNoticeDir,
      'website_description': websiteDescription,
      'website_features_promo4': websiteFeaturesPromo4,
      'website_new_visitor_popup_expiry_date': websiteNewVisitorPopupExpiryDate,
      'tjara_app_apple_app_store_link': tjaraAppAppleAppStoreLink,
      'lebanon_tech_minimum_amount': lebanonTechMinimumAmount,
      'tjara_app_google_play_store_link': tjaraAppGooglePlayStoreLink,
      'website_admin_commision': websiteAdminCommision,
      'all_products_notice': allProductsNotice,
      'website_logo_id': websiteLogoId,
      'website_whatsapp_number': websiteWhatsappNumber,
      'header_categories': headerCategories,
      'website_email': websiteEmail,
      'website_new_visitor_popup_banner_image_link':
          websiteNewVisitorPopupBannerImageLink,
      'website_features_promo2': websiteFeaturesPromo2,
      'website_status': websiteStatus,
    };
  }
}
