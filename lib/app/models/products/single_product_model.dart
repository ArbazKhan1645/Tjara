// ignore_for_file: non_constant_identifier_names

import 'package:tjara/app/models/media_model/media_model.dart';
import 'package:tjara/app/models/products/variation.dart';

class SingleModelClass {
  SingleModelClass({required this.product});

  final Product? product;

  SingleModelClass copyWith({Product? product}) {
    return SingleModelClass(product: product ?? this.product);
  }

  factory SingleModelClass.fromJson(Map<String, dynamic> json) {
    return SingleModelClass(
      product:
          json["product"] == null ? null : Product.fromJson(json["product"]),
    );
  }

  Map<String, dynamic> toJson() => {"product": product?.toJson()};

  @override
  String toString() {
    return "$product, ";
  }
}

class Product {
  Product({
    required this.id,
    required this.prevId,
    required this.shopId,
    required this.variation,
    required this.slug,
    required this.name,
    required this.productType,
    required this.productGroup,
    required this.thumbnailId,
    required this.description,
    required this.stock,
    required this.isFeatured,
    required this.isDeal,
    required this.price,
    required this.salePrice,
    required this.reservedPrice,
    required this.auctionStartTime,
    required this.auctionEndTime,
    required this.winnerId,
    required this.minPrice,
    required this.maxPrice,
    required this.saleStartTime,
    required this.saleEndTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnail,
    required this.shop,
    required this.categories,
    required this.brands,
    required this.video,
    required this.model,
    required this.year,
    required this.meta,
    required this.gallery,
    // New nullable fields
    this.hasGlobalPromotion,
    this.discountInfo,
    this.appliedPromotions,
    this.bids,
    this.delivery,
    this.estimatedDeliveryCost,
    this.estimatedDeliveryTime,
    this.reviews,
  });

  final String id;
  final dynamic prevId;
  final String shopId;
  final String slug;
  final String name;
  final String productType;
  final String productGroup;
  final String thumbnailId;
  final String description;
  final num stock;
  final num isFeatured;
  final num isDeal;
  final num price;
  final num salePrice;
  final dynamic reservedPrice;
  final dynamic auctionStartTime;
  final dynamic auctionEndTime;
  final dynamic winnerId;
  final dynamic minPrice;
  final dynamic maxPrice;
  final dynamic saleStartTime;
  final dynamic saleEndTime;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ThumbnailElement? thumbnail;
  final ProductShop? shop;
  final Brands? categories;
  final Brands? brands;
  final Video? video;
  final Brands? model;
  final Brands? year;
  final ProductMeta? meta;
  final List<ThumbnailElement> gallery;
  final ProductVariationShop? variation;

  // New nullable fields
  final bool? hasGlobalPromotion;
  final dynamic discountInfo;
  final List<dynamic>? appliedPromotions;
  final ProductBids? bids;
  final ProductDelivery? delivery;
  final num? estimatedDeliveryCost;
  final String? estimatedDeliveryTime;
  final dynamic reviews;

  Product copyWith({
    String? id,
    dynamic prevId,
    String? shopId,
    String? slug,
    String? name,
    String? productType,
    String? productGroup,
    String? thumbnailId,
    ProductVariationShop? variation,
    String? description,
    num? stock,
    num? isFeatured,
    num? isDeal,
    num? price,
    num? salePrice,
    dynamic reservedPrice,
    dynamic auctionStartTime,
    dynamic auctionEndTime,
    dynamic winnerId,
    dynamic minPrice,
    dynamic maxPrice,
    dynamic saleStartTime,
    dynamic saleEndTime,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    ThumbnailElement? thumbnail,
    ProductShop? shop,
    Brands? categories,
    Brands? brands,
    Video? video,
    Brands? model,
    Brands? year,
    ProductMeta? meta,
    List<ThumbnailElement>? gallery,
    // New nullable fields
    bool? hasGlobalPromotion,
    dynamic discountInfo,
    List<dynamic>? appliedPromotions,
    ProductBids? bids,
    ProductDelivery? delivery,
    num? estimatedDeliveryCost,
    String? estimatedDeliveryTime,
    dynamic reviews,
  }) {
    return Product(
      id: id ?? this.id,
      prevId: prevId ?? this.prevId,
      shopId: shopId ?? this.shopId,
      slug: slug ?? this.slug,
      variation: variation ?? this.variation,
      name: name ?? this.name,
      productType: productType ?? this.productType,
      productGroup: productGroup ?? this.productGroup,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      isDeal: isDeal ?? this.isDeal,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      reservedPrice: reservedPrice ?? this.reservedPrice,
      auctionStartTime: auctionStartTime ?? this.auctionStartTime,
      auctionEndTime: auctionEndTime ?? this.auctionEndTime,
      winnerId: winnerId ?? this.winnerId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      saleStartTime: saleStartTime ?? this.saleStartTime,
      saleEndTime: saleEndTime ?? this.saleEndTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      shop: shop ?? this.shop,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      video: video ?? this.video,
      model: model ?? this.model,
      year: year ?? this.year,
      meta: meta ?? this.meta,
      gallery: gallery ?? this.gallery,
      // New nullable fields
      hasGlobalPromotion: hasGlobalPromotion ?? this.hasGlobalPromotion,
      discountInfo: discountInfo ?? this.discountInfo,
      appliedPromotions: appliedPromotions ?? this.appliedPromotions,
      bids: bids ?? this.bids,
      delivery: delivery ?? this.delivery,
      estimatedDeliveryCost:
          estimatedDeliveryCost ?? this.estimatedDeliveryCost,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      reviews: reviews ?? this.reviews,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"] ?? "",
      prevId: json["prev_id"],
      shopId: json["shop_id"] ?? "",
      slug: json["slug"] ?? "",
      name: json["name"] ?? "N/A",
      productType: json["product_type"] ?? "",
      productGroup: json["product_group"] ?? "",
      thumbnailId: json["thumbnail_id"] ?? "",
      description: json["description"] ?? "",
      stock: json["stock"] ?? 0,
      isFeatured: json["is_featured"] ?? 0,
      isDeal: json["is_deal"] ?? 0,
      price: json["price"] ?? 0,
      salePrice: json["sale_price"] ?? 0,
      reservedPrice: json["reserved_price"],
      auctionStartTime: json["auction_start_time"],
      auctionEndTime: json["auction_end_time"],
      winnerId: json["winner_id"],
      minPrice: json["min_price"],
      maxPrice: json["max_price"],
      saleStartTime: json["sale_start_time"],
      saleEndTime: json["sale_end_time"],
      status: json["status"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      thumbnail:
          json["thumbnail"] == null
              ? null
              : ThumbnailElement.fromJson(json["thumbnail"]),
      shop: json["shop"] == null ? null : ProductShop.fromJson(json["shop"]),
      variation:
          json["variations"] == null
              ? null
              : ProductVariationShop.fromJson(json["variations"]),
      categories:
          json["categories"] == null
              ? null
              : Brands.fromJson(json["categories"]),
      brands: json["brands"] == null ? null : Brands.fromJson(json["brands"]),
      video: json["video"] == null ? null : Video.fromJson(json["video"]),
      model: json["model"] == null ? null : Brands.fromJson(json["model"]),
      year: json["year"] == null ? null : Brands.fromJson(json["year"]),
      meta: json["meta"] == null ? null : ProductMeta.fromJson(json["meta"]),
      gallery:
          json["gallery"] == null
              ? []
              : List<ThumbnailElement>.from(
                json["gallery"]!.map((x) => ThumbnailElement.fromJson(x)),
              ),
      // New nullable fields
      hasGlobalPromotion: json["has_global_promotion"],
      discountInfo: json["discount_info"],
      appliedPromotions:
          json["applied_promotions"] == null
              ? null
              : List<dynamic>.from(json["applied_promotions"]),
      bids: json["bids"] == null ? null : ProductBids.fromJson(json["bids"]),
      delivery:
          json["delivery"] == null
              ? null
              : ProductDelivery.fromJson(json["delivery"]),
      estimatedDeliveryCost: json["estimated_delivery_cost"],
      estimatedDeliveryTime: json["estimated_delivery_time"],
      reviews: json["reviews"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "prev_id": prevId,
    "shop_id": shopId,
    "slug": slug,
    "name": name,
    "product_type": productType,
    "product_group": productGroup,
    "thumbnail_id": thumbnailId,
    "description": description,
    "stock": stock,
    "is_featured": isFeatured,
    "is_deal": isDeal,
    "price": price,
    "sale_price": salePrice,
    "reserved_price": reservedPrice,
    "auction_start_time": auctionStartTime,
    "auction_end_time": auctionEndTime,
    "winner_id": winnerId,
    "min_price": minPrice,
    "max_price": maxPrice,
    "sale_start_time": saleStartTime,
    "sale_end_time": saleEndTime,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "thumbnail": thumbnail?.toJson(),
    "shop": shop?.toJson(),
    "categories": categories?.toJson(),
    "brands": brands?.toJson(),
    "video": video?.toJson(),
    "model": model?.toJson(),
    "year": year?.toJson(),
    "meta": meta?.toJson(),
    "gallery": gallery.map((x) => x.toJson()).toList(),
    // New nullable fields
    "has_global_promotion": hasGlobalPromotion,
    "discount_info": discountInfo,
    "applied_promotions": appliedPromotions,
    "bids": bids?.toJson(),
    "delivery": delivery?.toJson(),
    "estimated_delivery_cost": estimatedDeliveryCost,
    "estimated_delivery_time": estimatedDeliveryTime,
    "reviews": reviews,
  };

  @override
  String toString() {
    return "$id, $prevId, $shopId, $slug, $name, $productType, $productGroup, $thumbnailId, $description, $stock, $isFeatured, $isDeal, $price, $salePrice, $reservedPrice, $auctionStartTime, $auctionEndTime, $winnerId, $minPrice, $maxPrice, $saleStartTime, $saleEndTime, $status, $createdAt, $updatedAt, $thumbnail, $shop, $categories, $brands, $video, $model, $year, $meta, $gallery, ";
  }
}

// ==================== NEW CLASSES FOR BIDS ====================

class ProductBids {
  ProductBids({this.totalBids, this.highestBid, this.bids, this.isReserveMet});

  final int? totalBids;
  final num? highestBid;
  final List<Bid>? bids;
  final bool? isReserveMet;

  ProductBids copyWith({
    int? totalBids,
    num? highestBid,
    List<Bid>? bids,
    bool? isReserveMet,
  }) {
    return ProductBids(
      totalBids: totalBids ?? this.totalBids,
      highestBid: highestBid ?? this.highestBid,
      bids: bids ?? this.bids,
      isReserveMet: isReserveMet ?? this.isReserveMet,
    );
  }

  factory ProductBids.fromJson(Map<String, dynamic> json) {
    return ProductBids(
      totalBids: json["total_bids"],
      highestBid: json["highest_bid"],
      bids:
          json["bids"] == null
              ? null
              : List<Bid>.from(json["bids"].map((x) => Bid.fromJson(x))),
      isReserveMet: json["is_reserve_met"],
    );
  }

  Map<String, dynamic> toJson() => {
    "total_bids": totalBids,
    "highest_bid": highestBid,
    "bids": bids?.map((x) => x.toJson()).toList(),
    "is_reserve_met": isReserveMet,
  };

  @override
  String toString() {
    return "ProductBids(totalBids: $totalBids, highestBid: $highestBid, isReserveMet: $isReserveMet)";
  }
}

class Bid {
  Bid({
    this.id,
    this.userId,
    this.productId,
    this.auctionBidPrice,
    this.createdAt,
    this.updatedAt,
    this.bidder,
    this.hasMetReservedPrice,
  });

  final String? id;
  final String? userId;
  final String? productId;
  final num? auctionBidPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Bidder? bidder;
  final bool? hasMetReservedPrice;

  Bid copyWith({
    String? id,
    String? userId,
    String? productId,
    num? auctionBidPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    Bidder? bidder,
    bool? hasMetReservedPrice,
  }) {
    return Bid(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      auctionBidPrice: auctionBidPrice ?? this.auctionBidPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bidder: bidder ?? this.bidder,
      hasMetReservedPrice: hasMetReservedPrice ?? this.hasMetReservedPrice,
    );
  }

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json["id"],
      userId: json["user_id"],
      productId: json["product_id"],
      auctionBidPrice: json["auction_bid_price"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      bidder: json["bidder"] == null ? null : Bidder.fromJson(json["bidder"]),
      hasMetReservedPrice: json["has_met_reserved_price"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "product_id": productId,
    "auction_bid_price": auctionBidPrice,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "bidder": bidder?.toJson(),
    "has_met_reserved_price": hasMetReservedPrice,
  };

  @override
  String toString() {
    return "Bid(id: $id, auctionBidPrice: $auctionBidPrice, hasMetReservedPrice: $hasMetReservedPrice)";
  }
}

class Bidder {
  Bidder({
    this.id,
    this.prevId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.thumbnailId,
    this.authToken,
    this.phoneVerificationCode,
    this.emailVerifiedAt,
    this.role,
    this.roles,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isBlockedFromBidding,
    this.isGloballyBlocked,
    this.isProductBlocked,
    this.blockNote,
    this.blockType,
  });

  final String? id;
  final dynamic prevId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? thumbnailId;
  final String? authToken;
  final String? phoneVerificationCode;
  final String? emailVerifiedAt;
  final String? role;
  final String? roles;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isBlockedFromBidding;
  final bool? isGloballyBlocked;
  final bool? isProductBlocked;
  final String? blockNote;
  final String? blockType;

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();

  Bidder copyWith({
    String? id,
    dynamic prevId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? thumbnailId,
    String? authToken,
    String? phoneVerificationCode,
    String? emailVerifiedAt,
    String? role,
    String? roles,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBlockedFromBidding,
    bool? isGloballyBlocked,
    bool? isProductBlocked,
    String? blockNote,
    String? blockType,
  }) {
    return Bidder(
      id: id ?? this.id,
      prevId: prevId ?? this.prevId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      authToken: authToken ?? this.authToken,
      phoneVerificationCode:
          phoneVerificationCode ?? this.phoneVerificationCode,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBlockedFromBidding: isBlockedFromBidding ?? this.isBlockedFromBidding,
      isGloballyBlocked: isGloballyBlocked ?? this.isGloballyBlocked,
      isProductBlocked: isProductBlocked ?? this.isProductBlocked,
      blockNote: blockNote ?? this.blockNote,
      blockType: blockType ?? this.blockType,
    );
  }

  factory Bidder.fromJson(Map<String, dynamic> json) {
    return Bidder(
      id: json["id"],
      prevId: json["prev_id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      email: json["email"],
      phone: json["phone"],
      thumbnailId: json["thumbnail_id"],
      authToken: json["authToken"],
      phoneVerificationCode: json["phone_verification_code"],
      emailVerifiedAt: json["email_verified_at"],
      role: json["role"],
      roles: json["roles"],
      status: json["status"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      isBlockedFromBidding: json["is_blocked_from_bidding"],
      isGloballyBlocked: json["is_globally_blocked"],
      isProductBlocked: json["is_product_blocked"],
      blockNote: json["block_note"],
      blockType: json["block_type"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "prev_id": prevId,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "thumbnail_id": thumbnailId,
    "authToken": authToken,
    "phone_verification_code": phoneVerificationCode,
    "email_verified_at": emailVerifiedAt,
    "role": role,
    "roles": roles,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "is_blocked_from_bidding": isBlockedFromBidding,
    "is_globally_blocked": isGloballyBlocked,
    "is_product_blocked": isProductBlocked,
    "block_note": blockNote,
    "block_type": blockType,
  };

  @override
  String toString() {
    return "Bidder(id: $id, fullName: $fullName, email: $email)";
  }
}

// ==================== NEW CLASSES FOR DELIVERY ====================

class ProductDelivery {
  ProductDelivery({
    this.provider,
    this.available,
    this.options,
    this.supportedAreas,
    this.features,
  });

  final String? provider;
  final bool? available;
  final List<DeliveryOption>? options;
  final List<String>? supportedAreas;
  final DeliveryFeatures? features;

  ProductDelivery copyWith({
    String? provider,
    bool? available,
    List<DeliveryOption>? options,
    List<String>? supportedAreas,
    DeliveryFeatures? features,
  }) {
    return ProductDelivery(
      provider: provider ?? this.provider,
      available: available ?? this.available,
      options: options ?? this.options,
      supportedAreas: supportedAreas ?? this.supportedAreas,
      features: features ?? this.features,
    );
  }

  factory ProductDelivery.fromJson(Map<String, dynamic> json) {
    return ProductDelivery(
      provider: json["provider"],
      available: json["available"],
      options:
          json["options"] == null
              ? null
              : List<DeliveryOption>.from(
                json["options"].map((x) => DeliveryOption.fromJson(x)),
              ),
      supportedAreas:
          json["supported_areas"] == null
              ? null
              : List<String>.from(
                json["supported_areas"].map((x) => x.toString()),
              ),
      features:
          json["features"] == null
              ? null
              : DeliveryFeatures.fromJson(json["features"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "provider": provider,
    "available": available,
    "options": options?.map((x) => x.toJson()).toList(),
    "supported_areas": supportedAreas,
    "features": features?.toJson(),
  };

  @override
  String toString() {
    return "ProductDelivery(provider: $provider, available: $available)";
  }
}

class DeliveryOption {
  DeliveryOption({
    this.type,
    this.name,
    this.description,
    this.cost,
    this.currency,
    this.estimatedTime,
    this.vehicleType,
    this.available,
  });

  final String? type;
  final String? name;
  final String? description;
  final num? cost;
  final String? currency;
  final String? estimatedTime;
  final int? vehicleType;
  final bool? available;

  DeliveryOption copyWith({
    String? type,
    String? name,
    String? description,
    num? cost,
    String? currency,
    String? estimatedTime,
    int? vehicleType,
    bool? available,
  }) {
    return DeliveryOption(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      vehicleType: vehicleType ?? this.vehicleType,
      available: available ?? this.available,
    );
  }

  factory DeliveryOption.fromJson(Map<String, dynamic> json) {
    return DeliveryOption(
      type: json["type"],
      name: json["name"],
      description: json["description"],
      cost: json["cost"],
      currency: json["currency"],
      estimatedTime: json["estimated_time"],
      vehicleType: json["vehicle_type"],
      available: json["available"],
    );
  }

  Map<String, dynamic> toJson() => {
    "type": type,
    "name": name,
    "description": description,
    "cost": cost,
    "currency": currency,
    "estimated_time": estimatedTime,
    "vehicle_type": vehicleType,
    "available": available,
  };

  @override
  String toString() {
    return "DeliveryOption(type: $type, name: $name, cost: $cost)";
  }
}

class DeliveryFeatures {
  DeliveryFeatures({
    this.cashOnDelivery,
    this.tracking,
    this.insurance,
    this.scheduledDelivery,
  });

  final bool? cashOnDelivery;
  final bool? tracking;
  final bool? insurance;
  final bool? scheduledDelivery;

  DeliveryFeatures copyWith({
    bool? cashOnDelivery,
    bool? tracking,
    bool? insurance,
    bool? scheduledDelivery,
  }) {
    return DeliveryFeatures(
      cashOnDelivery: cashOnDelivery ?? this.cashOnDelivery,
      tracking: tracking ?? this.tracking,
      insurance: insurance ?? this.insurance,
      scheduledDelivery: scheduledDelivery ?? this.scheduledDelivery,
    );
  }

  factory DeliveryFeatures.fromJson(Map<String, dynamic> json) {
    return DeliveryFeatures(
      cashOnDelivery: json["cash_on_delivery"],
      tracking: json["tracking"],
      insurance: json["insurance"],
      scheduledDelivery: json["scheduled_delivery"],
    );
  }

  Map<String, dynamic> toJson() => {
    "cash_on_delivery": cashOnDelivery,
    "tracking": tracking,
    "insurance": insurance,
    "scheduled_delivery": scheduledDelivery,
  };

  @override
  String toString() {
    return "DeliveryFeatures(cashOnDelivery: $cashOnDelivery, tracking: $tracking)";
  }
}

// ==================== EXISTING CLASSES (UNCHANGED) ====================

class Brands {
  Brands({required this.productAttributeItems});

  final List<ProductAttributeItemElement> productAttributeItems;

  Brands copyWith({List<ProductAttributeItemElement>? productAttributeItems}) {
    return Brands(
      productAttributeItems:
          productAttributeItems ?? this.productAttributeItems,
    );
  }

  factory Brands.fromJson(Map<String, dynamic> json) {
    return Brands(
      productAttributeItems:
          json["product_attribute_items"] == null
              ? []
              : List<ProductAttributeItemElement>.from(
                json["product_attribute_items"]!.map(
                  (x) => ProductAttributeItemElement.fromJson(x),
                ),
              ),
    );
  }

  Map<String, dynamic> toJson() => {
    "product_attribute_items":
        productAttributeItems.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$productAttributeItems, ";
  }
}

class ProductAttributeItemElement {
  ProductAttributeItemElement({
    required this.id,
    required this.productId,
    required this.attributeId,
    required this.attributeItemId,
    required this.createdAt,
    required this.updatedAt,
    required this.attributeItem,
  });

  final String id;
  final String productId;
  final String attributeId;
  final String attributeItemId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AttributeItem? attributeItem;

  ProductAttributeItemElement copyWith({
    String? id,
    String? productId,
    String? attributeId,
    String? attributeItemId,
    DateTime? createdAt,
    DateTime? updatedAt,
    AttributeItem? attributeItem,
  }) {
    return ProductAttributeItemElement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      attributeId: attributeId ?? this.attributeId,
      attributeItemId: attributeItemId ?? this.attributeItemId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attributeItem: attributeItem ?? this.attributeItem,
    );
  }

  factory ProductAttributeItemElement.fromJson(Map<String, dynamic> json) {
    return ProductAttributeItemElement(
      id: json["id"] ?? "",
      productId: json["product_id"] ?? "",
      attributeId: json["attribute_id"] ?? "",
      attributeItemId: json["attribute_item_id"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      attributeItem:
          json["attribute_item"] == null
              ? null
              : AttributeItem.fromJson(json["attribute_item"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "attribute_id": attributeId,
    "attribute_item_id": attributeItemId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "attribute_item": attributeItem?.toJson(),
  };

  @override
  String toString() {
    return "$id, $productId, $attributeId, $attributeItemId, $createdAt, $updatedAt, $attributeItem, ";
  }
}

class AttributeItem {
  AttributeItem({required this.productAttributeItem});

  final AttributeItemProductAttributeItem? productAttributeItem;

  AttributeItem copyWith({
    AttributeItemProductAttributeItem? productAttributeItem,
  }) {
    return AttributeItem(
      productAttributeItem: productAttributeItem ?? this.productAttributeItem,
    );
  }

  factory AttributeItem.fromJson(Map<String, dynamic> json) {
    return AttributeItem(
      productAttributeItem:
          json["product_attribute_item"] == null
              ? null
              : AttributeItemProductAttributeItem.fromJson(
                json["product_attribute_item"],
              ),
    );
  }

  Map<String, dynamic> toJson() => {
    "product_attribute_item": productAttributeItem?.toJson(),
  };

  @override
  String toString() {
    return "$productAttributeItem, ";
  }
}

class AttributeItemProductAttributeItem {
  AttributeItemProductAttributeItem({
    required this.id,
    required this.attributeId,
    required this.name,
    required this.slug,
    required this.value,
    required this.postType,
    required this.parentId,
    required this.thumbnailId,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnail,
    required this.parent,
  });

  final String id;
  final String attributeId;
  final String name;
  final String slug;
  final dynamic value;
  final String postType;
  final String parentId;
  final String thumbnailId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProductAttributeItemThumbnail? thumbnail;
  final dynamic parent;

  AttributeItemProductAttributeItem copyWith({
    String? id,
    String? attributeId,
    String? name,
    String? slug,
    dynamic value,
    String? postType,
    String? parentId,
    String? thumbnailId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductAttributeItemThumbnail? thumbnail,
    dynamic parent,
  }) {
    return AttributeItemProductAttributeItem(
      id: id ?? this.id,
      attributeId: attributeId ?? this.attributeId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      value: value ?? this.value,
      postType: postType ?? this.postType,
      parentId: parentId ?? this.parentId,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      parent: parent ?? this.parent,
    );
  }

  factory AttributeItemProductAttributeItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttributeItemProductAttributeItem(
      id: json["id"] ?? "",
      attributeId: json["attribute_id"] ?? "",
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      value: json["value"],
      postType: json["post_type"] ?? "",
      parentId: json["parent_id"] ?? "",
      thumbnailId: json["thumbnail_id"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      thumbnail:
          json["thumbnail"] == null
              ? null
              : ProductAttributeItemThumbnail.fromJson(json["thumbnail"]),
      parent: json["parent"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "attribute_id": attributeId,
    "name": name,
    "slug": slug,
    "value": value,
    "post_type": postType,
    "parent_id": parentId,
    "thumbnail_id": thumbnailId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "thumbnail": thumbnail?.toJson(),
    "parent": parent,
  };

  @override
  String toString() {
    return "$id, $attributeId, $name, $slug, $value, $postType, $parentId, $thumbnailId, $createdAt, $updatedAt, $thumbnail, $parent, ";
  }
}

class PurpleParent {
  PurpleParent({
    required this.id,
    required this.attributeId,
    required this.name,
    required this.slug,
    required this.value,
    required this.postType,
    required this.parentId,
    required this.thumbnailId,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnail,
    required this.parent,
  });

  final String id;
  final String attributeId;
  final String name;
  final String slug;
  final dynamic value;
  final String postType;
  final String parentId;
  final String thumbnailId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ThumbnailElement? thumbnail;
  final FluffyParent? parent;

  PurpleParent copyWith({
    String? id,
    String? attributeId,
    String? name,
    String? slug,
    dynamic value,
    String? postType,
    String? parentId,
    String? thumbnailId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ThumbnailElement? thumbnail,
    FluffyParent? parent,
  }) {
    return PurpleParent(
      id: id ?? this.id,
      attributeId: attributeId ?? this.attributeId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      value: value ?? this.value,
      postType: postType ?? this.postType,
      parentId: parentId ?? this.parentId,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      parent: parent ?? this.parent,
    );
  }

  factory PurpleParent.fromJson(Map<String, dynamic> json) {
    return PurpleParent(
      id: json["id"] ?? "",
      attributeId: json["attribute_id"] ?? "",
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      value: json["value"],
      postType: json["post_type"] ?? "",
      parentId: json["parent_id"] ?? "",
      thumbnailId: json["thumbnail_id"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      thumbnail:
          json["thumbnail"] == null
              ? null
              : ThumbnailElement.fromJson(json["thumbnail"]),
      parent:
          json["parent"] == null ? null : FluffyParent.fromJson(json["parent"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "attribute_id": attributeId,
    "name": name,
    "slug": slug,
    "value": value,
    "post_type": postType,
    "parent_id": parentId,
    "thumbnail_id": thumbnailId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "thumbnail": thumbnail?.toJson(),
    "parent": parent?.toJson(),
  };

  @override
  String toString() {
    return "$id, $attributeId, $name, $slug, $value, $postType, $parentId, $thumbnailId, $createdAt, $updatedAt, $thumbnail, $parent, ";
  }
}

class FluffyParent {
  FluffyParent({
    required this.id,
    required this.attributeId,
    required this.name,
    required this.slug,
    required this.value,
    required this.postType,
    required this.parentId,
    required this.thumbnailId,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnail,
    required this.parent,
  });

  final String id;
  final String attributeId;
  final String name;
  final String slug;
  final dynamic value;
  final String postType;
  final String parentId;
  final String thumbnailId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ThumbnailElement? thumbnail;
  final TentacledParent? parent;

  FluffyParent copyWith({
    String? id,
    String? attributeId,
    String? name,
    String? slug,
    dynamic value,
    String? postType,
    String? parentId,
    String? thumbnailId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ThumbnailElement? thumbnail,
    TentacledParent? parent,
  }) {
    return FluffyParent(
      id: id ?? this.id,
      attributeId: attributeId ?? this.attributeId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      value: value ?? this.value,
      postType: postType ?? this.postType,
      parentId: parentId ?? this.parentId,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      parent: parent ?? this.parent,
    );
  }

  factory FluffyParent.fromJson(Map<String, dynamic> json) {
    return FluffyParent(
      id: json["id"] ?? "",
      attributeId: json["attribute_id"] ?? "",
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      value: json["value"],
      postType: json["post_type"] ?? "",
      parentId: json["parent_id"] ?? "",
      thumbnailId: json["thumbnail_id"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      thumbnail:
          json["thumbnail"] == null
              ? null
              : ThumbnailElement.fromJson(json["thumbnail"]),
      parent:
          json["parent"] == null
              ? null
              : TentacledParent.fromJson(json["parent"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "attribute_id": attributeId,
    "name": name,
    "slug": slug,
    "value": value,
    "post_type": postType,
    "parent_id": parentId,
    "thumbnail_id": thumbnailId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "thumbnail": thumbnail?.toJson(),
    "parent": parent?.toJson(),
  };

  @override
  String toString() {
    return "$id, $attributeId, $name, $slug, $value, $postType, $parentId, $thumbnailId, $createdAt, $updatedAt, $thumbnail, $parent, ";
  }
}

class TentacledParent {
  TentacledParent({
    required this.id,
    required this.attributeId,
    required this.name,
    required this.slug,
    required this.value,
    required this.postType,
    required this.parentId,
    required this.thumbnailId,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnail,
    required this.parent,
  });

  final String id;
  final String attributeId;
  final String name;
  final String slug;
  final dynamic value;
  final String postType;
  final String parentId;
  final String thumbnailId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ThumbnailElement? thumbnail;
  final StickyParent? parent;

  TentacledParent copyWith({
    String? id,
    String? attributeId,
    String? name,
    String? slug,
    dynamic value,
    String? postType,
    String? parentId,
    String? thumbnailId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ThumbnailElement? thumbnail,
    StickyParent? parent,
  }) {
    return TentacledParent(
      id: id ?? this.id,
      attributeId: attributeId ?? this.attributeId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      value: value ?? this.value,
      postType: postType ?? this.postType,
      parentId: parentId ?? this.parentId,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      parent: parent ?? this.parent,
    );
  }

  factory TentacledParent.fromJson(Map<String, dynamic> json) {
    return TentacledParent(
      id: json["id"] ?? "",
      attributeId: json["attribute_id"] ?? "",
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      value: json["value"],
      postType: json["post_type"] ?? "",
      parentId: json["parent_id"] ?? "",
      thumbnailId: json["thumbnail_id"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      thumbnail:
          json["thumbnail"] == null
              ? null
              : ThumbnailElement.fromJson(json["thumbnail"]),
      parent:
          json["parent"] == null ? null : StickyParent.fromJson(json["parent"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "attribute_id": attributeId,
    "name": name,
    "slug": slug,
    "value": value,
    "post_type": postType,
    "parent_id": parentId,
    "thumbnail_id": thumbnailId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "thumbnail": thumbnail?.toJson(),
    "parent": parent?.toJson(),
  };

  @override
  String toString() {
    return "$id, $attributeId, $name, $slug, $value, $postType, $parentId, $thumbnailId, $createdAt, $updatedAt, $thumbnail, $parent, ";
  }
}

class StickyParent {
  StickyParent({
    required this.id,
    required this.attributeId,
    required this.name,
    required this.slug,
    required this.value,
    required this.postType,
    required this.parentId,
    required this.thumbnailId,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnail,
    required this.parent,
  });

  final String id;
  final String attributeId;
  final String name;
  final String slug;
  final dynamic value;
  final String postType;
  final dynamic parentId;
  final String thumbnailId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ThumbnailElement? thumbnail;
  final String parent;

  StickyParent copyWith({
    String? id,
    String? attributeId,
    String? name,
    String? slug,
    dynamic value,
    String? postType,
    dynamic parentId,
    String? thumbnailId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ThumbnailElement? thumbnail,
    String? parent,
  }) {
    return StickyParent(
      id: id ?? this.id,
      attributeId: attributeId ?? this.attributeId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      value: value ?? this.value,
      postType: postType ?? this.postType,
      parentId: parentId ?? this.parentId,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      parent: parent ?? this.parent,
    );
  }

  factory StickyParent.fromJson(Map<String, dynamic> json) {
    return StickyParent(
      id: json["id"] ?? "",
      attributeId: json["attribute_id"] ?? "",
      name: json["name"] ?? "",
      slug: json["slug"] ?? "",
      value: json["value"],
      postType: json["post_type"] ?? "",
      parentId: json["parent_id"],
      thumbnailId: json["thumbnail_id"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      thumbnail:
          json["thumbnail"] == null
              ? null
              : ThumbnailElement.fromJson(json["thumbnail"]),
      parent: json["parent"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "attribute_id": attributeId,
    "name": name,
    "slug": slug,
    "value": value,
    "post_type": postType,
    "parent_id": parentId,
    "thumbnail_id": thumbnailId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "thumbnail": thumbnail?.toJson(),
    "parent": parent,
  };

  @override
  String toString() {
    return "$id, $attributeId, $name, $slug, $value, $postType, $parentId, $thumbnailId, $createdAt, $updatedAt, $thumbnail, $parent, ";
  }
}

class ThumbnailElement {
  ThumbnailElement({required this.media});

  final MediaUniversalModel? media;

  ThumbnailElement copyWith({MediaUniversalModel? media}) {
    return ThumbnailElement(media: media ?? this.media);
  }

  factory ThumbnailElement.fromJson(Map<String, dynamic> json) {
    return ThumbnailElement(
      media:
          json["media"] == null
              ? null
              : MediaUniversalModel.fromJson(json["media"]),
    );
  }

  Map<String, dynamic> toJson() => {"media": media?.toJson()};

  @override
  String toString() {
    return "$media, ";
  }
}

class Media {
  Media({
    required this.id,
    required this.url,
    required this.optimizedMediaUrl,
    required this.mediaType,
    required this.isUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String url;
  final String optimizedMediaUrl;
  final String mediaType;
  final dynamic isUsed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Media copyWith({
    String? id,
    String? url,
    String? optimizedMediaUrl,
    String? mediaType,
    dynamic isUsed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Media(
      id: id ?? this.id,
      url: url ?? this.url,
      optimizedMediaUrl: optimizedMediaUrl ?? this.optimizedMediaUrl,
      mediaType: mediaType ?? this.mediaType,
      isUsed: isUsed ?? this.isUsed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json["id"] ?? "",
      url: json["url"] ?? "",
      optimizedMediaUrl: json["optimized_media_url"] ?? "",
      mediaType: json["media_type"] ?? "",
      isUsed: json["is_used"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "optimized_media_url": optimizedMediaUrl,
    "media_type": mediaType,
    "is_used": isUsed,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$id, $url, $optimizedMediaUrl, $mediaType, $isUsed, $createdAt, $updatedAt, ";
  }
}

class ProductAttributeItemThumbnail {
  ProductAttributeItemThumbnail({required this.media, required this.message});

  final Media? media;
  final String message;

  ProductAttributeItemThumbnail copyWith({Media? media, String? message}) {
    return ProductAttributeItemThumbnail(
      media: media ?? this.media,
      message: message ?? this.message,
    );
  }

  factory ProductAttributeItemThumbnail.fromJson(Map<String, dynamic> json) {
    return ProductAttributeItemThumbnail(
      media: json["media"] == null ? null : Media.fromJson(json["media"]),
      message: json["message"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "media": media?.toJson(),
    "message": message,
  };

  @override
  String toString() {
    return "$media, $message, ";
  }
}

// ==================== UPDATED ProductMeta with new fields ====================

class ProductMeta {
  ProductMeta({
    required this.productId,
    required this.views,
    required this.gallery,
    required this.videoId,
    required this.countryId,
    // New nullable fields for auction
    this.shippingTimeFrom,
    this.sold,
    this.bidIncrementBy,
    this.auctionEnded,
    this.auctionEndedAt,
    this.auctionOrderNumber,
    this.auctionEndedReason,
    this.shippingTimeUnit,
    this.recentBuyer,
    this.shippingMethod,
    this.shippingCompany,
    this.shippingTimeTo,
    this.shippingFees,
    this.auctionScheduleType,
  });

  final String productId;
  final String views;
  final String gallery;
  final dynamic videoId;
  final String countryId;

  // New nullable fields
  final String? shippingTimeFrom;
  final String? sold;
  final String? bidIncrementBy;
  final String? auctionEnded;
  final String? auctionEndedAt;
  final String? auctionOrderNumber;
  final String? auctionEndedReason;
  final String? shippingTimeUnit;
  final String? recentBuyer;
  final String? shippingMethod;
  final String? shippingCompany;
  final String? shippingTimeTo;
  final String? shippingFees;
  final String? auctionScheduleType;

  ProductMeta copyWith({
    String? productId,
    String? views,
    String? gallery,
    dynamic videoId,
    String? countryId,
    String? shippingTimeFrom,
    String? sold,
    String? bidIncrementBy,
    String? auctionEnded,
    String? auctionEndedAt,
    String? auctionOrderNumber,
    String? auctionEndedReason,
    String? shippingTimeUnit,
    String? recentBuyer,
    String? shippingMethod,
    String? shippingCompany,
    String? shippingTimeTo,
    String? shippingFees,
    String? auctionScheduleType,
  }) {
    return ProductMeta(
      productId: productId ?? this.productId,
      views: views ?? this.views,
      gallery: gallery ?? this.gallery,
      videoId: videoId ?? this.videoId,
      countryId: countryId ?? this.countryId,
      shippingTimeFrom: shippingTimeFrom ?? this.shippingTimeFrom,
      sold: sold ?? this.sold,
      bidIncrementBy: bidIncrementBy ?? this.bidIncrementBy,
      auctionEnded: auctionEnded ?? this.auctionEnded,
      auctionEndedAt: auctionEndedAt ?? this.auctionEndedAt,
      auctionOrderNumber: auctionOrderNumber ?? this.auctionOrderNumber,
      auctionEndedReason: auctionEndedReason ?? this.auctionEndedReason,
      shippingTimeUnit: shippingTimeUnit ?? this.shippingTimeUnit,
      recentBuyer: recentBuyer ?? this.recentBuyer,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      shippingCompany: shippingCompany ?? this.shippingCompany,
      shippingTimeTo: shippingTimeTo ?? this.shippingTimeTo,
      shippingFees: shippingFees ?? this.shippingFees,
      auctionScheduleType: auctionScheduleType ?? this.auctionScheduleType,
    );
  }

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      productId: json["product_id"] ?? "",
      views: json["views"] ?? "",
      gallery: json["gallery"] ?? "",
      videoId: json["video_id"],
      countryId: json["country_id"] ?? "",
      shippingTimeFrom: json["shipping_time_from"]?.toString(),
      sold: json["sold"]?.toString(),
      bidIncrementBy: json["bid_increment_by"]?.toString(),
      auctionEnded: json["auction_ended"]?.toString(),
      auctionEndedAt: json["auction_ended_at"]?.toString(),
      auctionOrderNumber: json["auction_order_number"]?.toString(),
      auctionEndedReason: json["auction_ended_reason"]?.toString(),
      shippingTimeUnit: json["shipping_time_unit"]?.toString(),
      recentBuyer: json["recent_buyer"]?.toString(),
      shippingMethod: json["shipping_method"]?.toString(),
      shippingCompany: json["shipping_company"]?.toString(),
      shippingTimeTo: json["shipping_time_to"]?.toString(),
      shippingFees: json["shipping_fees"]?.toString(),
      auctionScheduleType: json["auction_schedule_type"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "views": views,
    "gallery": gallery,
    "video_id": videoId,
    "country_id": countryId,
    "shipping_time_from": shippingTimeFrom,
    "sold": sold,
    "bid_increment_by": bidIncrementBy,
    "auction_ended": auctionEnded,
    "auction_ended_at": auctionEndedAt,
    "auction_order_number": auctionOrderNumber,
    "auction_ended_reason": auctionEndedReason,
    "shipping_time_unit": shippingTimeUnit,
    "recent_buyer": recentBuyer,
    "shipping_method": shippingMethod,
    "shipping_company": shippingCompany,
    "shipping_time_to": shippingTimeTo,
    "shipping_fees": shippingFees,
    "auction_schedule_type": auctionScheduleType,
  };

  @override
  String toString() {
    return "$productId, $views, $gallery, $videoId, $countryId, ";
  }
}

class ProductShop {
  ProductShop({required this.shop});

  final ShopShop? shop;

  ProductShop copyWith({ShopShop? shop}) {
    return ProductShop(shop: shop ?? this.shop);
  }

  factory ProductShop.fromJson(Map<String, dynamic> json) {
    return ProductShop(
      shop: json["shop"] == null ? null : ShopShop.fromJson(json["shop"]),
    );
  }

  Map<String, dynamic> toJson() => {"shop": shop?.toJson()};

  @override
  String toString() {
    return "$shop, ";
  }
}

class ShopShop {
  ShopShop({
    required this.id,
    required this.prevId,
    required this.userId,
    required this.membershipId,
    required this.membershipStartDate,
    required this.membershipEndDate,
    required this.slug,
    required this.name,
    required this.thumbnailId,
    required this.bannerImageId,
    required this.stripeAccountId,
    required this.balance,
    required this.description,
    required this.isVerified,
    required this.isFeatured,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.banner,
    required this.thumbnail,
    required this.membership,
    required this.meta,
  });

  final String id;
  final dynamic prevId;
  final String userId;
  final dynamic membershipId;
  final dynamic membershipStartDate;
  final dynamic membershipEndDate;
  final String slug;
  final String name;
  final dynamic thumbnailId;
  final dynamic bannerImageId;
  final dynamic stripeAccountId;
  final num balance;
  final String description;
  final num isVerified;
  final num isFeatured;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Video? banner;
  final Video? thumbnail;
  final Video? membership;
  final ShopMeta? meta;

  ShopShop copyWith({
    String? id,
    dynamic prevId,
    String? userId,
    dynamic membershipId,
    dynamic membershipStartDate,
    dynamic membershipEndDate,
    String? slug,
    String? name,
    dynamic thumbnailId,
    dynamic bannerImageId,
    dynamic stripeAccountId,
    num? balance,
    String? description,
    num? isVerified,
    num? isFeatured,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Video? banner,
    Video? thumbnail,
    Video? membership,
    ShopMeta? meta,
  }) {
    return ShopShop(
      id: id ?? this.id,
      prevId: prevId ?? this.prevId,
      userId: userId ?? this.userId,
      membershipId: membershipId ?? this.membershipId,
      membershipStartDate: membershipStartDate ?? this.membershipStartDate,
      membershipEndDate: membershipEndDate ?? this.membershipEndDate,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      bannerImageId: bannerImageId ?? this.bannerImageId,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      banner: banner ?? this.banner,
      thumbnail: thumbnail ?? this.thumbnail,
      membership: membership ?? this.membership,
      meta: meta ?? this.meta,
    );
  }

  factory ShopShop.fromJson(Map<String, dynamic> json) {
    return ShopShop(
      id: json["id"] ?? "",
      prevId: json["prev_id"],
      userId: json["user_id"] ?? "",
      membershipId: json["membership_id"],
      membershipStartDate: json["membership_start_date"],
      membershipEndDate: json["membership_end_date"],
      slug: json["slug"] ?? "",
      name: json["name"] ?? "",
      thumbnailId: json["thumbnail_id"],
      bannerImageId: json["banner_image_id"],
      stripeAccountId: json["stripe_account_id"],
      balance: json["balance"] ?? 0,
      description: json["description"] ?? "",
      isVerified: json["is_verified"] ?? 0,
      isFeatured: json["is_featured"] ?? 0,
      status: json["status"] ?? "",
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      banner: json["banner"] == null ? null : Video.fromJson(json["banner"]),
      thumbnail:
          json["thumbnail"] == null ? null : Video.fromJson(json["thumbnail"]),
      membership:
          json["membership"] == null
              ? null
              : Video.fromJson(json["membership"]),
      meta: json["meta"] == null ? null : ShopMeta.fromJson(json["meta"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "prev_id": prevId,
    "user_id": userId,
    "membership_id": membershipId,
    "membership_start_date": membershipStartDate,
    "membership_end_date": membershipEndDate,
    "slug": slug,
    "name": name,
    "thumbnail_id": thumbnailId,
    "banner_image_id": bannerImageId,
    "stripe_account_id": stripeAccountId,
    "balance": balance,
    "description": description,
    "is_verified": isVerified,
    "is_featured": isFeatured,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "banner": banner?.toJson(),
    "thumbnail": thumbnail?.toJson(),
    "membership": membership?.toJson(),
    "meta": meta?.toJson(),
  };

  @override
  String toString() {
    return "$id, $prevId, $userId, $membershipId, $membershipStartDate, $membershipEndDate, $slug, $name, $thumbnailId, $bannerImageId, $stripeAccountId, $balance, $description, $isVerified, $isFeatured, $status, $createdAt, $updatedAt, $banner, $thumbnail, $membership, $meta, ";
  }
}

class Video {
  Video({required this.media});

  final MediaUniversalModel? media;

  Video copyWith({MediaUniversalModel? media}) {
    return Video(media: media ?? this.media);
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    if (json['media'] is String) {
      return Video(media: null);
    }
    return Video(
      media:
          json['media'] == null
              ? null
              : MediaUniversalModel.fromJson(json["media"]),
    );
  }

  Map<String, dynamic> toJson() => {"media": media?.toJson()};

  @override
  String toString() => "$media";
}

class ShopMeta {
  ShopMeta({
    this.storeColor,
    this.address,
    this.areaCode,
    this.country,
    this.shippingTimeFrom,
    this.isEligibleForDiscounts,
    this.phone,
    this.whatsappAreaCode,
    this.city,
    this.email,
    this.shippingTimeTo,
    this.whatsapp,
    this.freeShippingTargetAmount,
    this.shopDiscountType,
    this.businessType,
    this.shopDiscountEndTime,
    this.shippingFees,
    this.shopDiscountValue,
    this.shopDiscountStartTime,
    this.globalPromotionActive,
    this.skype,
    this.shippingCompany,
    this.shippingTimeUnit,
  });

  final String? storeColor;
  final String? address;
  final String? areaCode;
  final String? country;
  final String? isEligibleForDiscounts;
  final String? shippingTimeFrom;
  final String? phone;
  final String? whatsappAreaCode;
  final String? city;
  final String? shippingTimeTo;
  final String? email;
  final String? whatsapp;
  final String? freeShippingTargetAmount;
  final String? shopDiscountType;
  final String? businessType;
  final String? shopDiscountEndTime;
  final String? shippingFees;
  final String? shopDiscountValue;
  final String? shopDiscountStartTime;
  final String? globalPromotionActive;
  final String? skype;
  final String? shippingCompany;
  final String? shippingTimeUnit;

  ShopMeta copyWith({
    String? storeColor,
    String? address,
    String? areaCode,
    String? shippingTimeFrom,
    String? country,
    String? isEligibleForDiscounts,
    String? phone,
    String? shippingTimeTo,
    String? whatsappAreaCode,
    String? city,
    String? email,
    String? whatsapp,
    String? freeShippingTargetAmount,
    String? shopDiscountType,
    String? businessType,
    String? shopDiscountEndTime,
    String? shippingFees,
    String? shopDiscountValue,
    String? shopDiscountStartTime,
    String? globalPromotionActive,
    String? skype,
    String? shippingCompany,
    String? shippingTimeUnit,
  }) {
    return ShopMeta(
      shippingTimeFrom: shippingTimeFrom ?? this.shippingTimeFrom,
      shippingTimeTo: shippingTimeTo ?? this.shippingTimeTo,
      storeColor: storeColor ?? this.storeColor,
      address: address ?? this.address,
      areaCode: areaCode ?? this.areaCode,
      country: country ?? this.country,
      isEligibleForDiscounts:
          isEligibleForDiscounts ?? this.isEligibleForDiscounts,
      phone: phone ?? this.phone,
      whatsappAreaCode: whatsappAreaCode ?? this.whatsappAreaCode,
      city: city ?? this.city,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      freeShippingTargetAmount:
          freeShippingTargetAmount ?? this.freeShippingTargetAmount,
      shopDiscountType: shopDiscountType ?? this.shopDiscountType,
      businessType: businessType ?? this.businessType,
      shopDiscountEndTime: shopDiscountEndTime ?? this.shopDiscountEndTime,
      shippingFees: shippingFees ?? this.shippingFees,
      shopDiscountValue: shopDiscountValue ?? this.shopDiscountValue,
      shopDiscountStartTime:
          shopDiscountStartTime ?? this.shopDiscountStartTime,
      globalPromotionActive:
          globalPromotionActive ?? this.globalPromotionActive,
      skype: skype ?? this.skype,
      shippingCompany: shippingCompany ?? this.shippingCompany,
      shippingTimeUnit: shippingTimeUnit ?? this.shippingTimeUnit,
    );
  }

  factory ShopMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ShopMeta();

    return ShopMeta(
      shippingTimeFrom: json["shipping_time_from"]?.toString(),
      shippingTimeTo: json["shipping_time_to"]?.toString(),
      storeColor: json["store_color"]?.toString(),
      address: json["address"]?.toString(),
      areaCode: json["area_code"]?.toString(),
      country: json["country"]?.toString(),
      isEligibleForDiscounts: json["is_eligible_for_discounts"]?.toString(),
      phone: json["phone"]?.toString(),
      whatsappAreaCode: json["whatsapp_area_code"]?.toString(),
      city: json["city"]?.toString(),
      email: json["email"]?.toString(),
      whatsapp: json["whatsapp"]?.toString(),
      freeShippingTargetAmount: json["free_shipping_target_amount"]?.toString(),
      shopDiscountType: json["shop_discount_type"]?.toString(),
      businessType: json["business_type"]?.toString(),
      shopDiscountEndTime: json["shop_discount_end_time"]?.toString(),
      shippingFees: json["shipping_fees"]?.toString(),
      shopDiscountValue: json["shop_discount_value"]?.toString(),
      shopDiscountStartTime: json["shop_discount_start_time"]?.toString(),
      globalPromotionActive: json["global_promotion_active"]?.toString(),
      skype: json["skype"]?.toString(),
      shippingCompany: json["shipping_company"]?.toString(),
      shippingTimeUnit: json["shipping_time_unit"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "store_color": storeColor,
    "shipping_time_from": shippingTimeFrom,
    "shipping_time_to": shippingTimeTo,
    "address": address,
    "area_code": areaCode,
    "country": country,
    "is_eligible_for_discounts": isEligibleForDiscounts,
    "phone": phone,
    "whatsapp_area_code": whatsappAreaCode,
    "city": city,
    "email": email,
    "whatsapp": whatsapp,
    "free_shipping_target_amount": freeShippingTargetAmount,
    "shop_discount_type": shopDiscountType,
    "business_type": businessType,
    "shop_discount_end_time": shopDiscountEndTime,
    "shipping_fees": shippingFees,
    "shop_discount_value": shopDiscountValue,
    "shop_discount_start_time": shopDiscountStartTime,
    "global_promotion_active": globalPromotionActive,
    "skype": skype,
    "shipping_company": shippingCompany,
    "shipping_time_unit": shippingTimeUnit,
  };

  @override
  String toString() {
    return "ShopMeta(storeColor: $storeColor, address: $address, areaCode: $areaCode, country: $country, isEligibleForDiscounts: $isEligibleForDiscounts, phone: $phone, whatsappAreaCode: $whatsappAreaCode, city: $city, email: $email, whatsapp: $whatsapp)";
  }
}
