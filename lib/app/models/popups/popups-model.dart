import 'package:tjara/app/models/media_model/media_model.dart';
import 'package:tjara/app/models/products/products_model.dart';

class PopUpModels {
  Popups? popups;

  PopUpModels({this.popups});

  PopUpModels.fromJson(Map<String, dynamic> json) {
    popups = json['popups'] != null ? Popups.fromJson(json['popups']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (popups != null) {
      data['popups'] = popups!.toJson();
    }
    return data;
  }
}

class Popups {
  int? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl; // Changed from Null to String?
  int? to;
  int? total;

  Popups({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  Popups.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];

    // Fixed: Add type safety check for data
    if (json['data'] != null && json['data'] is List) {
      data = <Data>[];
      for (var v in (json['data'] as List)) {
        if (v is Map<String, dynamic>) {
          data!.add(Data.fromJson(v));
        }
      }
    }

    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class Data {
  String? id;
  String? slug;
  String? shopId;
  String? name;
  String? description; // Changed from Null to String?
  String? thumbnailId;
  String? type;
  String? pageLocation;
  String? linkUrl;
  bool? isActive;
  String? startTime;
  String? endTime;
  List<dynamic>? formFields; // Changed from List<Null>? to List<dynamic>?
  int? displayDelay;
  bool? showOncePerSession;
  int? displayInCategories;
  String? categoryIds;
  int? views;
  int? clicks;
  int? addToCartClicks;
  int? viewDetailsClicks;
  int? conversions;
  String? createdAt;
  String? updatedAt;
  bool? isAbTest;
  String? userSegment;
  String? abTestMethod;
  int? abTestViewsLimit;
  String? variantBThumbnailId;
  String? variantBLinkUrl;
  int? abVariantAViews;
  int? abVariantAClicks;
  int? variantAAddToCartClicks;
  int? variantAViewDetailsClicks;
  int? abVariantAConversions;
  int? abVariantBViews;
  int? abVariantBClicks;
  int? variantBAddToCartClicks;
  int? variantBViewDetailsClicks;
  int? abVariantBConversions;
  String? abTestStartTime;
  String? abTestEndTime;
  String? abTestWinner;
  bool? abTestAutoSelectWinner;
  bool? abTestCompleted;
  String? linkType;
  String? linkedPopupId;
  String? variantBLinkType;
  String? variantBLinkedPopupId;
  int? popupId;
  String? productId;
  String? productName;
  String? productPrice;
  ProductThumbnail? thumbnail;
  ProductThumbnail? productThumbnail;
  ShopShop? shop;
  ProductThumbnail? variantBThumbnail;
  List<String>? categoryNames;
  List<String>? selectedCategories;
  // Analytics fields
  double? clickRate;
  double? conversionRate;
  double? addToCartRate;
  double? viewDetailsRate;
  int? totalInteractions;
  int? totalViews;
  String? performanceStatus;
  String? lastInteractionAt;
  int? uniqueSessions;
  int? uniqueUsers;
  // A/B test analytics
  double? variantAClickRate;
  double? variantAConversionRate;
  double? variantBClickRate;
  double? variantBConversionRate;

  Data({
    this.id,
    this.slug,
    this.shopId,
    this.name,
    this.description,
    this.thumbnailId,
    this.type,
    this.pageLocation,
    this.linkUrl,
    this.isActive,
    this.startTime,
    this.endTime,
    this.formFields,
    this.displayDelay,
    this.showOncePerSession,
    this.displayInCategories,
    this.categoryIds,
    this.views,
    this.clicks,
    this.addToCartClicks,
    this.viewDetailsClicks,
    this.conversions,
    this.createdAt,
    this.updatedAt,
    this.isAbTest,
    this.userSegment,
    this.abTestMethod,
    this.abTestViewsLimit,
    this.variantBThumbnailId,
    this.variantBLinkUrl,
    this.abVariantAViews,
    this.abVariantAClicks,
    this.variantAAddToCartClicks,
    this.variantAViewDetailsClicks,
    this.abVariantAConversions,
    this.abVariantBViews,
    this.abVariantBClicks,
    this.variantBAddToCartClicks,
    this.variantBViewDetailsClicks,
    this.abVariantBConversions,
    this.abTestStartTime,
    this.abTestEndTime,
    this.abTestWinner,
    this.abTestAutoSelectWinner,
    this.abTestCompleted,
    this.linkType,
    this.linkedPopupId,
    this.variantBLinkType,
    this.variantBLinkedPopupId,
    this.popupId,
    this.productId,
    this.productName,
    this.productPrice,
    this.thumbnail,
    this.productThumbnail,
    this.shop,
    this.variantBThumbnail,
    this.categoryNames,
    this.selectedCategories,
    this.clickRate,
    this.conversionRate,
    this.addToCartRate,
    this.viewDetailsRate,
    this.totalInteractions,
    this.totalViews,
    this.performanceStatus,
    this.lastInteractionAt,
    this.uniqueSessions,
    this.uniqueUsers,
    this.variantAClickRate,
    this.variantAConversionRate,
    this.variantBClickRate,
    this.variantBConversionRate,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    shopId = json['shop_id'];
    name = json['name'];
    description = json['description'];
    thumbnailId = json['thumbnail_id'];
    type = json['type'];
    pageLocation = json['page_location'];
    linkUrl = json['link_url'];
    isActive = _toBool(json['is_active']);
    startTime = json['start_time'];
    endTime = json['end_time'];

    // Handle formFields safely
    if (json['form_fields'] != null && json['form_fields'] is List) {
      formFields = json['form_fields'];
    }

    displayDelay = json['display_delay'];
    showOncePerSession = _toBool(json['show_once_per_session']);
    displayInCategories = json['display_in_categories'];
    categoryIds = json['category_ids'];
    views = json['views'];
    clicks = json['clicks'];
    addToCartClicks = json['add_to_cart_clicks'];
    viewDetailsClicks = json['view_details_clicks'];
    conversions = json['conversions'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isAbTest = _toBool(json['is_ab_test']);
    userSegment = json['user_segment'];
    abTestMethod = json['ab_test_method'];
    abTestViewsLimit = json['ab_test_views_limit'];
    variantBThumbnailId = json['variant_b_thumbnail_id'];
    variantBLinkUrl = json['variant_b_link_url'];
    abVariantAViews = json['ab_variant_a_views'];
    abVariantAClicks = json['ab_variant_a_clicks'];
    variantAAddToCartClicks = json['variant_a_add_to_cart_clicks'];
    variantAViewDetailsClicks = json['variant_a_view_details_clicks'];
    abVariantAConversions = json['ab_variant_a_conversions'];
    abVariantBViews = json['ab_variant_b_views'];
    abVariantBClicks = json['ab_variant_b_clicks'];
    variantBAddToCartClicks = json['variant_b_add_to_cart_clicks'];
    variantBViewDetailsClicks = json['variant_b_view_details_clicks'];
    abVariantBConversions = json['ab_variant_b_conversions'];
    abTestStartTime = json['ab_test_start_time'];
    abTestEndTime = json['ab_test_end_time'];
    abTestWinner = json['ab_test_winner'];
    abTestAutoSelectWinner = _toBool(json['ab_test_auto_select_winner']);
    abTestCompleted = _toBool(json['ab_test_completed']);
    linkType = json['link_type'];
    linkedPopupId = json['linked_popup_id'];
    variantBLinkType = json['variant_b_link_type'];
    variantBLinkedPopupId = json['variant_b_linked_popup_id'];
    popupId = json['popup_id'];
    productId = json['product_id'];
    productName = json['product_name'];
    productPrice = json['product_price']?.toString();

    // thumbnail can be a Map with media, or an empty List []
    if (json['thumbnail'] != null && json['thumbnail'] is Map<String, dynamic>) {
      thumbnail = ProductThumbnail.fromJson(json['thumbnail']);
    }
    if (json['product_thumbnail'] != null && json['product_thumbnail'] is Map<String, dynamic>) {
      productThumbnail = ProductThumbnail.fromJson(json['product_thumbnail']);
    }
    if (json['variant_b_thumbnail'] != null && json['variant_b_thumbnail'] is Map<String, dynamic>) {
      variantBThumbnail = ProductThumbnail.fromJson(json['variant_b_thumbnail']);
    }

    // shop is wrapped in {"original": {...}} in the API
    if (json['shop'] != null && json['shop'] is Map<String, dynamic>) {
      final shopData = json['shop'];
      if (shopData.containsKey('original') && shopData['original'] is Map<String, dynamic>) {
        shop = ShopShop.fromJson(shopData['original']);
      } else {
        shop = ShopShop.fromJson(shopData);
      }
    }

    // Parse category_names
    if (json['category_names'] != null && json['category_names'] is List) {
      categoryNames = List<String>.from(json['category_names']);
    }
    if (json['selected_categories'] != null && json['selected_categories'] is List) {
      selectedCategories = List<String>.from(json['selected_categories']);
    }

    // Analytics fields
    clickRate = _toDouble(json['click_rate']);
    conversionRate = _toDouble(json['conversion_rate']);
    addToCartRate = _toDouble(json['add_to_cart_rate']);
    viewDetailsRate = _toDouble(json['view_details_rate']);
    totalInteractions = json['total_interactions'];
    totalViews = json['total_views'];
    performanceStatus = json['performance_status'];
    lastInteractionAt = json['last_interaction_at'];
    uniqueSessions = json['unique_sessions'];
    uniqueUsers = json['unique_users'];
    // A/B test analytics
    variantAClickRate = _toDouble(json['variant_a_click_rate']);
    variantAConversionRate = _toDouble(json['variant_a_conversion_rate']);
    variantBClickRate = _toDouble(json['variant_b_click_rate']);
    variantBConversionRate = _toDouble(json['variant_b_conversion_rate']);
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value == 'true';
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['slug'] = slug;
    data['shop_id'] = shopId;
    data['name'] = name;
    data['description'] = description;
    data['thumbnail_id'] = thumbnailId;
    data['type'] = type;
    data['page_location'] = pageLocation;
    data['link_url'] = linkUrl;
    data['is_active'] = isActive;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['form_fields'] = formFields;
    data['display_delay'] = displayDelay;
    data['show_once_per_session'] = showOncePerSession;
    data['display_in_categories'] = displayInCategories;
    data['category_ids'] = categoryIds;
    data['views'] = views;
    data['clicks'] = clicks;
    data['add_to_cart_clicks'] = addToCartClicks;
    data['view_details_clicks'] = viewDetailsClicks;
    data['conversions'] = conversions;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_ab_test'] = isAbTest;
    data['user_segment'] = userSegment;
    data['ab_test_method'] = abTestMethod;
    data['ab_test_views_limit'] = abTestViewsLimit;
    data['variant_b_thumbnail_id'] = variantBThumbnailId;
    data['variant_b_link_url'] = variantBLinkUrl;
    data['ab_variant_a_views'] = abVariantAViews;
    data['ab_variant_a_clicks'] = abVariantAClicks;
    data['variant_a_add_to_cart_clicks'] = variantAAddToCartClicks;
    data['variant_a_view_details_clicks'] = variantAViewDetailsClicks;
    data['ab_variant_a_conversions'] = abVariantAConversions;
    data['ab_variant_b_views'] = abVariantBViews;
    data['ab_variant_b_clicks'] = abVariantBClicks;
    data['variant_b_add_to_cart_clicks'] = variantBAddToCartClicks;
    data['variant_b_view_details_clicks'] = variantBViewDetailsClicks;
    data['ab_variant_b_conversions'] = abVariantBConversions;
    data['ab_test_start_time'] = abTestStartTime;
    data['ab_test_end_time'] = abTestEndTime;
    data['ab_test_winner'] = abTestWinner;
    data['ab_test_auto_select_winner'] = abTestAutoSelectWinner;
    data['ab_test_completed'] = abTestCompleted;
    data['link_type'] = linkType;
    data['linked_popup_id'] = linkedPopupId;
    data['variant_b_link_type'] = variantBLinkType;
    data['variant_b_linked_popup_id'] = variantBLinkedPopupId;
    data['popup_id'] = popupId;
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['product_price'] = productPrice;
    if (thumbnail != null) {
      data['thumbnail'] = thumbnail!.toJson();
    }
    if (productThumbnail != null) {
      data['product_thumbnail'] = productThumbnail!.toJson();
    }
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    if (variantBThumbnail != null) {
      data['variant_b_thumbnail'] = variantBThumbnail!.toJson();
    }
    if (categoryNames != null) {
      data['category_names'] = categoryNames;
    }
    if (selectedCategories != null) {
      data['selected_categories'] = selectedCategories;
    }
    return data;
  }
}

class Thumbnail {
  String? message;
  MediaUniversalModel? media;

  Thumbnail({this.message, this.media});

  Thumbnail.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    media =
        json['media'] != null
            ? MediaUniversalModel.fromJson(json['media'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (media != null) {
      data['media'] = media!.toJson();
    }
    return data;
  }
}

class ProductThumbnail {
  MediaUniversalModel? media;

  ProductThumbnail({this.media});

  ProductThumbnail.fromJson(Map<String, dynamic> json) {
    media =
        json['media'] != null
            ? MediaUniversalModel.fromJson(json['media'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (media != null) {
      data['media'] = media!.toJson();
    }
    return data;
  }
}
