class ProductVariationShop {
  ProductVariationShop({required this.shop});
  final List<ProductVariation>? shop;

  ProductVariationShop copyWith({List<ProductVariation>? shop}) {
    return ProductVariationShop(shop: shop ?? this.shop);
  }

  factory ProductVariationShop.fromJson(Map<String, dynamic> json) {
    return ProductVariationShop(
      shop: json["product_variations"] == null
          ? null
          : List<ProductVariation>.from((json["product_variations"] as List)
              .map(
                  (x) => ProductVariation.fromJson(x as Map<String, dynamic>))),
    );
  }

  @override
  String toString() {
    return "$shop";
  }
}

class ProductVariation {
  final String? id;
  final String? productId;
  final String? thumbnailId;
  final double? price;
  final double? salePrice;
  final int? stock;
  final String? saleStartTime;
  final String? saleEndTime;
  final String? createdAt;
  final String? updatedAt;
  final VariationAttributes? attributes;
  final VariationThumbnail? thumbnail;

  ProductVariation({
    this.id,
    this.productId,
    this.thumbnailId,
    this.price,
    this.salePrice,
    this.stock,
    this.saleStartTime,
    this.saleEndTime,
    this.createdAt,
    this.updatedAt,
    this.attributes,
    this.thumbnail,
  });

  /// Returns the best available thumbnail URL for this variation
  String? get thumbnailUrl {
    final media = thumbnail?.media;
    if (media == null) return null;
    return media.cdnThumbnailUrl ??
        media.optimizedMediaCdnUrl ??
        media.cdnUrl ??
        media.optimizedMediaUrl ??
        media.url;
  }

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      id: json['id'],
      productId: json['product_id'],
      thumbnailId: json['thumbnail_id'],
      price: json['price']?.toDouble(),
      salePrice: json['sale_price']?.toDouble(),
      stock: json['stock'],
      saleStartTime: json['sale_start_time'],
      saleEndTime: json['sale_end_time'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      attributes: json['attributes'] != null
          ? VariationAttributes.fromJson(json['attributes'])
          : null,
      thumbnail: json['thumbnail'] != null
          ? VariationThumbnail.fromJson(json['thumbnail'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'thumbnail_id': thumbnailId,
      'price': price,
      'sale_price': salePrice,
      'stock': stock,
      'sale_start_time': saleStartTime,
      'sale_end_time': saleEndTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'attributes': attributes?.toJson(),
      'thumbnail': thumbnail?.toJson(),
    };
  }
}

class VariationAttributes {
  final List<VariationAttributeItem>? attributeItems;

  VariationAttributes({this.attributeItems});

  factory VariationAttributes.fromJson(Map<String, dynamic> json) {
    return VariationAttributes(
      attributeItems: json['product_variation_attribute_items'] != null
          ? List<VariationAttributeItem>.from(
              json['product_variation_attribute_items']
                  .map((x) => VariationAttributeItem.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_variation_attribute_items':
          attributeItems?.map((item) => item.toJson()).toList(),
    };
  }
}

class VariationAttributeItem {
  final String? id;
  final String? variationId;
  final String? attributeId;
  final String? attributeItemId;
  final String? createdAt;
  final String? updatedAt;
  final Attribute? attribute;
  final AttributeItem? attributeItem;

  VariationAttributeItem({
    this.id,
    this.variationId,
    this.attributeId,
    this.attributeItemId,
    this.createdAt,
    this.updatedAt,
    this.attribute,
    this.attributeItem,
  });

  factory VariationAttributeItem.fromJson(Map<String, dynamic> json) {
    return VariationAttributeItem(
      id: json['id'],
      variationId: json['variation_id'],
      attributeId: json['attribute_id'],
      attributeItemId: json['attribute_item_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      attribute: json['attribute'] != null
          ? Attribute.fromJson(json['attribute'])
          : null,
      attributeItem: json['attribute_item'] != null
          ? AttributeItem.fromJson(json['attribute_item'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variation_id': variationId,
      'attribute_id': attributeId,
      'attribute_item_id': attributeItemId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'attribute': attribute?.toJson(),
      'attribute_item': attributeItem?.toJson(),
    };
  }
}

class Attribute {
  final String? id;
  final String? name;
  final String? slug;
  final String? createdAt;
  final String? updatedAt;

  Attribute({
    this.id,
    this.name,
    this.slug,
    this.createdAt,
    this.updatedAt,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class AttributeItem {
  final String? id;
  final String? attributeId;
  final String? name;
  final String? slug;
  final String? value;
  final String? postType;
  final String? createdAt;
  final String? updatedAt;

  AttributeItem({
    this.id,
    this.attributeId,
    this.name,
    this.slug,
    this.value,
    this.postType,
    this.createdAt,
    this.updatedAt,
  });

  factory AttributeItem.fromJson(Map<String, dynamic> json) {
    return AttributeItem(
      id: json['id'],
      attributeId: json['attribute_id'],
      name: json['name'],
      slug: json['slug'],
      value: json['value'],
      postType: json['post_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attribute_id': attributeId,
      'name': name,
      'slug': slug,
      'value': value,
      'post_type': postType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class VariationThumbnail {
  final VariationMedia? media;

  VariationThumbnail({this.media});

  factory VariationThumbnail.fromJson(Map<String, dynamic> json) {
    return VariationThumbnail(
      media: json['media'] != null && json['media'] is Map
          ? VariationMedia.fromJson(json['media'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media': media?.toJson(),
    };
  }
}

class VariationMedia {
  final String? id;
  final String? url;
  final String? optimizedMediaUrl;
  final String? mediaType;
  final String? cdnUrl;
  final String? optimizedMediaCdnUrl;
  final String? cdnThumbnailUrl;
  final String? cdnStoragePath;
  final String? createdAt;
  final String? updatedAt;

  VariationMedia({
    this.id,
    this.url,
    this.optimizedMediaUrl,
    this.mediaType,
    this.cdnUrl,
    this.optimizedMediaCdnUrl,
    this.cdnThumbnailUrl,
    this.cdnStoragePath,
    this.createdAt,
    this.updatedAt,
  });

  factory VariationMedia.fromJson(Map<String, dynamic> json) {
    return VariationMedia(
      id: json['id'],
      url: json['url'],
      optimizedMediaUrl: json['optimized_media_url'],
      mediaType: json['media_type'],
      cdnUrl: json['cdn_url'],
      optimizedMediaCdnUrl: json['optimized_media_cdn_url'],
      cdnThumbnailUrl: json['cdn_thumbnail_url'],
      cdnStoragePath: json['cdn_storage_path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'optimized_media_url': optimizedMediaUrl,
      'media_type': mediaType,
      'cdn_url': cdnUrl,
      'optimized_media_cdn_url': optimizedMediaCdnUrl,
      'cdn_thumbnail_url': cdnThumbnailUrl,
      'cdn_storage_path': cdnStoragePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
