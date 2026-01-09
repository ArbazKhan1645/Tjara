class ProductAttributesResponse {
  List<ProductAttributes>? productAttributes;

  ProductAttributesResponse({this.productAttributes});

  ProductAttributesResponse.fromJson(Map<String, dynamic> json) {
    if (json['product_attributes'] != null) {
      productAttributes = <ProductAttributes>[];
      json['product_attributes'].forEach((v) {
        productAttributes!.add(ProductAttributes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (productAttributes != null) {
      data['product_attributes'] =
          productAttributes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductAttributes {
  String? id;
  String? name;
  String? slug;
  Null thumbnailId;
  Null parentId;
  String? createdAt;
  String? updatedAt;
  AttributeItems? attributeItems;

  ProductAttributes(
      {this.id,
      this.name,
      this.slug,
      this.thumbnailId,
      this.parentId,
      this.createdAt,
      this.updatedAt,
      this.attributeItems});

  ProductAttributes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    thumbnailId = json['thumbnail_id'];
    parentId = json['parent_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    attributeItems = json['attribute_items'] != null
        ? AttributeItems.fromJson(json['attribute_items'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['thumbnail_id'] = thumbnailId;
    data['parent_id'] = parentId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (attributeItems != null) {
      data['attribute_items'] = attributeItems!.toJson();
    }
    return data;
  }
}

class AttributeItems {
  List<ProductAttributeItems>? productAttributeItems;
  String? message;

  AttributeItems({this.productAttributeItems, this.message});

  AttributeItems.fromJson(Map<String, dynamic> json) {
    if (json['product_attribute_items'] != null) {
      productAttributeItems = <ProductAttributeItems>[];
      json['product_attribute_items'].forEach((v) {
        productAttributeItems!.add(ProductAttributeItems.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (productAttributeItems != null) {
      data['product_attribute_items'] =
          productAttributeItems!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class ProductAttributeItems {
  String? id;
  String? attributeId;
  String? name;
  String? slug;
  String? value;
  String? postType;
  String? parentId;
  String? thumbnailId;
  String? createdAt;
  String? updatedAt;

  ProductAttributeItems(
      {this.id,
      this.attributeId,
      this.name,
      this.slug,
      this.value,
      this.postType,
      this.parentId,
      this.thumbnailId,
      this.createdAt,
      this.updatedAt});

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
    return data;
  }
}
