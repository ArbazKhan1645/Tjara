class ProductModel {
  final Products? products;

  ProductModel({this.products});

  factory ProductModel.fromJson(Map<String, dynamic>? json) {
    return ProductModel(
      products: json?['products'] != null
          ? Products.fromJson(json!['products'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'products': products?.toJson(),
      };
}

class Products {
  final num? currentPage; // Changed to num?
  final List<Datum>? data;

  Products({this.currentPage, this.data});

  factory Products.fromJson(Map<String, dynamic>? json) {
    return Products(
      currentPage: json?['current_page'] != null
          ? num.parse(json!['current_page'].toString())
          : null,
      data: json?['data'] != null
          ? List<Datum>.from(json!['data'].map((x) => Datum.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'data': data?.map((x) => x.toJson()).toList(),
      };
}

class Datum {
  final String? id;
  final dynamic prevId;
  final String? shopId;
  final String? slug;
  final String? name;
  final String? productType;
  final String? productGroup;
  final String? thumbnailId;
  final String? description;
  final num? stock;
  final num? isFeatured;
  final num? isDeal;
  final num? price;
  final num? salePrice;
  final dynamic reservedPrice;
  final dynamic auctionStartTime;
  final dynamic auctionEndTime;
  final dynamic winnerId;
  final dynamic minPrice;
  final dynamic maxPrice;
  final dynamic saleStartTime;
  final dynamic saleEndTime;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Thumbnail? thumbnail;
  final List<dynamic>? rating;
  final DatumShop? shop;
  final Brands? brands;
  final Video? video;
  final DatumMeta? meta;
  final bool? isDiscountProduct;

  Datum({
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
    this.brands,
    this.video,
    this.meta,
    this.isDiscountProduct,
  });

  factory Datum.fromJson(Map<String, dynamic>? json) {
    return Datum(
      id: json?['id']?.toString(),
      prevId: json?['prev_id'],
      shopId: json?['shop_id']?.toString(),
      slug: json?['slug'],
      name: json?['name'],
      productType: json?['product_type'],
      productGroup: json?['product_group'],
      thumbnailId: json?['thumbnail_id'],
      description: json?['description'],
      stock:
          json?['stock'] != null ? num.parse(json!['stock'].toString()) : null,
      isFeatured: json?['is_featured'] != null
          ? num.parse(json!['is_featured'].toString())
          : null,
      isDeal: json?['is_deal'] != null
          ? num.parse(json!['is_deal'].toString())
          : null,
      price:
          json?['price'] != null ? num.parse(json!['price'].toString()) : null,
      salePrice: json?['sale_price'] != null
          ? num.parse(json!['sale_price'].toString())
          : null,
      reservedPrice: json?['reserved_price'],
      auctionStartTime: json?['auction_start_time'],
      auctionEndTime: json?['auction_end_time'],
      winnerId: json?['winner_id'],
      minPrice: json?['min_price'],
      maxPrice: json?['max_price'],
      saleStartTime: json?['sale_start_time'],
      saleEndTime: json?['sale_end_time'],
      status: json?['status'],
      createdAt: json?['created_at'] != null
          ? DateTime.parse(json!['created_at'])
          : null,
      updatedAt: json?['updated_at'] != null
          ? DateTime.parse(json!['updated_at'])
          : null,
      thumbnail: json?['thumbnail'] != null
          ? Thumbnail.fromJson(json!['thumbnail'])
          : null,
      rating:
          json?['rating'] != null ? List<dynamic>.from(json!['rating']) : null,
      shop: json?['shop'] != null ? DatumShop.fromJson(json!['shop']) : null,
      brands: json?['brands'] != null ? Brands.fromJson(json!['brands']) : null,
      video: json?['video'] != null ? Video.fromJson(json!['video']) : null,
      meta: json?['meta'] != null ? DatumMeta.fromJson(json!['meta']) : null,
      isDiscountProduct: json?['is_discount_product'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prev_id': prevId,
        'shop_id': shopId,
        'slug': slug,
        'name': name,
        'product_type': productType,
        'product_group': productGroup,
        'thumbnail_id': thumbnailId,
        'description': description,
        'stock': stock,
        'is_featured': isFeatured,
        'is_deal': isDeal,
        'price': price,
        'sale_price': salePrice,
        'reserved_price': reservedPrice,
        'auction_start_time': auctionStartTime,
        'auction_end_time': auctionEndTime,
        'winner_id': winnerId,
        'min_price': minPrice,
        'max_price': maxPrice,
        'sale_start_time': saleStartTime,
        'sale_end_time': saleEndTime,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'thumbnail': thumbnail?.toJson(),
        'rating': rating,
        'shop': shop?.toJson(),
        'brands': brands?.toJson(),
        'video': video?.toJson(),
        'meta': meta?.toJson(),
        'is_discount_product': isDiscountProduct,
      };
}

class Brands {
  final List<dynamic>? productAttributeItems;

  Brands({this.productAttributeItems});

  factory Brands.fromJson(Map<String, dynamic>? json) {
    return Brands(
      productAttributeItems: json?['product_attribute_items'] != null
          ? List<dynamic>.from(json!['product_attribute_items'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_attribute_items': productAttributeItems,
      };
}

class DatumMeta {
  final String? productId;
  final String? views;
  final String? countryId;
  final dynamic videoId;
  final String? gallery;

  DatumMeta({
    this.productId,
    this.views,
    this.countryId,
    this.videoId,
    this.gallery,
  });

  factory DatumMeta.fromJson(Map<String, dynamic>? json) {
    return DatumMeta(
      productId: json?['product_id']?.toString(),
      views: json?['views']?.toString(),
      countryId: json?['country_id']?.toString(),
      videoId: json?['video_id'],
      gallery: json?['gallery'],
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'views': views,
        'country_id': countryId,
        'video_id': videoId,
        'gallery': gallery,
      };
}

class DatumShop {
  final ShopShop? shop;

  DatumShop({this.shop});

  factory DatumShop.fromJson(Map<String, dynamic>? json) {
    return DatumShop(
      shop: json?['shop'] != null ? ShopShop.fromJson(json!['shop']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'shop': shop?.toJson(),
      };
}

class ShopShop {
  final String? id;
  final dynamic prevId;
  final String? userId;
  final dynamic membershipId;
  final dynamic membershipStartDate;
  final dynamic membershipEndDate;
  final String? slug;
  final String? name;
  final dynamic thumbnailId;
  final dynamic bannerImageId;
  final dynamic stripeAccountId;
  final num? balance;
  final String? description;
  final num? isVerified;
  final num? isFeatured;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Video? banner;
  final Video? thumbnail;
  final Video? membership;
  final ShopMeta? meta;

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

  factory ShopShop.fromJson(Map<String, dynamic>? json) {
    return ShopShop(
      id: json?['id']?.toString(),
      prevId: json?['prev_id'],
      userId: json?['user_id']?.toString(),
      membershipId: json?['membership_id'],
      membershipStartDate: json?['membership_start_date'],
      membershipEndDate: json?['membership_end_date'],
      slug: json?['slug'],
      name: json?['name'],
      thumbnailId: json?['thumbnail_id'],
      bannerImageId: json?['banner_image_id'],
      stripeAccountId: json?['stripe_account_id'],
      balance: json?['balance'] != null
          ? num.parse(json!['balance'].toString())
          : null,
      description: json?['description'],
      isVerified: json?['is_verified'] != null
          ? num.parse(json!['is_verified'].toString())
          : null,
      isFeatured: json?['is_featured'] != null
          ? num.parse(json!['is_featured'].toString())
          : null,
      status: json?['status'],
      createdAt: json?['created_at'] != null
          ? DateTime.parse(json!['created_at'])
          : null,
      updatedAt: json?['updated_at'] != null
          ? DateTime.parse(json!['updated_at'])
          : null,
      banner: json?['banner'] != null ? Video.fromJson(json!['banner']) : null,
      thumbnail: json?['thumbnail'] != null
          ? Video.fromJson(json!['thumbnail'])
          : null,
      membership: json?['membership'] != null
          ? Video.fromJson(json!['membership'])
          : null,
      meta: json?['meta'] != null ? ShopMeta.fromJson(json!['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prev_id': prevId,
        'user_id': userId,
        'membership_id': membershipId,
        'membership_start_date': membershipStartDate,
        'membership_end_date': membershipEndDate,
        'slug': slug,
        'name': name,
        'thumbnail_id': thumbnailId,
        'banner_image_id': bannerImageId,
        'stripe_account_id': stripeAccountId,
        'balance': balance,
        'description': description,
        'is_verified': isVerified,
        'is_featured': isFeatured,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'banner': banner?.toJson(),
        'thumbnail': thumbnail?.toJson(),
        'membership': membership?.toJson(),
        'meta': meta?.toJson(),
      };
}

class Video {
  final String? message;

  Video({this.message});

  factory Video.fromJson(Map<String, dynamic>? json) {
    return Video(
      message: json?['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}

class ShopMeta {
  final String? phone;

  ShopMeta({this.phone});

  factory ShopMeta.fromJson(Map<String, dynamic>? json) {
    return ShopMeta(
      phone: json?['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'phone': phone,
      };
}

class Thumbnail {
  final Media? media;

  Thumbnail({this.media});

  factory Thumbnail.fromJson(Map<String, dynamic>? json) {
    return Thumbnail(
      media: json?['media'] != null ? Media.fromJson(json!['media']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'media': media?.toJson(),
      };
}

class Media {
  final String? id;
  final String? url;
  final String? optimizedMediaUrl;
  final String? mediaType;
  final dynamic isUsed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Media({
    this.id,
    this.url,
    this.optimizedMediaUrl,
    this.mediaType,
    this.isUsed,
    this.createdAt,
    this.updatedAt,
  });

  factory Media.fromJson(Map<String, dynamic>? json) {
    return Media(
      id: json?['id'],
      url: json?['url'],
      optimizedMediaUrl: json?['optimized_media_url'],
      mediaType: json?['media_type'],
      isUsed: json?['is_used'],
      createdAt: json?['created_at'] != null
          ? DateTime.parse(json!['created_at'])
          : null,
      updatedAt: json?['updated_at'] != null
          ? DateTime.parse(json!['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'optimized_media_url': optimizedMediaUrl,
        'media_type': mediaType,
        'is_used': isUsed,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
