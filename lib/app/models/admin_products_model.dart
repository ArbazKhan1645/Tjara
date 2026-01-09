import 'dart:convert';

class AdminProductsModel {
  final ProductsModel? products;
  final String? query;
  final List<dynamic>? bindings;
  final dynamic metadata;

  AdminProductsModel({this.products, this.query, this.bindings, this.metadata});

  factory AdminProductsModel.fromJson(Map<String, dynamic> json) {
    return AdminProductsModel(
      products:
          json['products'] != null
              ? ProductsModel.fromJson(json['products'])
              : null,
      query: json['query'] as String?,
      bindings:
          json['bindings'] != null
              ? List<dynamic>.from(json['bindings'])
              : null,
      metadata: json['metadata'],
    );
  }

  static AdminProductsModel parse(String response) {
    final json = jsonDecode(response);
    return AdminProductsModel.fromJson(json);
  }
}

class ProductsModel {
  final int? currentPage;
  final List<AdminProducts>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  ProductsModel({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json) {
    return ProductsModel(
      currentPage: json['current_page'] as int?,
      data:
          json['data'] != null
              ? List<AdminProducts>.from(
                json['data'].map((x) => AdminProducts.fromJson(x)),
              )
              : null,
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int?,
      lastPageUrl: json['last_page_url'] as String?,
      links:
          json['links'] != null
              ? List<Link>.from(json['links'].map((x) => Link.fromJson(x)))
              : null,
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String?,
      perPage: json['per_page'] as int?,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int?,
      total: json['total'] as int?,
    );
  }
}

class Link {
  final String? url;
  final String? label;
  final bool? active;

  Link({this.url, this.label, this.active});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'] as String?,
      label: json['label'] as String?,
      active: json['active'] as bool?,
    );
  }
}

class AdminProducts {
  final String? id;
  final dynamic prevId;
  final String? shopId;
  final String? slug;
  final String? name;
  final String? productType;
  final String? productGroup;
  final String? thumbnailId;
  final String? description;
  final int? stock;
  final int? isFeatured;
  final int? isDeal;
  final double? price;
  final double? salePrice;
  final dynamic reservedPrice;
  final dynamic auctionStartTime;
  final dynamic auctionEndTime;
  final dynamic winnerId;
  final double? minPrice;
  final double? maxPrice;
  final dynamic saleStartTime;
  final dynamic saleEndTime;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Thumbnail? thumbnail;
  final List<dynamic>? rating;
  final Shop? shop;
  final ProductMeta? meta;
  final bool? isDiscountProduct;
  final Video? video;

  AdminProducts({
    this.id,
    this.prevId,
    this.shopId,
    this.slug,
    this.name,
    this.productType,
    this.productGroup,
    this.thumbnailId,
    this.description,
    this.stock,
    this.isFeatured,
    this.isDeal,
    this.price,
    this.salePrice,
    this.reservedPrice,
    this.auctionStartTime,
    this.auctionEndTime,
    this.winnerId,
    this.minPrice,
    this.maxPrice,
    this.saleStartTime,
    this.saleEndTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.rating,
    this.shop,
    this.meta,
    this.isDiscountProduct,
    this.video,
  });

  factory AdminProducts.fromJson(Map<String, dynamic> json) {
    return AdminProducts(
      id: json['id'] as String?,
      prevId: json['prev_id'],
      shopId: json['shop_id'] as String?,
      slug: json['slug'] as String?,
      name: json['name'] as String?,
      productType: json['product_type'] as String?,
      productGroup: json['product_group'] as String?,
      thumbnailId: json['thumbnail_id'] as String?,
      description: json['description'] as String?,
      stock: json['stock'] as int?,
      isFeatured: json['is_featured'] as int?,
      isDeal: json['is_deal'] as int?,
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
      salePrice:
          json['sale_price'] != null
              ? double.parse(json['sale_price'].toString())
              : null,
      reservedPrice: json['reserved_price'],
      auctionStartTime: json['auction_start_time'],
      auctionEndTime: json['auction_end_time'],
      winnerId: json['winner_id'],
      minPrice:
          json['min_price'] != null
              ? double.parse(json['min_price'].toString())
              : null,
      maxPrice:
          json['max_price'] != null
              ? double.parse(json['max_price'].toString())
              : null,
      saleStartTime: json['sale_start_time'],
      saleEndTime: json['sale_end_time'],
      status: json['status'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      thumbnail:
          json['thumbnail'] != null
              ? Thumbnail.fromJson(json['thumbnail'])
              : null,
      rating:
          json['rating'] != null ? List<dynamic>.from(json['rating']) : null,
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
      meta: json['meta'] != null ? ProductMeta.fromJson(json['meta']) : null,
      isDiscountProduct: json['is_discount_product'] as bool?,
      video: json['video'] != null ? Video.fromJson(json['video']) : null,
    );
  }
}

class Thumbnail {
  final Media? media;

  Thumbnail({this.media});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    if (json['media'] == null || json['media'] is String) {
      return Thumbnail(media: null);
    }
    return Thumbnail(media: Media.fromJson(json['media']));
  }
}

class Media {
  final String? id;
  final String? url;
  final String? optimizedMediaUrl;
  final String? mediaType;
  final String? cdnUrl;
  final String? optimizedMediaCdnUrl;
  final dynamic cdnVideoId;
  final dynamic cdnThumbnailUrl;
  final String? cdnStoragePath;
  final bool? isStreaming;
  final dynamic isUsed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? localUrl;
  final String? localOptimizedUrl;
  final bool? usingCdn;
  final VideoThumbnail? videoThumbnail;

  Media({
    this.id,
    this.url,
    this.optimizedMediaUrl,
    this.mediaType,
    this.cdnUrl,
    this.optimizedMediaCdnUrl,
    this.cdnVideoId,
    this.cdnThumbnailUrl,
    this.cdnStoragePath,
    this.isStreaming,
    this.isUsed,
    this.createdAt,
    this.updatedAt,
    this.localUrl,
    this.localOptimizedUrl,
    this.usingCdn,
    this.videoThumbnail,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] as String?,
      url: json['url'] as String?,
      optimizedMediaUrl: json['optimized_media_url'] as String?,
      mediaType: json['media_type'] as String?,
      cdnUrl: json['cdn_url'] as String?,
      optimizedMediaCdnUrl: json['optimized_media_cdn_url'] as String?,
      cdnVideoId: json['cdn_video_id'],
      cdnThumbnailUrl: json['cdn_thumbnail_url'],
      cdnStoragePath: json['cdn_storage_path'] as String?,
      isStreaming: json['is_streaming'] as bool?,
      isUsed: json['is_used'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      localUrl: json['local_url'] as String?,
      localOptimizedUrl: json['local_optimized_url'] as String?,
      usingCdn: json['using_cdn'] as bool?,
      videoThumbnail:
          json['video_thumbnail'] != null
              ? VideoThumbnail.fromJson(json['video_thumbnail'])
              : null,
    );
  }
}

class VideoThumbnail {
  final String? url;
  final String? mediaType;

  VideoThumbnail({this.url, this.mediaType});

  factory VideoThumbnail.fromJson(Map<String, dynamic> json) {
    return VideoThumbnail(
      url: json['url'] as String?,
      mediaType: json['media_type'] as String?,
    );
  }
}

class Shop {
  final ShopData? shop;
  final dynamic thumbnail;
  final Membership? membership;
  final ShopMeta? meta;

  Shop({this.shop, this.thumbnail, this.membership, this.meta});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shop: json['shop'] != null ? ShopData.fromJson(json['shop']) : null,
      thumbnail: json['thumbnail'],
      membership:
          json['membership'] != null
              ? (json['membership'] is Map
                  ? Membership.fromJson(json['membership'])
                  : null)
              : null,
      meta:
          json['meta'] != null
              ? (json['meta'] is Map ? ShopMeta.fromJson(json['meta']) : null)
              : null,
    );
  }
}

class ShopData {
  final String? id;
  final dynamic prevId;
  final String? userId;
  final String? membershipId;
  final dynamic membershipStartDate;
  final dynamic membershipEndDate;
  final String? slug;
  final String? name;
  final dynamic thumbnailId;
  final String? bannerImageId;
  final dynamic stripeAccountId;
  final double? balance;
  final String? description;
  final int? isVerified;
  final dynamic isFeatured;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Banner? banner;

  ShopData({
    this.id,
    this.prevId,
    this.userId,
    this.membershipId,
    this.membershipStartDate,
    this.membershipEndDate,
    this.slug,
    this.name,
    this.thumbnailId,
    this.bannerImageId,
    this.stripeAccountId,
    this.balance,
    this.description,
    this.isVerified,
    this.isFeatured,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.banner,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      id: json['id'] as String?,
      prevId: json['prev_id'],
      userId: json['user_id'] as String?,
      membershipId: json['membership_id'] as String?,
      membershipStartDate: json['membership_start_date'],
      membershipEndDate: json['membership_end_date'],
      slug: json['slug'] as String?,
      name: json['name'] as String?,
      thumbnailId: json['thumbnail_id'],
      bannerImageId: json['banner_image_id'] as String?,
      stripeAccountId: json['stripe_account_id'],
      balance:
          json['balance'] != null
              ? double.parse(json['balance'].toString())
              : null,
      description: json['description'] as String?,
      isVerified: json['is_verified'] as int?,
      isFeatured: json['is_featured'],
      status: json['status'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      banner: json['banner'] != null ? Banner.fromJson(json['banner']) : null,
    );
  }
}

class Banner {
  final Media? media;

  Banner({this.media});

  factory Banner.fromJson(Map<String, dynamic> json) {
    if (json['media'] == null || json['media'] is String) {
      return Banner(media: null);
    }
    return Banner(media: Media.fromJson(json['media']));
  }
}

class Membership {
  final MembershipPlan? membershipPlan;

  Membership({this.membershipPlan});

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      membershipPlan:
          json['membership_plan'] != null
              ? MembershipPlan.fromJson(json['membership_plan'])
              : null,
    );
  }
}

class MembershipPlan {
  final String? id;
  final String? slug;
  final String? userType;
  final String? name;
  final int? price;
  final String? description;
  final String? duration;
  final dynamic parentId;
  final String? status;
  final dynamic createdAt;
  final dynamic updatedAt;
  final dynamic thumbnail;
  final Features? features;

  MembershipPlan({
    this.id,
    this.slug,
    this.userType,
    this.name,
    this.price,
    this.description,
    this.duration,
    this.parentId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.features,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] as String?,
      slug: json['slug'] as String?,
      userType: json['user_type'] as String?,
      name: json['name'] as String?,
      price: json['price'] as int?,
      description: json['description'] as String?,
      duration: json['duration'] as String?,
      parentId: json['parent_id'],
      status: json['status'] as String?,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      thumbnail: json['thumbnail'],
      features:
          json['features'] != null ? Features.fromJson(json['features']) : null,
    );
  }
}

class Features {
  final List<dynamic>? membershipPlanFeatures;

  Features({this.membershipPlanFeatures});

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      membershipPlanFeatures:
          json['membership_plan_features'] != null
              ? List<dynamic>.from(json['membership_plan_features'])
              : null,
    );
  }
}

class ShopMeta {
  final String? shippingTimeFrom;
  final String? storeColor;
  final String? address;
  final String? freeShippingTargetAmount;
  final String? country;
  final String? shippingFees;
  final String? isEligibleForDiscounts;
  final String? phone;
  final String? shippingCompany;
  final String? city;
  final String? email;
  final String? whatsapp;
  final String? shippingTimeTo;
  final String? areaCode;
  final String? whatsappAreaCode;

  ShopMeta({
    this.shippingTimeFrom,
    this.storeColor,
    this.address,
    this.freeShippingTargetAmount,
    this.country,
    this.shippingFees,
    this.isEligibleForDiscounts,
    this.phone,
    this.shippingCompany,
    this.city,
    this.email,
    this.whatsapp,
    this.shippingTimeTo,
    this.areaCode,
    this.whatsappAreaCode,
  });

  factory ShopMeta.fromJson(Map<String, dynamic> json) {
    return ShopMeta(
      shippingTimeFrom: json['shipping_time_from'] as String?,
      storeColor: json['store_color'] as String?,
      address: json['address'] as String?,
      freeShippingTargetAmount: json['free_shipping_target_amount'] as String?,
      country: json['country'] as String?,
      shippingFees: json['shipping_fees'] as String?,
      isEligibleForDiscounts: json['is_eligible_for_discounts'] as String?,
      phone: json['phone'] as String?,
      shippingCompany: json['shipping_company'] as String?,
      city: json['city'] as String?,
      email: json['email'] as String?,
      whatsapp: json['whatsapp'] as String?,
      shippingTimeTo: json['shipping_time_to'] as String?,
      areaCode: json['area-code'] as String?,
      whatsappAreaCode: json['whatsapp-area-code'] as String?,
    );
  }
}

class ProductMeta {
  final dynamic videoId;
  final String? views;
  final String? productId;
  final String? gallery;
  final String? shippingFees;
  final String? shippingTimeFrom;
  final String? shippingTimeTo;
  final String? sku;
  final String? countryId;
  final String? stateId;
  final String? cityId;
  final String? sold;
  final String? recentBuyer;
  final String? lastAddToWishlistAt;
  final String? addToCartClicks;
  final String? lastWhatsappClickAt;
  final String? shippingCompany;
  final String? whatsappClickClicks;
  final String? enquireNowClicks;
  final String? lastInteractionAt;
  final String? shippingTimeUnit;
  final String? addToWishlistClicks;
  final String? lastEnquireNowAt;
  final String? lastAddToCartAt;
  final String? upcCode; // New
  final String? productNotice; // New
  final String? bid_increment_by;
  // Car-specific meta
  final String? mileage;
  final String? transmission;
  final String? fuelType;
  final String? engine;
  final String? hidePrice;

  ProductMeta({
    this.videoId,
    this.views,
    this.productId,
    this.gallery,
    this.shippingFees,
    this.shippingTimeFrom,
    this.shippingTimeTo,
    this.sku,
    this.countryId,
    this.stateId,
    this.cityId,
    this.sold,
    this.recentBuyer,
    this.lastAddToWishlistAt,
    this.addToCartClicks,
    this.lastWhatsappClickAt,
    this.shippingCompany,
    this.whatsappClickClicks,
    this.enquireNowClicks,
    this.lastInteractionAt,
    this.shippingTimeUnit,
    this.addToWishlistClicks,
    this.lastEnquireNowAt,
    this.lastAddToCartAt,
    this.bid_increment_by,
    this.upcCode, // New
    this.productNotice, // New
    this.mileage,
    this.transmission,
    this.fuelType,
    this.engine,
    this.hidePrice,
  });

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      videoId: json['video_id'],
      views: json['views'] as String?,
      productId: json['product_id'] as String?,
      gallery: json['gallery'] as String?,
      shippingFees: json['shipping_fees'] as String?,
      shippingTimeFrom: json['shipping_time_from'] as String?,
      shippingTimeTo: json['shipping_time_to'] as String?,
      sku: json['sku'] as String?,
      countryId: json['country_id'] as String?,
      stateId: json['state_id'] as String?,
      cityId: json['city_id'] as String?,
      sold: json['sold'] as String?,
      bid_increment_by: json['bid_increment_by'] as String?,
      recentBuyer: json['recent_buyer'] as String?,
      lastAddToWishlistAt: json['last_add_to_wishlist_at'] as String?,
      addToCartClicks: json['add_to_cart_clicks'] as String?,
      lastWhatsappClickAt: json['last_whatsapp_click_at'] as String?,
      shippingCompany: json['shipping_company'] as String?,
      whatsappClickClicks: json['whatsapp_click_clicks'] as String?,
      enquireNowClicks: json['enquire_now_clicks'] as String?,
      lastInteractionAt: json['last_interaction_at'] as String?,
      shippingTimeUnit: json['shipping_time_unit'] as String?,
      addToWishlistClicks: json['add_to_wishlist_clicks'] as String?,
      lastEnquireNowAt: json['last_enquire_now_at'] as String?,
      lastAddToCartAt: json['last_add_to_cart_at'] as String?,
      upcCode: json['upc_code'] as String?, // New
      productNotice: json['product_notice'] as String?, // New
      mileage: json['mileage']?.toString(),
      transmission: json['transmission'] as String?,
      fuelType: json['fuel_type'] as String?,
      engine: json['engine']?.toString(),
      hidePrice: json['hide_price']?.toString(),
    );
  }
}

class Video {
  final Media? media;

  Video({this.media});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
    );
  }
}
