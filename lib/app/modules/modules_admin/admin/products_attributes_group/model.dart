class AttributeGroupModel {
  final String id;
  final String name;
  final String slug;
  final List<AttributeData> attributes;

  AttributeGroupModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.attributes,
  });

  factory AttributeGroupModel.fromJson(Map<String, dynamic> json) {
    return AttributeGroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      attributes:
          (json['attributes'] as List<dynamic>?)
              ?.map((e) => AttributeData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'attributes': attributes.map((e) => e.toJson()).toList(),
    };
  }
}

class AttributeData {
  final String id;
  final String name;
  final List<AttributeItem> items;

  AttributeData({required this.id, required this.name, required this.items});

  factory AttributeData.fromJson(Map<String, dynamic> json) {
    return AttributeData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => AttributeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class AttributeItem {
  final String id;
  final String name;
  bool isSelected;

  AttributeItem({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  factory AttributeItem.fromJson(Map<String, dynamic> json) {
    return AttributeItem(id: json['id'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// Model for product attributes API response
class ProductAttribute {
  final String id;
  final String name;
  final String slug;
  final AttributeItemsData? attributeItems;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.slug,
    this.attributeItems,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      attributeItems:
          json['attribute_items'] != null
              ? AttributeItemsData.fromJson(json['attribute_items'])
              : null,
    );
  }
}

class AttributeItemsData {
  final List<ProductAttributeItem> items;

  AttributeItemsData({required this.items});

  factory AttributeItemsData.fromJson(Map<String, dynamic> json) {
    if (json['product_attribute_items'] != null) {
      return AttributeItemsData(
        items:
            (json['product_attribute_items'] as List<dynamic>)
                .map(
                  (e) =>
                      ProductAttributeItem.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
      );
    }
    return AttributeItemsData(items: []);
  }
}

class ProductAttributeItem {
  final String id;
  final String attributeId;
  final String name;
  final String slug;
  bool isSelected;

  ProductAttributeItem({
    required this.id,
    required this.attributeId,
    required this.name,
    required this.slug,
    this.isSelected = false,
  });

  factory ProductAttributeItem.fromJson(Map<String, dynamic> json) {
    return ProductAttributeItem(
      id: json['id'] ?? '',
      attributeId: json['attribute_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}
