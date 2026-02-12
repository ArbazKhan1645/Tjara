class PromotionsResponse {
  final PromotionsPagination promotions;
  final String? shopId;

  PromotionsResponse({
    required this.promotions,
    this.shopId,
  });

  factory PromotionsResponse.fromJson(Map<String, dynamic> json) {
    return PromotionsResponse(
      promotions: PromotionsPagination.fromJson(json['promotions'] ?? {}),
      shopId: json['shop_id'],
    );
  }
}

class PromotionsPagination {
  final int currentPage;
  final List<Promotion> data;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  PromotionsPagination({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory PromotionsPagination.fromJson(Map<String, dynamic> json) {
    return PromotionsPagination(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Promotion.fromJson(e))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List<dynamic>?)
              ?.map((e) => PaginationLink.fromJson(e))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 100,
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}

class Promotion {
  final String id;
  final String? shopId;
  final String name;
  final String? description;
  final String discountType;
  final String? applyTo;
  final String discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCurrentlyActive;
  final int productsCount;
  final PromotionShop? shop;
  final List<PromotionProduct> products;

  Promotion({
    required this.id,
    this.shopId,
    required this.name,
    this.description,
    required this.discountType,
    this.applyTo,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isCurrentlyActive,
    required this.productsCount,
    this.shop,
    required this.products,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? '',
      shopId: json['shop_id'],
      name: json['name'] ?? '',
      description: json['description'],
      discountType: json['discount_type'] ?? 'percentage',
      applyTo: json['apply_to'],
      discountValue: json['discount_value'] ?? '0',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'inactive',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isCurrentlyActive: json['is_currently_active'] ?? false,
      productsCount: json['products_count'] ?? 0,
      shop: json['shop'] != null ? PromotionShop.fromJson(json['shop']) : null,
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => PromotionProduct.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description ?? '',
      'discount_type': discountType,
      'discount_value': discountValue,
      'start_date': _formatDateTime(startDate),
      'end_date': _formatDateTime(endDate),
      'status': status,
    };
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}T${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Promotion copyWith({
    String? id,
    String? shopId,
    String? name,
    String? description,
    String? discountType,
    String? applyTo,
    String? discountValue,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCurrentlyActive,
    int? productsCount,
    PromotionShop? shop,
    List<PromotionProduct>? products,
  }) {
    return Promotion(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      applyTo: applyTo ?? this.applyTo,
      discountValue: discountValue ?? this.discountValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCurrentlyActive: isCurrentlyActive ?? this.isCurrentlyActive,
      productsCount: productsCount ?? this.productsCount,
      shop: shop ?? this.shop,
      products: products ?? this.products,
    );
  }
}

class PromotionShop {
  final String id;
  final String name;

  PromotionShop({
    required this.id,
    required this.name,
  });

  factory PromotionShop.fromJson(Map<String, dynamic> json) {
    return PromotionShop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class PromotionProduct {
  final String id;
  final String name;
  final ProductPivot? pivot;

  PromotionProduct({
    required this.id,
    required this.name,
    this.pivot,
  });

  factory PromotionProduct.fromJson(Map<String, dynamic> json) {
    return PromotionProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      pivot: json['pivot'] != null ? ProductPivot.fromJson(json['pivot']) : null,
    );
  }
}

class ProductPivot {
  final String promotionId;
  final String productId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductPivot({
    required this.promotionId,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductPivot.fromJson(Map<String, dynamic> json) {
    return ProductPivot(
      promotionId: json['promotion_id'] ?? '',
      productId: json['product_id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
