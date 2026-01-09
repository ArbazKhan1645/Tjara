class ServiceAttributesResponse {
  List<ServiceAttribute>? serviceAttributes;

  ServiceAttributesResponse({this.serviceAttributes});

  factory ServiceAttributesResponse.fromJson(Map<String, dynamic> json) {
    return ServiceAttributesResponse(
      serviceAttributes: (json['service_attributes'] as List?)
          ?.map((e) => ServiceAttribute.fromJson(e))
          .toList(),
    );
  }
}

class ServiceAttribute {
  String? id;
  String? name;
  String? slug;
  String? thumbnailId;
  String? parentId;
  String? createdAt;
  String? updatedAt;
  ThumbnailWrapper? thumbnail;
  AttributeItems? attributeItems;
  dynamic parent;

  ServiceAttribute({
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

  factory ServiceAttribute.fromJson(Map<String, dynamic> json) {
    return ServiceAttribute(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      thumbnailId: json['thumbnail_id'],
      parentId: json['parent_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      thumbnail: json['thumbnail'] != null
          ? ThumbnailWrapper.fromJson(json['thumbnail'])
          : null,
      attributeItems: json['attribute_items'] != null
          ? AttributeItems.fromJson(json['attribute_items'])
          : null,
      parent: json['parent'],
    );
  }
}

class ThumbnailWrapper {
  String? message;
  Media? media;

  ThumbnailWrapper({this.message, this.media});

  factory ThumbnailWrapper.fromJson(Map<String, dynamic> json) {
    return ThumbnailWrapper(
      message: json['message'],
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
    );
  }
}

class AttributeItems {
  List<ServiceAttributeItem>? serviceAttributeItems;

  AttributeItems({this.serviceAttributeItems});

  factory AttributeItems.fromJson(Map<String, dynamic> json) {
    return AttributeItems(
      serviceAttributeItems:
          (json['service_attribute_items'] as List?)?.map((e) {
        return ServiceAttributeItem.fromJson(e);
      }).toList(),
    );
  }
}

class ServiceAttributeItem {
  String? id;
  String? attributeId;
  String? name;
  String? slug;
  dynamic value;
  String? parentId;
  String? thumbnailId;
  String? createdAt;
  String? updatedAt;
  ThumbnailWrapper? thumbnail;
  dynamic parent;

  ServiceAttributeItem({
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

  factory ServiceAttributeItem.fromJson(Map<String, dynamic> json) {
    return ServiceAttributeItem(
      id: json['id'],
      attributeId: json['attribute_id'],
      name: json['name'],
      slug: json['slug'],
      value: json['value'],
      parentId: json['parent_id'],
      thumbnailId: json['thumbnail_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      thumbnail: json['thumbnail'] != null
          ? ThumbnailWrapper.fromJson(json['thumbnail'])
          : null,
      parent: json['parent'],
    );
  }
}

class Media {
  String? id;
  String? url;
  String? optimizedMediaUrl;
  String? mediaType;
  String? cdnUrl;
  String? optimizedMediaCdnUrl;
  String? cdnVideoId;
  String? cdnThumbnailUrl;
  String? cdnStoragePath;
  bool? isStreaming;
  bool? isUsed;
  String? createdAt;
  String? updatedAt;
  bool? usingCdn;
  String? localUrl;
  String? localOptimizedUrl;
  List<MediaCopy>? copies;

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
    this.usingCdn,
    this.localUrl,
    this.localOptimizedUrl,
    this.copies,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      url: json['url'],
      optimizedMediaUrl: json['optimized_media_url'],
      mediaType: json['media_type'],
      cdnUrl: json['cdn_url'],
      optimizedMediaCdnUrl: json['optimized_media_cdn_url'],
      cdnVideoId: json['cdn_video_id'],
      cdnThumbnailUrl: json['cdn_thumbnail_url'],
      cdnStoragePath: json['cdn_storage_path'],
      isStreaming: json['is_streaming'],
      isUsed: json['is_used'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      usingCdn: json['using_cdn'],
      localUrl: json['local_url'],
      localOptimizedUrl: json['local_optimized_url'],
      copies: (json['copies'] as List?)?.map((e) {
        return MediaCopy.fromJson(e);
      }).toList(),
    );
  }
}

class MediaCopy {
  String? id;
  String? mediaId;
  String? url;
  String? path;
  String? mediaType;
  int? width;
  int? height;
  String? format;
  String? purpose;
  bool? isOptimized;
  String? cdnUrl;
  String? cdnStoragePath;
  String? createdAt;
  String? updatedAt;

  MediaCopy({
    this.id,
    this.mediaId,
    this.url,
    this.path,
    this.mediaType,
    this.width,
    this.height,
    this.format,
    this.purpose,
    this.isOptimized,
    this.cdnUrl,
    this.cdnStoragePath,
    this.createdAt,
    this.updatedAt,
  });

  factory MediaCopy.fromJson(Map<String, dynamic> json) {
    return MediaCopy(
      id: json['id'],
      mediaId: json['media_id'],
      url: json['url'],
      path: json['path'],
      mediaType: json['media_type'],
      width: json['width'],
      height: json['height'],
      format: json['format'],
      purpose: json['purpose'],
      isOptimized: json['is_optimized'],
      cdnUrl: json['cdn_url'],
      cdnStoragePath: json['cdn_storage_path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
