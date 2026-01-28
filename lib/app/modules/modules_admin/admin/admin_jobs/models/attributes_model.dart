class JobAttributesResponse {
  List<JobAttribute>? jobAttributes;

  JobAttributesResponse({this.jobAttributes});

  factory JobAttributesResponse.fromJson(Map<String, dynamic> json) {
    return JobAttributesResponse(
      jobAttributes: json['job_attributes'] != null
          ? (json['job_attributes'] as List)
              .map((i) => JobAttribute.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_attributes': jobAttributes?.map((e) => e.toJson()).toList(),
    };
  }
}

class JobAttribute {
  String? id;
  String? name;
  String? slug;
  dynamic thumbnailId;
  dynamic parentId;
  DateTime? createdAt;
  DateTime? updatedAt;
  Thumbnail? thumbnail;
  AttributeItems? attributeItems;
  dynamic parent;

  JobAttribute({
    this.id,
    this.name,
    this.slug,
    this.thumbnailId,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.attributeItems,
    this.parent,
  });

  factory JobAttribute.fromJson(Map<String, dynamic> json) {
    return JobAttribute(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      thumbnailId: json['thumbnail_id'],
      parentId: json['parent_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
      attributeItems: json['attribute_items'] != null
          ? AttributeItems.fromJson(json['attribute_items'])
          : null,
      parent: json['parent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'thumbnail_id': thumbnailId,
      'parent_id': parentId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'thumbnail': thumbnail?.toJson(),
      'attribute_items': attributeItems?.toJson(),
      'parent': parent,
    };
  }
}

class Thumbnail {
  String? message;

  Thumbnail({this.message});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class AttributeItems {
  List<JobAttributeItem>? jobAttributeItems;

  AttributeItems({this.jobAttributeItems});

  factory AttributeItems.fromJson(Map<String, dynamic> json) {
    return AttributeItems(
      jobAttributeItems: json['job_attribute_items'] != null
          ? (json['job_attribute_items'] as List)
              .map((i) => JobAttributeItem.fromJson(i))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_attribute_items': jobAttributeItems?.map((e) => e.toJson()).toList(),
    };
  }
}

class JobAttributeItem {
  String? id;
  String? attributeId;
  String? name;
  String? slug;
  dynamic value;
  dynamic parentId;
  dynamic thumbnailId;
  DateTime? createdAt;
  DateTime? updatedAt;
  Thumbnail? thumbnail;
  dynamic parent;

  JobAttributeItem({
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

  factory JobAttributeItem.fromJson(Map<String, dynamic> json) {
    return JobAttributeItem(
      id: json['id'],
      attributeId: json['attribute_id'],
      name: json['name'],
      slug: json['slug'],
      value: json['value'],
      parentId: json['parent_id'],
      thumbnailId: json['thumbnail_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
      parent: json['parent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attribute_id': attributeId,
      'name': name,
      'slug': slug,
      'value': value,
      'parent_id': parentId,
      'thumbnail_id': thumbnailId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'thumbnail': thumbnail?.toJson(),
      'parent': parent,
    };
  }
}
