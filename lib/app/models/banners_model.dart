// To parse this JSON data, do
//
//     final banners = bannersFromMap(jsonString);

import 'dart:convert';

Banners bannersFromMap(String str) => Banners.fromMap(json.decode(str));

String bannersToMap(Banners data) => json.encode(data.toMap());

class Banners {
  Posts? posts;
  String? provider;

  Banners({this.posts, this.provider});

  Banners copyWith({Posts? posts, String? provider}) =>
      Banners(posts: posts ?? this.posts, provider: provider ?? this.provider);

  factory Banners.fromMap(Map<String, dynamic> json) => Banners(
    posts: json["posts"] == null ? null : Posts.fromMap(json["posts"]),
    provider: json["provider"],
  );

  Map<String, dynamic> toMap() => {
    "posts": posts?.toMap(),
    "provider": provider,
  };
}

class Posts {
  int? currentPage;
  List<Datum>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Posts({
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

  Posts copyWith({
    int? currentPage,
    List<Datum>? data,
    String? firstPageUrl,
    int? from,
    int? lastPage,
    String? lastPageUrl,
    List<Link>? links,
    dynamic nextPageUrl,
    String? path,
    int? perPage,
    dynamic prevPageUrl,
    int? to,
    int? total,
  }) => Posts(
    currentPage: currentPage ?? this.currentPage,
    data: data ?? this.data,
    firstPageUrl: firstPageUrl ?? this.firstPageUrl,
    from: from ?? this.from,
    lastPage: lastPage ?? this.lastPage,
    lastPageUrl: lastPageUrl ?? this.lastPageUrl,
    links: links ?? this.links,
    nextPageUrl: nextPageUrl ?? this.nextPageUrl,
    path: path ?? this.path,
    perPage: perPage ?? this.perPage,
    prevPageUrl: prevPageUrl ?? this.prevPageUrl,
    to: to ?? this.to,
    total: total ?? this.total,
  );

  factory Posts.fromMap(Map<String, dynamic> json) => Posts(
    currentPage: json["current_page"],
    data:
        json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromMap(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links:
        json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromMap(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toMap() => {
    "current_page": currentPage,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links":
        links == null ? [] : List<dynamic>.from(links!.map((x) => x.toMap())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Datum {
  String? id;
  String? slug;
  String? shopId;
  String? name;
  dynamic description;
  String? thumbnailId;
  String? postType;
  String? status;
  String? languageId;
  dynamic parentId;
  String? createdAt;
  String? updatedAt;
  Video? video;
  MobileThumbnail? thumbnail;
  MobileThumbnail? mobileThumbnail;
  DatumShop? shop;
  Language? language;
  DatumMeta? meta;
  Map<String, double>? analytics;

  Datum({
    this.id,
    this.slug,
    this.shopId,
    this.name,
    this.description,
    this.thumbnailId,
    this.postType,
    this.status,
    this.languageId,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.video,
    this.thumbnail,
    this.mobileThumbnail,
    this.shop,
    this.language,
    this.meta,
    this.analytics,
  });

  Datum copyWith({
    String? id,
    String? slug,
    String? shopId,
    String? name,
    dynamic description,
    String? thumbnailId,
    String? postType,
    String? status,
    String? languageId,
    dynamic parentId,
    String? createdAt,
    String? updatedAt,
    Video? video,
    MobileThumbnail? thumbnail,
    MobileThumbnail? mobileThumbnail,
    DatumShop? shop,
    Language? language,
    DatumMeta? meta,
    Map<String, double>? analytics,
  }) => Datum(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    shopId: shopId ?? this.shopId,
    name: name ?? this.name,
    description: description ?? this.description,
    thumbnailId: thumbnailId ?? this.thumbnailId,
    postType: postType ?? this.postType,
    status: status ?? this.status,
    languageId: languageId ?? this.languageId,
    parentId: parentId ?? this.parentId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    video: video ?? this.video,
    thumbnail: thumbnail ?? this.thumbnail,
    mobileThumbnail: mobileThumbnail ?? this.mobileThumbnail,
    shop: shop ?? this.shop,
    language: language ?? this.language,
    meta: meta ?? this.meta,
    analytics: analytics ?? this.analytics,
  );

  factory Datum.fromMap(Map<String, dynamic> json) => Datum(
    id: json["id"],
    slug: json["slug"],
    shopId: json["shop_id"],
    name: json["name"],
    description: json["description"],
    thumbnailId: json["thumbnail_id"],
    postType: json["post_type"],
    status: json["status"],
    languageId: json["language_id"],
    parentId: json["parent_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    video: json["video"] == null ? null : Video.fromMap(json["video"]),
    thumbnail:
        json["thumbnail"] == null
            ? null
            : MobileThumbnail.fromMap(json["thumbnail"]),
    mobileThumbnail:
        json["mobile_thumbnail"] == null
            ? null
            : MobileThumbnail.fromMap(json["mobile_thumbnail"]),
    shop: json["shop"] == null ? null : DatumShop.fromMap(json["shop"]),
    language:
        json["language"] == null ? null : Language.fromMap(json["language"]),
    meta: json["meta"] == null ? null : DatumMeta.fromMap(json["meta"]),
    analytics: Map.from(
      json["analytics"]!,
    ).map((k, v) => MapEntry<String, double>(k, v?.toDouble())),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "slug": slug,
    "shop_id": shopId,
    "name": name,
    "description": description,
    "thumbnail_id": thumbnailId,
    "post_type": postType,
    "status": status,
    "language_id": languageId,
    "parent_id": parentId,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "video": video?.toMap(),
    "thumbnail": thumbnail?.toMap(),
    "mobile_thumbnail": mobileThumbnail?.toMap(),
    "shop": shop?.toMap(),
    "language": language?.toMap(),
    "meta": meta?.toMap(),
    "analytics": Map.from(
      analytics!,
    ).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}

class Language {
  String? id;
  String? code;
  String? name;
  String? nativeName;
  String? dir;
  String? flag;
  bool? isDefault;
  bool? isActive;
  int? sortOrder;
  String? createdAt;
  String? updatedAt;

  Language({
    this.id,
    this.code,
    this.name,
    this.nativeName,
    this.dir,
    this.flag,
    this.isDefault,
    this.isActive,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  Language copyWith({
    String? id,
    String? code,
    String? name,
    String? nativeName,
    String? dir,
    String? flag,
    bool? isDefault,
    bool? isActive,
    int? sortOrder,
    String? createdAt,
    String? updatedAt,
  }) => Language(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    nativeName: nativeName ?? this.nativeName,
    dir: dir ?? this.dir,
    flag: flag ?? this.flag,
    isDefault: isDefault ?? this.isDefault,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Language.fromMap(Map<String, dynamic> json) => Language(
    id: json["id"],
    code: json["code"],
    name: json["name"],
    nativeName: json["native_name"],
    dir: json["dir"],
    flag: json["flag"],
    isDefault: json["is_default"],
    isActive: json["is_active"],
    sortOrder: json["sort_order"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "code": code,
    "name": name,
    "native_name": nativeName,
    "dir": dir,
    "flag": flag,
    "is_default": isDefault,
    "is_active": isActive,
    "sort_order": sortOrder,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class DatumMeta {
  String? bannerImageUrl;
  String? views;
  String? mobileThumbnailId;

  DatumMeta({this.bannerImageUrl, this.views, this.mobileThumbnailId});

  DatumMeta copyWith({
    String? bannerImageUrl,
    String? views,
    String? mobileThumbnailId,
  }) => DatumMeta(
    bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
    views: views ?? this.views,
    mobileThumbnailId: mobileThumbnailId ?? this.mobileThumbnailId,
  );

  factory DatumMeta.fromMap(Map<String, dynamic> json) => DatumMeta(
    bannerImageUrl: json["banner_image_url"],
    views: json["views"],
    mobileThumbnailId: json["mobile_thumbnail_id"],
  );

  Map<String, dynamic> toMap() => {
    "banner_image_url": bannerImageUrl,
    "views": views,
    "mobile_thumbnail_id": mobileThumbnailId,
  };
}

class MobileThumbnail {
  Media? media;

  MobileThumbnail({this.media});

  MobileThumbnail copyWith({Media? media}) =>
      MobileThumbnail(media: media ?? this.media);

  factory MobileThumbnail.fromMap(Map<String, dynamic> json) => MobileThumbnail(
    media: json["media"] == null ? null : Media.fromMap(json["media"]),
  );

  Map<String, dynamic> toMap() => {"media": media?.toMap()};
}

class Media {
  String? id;
  String? url;
  String? optimizedMediaUrl;
  String? mediaType;
  String? cdnUrl;
  String? optimizedMediaCdnUrl;
  dynamic cdnVideoId;
  dynamic cdnThumbnailUrl;
  String? cdnStoragePath;
  bool? isStreaming;
  dynamic isUsed;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? copies;
  bool? usingCdn;

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
    this.usingCdn,
  });

  Media copyWith({
    String? id,
    String? url,
    String? optimizedMediaUrl,
    String? mediaType,
    String? cdnUrl,
    String? optimizedMediaCdnUrl,
    dynamic cdnVideoId,
    dynamic cdnThumbnailUrl,
    String? cdnStoragePath,
    bool? isStreaming,
    dynamic isUsed,
    String? createdAt,
    String? updatedAt,
    List<dynamic>? copies,
    bool? usingCdn,
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
    usingCdn: usingCdn ?? this.usingCdn,
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
            : List<dynamic>.from(json["copies"]!.map((x) => x)),
    usingCdn: json["using_cdn"],
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
    "copies": copies == null ? [] : List<dynamic>.from(copies!.map((x) => x)),
    "using_cdn": usingCdn,
  };
}

class DatumShop {
  ShopShop? shop;

  DatumShop({this.shop});

  DatumShop copyWith({ShopShop? shop}) => DatumShop(shop: shop ?? this.shop);

  factory DatumShop.fromMap(Map<String, dynamic> json) => DatumShop(
    shop: json["shop"] == null ? null : ShopShop.fromMap(json["shop"]),
  );

  Map<String, dynamic> toMap() => {"shop": shop?.toMap()};
}

class ShopShop {
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
  MobileThumbnail? banner;
  MobileThumbnail? thumbnail;
  Membership? membership;
  ShopMeta? meta;

  ShopShop({
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
    this.thumbnail,
    this.membership,
    this.meta,
  });

  ShopShop copyWith({
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
    MobileThumbnail? banner,
    MobileThumbnail? thumbnail,
    Membership? membership,
    ShopMeta? meta,
  }) => ShopShop(
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

  factory ShopShop.fromMap(Map<String, dynamic> json) => ShopShop(
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
    balance: json["balance"],
    description: json["description"],
    isVerified: json["is_verified"],
    isFeatured: json["is_featured"],
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    banner:
        json["banner"] == null ? null : MobileThumbnail.fromMap(json["banner"]),
    thumbnail:
        json["thumbnail"] == null
            ? null
            : MobileThumbnail.fromMap(json["thumbnail"]),
    membership:
        json["membership"] == null
            ? null
            : Membership.fromMap(json["membership"]),
    meta: json["meta"] == null ? null : ShopMeta.fromMap(json["meta"]),
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
    "banner": banner?.toMap(),
    "thumbnail": thumbnail?.toMap(),
    "membership": membership?.toMap(),
    "meta": meta?.toMap(),
  };
}

class Membership {
  MembershipPlan? membershipPlan;

  Membership({this.membershipPlan});

  Membership copyWith({MembershipPlan? membershipPlan}) =>
      Membership(membershipPlan: membershipPlan ?? this.membershipPlan);

  factory Membership.fromMap(Map<String, dynamic> json) => Membership(
    membershipPlan:
        json["membership_plan"] == null
            ? null
            : MembershipPlan.fromMap(json["membership_plan"]),
  );

  Map<String, dynamic> toMap() => {"membership_plan": membershipPlan?.toMap()};
}

class MembershipPlan {
  String? id;
  String? slug;
  String? userType;
  String? name;
  int? price;
  String? description;
  String? duration;
  dynamic parentId;
  String? status;
  dynamic createdAt;
  dynamic updatedAt;
  Video? thumbnail;
  Features? features;

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

  MembershipPlan copyWith({
    String? id,
    String? slug,
    String? userType,
    String? name,
    int? price,
    String? description,
    String? duration,
    dynamic parentId,
    String? status,
    dynamic createdAt,
    dynamic updatedAt,
    Video? thumbnail,
    Features? features,
  }) => MembershipPlan(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    userType: userType ?? this.userType,
    name: name ?? this.name,
    price: price ?? this.price,
    description: description ?? this.description,
    duration: duration ?? this.duration,
    parentId: parentId ?? this.parentId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    thumbnail: thumbnail ?? this.thumbnail,
    features: features ?? this.features,
  );

  factory MembershipPlan.fromMap(Map<String, dynamic> json) => MembershipPlan(
    id: json["id"],
    slug: json["slug"],
    userType: json["user_type"],
    name: json["name"],
    price: json["price"],
    description: json["description"],
    duration: json["duration"],
    parentId: json["parent_id"],
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    thumbnail:
        json["thumbnail"] == null ? null : Video.fromMap(json["thumbnail"]),
    features:
        json["features"] == null ? null : Features.fromMap(json["features"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "slug": slug,
    "user_type": userType,
    "name": name,
    "price": price,
    "description": description,
    "duration": duration,
    "parent_id": parentId,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "thumbnail": thumbnail?.toMap(),
    "features": features?.toMap(),
  };
}

class Features {
  List<MembershipPlanFeature>? membershipPlanFeatures;

  Features({this.membershipPlanFeatures});

  Features copyWith({List<MembershipPlanFeature>? membershipPlanFeatures}) =>
      Features(
        membershipPlanFeatures:
            membershipPlanFeatures ?? this.membershipPlanFeatures,
      );

  factory Features.fromMap(Map<String, dynamic> json) => Features(
    membershipPlanFeatures:
        json["membership_plan_features"] == null
            ? []
            : List<MembershipPlanFeature>.from(
              json["membership_plan_features"]!.map(
                (x) => MembershipPlanFeature.fromMap(x),
              ),
            ),
  );

  Map<String, dynamic> toMap() => {
    "membership_plan_features":
        membershipPlanFeatures == null
            ? []
            : List<dynamic>.from(membershipPlanFeatures!.map((x) => x.toMap())),
  };
}

class MembershipPlanFeature {
  String? id;
  String? planId;
  String? name;
  String? value;
  int? isAvailable;
  String? createdAt;
  String? updatedAt;

  MembershipPlanFeature({
    this.id,
    this.planId,
    this.name,
    this.value,
    this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  MembershipPlanFeature copyWith({
    String? id,
    String? planId,
    String? name,
    String? value,
    int? isAvailable,
    String? createdAt,
    String? updatedAt,
  }) => MembershipPlanFeature(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    name: name ?? this.name,
    value: value ?? this.value,
    isAvailable: isAvailable ?? this.isAvailable,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory MembershipPlanFeature.fromMap(Map<String, dynamic> json) =>
      MembershipPlanFeature(
        id: json["id"],
        planId: json["plan_id"],
        name: json["name"],
        value: json["value"],
        isAvailable: json["is_available"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "plan_id": planId,
    "name": name,
    "value": value,
    "is_available": isAvailable,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class Video {
  String? message;

  Video({this.message});

  Video copyWith({String? message}) => Video(message: message ?? this.message);

  factory Video.fromMap(Map<String, dynamic> json) =>
      Video(message: json["message"]);

  Map<String, dynamic> toMap() => {"message": message};
}

class ShopMeta {
  String? shippingMethod;
  String? freeShippingTargetAmount;
  String? shippingFees;
  String? shippingService;
  String? shippingTimeUnit;
  String? shippingCompany;
  String? shippingTimeFrom;
  String? isEligibleForDiscounts;
  String? shippingTimeTo;
  dynamic whatsapp;
  String? phone;

  ShopMeta({
    this.shippingMethod,
    this.freeShippingTargetAmount,
    this.shippingFees,
    this.shippingService,
    this.shippingTimeUnit,
    this.shippingCompany,
    this.shippingTimeFrom,
    this.isEligibleForDiscounts,
    this.shippingTimeTo,
    this.whatsapp,
    this.phone,
  });

  ShopMeta copyWith({
    String? shippingMethod,
    String? freeShippingTargetAmount,
    String? shippingFees,
    String? shippingService,
    String? shippingTimeUnit,
    String? shippingCompany,
    String? shippingTimeFrom,
    String? isEligibleForDiscounts,
    String? shippingTimeTo,
    dynamic whatsapp,
    String? phone,
  }) => ShopMeta(
    shippingMethod: shippingMethod ?? this.shippingMethod,
    freeShippingTargetAmount:
        freeShippingTargetAmount ?? this.freeShippingTargetAmount,
    shippingFees: shippingFees ?? this.shippingFees,
    shippingService: shippingService ?? this.shippingService,
    shippingTimeUnit: shippingTimeUnit ?? this.shippingTimeUnit,
    shippingCompany: shippingCompany ?? this.shippingCompany,
    shippingTimeFrom: shippingTimeFrom ?? this.shippingTimeFrom,
    isEligibleForDiscounts:
        isEligibleForDiscounts ?? this.isEligibleForDiscounts,
    shippingTimeTo: shippingTimeTo ?? this.shippingTimeTo,
    whatsapp: whatsapp ?? this.whatsapp,
    phone: phone ?? this.phone,
  );

  factory ShopMeta.fromMap(Map<String, dynamic> json) => ShopMeta(
    shippingMethod: json["shipping_method"],
    freeShippingTargetAmount: json["free_shipping_target_amount"],
    shippingFees: json["shipping_fees"],
    shippingService: json["shipping_service"],
    shippingTimeUnit: json["shipping_time_unit"],
    shippingCompany: json["shipping_company"],
    shippingTimeFrom: json["shipping_time_from"],
    isEligibleForDiscounts: json["is_eligible_for_discounts"],
    shippingTimeTo: json["shipping_time_to"],
    whatsapp: json["whatsapp"],
    phone: json["phone"],
  );

  Map<String, dynamic> toMap() => {
    "shipping_method": shippingMethod,
    "free_shipping_target_amount": freeShippingTargetAmount,
    "shipping_fees": shippingFees,
    "shipping_service": shippingService,
    "shipping_time_unit": shippingTimeUnit,
    "shipping_company": shippingCompany,
    "shipping_time_from": shippingTimeFrom,
    "is_eligible_for_discounts": isEligibleForDiscounts,
    "shipping_time_to": shippingTimeTo,
    "whatsapp": whatsapp,
    "phone": phone,
  };
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({this.url, this.label, this.active});

  Link copyWith({String? url, String? label, bool? active}) => Link(
    url: url ?? this.url,
    label: label ?? this.label,
    active: active ?? this.active,
  );

  factory Link.fromMap(Map<String, dynamic> json) =>
      Link(url: json["url"], label: json["label"], active: json["active"]);

  Map<String, dynamic> toMap() => {
    "url": url,
    "label": label,
    "active": active,
  };
}
