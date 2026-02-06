class CategoriesResponse {
  final ProductAttribute productAttribute;
  final String provider;

  CategoriesResponse({
    required this.productAttribute,
    required this.provider,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      productAttribute: ProductAttribute.fromJson(json['product_attribute'] ?? {}),
      provider: json['provider'] ?? 'database',
    );
  }
}

class ProductAttribute {
  final String id;
  final String name;
  final String slug;
  final String? thumbnailId;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AttributeItems attributeItems;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.slug,
    this.thumbnailId,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    required this.attributeItems,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      thumbnailId: json['thumbnail_id'],
      parentId: json['parent_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      attributeItems: AttributeItems.fromJson(json['attribute_items'] ?? {}),
    );
  }
}

class AttributeItems {
  final List<Category> productAttributeItems;
  final String provider;

  AttributeItems({
    required this.productAttributeItems,
    required this.provider,
  });

  factory AttributeItems.fromJson(Map<String, dynamic> json) {
    return AttributeItems(
      productAttributeItems: (json['product_attribute_items'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
      provider: json['provider'] ?? 'database',
    );
  }
}

class Category {
  final String id;
  final String attributeId;
  final String name;
  final String slug;
  final String? value;
  final String postType;
  final String? parentId;
  final String? thumbnailId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.attributeId,
    required this.name,
    required this.slug,
    this.value,
    required this.postType,
    this.parentId,
    this.thumbnailId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      attributeId: json['attribute_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      value: json['value'],
      postType: json['post_type'] ?? 'product',
      parentId: json['parent_id'],
      thumbnailId: json['thumbnail_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
