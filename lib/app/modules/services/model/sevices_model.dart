class ServicesResponse {
  ServicesResponse({this.services});

  final Services? services;

  factory ServicesResponse.fromJson(Map<String, dynamic> json) {
    return ServicesResponse(
      services:
          json['services'] == null
              ? null
              : Services.fromJson(json['services'] as Map<String, dynamic>),
    );
  }
}

class Services {
  Services({
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

  final int? currentPage;
  final List<ServiceData>? data;
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

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      currentPage: json['current_page'] as int?,
      data:
          json['data'] == null
              ? null
              : List<ServiceData>.from(
                (json['data'] as List).map(
                  (x) => ServiceData.fromJson(x as Map<String, dynamic>),
                ),
              ),
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int?,
      lastPageUrl: json['last_page_url'] as String?,
      // links: json['links'] == null
      //     ? null
      //     : List<Link>.from(
      //         (json['links'] as List).map(
      //           (x) => Link.fromJson(x as Map<String, dynamic>),
      //         ),
      //       ),
      // nextPageUrl: json['next_page_url'] as String?,
      // path: json['path'] as String?,
      perPage: json['per_page'] as int?,
      // prevPageUrl: json['prev_page_url'] as String?,
      // to: json['to'] as int?,
      total: json['total'] as int?,
    );
  }
}

class ServiceData {
  ServiceData({
    this.id,
    this.slug,
    this.shopId,
    this.name,
    this.description,
    this.thumbnailId,
    this.price,
    this.countryId,
    this.stateId,
    this.cityId,
    this.salePrice,
    this.isFeatured,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.shop,
    this.categories,
    this.country,
    this.state,
    this.city,
    this.rating,
    this.meta,
  });

  final String? id;
  final String? slug;
  final String? shopId;
  final String? name;
  final String? description;
  final String? thumbnailId;
  final int? price;
  final String? countryId;
  final String? stateId;
  final String? cityId;
  final int? salePrice;
  final dynamic isFeatured;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final Thumbnail? thumbnail;
  final ShopWrapper? shop;
  final Categories? categories;
  final Country? country;
  final State? state;
  final City? city;
  final List<dynamic>? rating;
  final Meta? meta;

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      id: json['id'] as String?,
      slug: json['slug'] as String?,
      shopId: json['shop_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      thumbnailId: json['thumbnail_id'] as String?,
      price: json['price'] as int?,
      countryId: json['country_id'] as String?,
      stateId: json['state_id'] as String?,
      cityId: json['city_id'] as String?,
      salePrice: json['sale_price'] as int?,
      isFeatured: json['is_featured'],
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      thumbnail:
          json['thumbnail'] == null
              ? null
              : Thumbnail.fromJson(json['thumbnail'] as Map<String, dynamic>),
      // // shop: json['shop'] == null
      // //     ? null
      // //     : ShopWrapper.fromJson(json['shop'] as Map<String, dynamic>),
      // categories: json['categories'] == null
      //     ? null
      //     : Categories.fromJson(json['categories'] as Map<String, dynamic>),
      country:
          json['country'] == null
              ? null
              : Country.fromJson(json['country'] as Map<String, dynamic>),
      state:
          json['state'] == null
              ? null
              : State.fromJson(json['state'] as Map<String, dynamic>),
      // city: json['city'] == null
      //     ? null
      //     : City.fromJson(json['city'] as Map<String, dynamic>),
      // rating: json['rating'] == null
      //     ? null
      //     : List<dynamic>.from(json['rating'] as List),
      // meta: json['meta'] == null
      //     ? null
      //     : Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class Thumbnail {
  Thumbnail({this.media});

  final Media? media;

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      media:
          json['media'] == null
              ? null
              : Media.fromJson(json['media'] as Map<String, dynamic>),
    );
  }
}

class Media {
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
  });

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
  final String? createdAt;
  final String? updatedAt;
  final String? localUrl;
  final String? localOptimizedUrl;
  final bool? usingCdn;

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
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      localUrl: json['local_url'] as String?,
      localOptimizedUrl: json['local_optimized_url'] as String?,
      usingCdn: json['using_cdn'] as bool?,
    );
  }
}

class ShopWrapper {
  ShopWrapper({this.shop});

  final Shop? shop;

  factory ShopWrapper.fromJson(Map<String, dynamic> json) {
    return ShopWrapper(
      shop:
          json['shop'] == null
              ? null
              : Shop.fromJson(json['shop'] as Map<String, dynamic>),
    );
  }
}

class Shop {
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
    this.banner,
    this.thumbnail,
    this.membership,
    this.meta,
  });

  final String? id;
  final dynamic prevId;
  final String? userId;
  final String? membershipId;
  final String? membershipStartDate;
  final String? membershipEndDate;
  final String? slug;
  final String? name;
  final String? thumbnailId;
  final String? bannerImageId;
  final dynamic stripeAccountId;
  final int? balance;
  final String? description;
  final int? isVerified;
  final int? isFeatured;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final Banner? banner;
  final Thumbnail? thumbnail;
  final dynamic membership; // Can be Map or String message
  final ShopMeta? meta;

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String?,
      prevId: json['prev_id'],
      userId: json['user_id'] as String?,
      membershipId: json['membership_id'] as String?,
      membershipStartDate: json['membership_start_date'] as String?,
      membershipEndDate: json['membership_end_date'] as String?,
      slug: json['slug'] as String?,
      name: json['name'] as String?,
      thumbnailId: json['thumbnail_id'] as String?,
      bannerImageId: json['banner_image_id'] as String?,
      stripeAccountId: json['stripe_account_id'],
      balance: json['balance'] as int?,
      description: json['description'] as String?,
      isVerified: json['is_verified'] as int?,
      isFeatured: json['is_featured'] as int?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      banner:
          json['banner'] == null
              ? null
              : Banner.fromJson(json['banner'] as Map<String, dynamic>),
      thumbnail:
          json['thumbnail'] == null
              ? null
              : Thumbnail.fromJson(json['thumbnail'] as Map<String, dynamic>),
      membership: json['membership'], // Can be Map or String
      meta:
          json['meta'] == null
              ? null
              : ShopMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class Banner {
  Banner({this.media});

  final Media? media;

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      media:
          json['media'] == null
              ? null
              : Media.fromJson(json['media'] as Map<String, dynamic>),
    );
  }
}

class Categories {
  Categories({this.serviceAttributeItems});

  final List<ServiceAttributeItem>? serviceAttributeItems;

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      serviceAttributeItems:
          json['service_attribute_items'] == null
              ? null
              : List<ServiceAttributeItem>.from(
                (json['service_attribute_items'] as List).map(
                  (x) =>
                      ServiceAttributeItem.fromJson(x as Map<String, dynamic>),
                ),
              ),
    );
  }
}

class ServiceAttributeItem {
  ServiceAttributeItem({
    this.id,
    this.serviceId,
    this.attributeId,
    this.attributeItemId,
    this.createdAt,
    this.updatedAt,
    this.attributeItem,
  });

  final String? id;
  final String? serviceId;
  final String? attributeId;
  final String? attributeItemId;
  final String? createdAt;
  final String? updatedAt;
  final AttributeItemWrapper? attributeItem;

  factory ServiceAttributeItem.fromJson(Map<String, dynamic> json) {
    return ServiceAttributeItem(
      id: json['id'] as String?,
      serviceId: json['service_id'] as String?,
      attributeId: json['attribute_id'] as String?,
      attributeItemId: json['attribute_item_id'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      attributeItem:
          json['attribute_item'] == null
              ? null
              : AttributeItemWrapper.fromJson(
                json['attribute_item'] as Map<String, dynamic>,
              ),
    );
  }
}

class AttributeItemWrapper {
  AttributeItemWrapper({this.serviceAttributeItem});

  final ServiceAttributeItemData? serviceAttributeItem;

  factory AttributeItemWrapper.fromJson(Map<String, dynamic> json) {
    return AttributeItemWrapper(
      serviceAttributeItem:
          json['service_attribute_item'] == null
              ? null
              : ServiceAttributeItemData.fromJson(
                json['service_attribute_item'] as Map<String, dynamic>,
              ),
    );
  }
}

class ServiceAttributeItemData {
  ServiceAttributeItemData({
    this.id,
    this.attributeId,
    this.name,
    this.slug,
    this.value,
    this.parentId,
    this.thumbnailId,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.parent,
  });

  final String? id;
  final String? attributeId;
  final String? name;
  final String? slug;
  final dynamic value;
  final dynamic parentId;
  final String? thumbnailId;
  final String? createdAt;
  final String? updatedAt;
  final Thumbnail? thumbnail;
  final dynamic parent;

  factory ServiceAttributeItemData.fromJson(Map<String, dynamic> json) {
    return ServiceAttributeItemData(
      id: json['id'] as String?,
      attributeId: json['attribute_id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      value: json['value'],
      parentId: json['parent_id'],
      thumbnailId: json['thumbnail_id'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      thumbnail:
          json['thumbnail'] == null
              ? null
              : Thumbnail.fromJson(json['thumbnail'] as Map<String, dynamic>),
      parent: json['parent'],
    );
  }
}

class Country {
  Country({
    this.id,
    this.name,
    this.countryCode,
    this.currency,
    this.currencyCode,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? name;
  final String? countryCode;
  final String? currency;
  final String? currencyCode;
  final String? createdAt;
  final String? updatedAt;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String?,
      name: json['name'] as String?,
      countryCode: json['country_code'] as String?,
      currency: json['currency'] as String?,
      currencyCode: json['currency_code'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class State {
  State({
    this.id,
    this.countryId,
    this.name,
    this.isoCode,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? countryId;
  final String? name;
  final String? isoCode;
  final String? createdAt;
  final String? updatedAt;

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'] as String?,
      countryId: json['country_id'] as String?,
      name: json['name'] as String?,
      isoCode: json['iso_code'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class City {
  City({this.id, this.stateId, this.name, this.createdAt, this.updatedAt});

  final String? id;
  final String? stateId;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String?,
      stateId: json['state_id'] as String?,
      name: json['name'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class Meta {
  Meta({this.videoId, this.gallery});

  final dynamic videoId;
  final dynamic gallery; // Can be String or null

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(videoId: json['video_id'], gallery: json['gallery']);
  }
}

class ShopMeta {
  ShopMeta({
    this.freeShippingTargetAmount,
    this.shippingFees,
    this.shippingCompany,
    this.shippingTimeFrom,
    this.isEligibleForDiscounts,
    this.shippingTimeTo,
    this.whatsapp,
    this.phone,
  });

  final String? freeShippingTargetAmount;
  final String? shippingFees;
  final String? shippingCompany;
  final String? shippingTimeFrom;
  final String? isEligibleForDiscounts;
  final String? shippingTimeTo;
  final dynamic whatsapp;
  final String? phone;

  factory ShopMeta.fromJson(Map<String, dynamic> json) {
    return ShopMeta(
      freeShippingTargetAmount: json['free_shipping_target_amount'] as String?,
      shippingFees: json['shipping_fees'] as String?,
      shippingCompany: json['shipping_company'] as String?,
      shippingTimeFrom: json['shipping_time_from'] as String?,
      isEligibleForDiscounts: json['is_eligible_for_discounts'] as String?,
      shippingTimeTo: json['shipping_time_to'] as String?,
      whatsapp: json['whatsapp'],
      phone: json['phone'] as String?,
    );
  }
}

class Link {
  Link({this.url, this.label, this.active});

  final String? url;
  final String? label;
  final bool? active;

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'] as String?,
      label: json['label'] as String?,
      active: json['active'] as bool?,
    );
  }
}
