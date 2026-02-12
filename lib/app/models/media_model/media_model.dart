class MediaUniversalModel {
  final String? id;
  final String? url;
  final String? optimizedMediaUrl;
  final String? mediaType;
  final String? cdnUrl;
  final String? optimizedMediaCdnUrl;
  final String? cdnVideoId;
  final String? cdnThumbnailUrl;
  final String? cdnStoragePath;
  final bool? isStreaming;
  final bool? isUsed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? localUrl;

  MediaUniversalModel({
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
  });

  factory MediaUniversalModel.fromJson(Map<String, dynamic> json) {
    
    return MediaUniversalModel(
      id: json['id'] as String?,
      url: json['url'] as String?,
      optimizedMediaUrl: json['optimized_media_url'] as String?,
      mediaType: json['media_type'] as String?,
      cdnUrl: json['cdn_url'] as String?,
      optimizedMediaCdnUrl: json['optimized_media_cdn_url'] as String?,
      cdnVideoId: json['cdn_video_id'] as String?,
      cdnThumbnailUrl: json['cdn_thumbnail_url'] as String?,
      cdnStoragePath: json['cdn_storage_path'] as String?,
      isStreaming: _toBool(json['is_streaming']),
      isUsed: _toBool(json['is_used']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      localUrl: json['local_url'] as String?,
    );
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value == 'true';
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'optimized_media_url': optimizedMediaUrl,
      'media_type': mediaType,
      'cdn_url': cdnUrl,
      'optimized_media_cdn_url': optimizedMediaCdnUrl,
      'cdn_video_id': cdnVideoId,
      'cdn_thumbnail_url': cdnThumbnailUrl,
      'cdn_storage_path': cdnStoragePath,
      'is_streaming': isStreaming,
      'is_used': isUsed,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'local_url': localUrl,
    };
  }
}