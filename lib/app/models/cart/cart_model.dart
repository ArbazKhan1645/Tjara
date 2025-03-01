import 'package:tjara/app/models/products/single_product_model.dart';

class CartModel {
  List<CartItem> cartItems;
  double? cartTotal;
  double? totalDiscounts;
  double? totalBonuses;
  double? totalWithDiscount;
  double? totalShippingFees;
  double? grandTotal;
  ResellerProgress? resellerProgress;
  List<String?>? discountMessages;

  CartModel({
    required this.cartItems,
    this.cartTotal,
    this.totalDiscounts,
    this.totalBonuses,
    this.totalWithDiscount,
    this.totalShippingFees,
    this.grandTotal,
    this.resellerProgress,
    this.discountMessages,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartItems: (json['cartItems'] as List?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      cartTotal: json['cartTotal'] != null
          ? double.tryParse(json['cartTotal'].toString()) ?? 0.0
          : 0.0,
      totalDiscounts: json['totalDiscounts'] != null
          ? double.tryParse(json['totalDiscounts'].toString()) ?? 0.0
          : 0.0,
      totalBonuses: json['totalBonuses'] != null
          ? double.tryParse(json['totalBonuses'].toString()) ?? 0.0
          : 0.0,
      totalWithDiscount: json['totalWithDiscount'] != null
          ? double.tryParse(json['totalWithDiscount'].toString()) ?? 0.0
          : 0.0,
      totalShippingFees: json['totalShippingFees'] != null
          ? double.tryParse(json['totalShippingFees'].toString()) ?? 0.0
          : 0.0,
      grandTotal: json['grandTotal'] != null
          ? double.tryParse(json['grandTotal'].toString()) ?? 0.0
          : 0.0,
      resellerProgress:
          ResellerProgress.fromJson(json['resellerProgress'] ?? {}),
      discountMessages: (json['discountMessages'] as List?)
              ?.map((e) => e?.toString())
              .toList() ??
          [],
    );
  }
}

class CartItem {
  Shop shop;
  List<Item> items;
  double shopTotal;
  double maxShippingFee;
  CurrentPlan? currentPlan;
  double shopDiscount;
  double shopBonus;
  double displayDiscount;
  double displayBonus;
  bool displayHasLevelFreeShipping;
  String? nextTierMessage;
  String? nextTierMessageCheckout;
  LevelProgress? levelProgress;
  bool isEligibleForDiscount;
  bool freeShipping;
  String freeShippingNotice;
  LebanonTechDiscount? lebanonTechDiscount;

  CartItem({
    required this.shop,
    required this.items,
    required this.shopTotal,
    required this.maxShippingFee,
    this.currentPlan,
    required this.shopDiscount,
    required this.shopBonus,
    required this.displayDiscount,
    required this.displayBonus,
    required this.displayHasLevelFreeShipping,
    this.nextTierMessage,
    this.nextTierMessageCheckout,
    this.levelProgress,
    required this.isEligibleForDiscount,
    required this.freeShipping,
    required this.freeShippingNotice,
    this.lebanonTechDiscount,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      shop: Shop.fromJson(json['shop'] ?? {}),
      items: (json['items'] as List?)
              ?.map((item) => Item.fromJson(item))
              .toList() ??
          [],
      shopTotal: json['shopTotal'] != null
          ? double.tryParse(json['shopTotal'].toString()) ?? 0.0
          : 0.0,
      maxShippingFee: json['maxShippingFee'] != null
          ? double.tryParse(json['maxShippingFee'].toString()) ?? 0.0
          : 0.0,
      shopDiscount: json['shopDiscount'] != null
          ? double.tryParse(json['shopDiscount'].toString()) ?? 0.0
          : 0.0,
      shopBonus: json['shopBonus'] != null
          ? double.tryParse(json['shopBonus'].toString()) ?? 0.0
          : 0.0,
      displayDiscount: json['displayDiscount'] != null
          ? double.tryParse(json['displayDiscount'].toString()) ?? 0.0
          : 0.0,
      displayBonus: json['displayBonus'] != null
          ? double.tryParse(json['displayBonus'].toString()) ?? 0.0
          : 0.0,
      displayHasLevelFreeShipping: json['displayHasLevelFreeShipping'] ?? false,
      nextTierMessage: json['nextTierMessage'],
      nextTierMessageCheckout: json['nextTierMessageCheckout'],
      levelProgress: json['levelProgress'] != null
          ? LevelProgress.fromJson(json['levelProgress'])
          : null,
      isEligibleForDiscount: json['isEligibleForDiscount'] ?? false,
      freeShipping: json['freeShipping'] ?? false,
      freeShippingNotice: json['freeShippingNotice'] ?? '',
      lebanonTechDiscount: json['lebanonTechDiscount'] != null
          ? LebanonTechDiscount.fromJson(json['lebanonTechDiscount'])
          : null,
    );
  }
}

class Shop {
  ShopDetails shop;

  Shop({
    required this.shop,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shop: ShopDetails.fromJson(json['shop'] ?? {}),
    );
  }
}

class ShopDetails {
  String id;
  int prevId;
  String userId;
  String membershipId;
  String? membershipStartDate;
  String? membershipEndDate;
  String slug;
  String name;
  String? thumbnailId;
  String? bannerImageId;
  String? stripeAccountId;
  double balance;
  String description;
  int isVerified;
  dynamic isFeatured;
  String status;
  String createdAt;
  String updatedAt;
  Banner banner;
  Thumbnail thumbnail;
  Membership membership;
  Meta meta;

  ShopDetails({
    required this.id,
    required this.prevId,
    required this.userId,
    required this.membershipId,
    this.membershipStartDate,
    this.membershipEndDate,
    required this.slug,
    required this.name,
    this.thumbnailId,
    this.bannerImageId,
    this.stripeAccountId,
    required this.balance,
    required this.description,
    required this.isVerified,
    this.isFeatured,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.banner,
    required this.thumbnail,
    required this.membership,
    required this.meta,
  });

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    return ShopDetails(
      id: json['id'] ?? '',
      prevId: json['prev_id'] ?? 0,
      userId: json['user_id'] ?? '',
      membershipId: json['membership_id'] ?? '',
      membershipStartDate: json['membership_start_date'],
      membershipEndDate: json['membership_end_date'],
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      thumbnailId: json['thumbnail_id'],
      bannerImageId: json['banner_image_id'],
      stripeAccountId: json['stripe_account_id'],
      balance: json['balance'] != null
          ? double.tryParse(json['balance'].toString()) ?? 0.0
          : 0.0,
      description: json['description'] ?? '',
      isVerified: json['is_verified'] ?? 0,
      isFeatured: json['is_featured'],
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      banner: Banner.fromJson(json['banner'] ?? {}),
      thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),
      membership: Membership.fromJson(json['membership'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }
}

class Banner {
  String message;

  Banner({
    required this.message,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      message: json['message'] ?? '',
    );
  }
}

class Thumbnail {
  Media? media;

  Thumbnail({
    this.media,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
    );
  }
}

class Media {
  String id;
  String url;
  String optimizedMediaUrl;
  String mediaType;
  dynamic isUsed;
  String createdAt;
  String updatedAt;

  Media({
    required this.id,
    required this.url,
    required this.optimizedMediaUrl,
    required this.mediaType,
    this.isUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      optimizedMediaUrl: json['optimized_media_url'] ?? '',
      mediaType: json['media_type'] ?? '',
      isUsed: json['is_used'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Membership {
  MembershipPlan membershipPlan;

  Membership({
    required this.membershipPlan,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      membershipPlan: MembershipPlan.fromJson(json['membership_plan'] ?? {}),
    );
  }
}

class MembershipPlan {
  String id;
  String slug;
  String userType;
  String name;
  double price;
  String description;
  String duration;
  dynamic parentId;
  String status;
  dynamic createdAt;
  dynamic updatedAt;
  Thumbnail thumbnail;
  Features features;

  MembershipPlan({
    required this.id,
    required this.slug,
    required this.userType,
    required this.name,
    required this.price,
    required this.description,
    required this.duration,
    this.parentId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.thumbnail,
    required this.features,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      userType: json['user_type'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      parentId: json['parent_id'],
      status: json['status'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),
      features: Features.fromJson(json['features'] ?? {}),
    );
  }
}

class Features {
  List<dynamic> membershipPlanFeatures;

  Features({
    required this.membershipPlanFeatures,
  });

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      membershipPlanFeatures: (json['membership_plan_features'] as List?)
              ?.map((e) => e) // Keeps the dynamic type
              .toList() ??
          [],
    );
  }
}

class Meta {
  String freeShippingTargetAmount;
  String email;
  String phone;
  String isEligibleForDiscounts;
  String whatsapp;
  String country;
  String businessType;
  String whatsappAreaCode;
  String storeColor;
  String shippingFees;
  String city;
  String areaCode;
  String skype;
  String address;

  Meta({
    required this.freeShippingTargetAmount,
    required this.email,
    required this.phone,
    required this.isEligibleForDiscounts,
    required this.whatsapp,
    required this.country,
    required this.businessType,
    required this.whatsappAreaCode,
    required this.storeColor,
    required this.shippingFees,
    required this.city,
    required this.areaCode,
    required this.skype,
    required this.address,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      freeShippingTargetAmount: json['free_shipping_target_amount'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isEligibleForDiscounts: json['is_eligible_for_discounts'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      country: json['country'] ?? '',
      businessType: json['business_type'] ?? '',
      whatsappAreaCode: json['whatsapp_area_code'] ?? '',
      storeColor: json['store_color'] ?? '',
      shippingFees: json['shipping_fees'] ?? '',
      city: json['city'] ?? '',
      areaCode: json['area_code'] ?? '',
      skype: json['skype'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class Item {
  String id;
  String userId;
  String shopId;
  String productId;
  dynamic variationId;
  int quantity;
  double price;
  String createdAt;
  String updatedAt;
  Product product;
  ItemMeta meta;
  Thumbnail thumbnail;
  double? originalPrice;
  double? displayDiscountedPrice;
  double? displayItemDiscount;
  double? displayDiscountPerUnit;

  Item({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.productId,
    this.variationId,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
    required this.meta,
    required this.thumbnail,
    this.originalPrice,
    this.displayDiscountedPrice,
    this.displayItemDiscount,
    this.displayDiscountPerUnit,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      shopId: json['shop_id'] ?? '',
      productId: json['product_id'] ?? '',
      variationId: json['variation_id'],
      quantity: json['quantity'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      meta: ItemMeta.fromJson(json['meta'] ?? {}),
      thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      originalPrice: json['original_price'] != null
          ? double.tryParse(json['original_price'].toString())
          : null,
      displayDiscountedPrice: json['displayDiscountedPrice'] != null
          ? double.tryParse(json['displayDiscountedPrice'].toString())
          : null,
      displayItemDiscount: json['display_item_discount'] != null
          ? double.tryParse(json['display_item_discount'].toString())
          : null,
      displayDiscountPerUnit: json['display_discount_per_unit'] != null
          ? double.tryParse(json['display_discount_per_unit'].toString())
          : null,
    );
  }
}

class ItemMeta {
  String shippingFees;
  String gallery;
  String views;
  String shippingCompany;
  String productId;
  String? videoId;
  String shippingTimeFrom;
  String shippingTimeTo;
  String? sku;

  ItemMeta({
    required this.shippingFees,
    required this.gallery,
    required this.views,
    required this.shippingCompany,
    required this.productId,
    this.videoId,
    required this.shippingTimeFrom,
    required this.shippingTimeTo,
    this.sku,
  });

  factory ItemMeta.fromJson(Map<String, dynamic> json) {
    return ItemMeta(
      shippingFees: json['shipping_fees'] ?? '',
      gallery: json['gallery'] ?? '',
      views: json['views'] ?? '',
      shippingCompany: json['shipping_company'] ?? '',
      productId: json['product_id'] ?? '',
      videoId: json['video_id'],
      shippingTimeFrom: json['shipping_time_from'] ?? '',
      shippingTimeTo: json['shipping_time_to'] ?? '',
      sku: json['sku'],
    );
  }
}

class CurrentPlan {
  String id;
  String planId;
  String name;
  String value;
  int isAvailable;
  String createdAt;
  String updatedAt;

  CurrentPlan({
    required this.id,
    required this.planId,
    required this.name,
    required this.value,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CurrentPlan.fromJson(Map<String, dynamic> json) {
    return CurrentPlan(
      id: json['id'],
      planId: json['plan_id'],
      name: json['name'],
      value: json['value'],
      isAvailable: json['is_available'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class LevelProgress {
  List<Level> levels;
  dynamic currentLevel;
  dynamic nextLevel;
  double progress;

  LevelProgress({
    required this.levels,
    this.currentLevel,
    this.nextLevel,
    required this.progress,
  });

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levels: (json['levels'] as List?)
              ?.map((level) => Level.fromJson(level))
              .toList() ??
          [],
      currentLevel: json['currentLevel'],
      nextLevel: json['nextLevel'],
      progress: json['progress'] != null
          ? double.tryParse(json['progress'].toString()) ?? 0.0
          : 0.0,
    );
  }
}

class Level {
  int level;
  double shopTotal;
  double minSpent;
  double discount;
  double bonus;

  Level({
    required this.level,
    required this.shopTotal,
    required this.minSpent,
    required this.discount,
    required this.bonus,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      level: json['level'],
      shopTotal: json['shopTotal'] != null
          ? double.tryParse(json['shopTotal'].toString()) ?? 0.0
          : 0.0,
      minSpent: json['minSpent'] != null
          ? double.tryParse(json['minSpent'].toString()) ?? 0.0
          : 0.0,
      discount: json['discount'] != null
          ? double.tryParse(json['discount'].toString()) ?? 0.0
          : 0.0,
      bonus: json['bonus'] != null
          ? double.tryParse(json['bonus'].toString()) ?? 0.0
          : 0.0,
    );
  }
}

class LebanonTechDiscount {
  bool isEnabled;
  double discountAmount;
  double discountPercentage;
  String message;

  LebanonTechDiscount({
    required this.isEnabled,
    required this.discountAmount,
    required this.discountPercentage,
    required this.message,
  });

  factory LebanonTechDiscount.fromJson(Map<String, dynamic> json) {
    return LebanonTechDiscount(
      isEnabled: json['isEnabled'],
      discountAmount: json['discountAmount'] != null
          ? double.tryParse(json['discountAmount'].toString()) ?? 0.0
          : 0.0,
      discountPercentage: json['discountPercentage'] != null
          ? double.tryParse(json['discountPercentage'].toString()) ?? 0.0
          : 0.0,
      message: json['message'],
    );
  }
}

class ResellerProgress {
  List<ResellerLevel> levels;

  ResellerProgress({required this.levels});

  factory ResellerProgress.fromJson(Map<String, dynamic> json) {
    return ResellerProgress(
      levels: (json['levels'] as List?)
              ?.map((level) => ResellerLevel.fromJson(level))
              .toList() ??
          [],
    );
  }
}

class ResellerLevel {
  int level;
  double minSpent;
  double discount;
  double bonus;
  double referrelEarnings;

  ResellerLevel({
    required this.level,
    required this.minSpent,
    required this.discount,
    required this.bonus,
    required this.referrelEarnings,
  });

  factory ResellerLevel.fromJson(Map<String, dynamic> json) {
    return ResellerLevel(
      level: json['level'],
      minSpent: json['minSpent'] != null
          ? double.tryParse(json['minSpent'].toString()) ?? 0.0
          : 0.0,
      discount: json['discount'] != null
          ? double.tryParse(json['discount'].toString()) ?? 0.0
          : 0.0,
      bonus: json['bonus'] != null
          ? double.tryParse(json['bonus'].toString()) ?? 0.0
          : 0.0,
      referrelEarnings: json['referrel_earnings'] != null
          ? double.tryParse(json['referrel_earnings'].toString()) ?? 0.0
          : 0.0,
    );
  }
}
