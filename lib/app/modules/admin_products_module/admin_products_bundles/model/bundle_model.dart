class Bundle {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String productIds;
  final String? bundlePrice;
  final String discountType;
  final String? discountValue;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? thumbnailId;
  final BundleThumbnail? thumbnail;
  final int productCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bundle({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.productIds,
    this.bundlePrice,
    required this.discountType,
    this.discountValue,
    required this.status,
    this.startDate,
    this.endDate,
    this.thumbnailId,
    this.thumbnail,
    required this.productCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      productIds: json['product_ids'] ?? '',
      bundlePrice: json['bundle_price'],
      discountType: json['discount_type'] ?? 'none',
      discountValue: json['discount_value'],
      status: json['status'] ?? 'active',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      thumbnailId: json['thumbnail_id'],
      thumbnail: json['thumbnail'] != null
          ? BundleThumbnail.fromJson(json['thumbnail'])
          : null,
      productCount: json['product_count'] ?? 0,
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  List<String> get productIdsList {
    if (productIds.isEmpty) return [];
    return productIds.split(',').where((id) => id.isNotEmpty).toList();
  }

  String? get thumbnailUrl {
    return thumbnail?.media?.optimizedMediaUrl ?? thumbnail?.media?.url;
  }

  String get discountDisplay {
    if (discountType == 'none' || discountValue == null) return '';
    if (discountType == 'percentage') return '$discountValue% OFF';
    return '\$$discountValue OFF';
  }

  String get bundleUrl {
    return 'https://tjara.com/bundle/$slug';
  }
}

class BundleThumbnail {
  final BundleMedia? media;
  final bool cached;

  BundleThumbnail({this.media, this.cached = false});

  factory BundleThumbnail.fromJson(Map<String, dynamic> json) {
    return BundleThumbnail(
      media:
          json['media'] != null ? BundleMedia.fromJson(json['media']) : null,
      cached: json['cached'] ?? false,
    );
  }
}

class BundleMedia {
  final String id;
  final String? url;
  final String? optimizedMediaUrl;
  final String mediaType;

  BundleMedia({
    required this.id,
    this.url,
    this.optimizedMediaUrl,
    required this.mediaType,
  });

  factory BundleMedia.fromJson(Map<String, dynamic> json) {
    return BundleMedia(
      id: json['id'] ?? '',
      url: json['url'],
      optimizedMediaUrl: json['optimized_media_url'],
      mediaType: json['media_type'] ?? 'image',
    );
  }
}

class BundlesResponse {
  final BundlesPagination bundles;
  final String message;

  BundlesResponse({required this.bundles, required this.message});

  factory BundlesResponse.fromJson(Map<String, dynamic> json) {
    return BundlesResponse(
      bundles: BundlesPagination.fromJson(json['bundles'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class BundlesPagination {
  final int currentPage;
  final List<Bundle> data;
  final int lastPage;
  final int total;

  BundlesPagination({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory BundlesPagination.fromJson(Map<String, dynamic> json) {
    return BundlesPagination(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Bundle.fromJson(item))
              .toList() ??
          [],
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}
