import 'package:tjara/app/models/media_model/media_model.dart';

class CategoryModel {
  List<ProductAttributeItems>? productAttributeItems;

  CategoryModel({this.productAttributeItems});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    if (json['product_attribute_items'] != null) {
      productAttributeItems = <ProductAttributeItems>[];
      json['product_attribute_items'].forEach((v) {
        productAttributeItems!.add(ProductAttributeItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (productAttributeItems != null) {
      data['product_attribute_items'] =
          productAttributeItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  CategoryModel copyWith({
    List<ProductAttributeItems>? productAttributeItems,
  }) {
    return CategoryModel(
      productAttributeItems:
          productAttributeItems ?? this.productAttributeItems,
    );
  }
}

class ProductAttributeItems {
  String? id;
  String? attributeId;
  String? name;
  String? slug;
  Null value;
  String? postType;
  String? parentId;
  String? thumbnailId;
  String? createdAt;
  String? updatedAt;
  Thumbnail? thumbnail;
  bool? haveSubCategories;

  ProductAttributeItems({
    this.id,
    this.attributeId,
    this.name,
    this.slug,
    this.value,
    this.postType,
    this.parentId,
    this.thumbnailId,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.haveSubCategories,
  });

  ProductAttributeItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    attributeId = json['attribute_id'];
    name = json['name'];
    slug = json['slug'];
    value = json['value'];
    postType = json['post_type'];
    parentId = json['parent_id'];
    thumbnailId = json['thumbnail_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    thumbnail = json['thumbnail'] != null
        ? Thumbnail.fromJson(json['thumbnail'])
        : null;
    haveSubCategories = json['have_sub_categories'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['attribute_id'] = attributeId;
    data['name'] = name;
    data['slug'] = slug;
    data['value'] = value;
    data['post_type'] = postType;
    data['parent_id'] = parentId;
    data['thumbnail_id'] = thumbnailId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (thumbnail != null) {
      data['thumbnail'] = thumbnail!.toJson();
    }
    data['have_sub_categories'] = haveSubCategories;
    return data;
  }

  ProductAttributeItems copyWith({
    String? id,
    String? attributeId,
    String? name,
    String? slug,
    Null value,
    String? postType,
    String? parentId,
    String? thumbnailId,
    String? createdAt,
    String? updatedAt,
    Thumbnail? thumbnail,
    bool? haveSubCategories,
  }) {
    return ProductAttributeItems(
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
      haveSubCategories: haveSubCategories ?? this.haveSubCategories,
    );
  }

  @override
  String toString() {
    return name ?? '';
  }
}

class Thumbnail {
  String? message;
  MediaUniversalModel? media;

  Thumbnail({this.message, this.media});

  Thumbnail.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    media = json['media'] != null
        ? MediaUniversalModel.fromJson(json['media'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (media != null) {
      data['media'] = media!.toJson();
    }
    return data;
  }

  Thumbnail copyWith({
    String? message,
    MediaUniversalModel? media,
  }) {
    return Thumbnail(
      message: message ?? this.message,
      media: media ?? this.media,
    );
  }
}
