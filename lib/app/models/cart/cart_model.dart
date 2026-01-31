// ignore_for_file: avoid_print

import 'package:tjara/app/models/media_model/media_model.dart';
import 'package:tjara/app/models/products/single_product_model.dart';
import 'package:tjara/app/models/products/variation.dart';

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

  // New fields from API
  List<ResellerTier> resellerTiers;
  int currentTier;
  NextTierInfo? nextTier;
  double totalCartValue;
  double totalDiscount;
  double totalBonus;

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
    this.resellerTiers = const [],
    this.currentTier = 1,
    this.nextTier,
    this.totalCartValue = 0.0,
    this.totalDiscount = 0.0,
    this.totalBonus = 0.0,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // Parse resellerProgress object which contains levels, currentLevel, nextLevel
    final resellerProgressData = json['resellerProgress'] as Map<String, dynamic>?;

    // Parse levels array from resellerProgress
    List<ResellerTier> parsedTiers = [];
    if (resellerProgressData != null && resellerProgressData['levels'] != null) {
      parsedTiers = (resellerProgressData['levels'] as List)
          .map((item) => ResellerTier.fromJson(item))
          .toList();
    }

    // Parse currentLevel from resellerProgress
    int parsedCurrentTier = 1;
    if (resellerProgressData != null && resellerProgressData['currentLevel'] != null) {
      parsedCurrentTier = resellerProgressData['currentLevel']['level'] ?? 1;
    }

    // Parse nextLevel from resellerProgress
    NextTierInfo? parsedNextTier;
    if (resellerProgressData != null && resellerProgressData['nextLevel'] != null) {
      parsedNextTier = NextTierInfo.fromJson(
        resellerProgressData['nextLevel'],
        amountToNextLevel: resellerProgressData['amountToNextLevel'],
        progressValue: resellerProgressData['progress'],
      );
    }

    return CartModel(
      cartItems:
          (json['cartItems'] as List?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      cartTotal:
          json['cartTotal'] != null
              ? double.tryParse(json['cartTotal'].toString()) ?? 0.0
              : 0.0,
      totalDiscounts:
          json['totalDiscounts'] != null
              ? double.tryParse(json['totalDiscounts'].toString()) ?? 0.0
              : 0.0,
      totalBonuses:
          json['totalBonuses'] != null
              ? double.tryParse(json['totalBonuses'].toString()) ?? 0.0
              : 0.0,
      totalWithDiscount:
          json['totalWithDiscount'] != null
              ? double.tryParse(json['totalWithDiscount'].toString()) ?? 0.0
              : 0.0,
      totalShippingFees:
          json['totalShippingFees'] != null
              ? double.tryParse(json['totalShippingFees'].toString()) ?? 0.0
              : 0.0,
      grandTotal:
          json['grandTotal'] != null
              ? double.tryParse(json['grandTotal'].toString()) ?? 0.0
              : 0.0,
      resellerProgress: json['resellerProgress'] != null
          ? ResellerProgress.fromJson(json['resellerProgress'])
          : null,
      discountMessages:
          (json['discountMessages'] as List?)
              ?.map((e) => e?.toString())
              .toList() ??
          [],
      // Use parsed values from resellerProgress
      resellerTiers: parsedTiers,
      currentTier: parsedCurrentTier,
      nextTier: parsedNextTier,
      totalCartValue:
          json['totalCartValue'] != null
              ? double.tryParse(json['totalCartValue'].toString()) ?? 0.0
              : 0.0,
      totalDiscount:
          json['totalDiscount'] != null
              ? double.tryParse(json['totalDiscount'].toString()) ?? 0.0
              : 0.0,
      totalBonus:
          json['totalBonus'] != null
              ? double.tryParse(json['totalBonus'].toString()) ?? 0.0
              : 0.0,
    );
  }
}

// Reseller Tier from API resellerProgress.levels array
class ResellerTier {
  int tier;
  double minPurchase;
  double discountRate;
  double bonusAmount;

  ResellerTier({
    required this.tier,
    required this.minPurchase,
    required this.discountRate,
    required this.bonusAmount,
  });

  factory ResellerTier.fromJson(Map<String, dynamic> json) {
    return ResellerTier(
      // API uses "level" not "tier"
      tier: json['level'] ?? 1,
      // API uses "minSpent" not "minPurchase"
      minPurchase:
          json['minSpent'] != null
              ? double.tryParse(json['minSpent'].toString()) ?? 0.0
              : 0.0,
      // API uses "discount" not "discountRate"
      discountRate:
          json['discount'] != null
              ? double.tryParse(json['discount'].toString()) ?? 0.0
              : 0.0,
      // API uses "bonus" not "bonusAmount"
      bonusAmount:
          json['bonus'] != null
              ? double.tryParse(json['bonus'].toString()) ?? 0.0
              : 0.0,
    );
  }
}

// Next tier info from API resellerProgress.nextLevel
class NextTierInfo {
  int tier;
  double minPurchase;
  double discountRate;
  double bonusAmount;
  double amountNeeded;
  String message;
  double progress; // Progress percentage from API (e.g., 27.7)

  NextTierInfo({
    required this.tier,
    required this.minPurchase,
    required this.discountRate,
    required this.bonusAmount,
    required this.amountNeeded,
    required this.message,
    required this.progress,
  });

  factory NextTierInfo.fromJson(
    Map<String, dynamic> json, {
    dynamic amountToNextLevel,
    dynamic progressValue,
  }) {
    final tier = json['level'] ?? 1;
    final discount = json['discount'] != null
        ? double.tryParse(json['discount'].toString()) ?? 0.0
        : 0.0;
    final bonus = json['bonus'] != null
        ? double.tryParse(json['bonus'].toString()) ?? 0.0
        : 0.0;
    final minSpent = json['minSpent'] != null
        ? double.tryParse(json['minSpent'].toString()) ?? 0.0
        : 0.0;
    final amountNeeded = amountToNextLevel != null
        ? double.tryParse(amountToNextLevel.toString()) ?? 0.0
        : 0.0;
    final progress = progressValue != null
        ? double.tryParse(progressValue.toString()) ?? 0.0
        : 0.0;

    // Generate message like web: "Add $50.98 more to reach Level 3 and enjoy 17% discount plus $7 bonus!"
    final message = amountNeeded > 0
        ? 'Add \$${amountNeeded.toStringAsFixed(2)} more to reach Level $tier and enjoy ${discount.toStringAsFixed(0)}% discount plus \$${bonus.toStringAsFixed(0)} bonus!'
        : '';

    return NextTierInfo(
      tier: tier,
      minPurchase: minSpent,
      discountRate: discount,
      bonusAmount: bonus,
      amountNeeded: amountNeeded,
      message: message,
      progress: progress,
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
  String? firstOrderDiscountMessage;
  String freeShippingNotice;
  LebanonTechDiscount? lebanonTechDiscount;
  List<DiscountBreakdown> discountBreakdown;
  double firstOrderDiscount;
  double firstOrderDiscountPercentage;

  CartItem({
    required this.shop,
    required this.items,
    required this.shopTotal,
    required this.maxShippingFee,
    this.currentPlan,
    required this.firstOrderDiscountMessage,
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
    required this.discountBreakdown,
    required this.firstOrderDiscount,
    required this.firstOrderDiscountPercentage,
  });

  // Calculate shop final total after discounts
  double get shopFinalTotal {
    return shopTotal - shopDiscount;
  }

  // Get estimated delivery date based on shipping time
  String getEstimatedDelivery() {
    if (items.isEmpty) return 'No items available';

    // Find max shipping time from items
    int maxDays = 0;
    for (var item in items) {
      final shippingTo = int.tryParse(item.meta.shippingTimeTo) ?? 0;
      if (shippingTo > maxDays) {
        maxDays = shippingTo;
      }
    }

    if (maxDays == 0) return 'No items available';

    final deliveryDate = DateTime.now().add(Duration(days: maxDays));
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[deliveryDate.month - 1]} ${deliveryDate.day}';
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      firstOrderDiscountMessage: json['firstOrderDiscountMessage'],
      shop: Shop.fromJson(json['shop'] ?? {}),
      items:
          (json['items'] as List?)
              ?.map((item) => Item.fromJson(item))
              .toList() ??
          [],
      shopTotal:
          json['shopTotal'] != null
              ? double.tryParse(json['shopTotal'].toString()) ?? 0.0
              : 0.0,
      maxShippingFee:
          json['maxShippingFee'] != null
              ? double.tryParse(json['maxShippingFee'].toString()) ?? 0.0
              : 0.0,
      shopDiscount:
          json['shopDiscount'] != null
              ? double.tryParse(json['shopDiscount'].toString()) ?? 0.0
              : 0.0,
      shopBonus:
          json['shopBonus'] != null
              ? double.tryParse(json['shopBonus'].toString()) ?? 0.0
              : 0.0,
      displayDiscount:
          json['displayDiscount'] != null
              ? double.tryParse(json['displayDiscount'].toString()) ?? 0.0
              : 0.0,
      displayBonus:
          json['displayBonus'] != null
              ? double.tryParse(json['displayBonus'].toString()) ?? 0.0
              : 0.0,
      displayHasLevelFreeShipping: json['displayHasLevelFreeShipping'] ?? false,
      nextTierMessage: json['nextTierMessage'],
      nextTierMessageCheckout: json['nextTierMessageCheckout'],
      levelProgress:
          json['levelProgress'] != null
              ? LevelProgress.fromJson(json['levelProgress'])
              : null,
      isEligibleForDiscount: json['isEligibleForDiscount'] ?? false,
      freeShipping: json['freeShipping'] ?? false,
      freeShippingNotice: json['freeShippingNotice'] ?? '',
      lebanonTechDiscount:
          json['lebanonTechDiscount'] != null
              ? LebanonTechDiscount.fromJson(json['lebanonTechDiscount'])
              : null,
      discountBreakdown:
          (json['discountBreakdown'] as List?)
              ?.map((item) => DiscountBreakdown.fromJson(item))
              .toList() ??
          [],
      firstOrderDiscount:
          json['firstOrderDiscount'] != null
              ? double.tryParse(json['firstOrderDiscount'].toString()) ?? 0.0
              : 0.0,
      firstOrderDiscountPercentage:
          json['firstOrderDiscountPercentage'] != null
              ? double.tryParse(json['firstOrderDiscountPercentage'].toString()) ?? 0.0
              : 0.0,
    );
  }
}

class DiscountBreakdown {
  String type;
  String name;
  double amount;
  double percentage;
  String message;

  DiscountBreakdown({
    required this.type,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.message,
  });

  factory DiscountBreakdown.fromJson(Map<String, dynamic> json) {
    return DiscountBreakdown(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      amount:
          json['amount'] != null
              ? double.tryParse(json['amount'].toString()) ?? 0.0
              : 0.0,
      percentage:
          json['percentage'] != null
              ? double.tryParse(json['percentage'].toString()) ?? 0.0
              : 0.0,
      message: json['message'] ?? '',
    );
  }
}

class Shop {
  ShopDetails shop;

  Shop({required this.shop});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(shop: ShopDetails.fromJson(json['shop'] ?? {}));
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
      balance:
          json['balance'] != null
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

  Banner({required this.message});

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(message: json['message'] ?? '');
  }
}

class Thumbnail {
  MediaUniversalModel? media;

  Thumbnail({this.media});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      media:
          json['media'] != null
              ? MediaUniversalModel.fromJson(json['media'])
              : null,
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

  Membership({required this.membershipPlan});

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
      price:
          json['price'] != null
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

  Features({required this.membershipPlanFeatures});

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      membershipPlanFeatures:
          (json['membership_plan_features'] as List?)
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
  ProductVariationShop? productVariation;
  CartItemVariation? cartVariation;
  double? originalPrice;
  double? displayDiscountedPrice;
  double? displayItemDiscount;
  double? displayDiscountPerUnit;
  double? itemTotal;
  double? itemDiscount;
  double? discountedPrice;

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
    this.cartVariation,
    this.itemTotal,
    this.itemDiscount,
    this.discountedPrice,
  });

  // Get variation attribute display strings like "Colors: Pink"
  List<String> getAttributeDisplayStrings() {
    final List<String> attributes = [];
    if (cartVariation?.productVariation?.attributes?.attributeItems != null) {
      for (var attrItem
          in cartVariation!.productVariation!.attributes!.attributeItems!) {
        final attrName = attrItem.attribute?.name ?? '';
        final itemName = attrItem.attributeItem?.name ?? '';
        if (attrName.isNotEmpty && itemName.isNotEmpty) {
          attributes.add('$attrName: $itemName');
        }
      }
    }
    return attributes;
  }

  // Get variation thumbnail URL if available, otherwise use product thumbnail
  String? getDisplayThumbnailUrl() {
    // First try to get variation thumbnail
    final variationMedia = cartVariation?.productVariation?.thumbnail?.media;
    if (variationMedia != null) {
      return variationMedia.optimizedMediaUrl ?? variationMedia.url;
    }
    // Fallback to product thumbnail
    return thumbnail.media?.optimizedMediaUrl ?? thumbnail.media?.url;
  }

  // Get the effective price (discounted if available)
  double getEffectivePrice() {
    return discountedPrice ?? displayDiscountedPrice ?? price;
  }

  // Check if item has discount
  bool get hasDiscount {
    return (discountedPrice != null && discountedPrice! < price) ||
        (displayDiscountedPrice != null && displayDiscountedPrice! < price);
  }

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
      price:
          json['price'] != null
              ? double.tryParse(json['price'].toString()) ?? 0.0
              : 0.0,
      originalPrice:
          json['original_price'] != null
              ? double.tryParse(json['original_price'].toString())
              : null,
      displayDiscountedPrice:
          json['displayDiscountedPrice'] != null
              ? double.tryParse(json['displayDiscountedPrice'].toString())
              : null,
      displayItemDiscount:
          json['display_item_discount'] != null
              ? double.tryParse(json['display_item_discount'].toString())
              : null,
      displayDiscountPerUnit:
          json['display_discount_per_unit'] != null
              ? double.tryParse(json['display_discount_per_unit'].toString())
              : null,
      cartVariation:
          json['product_variation'] != null
              ? CartItemVariation.fromJson(json['product_variation'])
              : null,
      itemTotal:
          json['item_total'] != null
              ? double.tryParse(json['item_total'].toString())
              : null,
      itemDiscount:
          json['item_discount'] != null
              ? double.tryParse(json['item_discount'].toString())
              : null,
      discountedPrice:
          json['discounted_price'] != null
              ? double.tryParse(json['discounted_price'].toString())
              : null,
    );
  }
}

// Cart item variation - different structure from product variations list
class CartItemVariation {
  CartVariationDetails? productVariation;

  CartItemVariation({this.productVariation});

  factory CartItemVariation.fromJson(Map<String, dynamic> json) {
    return CartItemVariation(
      productVariation:
          json['product_variation'] != null
              ? CartVariationDetails.fromJson(json['product_variation'])
              : null,
    );
  }
}

class CartVariationDetails {
  String? id;
  String? productId;
  String? thumbnailId;
  double? price;
  double? salePrice;
  int? stock;
  CartVariationAttributes? attributes;
  CartVariationThumbnail? thumbnail;

  CartVariationDetails({
    this.id,
    this.productId,
    this.thumbnailId,
    this.price,
    this.salePrice,
    this.stock,
    this.attributes,
    this.thumbnail,
  });

  factory CartVariationDetails.fromJson(Map<String, dynamic> json) {
    return CartVariationDetails(
      id: json['id'],
      productId: json['product_id'],
      thumbnailId: json['thumbnail_id'],
      price:
          json['price'] != null
              ? double.tryParse(json['price'].toString())
              : null,
      salePrice:
          json['sale_price'] != null
              ? double.tryParse(json['sale_price'].toString())
              : null,
      stock: json['stock'],
      attributes:
          json['attributes'] != null
              ? CartVariationAttributes.fromJson(json['attributes'])
              : null,
      thumbnail:
          json['thumbnail'] != null
              ? CartVariationThumbnail.fromJson(json['thumbnail'])
              : null,
    );
  }
}

class CartVariationAttributes {
  List<CartVariationAttributeItem>? attributeItems;

  CartVariationAttributes({this.attributeItems});

  factory CartVariationAttributes.fromJson(Map<String, dynamic> json) {
    return CartVariationAttributes(
      attributeItems:
          json['product_variation_attribute_items'] != null
              ? (json['product_variation_attribute_items'] as List)
                  .map((x) => CartVariationAttributeItem.fromJson(x))
                  .toList()
              : null,
    );
  }
}

class CartVariationAttributeItem {
  String? id;
  String? variationId;
  String? attributeId;
  String? attributeItemId;
  CartAttribute? attribute;
  CartAttributeItem? attributeItem;

  CartVariationAttributeItem({
    this.id,
    this.variationId,
    this.attributeId,
    this.attributeItemId,
    this.attribute,
    this.attributeItem,
  });

  factory CartVariationAttributeItem.fromJson(Map<String, dynamic> json) {
    return CartVariationAttributeItem(
      id: json['id'],
      variationId: json['variation_id'],
      attributeId: json['attribute_id'],
      attributeItemId: json['attribute_item_id'],
      attribute:
          json['attribute'] != null
              ? CartAttribute.fromJson(json['attribute'])
              : null,
      attributeItem:
          json['attribute_item'] != null
              ? CartAttributeItem.fromJson(json['attribute_item'])
              : null,
    );
  }
}

class CartAttribute {
  String? id;
  String? name;
  String? slug;

  CartAttribute({this.id, this.name, this.slug});

  factory CartAttribute.fromJson(Map<String, dynamic> json) {
    return CartAttribute(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}

class CartAttributeItem {
  String? id;
  String? attributeId;
  String? name;
  String? slug;
  String? value;

  CartAttributeItem({
    this.id,
    this.attributeId,
    this.name,
    this.slug,
    this.value,
  });

  factory CartAttributeItem.fromJson(Map<String, dynamic> json) {
    return CartAttributeItem(
      id: json['id'],
      attributeId: json['attribute_id'],
      name: json['name'],
      slug: json['slug'],
      value: json['value'],
    );
  }
}

class CartVariationThumbnail {
  CartVariationMedia? media;

  CartVariationThumbnail({this.media});

  factory CartVariationThumbnail.fromJson(Map<String, dynamic> json) {
    return CartVariationThumbnail(
      media:
          json['media'] != null && json['media'] is Map
              ? CartVariationMedia.fromJson(json['media'])
              : null,
    );
  }
}

class CartVariationMedia {
  String? id;
  String? url;
  String? optimizedMediaUrl;

  CartVariationMedia({this.id, this.url, this.optimizedMediaUrl});

  factory CartVariationMedia.fromJson(Map<String, dynamic> json) {
    return CartVariationMedia(
      id: json['id'],
      url: json['url'],
      optimizedMediaUrl: json['optimized_media_url'],
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
      levels:
          (json['levels'] as List?)
              ?.map((level) => Level.fromJson(level))
              .toList() ??
          [],
      currentLevel: json['currentLevel'],
      nextLevel: json['nextLevel'],
      progress:
          json['progress'] != null
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
      shopTotal:
          json['shopTotal'] != null
              ? double.tryParse(json['shopTotal'].toString()) ?? 0.0
              : 0.0,
      minSpent:
          json['minSpent'] != null
              ? double.tryParse(json['minSpent'].toString()) ?? 0.0
              : 0.0,
      discount:
          json['discount'] != null
              ? double.tryParse(json['discount'].toString()) ?? 0.0
              : 0.0,
      bonus:
          json['bonus'] != null
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
      discountAmount:
          json['discountAmount'] != null
              ? double.tryParse(json['discountAmount'].toString()) ?? 0.0
              : 0.0,
      discountPercentage:
          json['discountPercentage'] != null
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
      levels:
          (json['levels'] as List?)
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
      minSpent:
          json['minSpent'] != null
              ? double.tryParse(json['minSpent'].toString()) ?? 0.0
              : 0.0,
      discount:
          json['discount'] != null
              ? double.tryParse(json['discount'].toString()) ?? 0.0
              : 0.0,
      bonus:
          json['bonus'] != null
              ? double.tryParse(json['bonus'].toString()) ?? 0.0
              : 0.0,
      referrelEarnings:
          json['referrel_earnings'] != null
              ? double.tryParse(json['referrel_earnings'].toString()) ?? 0.0
              : 0.0,
    );
  }
}

// Extensions for accessing size name from ProductVariationShop
extension ItemSizeExtension on Item {
  String getSizeName() {
    try {
      final variation = productVariation;
      if (variation != null) {
        // Method 1: Try to access the variation structure
        try {
          final dynamic dynVariation = variation;

          // Check if ProductVariationShop has productVariation property
          if (dynVariation.productVariation != null) {
            final nested = dynVariation.productVariation;
            if (nested.attributes != null) {
              final attributes = nested.attributes;
              if (attributes.productVariationAttributeItems != null) {
                final items = attributes.productVariationAttributeItems;
                if (items is List && items.isNotEmpty) {
                  final firstItem = items.first;
                  if (firstItem.attributeItem != null &&
                      firstItem.attributeItem.name != null) {
                    return firstItem.attributeItem.name;
                  }
                }
              }
            }
          }

          // Try direct attributes access
          if (dynVariation.attributes != null) {
            final attributes = dynVariation.attributes;
            if (attributes.productVariationAttributeItems != null) {
              final items = attributes.productVariationAttributeItems;
              if (items is List && items.isNotEmpty) {
                final firstItem = items.first;
                if (firstItem.attributeItem != null &&
                    firstItem.attributeItem.name != null) {
                  return firstItem.attributeItem.name;
                }
              }
            }
          }
        } catch (e) {
          print('Direct access failed: $e');
        }

        // Method 2: String parsing fallback
        try {
          final String variationStr = variation.toString();

          // Look for size patterns in the string representation
          final RegExp sizePattern = RegExp(
            r'\b(XS|S|Small|M|Medium|L|Large|XL|XXL|2XL|3XL)\b',
            caseSensitive: false,
          );
          final match = sizePattern.firstMatch(variationStr);
          if (match != null) {
            final String foundSize = match.group(0)!;
            // Normalize the size name
            switch (foundSize.toLowerCase()) {
              case 's':
                return 'Small';
              case 'm':
                return 'Medium';
              case 'l':
                return 'Large';
              case 'XL':
                return 'Xtra Large';
              default:
                return foundSize;
            }
          }
        } catch (e) {
          print('String parsing failed: $e');
        }
      }
    } catch (e) {
      print('Error getting size name: $e');
    }

    // Fallback to product name
    return product.name;
  }

  String getDisplayNameWithSize() {
    final sizeName = getSizeName();
    if (sizeName != product.name && !product.name.contains(sizeName)) {
      return '${product.name} - $sizeName';
    }
    return product.name;
  }
}

// Debug extension to help identify ProductVariationShop structure
extension DebugItemExtension on Item {
  void debugProductVariation() {
    print('=== DEBUG PRODUCT VARIATION ===');
    print('Product name: ${product.name}');
    print('ProductVariation exists: ${productVariation != null}');

    if (productVariation != null) {
      print('ProductVariation type: ${productVariation.runtimeType}');
      print('ProductVariation toString: ${productVariation.toString()}');

      try {
        final dynamic variation = productVariation;
        print('Available properties in variation:');

        // Check common properties
        try {
          print('- Has attributes: ${variation.attributes != null}');
        } catch (e) {
          print('- No attributes property');
        }

        try {
          print(
            '- Has productVariation: ${variation.productVariation != null}',
          );
        } catch (e) {
          print('- No productVariation property');
        }

        try {
          print('- Has variations: ${variation.variations != null}');
        } catch (e) {
          print('- No variations property');
        }

        try {
          print('- Has name: ${variation.name != null}');
        } catch (e) {
          print('- No name property');
        }
      } catch (e) {
        print('Error accessing variation properties: $e');
      }
    }
    print('=== END DEBUG ===');
  }
}
