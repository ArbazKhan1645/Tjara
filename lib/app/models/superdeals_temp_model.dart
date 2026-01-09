// To parse this JSON data, do
//
//     final superDeals = superDealsFromMap(jsonString);

import 'dart:convert';

SuperDeals superDealsFromMap(String str) =>
    SuperDeals.fromMap(json.decode(str));

String superDealsToMap(SuperDeals data) => json.encode(data.toMap());

class SuperDeals {
  bool? success;
  String? message;
  String? dealStatus;
  bool? inInterval;
  String? dealScheduleTime;
  String? currentDealProductId;
  String? currentDealStartTime;
  String? currentDealEndTime;
  List<String?>? dealSequenceProducts;
  IntervalInfo? intervalInfo;
  DealPosition? dealPosition;
  FlashDeal? flashDealInterval;
  FlashDeal? flashDealDuration;
  SequenceInfo? sequenceInfo;
  Product? product;
  String? timingSource;
  String? calculationMethod;
  Map<String, dynamic>? debugInfo;
  String? provider;

  SuperDeals({
    this.success,
    this.message,
    this.dealStatus,
    this.inInterval,
    this.dealScheduleTime,
    this.currentDealProductId,
    this.currentDealStartTime,
    this.currentDealEndTime,
    this.dealSequenceProducts,
    this.intervalInfo,
    this.dealPosition,
    this.flashDealInterval,
    this.flashDealDuration,
    this.sequenceInfo,
    this.product,
    this.timingSource,
    this.calculationMethod,
    this.debugInfo,
    this.provider,
  });

  SuperDeals copyWith({
    bool? success,
    String? message,
    String? dealStatus,
    bool? inInterval,
    String? dealScheduleTime,
    String? currentDealProductId,
    String? currentDealStartTime,
    String? currentDealEndTime,
    List<String?>? dealSequenceProducts,
    IntervalInfo? intervalInfo,
    DealPosition? dealPosition,
    FlashDeal? flashDealInterval,
    FlashDeal? flashDealDuration,
    SequenceInfo? sequenceInfo,
    Product? product,
    String? timingSource,
    String? calculationMethod,
    Map<String, dynamic>? debugInfo,
    String? provider,
  }) => SuperDeals(
    success: success ?? this.success,
    message: message ?? this.message,
    dealStatus: dealStatus ?? this.dealStatus,
    inInterval: inInterval ?? this.inInterval,
    dealScheduleTime: dealScheduleTime ?? this.dealScheduleTime,
    currentDealProductId: currentDealProductId ?? this.currentDealProductId,
    currentDealStartTime: currentDealStartTime ?? this.currentDealStartTime,
    currentDealEndTime: currentDealEndTime ?? this.currentDealEndTime,
    dealSequenceProducts: dealSequenceProducts ?? this.dealSequenceProducts,
    intervalInfo: intervalInfo ?? this.intervalInfo,
    dealPosition: dealPosition ?? this.dealPosition,
    flashDealInterval: flashDealInterval ?? this.flashDealInterval,
    flashDealDuration: flashDealDuration ?? this.flashDealDuration,
    sequenceInfo: sequenceInfo ?? this.sequenceInfo,
    product: product ?? this.product,
    timingSource: timingSource ?? this.timingSource,
    calculationMethod: calculationMethod ?? this.calculationMethod,
    debugInfo: debugInfo ?? this.debugInfo,
    provider: provider ?? this.provider,
  );

  factory SuperDeals.fromMap(Map<String, dynamic> json) => SuperDeals(
    success: json["success"],
    message: json["message"],
    dealStatus: json["deal_status"],
    inInterval: json["in_interval"],
    dealScheduleTime: json["deal_schedule_time"],
    currentDealProductId: json["current_deal_product_id"],
    currentDealStartTime: json["current_deal_start_time"],
    currentDealEndTime: json["current_deal_end_time"],
    dealSequenceProducts:
        json["deal_sequence_products"] == null
            ? []
            : List<String?>.from(
              json["deal_sequence_products"]!.map((x) => x?.toString()),
            ),
    intervalInfo:
        json["interval_info"] == null
            ? null
            : IntervalInfo.fromMap(json["interval_info"]),
    dealPosition:
        json["deal_position"] == null
            ? null
            : DealPosition.fromMap(json["deal_position"]),
    flashDealInterval:
        json["flash_deal_interval"] == null
            ? null
            : FlashDeal.fromMap(json["flash_deal_interval"]),
    flashDealDuration:
        json["flash_deal_duration"] == null
            ? null
            : FlashDeal.fromMap(json["flash_deal_duration"]),
    sequenceInfo:
        json["sequence_info"] == null
            ? null
            : SequenceInfo.fromMap(json["sequence_info"]),
    product: json["product"] == null ? null : Product.fromMap(json["product"]),
    timingSource: json["timing_source"],
    calculationMethod: json["calculation_method"],
    debugInfo:
        json["debug_info"] == null
            ? null
            : Map<String, dynamic>.from(json["debug_info"]),
    provider: json["provider"],
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "message": message,
    "deal_status": dealStatus,
    "in_interval": inInterval,
    "deal_schedule_time": dealScheduleTime,
    "current_deal_product_id": currentDealProductId,
    "current_deal_start_time": currentDealStartTime,
    "current_deal_end_time": currentDealEndTime,
    "deal_sequence_products":
        dealSequenceProducts == null
            ? []
            : List<dynamic>.from(dealSequenceProducts!.map((x) => x)),
    "interval_info": intervalInfo?.toMap(),
    "deal_position": dealPosition?.toMap(),
    "flash_deal_interval": flashDealInterval?.toMap(),
    "flash_deal_duration": flashDealDuration?.toMap(),
    "sequence_info": sequenceInfo?.toMap(),
    "product": product?.toMap(),
    "timing_source": timingSource,
    "calculation_method": calculationMethod,
    "debug_info": debugInfo,
    "provider": provider,
  };
}

class DealPosition {
  int? current;
  int? total;
  int? index;

  DealPosition({this.current, this.total, this.index});

  DealPosition copyWith({int? current, int? total, int? index}) => DealPosition(
    current: current ?? this.current,
    total: total ?? this.total,
    index: index ?? this.index,
  );

  factory DealPosition.fromMap(Map<String, dynamic> json) => DealPosition(
    current:
        json["current"] is int
            ? json["current"]
            : int.tryParse(json["current"]?.toString() ?? ''),
    total:
        json["total"] is int
            ? json["total"]
            : int.tryParse(json["total"]?.toString() ?? ''),
    index:
        json["index"] is int
            ? json["index"]
            : int.tryParse(json["index"]?.toString() ?? ''),
  );

  Map<String, dynamic> toMap() => {
    "current": current,
    "total": total,
    "index": index,
  };
}

class FlashDeal {
  String? value;
  String? unit;
  int? seconds;

  FlashDeal({this.value, this.unit, this.seconds});

  FlashDeal copyWith({String? value, String? unit, int? seconds}) => FlashDeal(
    value: value ?? this.value,
    unit: unit ?? this.unit,
    seconds: seconds ?? this.seconds,
  );

  factory FlashDeal.fromMap(Map<String, dynamic> json) => FlashDeal(
    value: json["value"]?.toString(), // Handle both int and String
    unit: json["unit"],
    seconds:
        json["seconds"] is int
            ? json["seconds"]
            : int.tryParse(json["seconds"]?.toString() ?? ''),
  );

  Map<String, dynamic> toMap() => {
    "value": value,
    "unit": unit,
    "seconds": seconds,
  };
}

class IntervalInfo {
  String? intervalStartTime;
  String? intervalEndTime;
  String? nextDealStartsAt;
  String? nextDealProductId;
  int? nextDealIndex;
  int? secondsRemaining;

  IntervalInfo({
    this.intervalStartTime,
    this.intervalEndTime,
    this.nextDealStartsAt,
    this.nextDealProductId,
    this.nextDealIndex,
    this.secondsRemaining,
  });

  IntervalInfo copyWith({
    String? intervalStartTime,
    String? intervalEndTime,
    String? nextDealStartsAt,
    String? nextDealProductId,
    int? nextDealIndex,
    int? secondsRemaining,
  }) => IntervalInfo(
    intervalStartTime: intervalStartTime ?? this.intervalStartTime,
    intervalEndTime: intervalEndTime ?? this.intervalEndTime,
    nextDealStartsAt: nextDealStartsAt ?? this.nextDealStartsAt,
    nextDealProductId: nextDealProductId ?? this.nextDealProductId,
    nextDealIndex: nextDealIndex ?? this.nextDealIndex,
    secondsRemaining: secondsRemaining ?? this.secondsRemaining,
  );

  factory IntervalInfo.fromMap(Map<String, dynamic> json) => IntervalInfo(
    intervalStartTime: json["interval_start_time"],
    intervalEndTime: json["interval_end_time"],
    nextDealStartsAt: json["next_deal_starts_at"],
    nextDealProductId: json["next_deal_product_id"],
    nextDealIndex:
        json["next_deal_index"] is int
            ? json["next_deal_index"]
            : int.tryParse(json["next_deal_index"]?.toString() ?? ''),
    secondsRemaining:
        json["seconds_remaining"] is int
            ? json["seconds_remaining"]
            : int.tryParse(json["seconds_remaining"]?.toString() ?? ''),
  );

  Map<String, dynamic> toMap() => {
    "interval_start_time": intervalStartTime,
    "interval_end_time": intervalEndTime,
    "next_deal_starts_at": nextDealStartsAt,
    "next_deal_product_id": nextDealProductId,
    "next_deal_index": nextDealIndex,
    "seconds_remaining": secondsRemaining,
  };
}

class Product {
  String? id;
  dynamic prevId;
  String? shopId;
  String? slug;
  String? name;
  String? productType;
  String? productGroup;
  String? thumbnailId;
  String? description;
  int? stock;
  int? isFeatured;
  int? isDeal;
  int? price;
  int? salePrice;
  dynamic reservedPrice;
  dynamic auctionStartTime;
  dynamic auctionEndTime;
  dynamic winnerId;
  dynamic minPrice;
  dynamic maxPrice;
  dynamic saleStartTime;
  dynamic saleEndTime;
  String? status;
  String? createdAt;
  String? updatedAt;
  Thumbnail? thumbnail;
  dynamic video;
  bool? hasGlobalPromotion;
  dynamic discountInfo;
  List<dynamic>? appliedPromotions;
  List<Meta>? meta;
  Delivery? delivery;
  Reviews? reviews;
  Shop? shop;

  Product({
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
    this.video,
    this.hasGlobalPromotion,
    this.discountInfo,
    this.appliedPromotions,
    this.meta,
    this.delivery,
    this.reviews,
    this.shop,
  });

  Product copyWith({
    String? id,
    dynamic prevId,
    String? shopId,
    String? slug,
    String? name,
    String? productType,
    String? productGroup,
    String? thumbnailId,
    String? description,
    int? stock,
    int? isFeatured,
    int? isDeal,
    int? price,
    int? salePrice,
    dynamic reservedPrice,
    dynamic auctionStartTime,
    dynamic auctionEndTime,
    dynamic winnerId,
    dynamic minPrice,
    dynamic maxPrice,
    dynamic saleStartTime,
    dynamic saleEndTime,
    String? status,
    String? createdAt,
    String? updatedAt,
    Thumbnail? thumbnail,
    dynamic video,
    bool? hasGlobalPromotion,
    dynamic discountInfo,
    List<dynamic>? appliedPromotions,
    List<Meta>? meta,
    Delivery? delivery,
    Reviews? reviews,
    Shop? shop,
  }) => Product(
    id: id ?? this.id,
    prevId: prevId ?? this.prevId,
    shopId: shopId ?? this.shopId,
    slug: slug ?? this.slug,
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
    video: video ?? this.video,
    hasGlobalPromotion: hasGlobalPromotion ?? this.hasGlobalPromotion,
    discountInfo: discountInfo ?? this.discountInfo,
    appliedPromotions: appliedPromotions ?? this.appliedPromotions,
    meta: meta ?? this.meta,
    delivery: delivery ?? this.delivery,
    reviews: reviews ?? this.reviews,
    shop: shop ?? this.shop,
  );

  factory Product.fromMap(Map<String, dynamic> json) => Product(
    id: json["id"],
    prevId: json["prev_id"],
    shopId: json["shop_id"],
    slug: json["slug"],
    name: json["name"],
    productType: json["product_type"],
    productGroup: json["product_group"],
    thumbnailId: json["thumbnail_id"],
    description: json["description"],
    stock:
        json["stock"] is int
            ? json["stock"]
            : int.tryParse(json["stock"]?.toString() ?? ''),
    isFeatured:
        json["is_featured"] is int
            ? json["is_featured"]
            : int.tryParse(json["is_featured"]?.toString() ?? ''),
    isDeal:
        json["is_deal"] is int
            ? json["is_deal"]
            : int.tryParse(json["is_deal"]?.toString() ?? ''),
    price:
        json["price"] is int
            ? json["price"]
            : int.tryParse(json["price"]?.toString() ?? ''),
    salePrice:
        json["sale_price"] is int
            ? json["sale_price"]
            : int.tryParse(json["sale_price"]?.toString() ?? ''),
    reservedPrice: json["reserved_price"],
    auctionStartTime: json["auction_start_time"],
    auctionEndTime: json["auction_end_time"],
    winnerId: json["winner_id"],
    minPrice: json["min_price"],
    maxPrice: json["max_price"],
    saleStartTime: json["sale_start_time"],
    saleEndTime: json["sale_end_time"],
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    thumbnail:
        json["thumbnail"] == null ? null : Thumbnail.fromMap(json["thumbnail"]),
    video: json["video"],
    hasGlobalPromotion: json["has_global_promotion"],
    discountInfo: json["discount_info"],
    appliedPromotions:
        json["applied_promotions"] == null
            ? []
            : List<dynamic>.from(json["applied_promotions"]!.map((x) => x)),
    meta:
        json["meta"] == null
            ? []
            : List<Meta>.from(json["meta"]!.map((x) => Meta.fromMap(x))),
    delivery:
        json["delivery"] == null ? null : Delivery.fromMap(json["delivery"]),
    reviews: json["reviews"] == null ? null : Reviews.fromMap(json["reviews"]),
    shop: json["shop"] == null ? null : Shop.fromMap(json["shop"]),
  );

  Map<String, dynamic> toMap() => {
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
    "created_at": createdAt,
    "updated_at": updatedAt,
    "thumbnail": thumbnail?.toMap(),
    "video": video,
    "has_global_promotion": hasGlobalPromotion,
    "discount_info": discountInfo,
    "applied_promotions":
        appliedPromotions == null
            ? []
            : List<dynamic>.from(appliedPromotions!.map((x) => x)),
    "meta": meta == null ? [] : List<dynamic>.from(meta!.map((x) => x.toMap())),
    "delivery": delivery?.toMap(),
    "reviews": reviews?.toMap(),
    "shop": shop?.toMap(),
  };
}

class Delivery {
  String? provider;
  bool? available;
  Features? features;

  Delivery({this.provider, this.available, this.features});

  Delivery copyWith({String? provider, bool? available, Features? features}) =>
      Delivery(
        provider: provider ?? this.provider,
        available: available ?? this.available,
        features: features ?? this.features,
      );

  factory Delivery.fromMap(Map<String, dynamic> json) => Delivery(
    provider: json["provider"],
    available: json["available"],
    features:
        json["features"] == null ? null : Features.fromMap(json["features"]),
  );

  Map<String, dynamic> toMap() => {
    "provider": provider,
    "available": available,
    "features": features?.toMap(),
  };
}

class Features {
  bool? cashOnDelivery;
  bool? tracking;
  bool? scheduledDelivery;

  Features({this.cashOnDelivery, this.tracking, this.scheduledDelivery});

  Features copyWith({
    bool? cashOnDelivery,
    bool? tracking,
    bool? scheduledDelivery,
  }) => Features(
    cashOnDelivery: cashOnDelivery ?? this.cashOnDelivery,
    tracking: tracking ?? this.tracking,
    scheduledDelivery: scheduledDelivery ?? this.scheduledDelivery,
  );

  factory Features.fromMap(Map<String, dynamic> json) => Features(
    cashOnDelivery: json["cash_on_delivery"],
    tracking: json["tracking"],
    scheduledDelivery: json["scheduled_delivery"],
  );

  Map<String, dynamic> toMap() => {
    "cash_on_delivery": cashOnDelivery,
    "tracking": tracking,
    "scheduled_delivery": scheduledDelivery,
  };
}

class Meta {
  String? id;
  String? productId;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Meta({
    this.id,
    this.productId,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Meta copyWith({
    String? id,
    String? productId,
    String? key,
    String? value,
    String? createdAt,
    String? updatedAt,
  }) => Meta(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    key: key ?? this.key,
    value: value ?? this.value,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Meta.fromMap(Map<String, dynamic> json) => Meta(
    id: json["id"],
    productId: json["product_id"],
    key: json["key"],
    value: json["value"]?.toString(), // Handle null values
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "product_id": productId,
    "key": key,
    "value": value,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Reviews {
  String? message;

  Reviews({this.message});

  Reviews copyWith({String? message}) =>
      Reviews(message: message ?? this.message);

  factory Reviews.fromMap(Map<String, dynamic> json) =>
      Reviews(message: json["message"]);

  Map<String, dynamic> toMap() => {"message": message};
}

class Shop {
  String? id;
  dynamic prevId;
  String? userId;
  String? membershipId;
  String? membershipStartDate;
  String? membershipEndDate;
  String? slug;
  String? name;
  String? thumbnailId;
  String? bannerImageId;
  dynamic stripeAccountId;
  int? balance;
  String? description;
  int? isVerified;
  int? isFeatured;
  String? status;
  String? createdAt;
  String? updatedAt;

  Shop({
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
  });

  Shop copyWith({
    String? id,
    dynamic prevId,
    String? userId,
    String? membershipId,
    String? membershipStartDate,
    String? membershipEndDate,
    String? slug,
    String? name,
    String? thumbnailId,
    String? bannerImageId,
    dynamic stripeAccountId,
    int? balance,
    String? description,
    int? isVerified,
    int? isFeatured,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) => Shop(
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
  );

  factory Shop.fromMap(Map<String, dynamic> json) => Shop(
    id: json["id"],
    prevId: json["prev_id"],
    userId: json["user_id"],
    membershipId: json["membership_id"],
    membershipStartDate: json["membership_start_date"],
    membershipEndDate: json["membership_end_date"],
    slug: json["slug"],
    name: json["name"],
    thumbnailId: json["thumbnail_id"],
    bannerImageId: json["banner_image_id"],
    stripeAccountId: json["stripe_account_id"],
    balance:
        json["balance"] is int
            ? json["balance"]
            : int.tryParse(json["balance"]?.toString() ?? ''),
    description: json["description"],
    isVerified:
        json["is_verified"] is int
            ? json["is_verified"]
            : int.tryParse(json["is_verified"]?.toString() ?? ''),
    isFeatured:
        json["is_featured"] is int
            ? json["is_featured"]
            : int.tryParse(json["is_featured"]?.toString() ?? ''),
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toMap() => {
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
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Thumbnail {
  Media? media;

  Thumbnail({this.media});

  Thumbnail copyWith({Media? media}) => Thumbnail(media: media ?? this.media);

  factory Thumbnail.fromMap(Map<String, dynamic> json) => Thumbnail(
    media: json["media"] == null ? null : Media.fromMap(json["media"]),
  );

  Map<String, dynamic> toMap() => {"media": media?.toMap()};
}

class Media {
  String? id;
  String? url;
  String? optimizedMediaUrl;
  String? mediaType;
  dynamic cdnUrl;
  dynamic optimizedMediaCdnUrl;
  dynamic cdnVideoId;
  dynamic cdnThumbnailUrl;
  dynamic cdnStoragePath;
  bool? isStreaming;
  dynamic isUsed;
  String? createdAt;
  String? updatedAt;
  List<Copy>? copies;

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
    this.copies,
  });

  Media copyWith({
    String? id,
    String? url,
    String? optimizedMediaUrl,
    String? mediaType,
    dynamic cdnUrl,
    dynamic optimizedMediaCdnUrl,
    dynamic cdnVideoId,
    dynamic cdnThumbnailUrl,
    dynamic cdnStoragePath,
    bool? isStreaming,
    dynamic isUsed,
    String? createdAt,
    String? updatedAt,
    List<Copy>? copies,
  }) => Media(
    id: id ?? this.id,
    url: url ?? this.url,
    optimizedMediaUrl: optimizedMediaUrl ?? this.optimizedMediaUrl,
    mediaType: mediaType ?? this.mediaType,
    cdnUrl: cdnUrl ?? this.cdnUrl,
    optimizedMediaCdnUrl: optimizedMediaCdnUrl ?? this.optimizedMediaCdnUrl,
    cdnVideoId: cdnVideoId ?? this.cdnVideoId,
    cdnThumbnailUrl: cdnThumbnailUrl ?? this.cdnThumbnailUrl,
    cdnStoragePath: cdnStoragePath ?? this.cdnStoragePath,
    isStreaming: isStreaming ?? this.isStreaming,
    isUsed: isUsed ?? this.isUsed,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    copies: copies ?? this.copies,
  );

  factory Media.fromMap(Map<String, dynamic> json) => Media(
    id: json["id"],
    url: json["url"],
    optimizedMediaUrl: json["optimized_media_url"],
    mediaType: json["media_type"],
    cdnUrl: json["cdn_url"],
    optimizedMediaCdnUrl: json["optimized_media_cdn_url"],
    cdnVideoId: json["cdn_video_id"],
    cdnThumbnailUrl: json["cdn_thumbnail_url"],
    cdnStoragePath: json["cdn_storage_path"],
    isStreaming: json["is_streaming"],
    isUsed: json["is_used"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    copies:
        json["copies"] == null
            ? []
            : List<Copy>.from(json["copies"]!.map((x) => Copy.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "url": url,
    "optimized_media_url": optimizedMediaUrl,
    "media_type": mediaType,
    "cdn_url": cdnUrl,
    "optimized_media_cdn_url": optimizedMediaCdnUrl,
    "cdn_video_id": cdnVideoId,
    "cdn_thumbnail_url": cdnThumbnailUrl,
    "cdn_storage_path": cdnStoragePath,
    "is_streaming": isStreaming,
    "is_used": isUsed,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "copies":
        copies == null ? [] : List<dynamic>.from(copies!.map((x) => x.toMap())),
  };
}

class Copy {
  String? id;
  String? mediaId;
  String? url;
  String? path;
  String? mediaType;
  int? width;
  int? height;
  String? format;
  String? purpose;
  bool? isOptimized;
  dynamic cdnUrl;
  dynamic cdnStoragePath;
  String? createdAt;
  String? updatedAt;

  Copy({
    this.id,
    this.mediaId,
    this.url,
    this.path,
    this.mediaType,
    this.width,
    this.height,
    this.format,
    this.purpose,
    this.isOptimized,
    this.cdnUrl,
    this.cdnStoragePath,
    this.createdAt,
    this.updatedAt,
  });

  Copy copyWith({
    String? id,
    String? mediaId,
    String? url,
    String? path,
    String? mediaType,
    int? width,
    int? height,
    String? format,
    String? purpose,
    bool? isOptimized,
    dynamic cdnUrl,
    dynamic cdnStoragePath,
    String? createdAt,
    String? updatedAt,
  }) => Copy(
    id: id ?? this.id,
    mediaId: mediaId ?? this.mediaId,
    url: url ?? this.url,
    path: path ?? this.path,
    mediaType: mediaType ?? this.mediaType,
    width: width ?? this.width,
    height: height ?? this.height,
    format: format ?? this.format,
    purpose: purpose ?? this.purpose,
    isOptimized: isOptimized ?? this.isOptimized,
    cdnUrl: cdnUrl ?? this.cdnUrl,
    cdnStoragePath: cdnStoragePath ?? this.cdnStoragePath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Copy.fromMap(Map<String, dynamic> json) => Copy(
    id: json["id"],
    mediaId: json["media_id"],
    url: json["url"],
    path: json["path"],
    mediaType: json["media_type"],
    width:
        json["width"] is int
            ? json["width"]
            : int.tryParse(json["width"]?.toString() ?? ''),
    height:
        json["height"] is int
            ? json["height"]
            : int.tryParse(json["height"]?.toString() ?? ''),
    format: json["format"],
    purpose: json["purpose"],
    isOptimized: json["is_optimized"],
    cdnUrl: json["cdn_url"],
    cdnStoragePath: json["cdn_storage_path"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "media_id": mediaId,
    "url": url,
    "path": path,
    "media_type": mediaType,
    "width": width,
    "height": height,
    "format": format,
    "purpose": purpose,
    "is_optimized": isOptimized,
    "cdn_url": cdnUrl,
    "cdn_storage_path": cdnStoragePath,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class SequenceInfo {
  String? startedAt;
  int? currentDealNumber;
  int? totalDeals;
  int? dealsRemaining;
  String? nextDealStartsAt;
  bool? isLastDeal;
  int? secondsRemaining; // Added missing field

  SequenceInfo({
    this.startedAt,
    this.currentDealNumber,
    this.totalDeals,
    this.dealsRemaining,
    this.nextDealStartsAt,
    this.isLastDeal,
    this.secondsRemaining,
  });

  SequenceInfo copyWith({
    String? startedAt,
    int? currentDealNumber,
    int? totalDeals,
    int? dealsRemaining,
    String? nextDealStartsAt,
    bool? isLastDeal,
    int? secondsRemaining,
  }) => SequenceInfo(
    startedAt: startedAt ?? this.startedAt,
    currentDealNumber: currentDealNumber ?? this.currentDealNumber,
    totalDeals: totalDeals ?? this.totalDeals,
    dealsRemaining: dealsRemaining ?? this.dealsRemaining,
    nextDealStartsAt: nextDealStartsAt ?? this.nextDealStartsAt,
    isLastDeal: isLastDeal ?? this.isLastDeal,
    secondsRemaining: secondsRemaining ?? this.secondsRemaining,
  );

  factory SequenceInfo.fromMap(Map<String, dynamic> json) => SequenceInfo(
    startedAt: json["started_at"],
    currentDealNumber:
        json["current_deal_number"] is int
            ? json["current_deal_number"]
            : int.tryParse(json["current_deal_number"]?.toString() ?? ''),
    totalDeals:
        json["total_deals"] is int
            ? json["total_deals"]
            : int.tryParse(json["total_deals"]?.toString() ?? ''),
    dealsRemaining:
        json["deals_remaining"] is int
            ? json["deals_remaining"]
            : int.tryParse(json["deals_remaining"]?.toString() ?? ''),
    nextDealStartsAt: json["next_deal_starts_at"],
    isLastDeal: json["is_last_deal"],
    secondsRemaining:
        json["seconds_remaining"] is int
            ? json["seconds_remaining"]
            : int.tryParse(json["seconds_remaining"]?.toString() ?? ''),
  );

  Map<String, dynamic> toMap() => {
    "started_at": startedAt,
    "current_deal_number": currentDealNumber,
    "total_deals": totalDeals,
    "deals_remaining": dealsRemaining,
    "next_deal_starts_at": nextDealStartsAt,
    "is_last_deal": isLastDeal,
    "seconds_remaining": secondsRemaining,
  };
}
