import 'package:tjara/app/models/products/variation.dart';

class SingleModelClass {
  SingleModelClass({
    required this.product,
  });

  final Product? product;

  SingleModelClass copyWith({
    Product? product,
  }) {
    return SingleModelClass(
      product: product ?? this.product,
    );
  }

  factory SingleModelClass.fromJson(Map<String, dynamic> json) {
    return SingleModelClass(
      product:
          json["product"] == null ? null : Product.fromJson(json["product"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "product": product?.toJson(),
      };

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
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"] ?? "",
      prevId: json["prev_id"],
      shopId: json["shop_id"] ?? "",
      slug: json["slug"] ?? "",
      name: json["name"] ?? "",
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
      thumbnail: json["thumbnail"] == null
          ? null
          : ThumbnailElement.fromJson(json["thumbnail"]),
      shop: json["shop"] == null ? null : ProductShop.fromJson(json["shop"]),
      variation: json["variations"] == null
          ? null
          : ProductVariationShop.fromJson(json["variations"]),
      categories: json["categories"] == null
          ? null
          : Brands.fromJson(json["categories"]),
      brands: json["brands"] == null ? null : Brands.fromJson(json["brands"]),
      video: json["video"] == null ? null : Video.fromJson(json["video"]),
      model: json["model"] == null ? null : Brands.fromJson(json["model"]),
      year: json["year"] == null ? null : Brands.fromJson(json["year"]),
      meta: json["meta"] == null ? null : ProductMeta.fromJson(json["meta"]),
      gallery: json["gallery"] == null
          ? []
          : List<ThumbnailElement>.from(
              json["gallery"]!.map((x) => ThumbnailElement.fromJson(x))),
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
      };

  @override
  String toString() {
    return "$id, $prevId, $shopId, $slug, $name, $productType, $productGroup, $thumbnailId, $description, $stock, $isFeatured, $isDeal, $price, $salePrice, $reservedPrice, $auctionStartTime, $auctionEndTime, $winnerId, $minPrice, $maxPrice, $saleStartTime, $saleEndTime, $status, $createdAt, $updatedAt, $thumbnail, $shop, $categories, $brands, $video, $model, $year, $meta, $gallery, ";
  }
}

class Brands {
  Brands({
    required this.productAttributeItems,
  });

  final List<ProductAttributeItemElement> productAttributeItems;

  Brands copyWith({
    List<ProductAttributeItemElement>? productAttributeItems,
  }) {
    return Brands(
      productAttributeItems:
          productAttributeItems ?? this.productAttributeItems,
    );
  }

  factory Brands.fromJson(Map<String, dynamic> json) {
    return Brands(
      productAttributeItems: json["product_attribute_items"] == null
          ? []
          : List<ProductAttributeItemElement>.from(
              json["product_attribute_items"]!
                  .map((x) => ProductAttributeItemElement.fromJson(x))),
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
      attributeItem: json["attribute_item"] == null
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
  AttributeItem({
    required this.productAttributeItem,
  });

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
      productAttributeItem: json["product_attribute_item"] == null
          ? null
          : AttributeItemProductAttributeItem.fromJson(
              json["product_attribute_item"]),
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
      Map<String, dynamic> json) {
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
      thumbnail: json["thumbnail"] == null
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
      thumbnail: json["thumbnail"] == null
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
      thumbnail: json["thumbnail"] == null
          ? null
          : ThumbnailElement.fromJson(json["thumbnail"]),
      parent: json["parent"] == null
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
      thumbnail: json["thumbnail"] == null
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
      thumbnail: json["thumbnail"] == null
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
  ThumbnailElement({
    required this.media,
  });

  final Media? media;

  ThumbnailElement copyWith({
    Media? media,
  }) {
    return ThumbnailElement(
      media: media ?? this.media,
    );
  }

  factory ThumbnailElement.fromJson(Map<String, dynamic> json) {
    return ThumbnailElement(
      media: json["media"] == null ? null : Media.fromJson(json["media"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "media": media?.toJson(),
      };

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
  ProductAttributeItemThumbnail({
    required this.media,
    required this.message,
  });

  final Media? media;
  final String message;

  ProductAttributeItemThumbnail copyWith({
    Media? media,
    String? message,
  }) {
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

class ProductMeta {
  ProductMeta({
    required this.productId,
    required this.views,
    required this.gallery,
    required this.videoId,
    required this.countryId,
  });

  final String productId;
  final String views;
  final String gallery;
  final dynamic videoId;
  final String countryId;

  ProductMeta copyWith({
    String? productId,
    String? views,
    String? gallery,
    dynamic videoId,
    String? countryId,
  }) {
    return ProductMeta(
      productId: productId ?? this.productId,
      views: views ?? this.views,
      gallery: gallery ?? this.gallery,
      videoId: videoId ?? this.videoId,
      countryId: countryId ?? this.countryId,
    );
  }

  factory ProductMeta.fromJson(Map<String, dynamic> json) {
    return ProductMeta(
      productId: json["product_id"] ?? "",
      views: json["views"] ?? "",
      gallery: json["gallery"] ?? "",
      videoId: json["video_id"],
      countryId: json["country_id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "views": views,
        "gallery": gallery,
        "video_id": videoId,
        "country_id": countryId,
      };

  @override
  String toString() {
    return "$productId, $views, $gallery, $videoId, $countryId, ";
  }
}

class ProductShop {
  ProductShop({
    required this.shop,
  });

  final ShopShop? shop;

  ProductShop copyWith({
    ShopShop? shop,
  }) {
    return ProductShop(
      shop: shop ?? this.shop,
    );
  }

  factory ProductShop.fromJson(Map<String, dynamic> json) {
    return ProductShop(
      shop: json["shop"] == null ? null : ShopShop.fromJson(json["shop"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "shop": shop?.toJson(),
      };

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
      membership: json["membership"] == null
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
  Video({
    required this.message,
  });

  final String message;

  Video copyWith({
    String? message,
  }) {
    return Video(
      message: message ?? this.message,
    );
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      message: json["message"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "message": message,
      };

  @override
  String toString() {
    return "$message, ";
  }
}

class ShopMeta {
  ShopMeta({
    required this.phone,
  });

  final String phone;

  ShopMeta copyWith({
    String? phone,
  }) {
    return ShopMeta(
      phone: phone ?? this.phone,
    );
  }

  factory ShopMeta.fromJson(Map<String, dynamic> json) {
    return ShopMeta(
      phone: json["phone"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "phone": phone,
      };

  @override
  String toString() {
    return "$phone, ";
  }
}
