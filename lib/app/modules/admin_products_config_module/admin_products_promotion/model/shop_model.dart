class ShopsResponse {
  final ShopsPagination shops;

  ShopsResponse({required this.shops});

  factory ShopsResponse.fromJson(Map<String, dynamic> json) {
    return ShopsResponse(
      shops: ShopsPagination.fromJson(json['shops'] ?? {}),
    );
  }
}

class ShopsPagination {
  final int currentPage;
  final List<Shop> data;
  final int lastPage;
  final int total;

  ShopsPagination({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory ShopsPagination.fromJson(Map<String, dynamic> json) {
    return ShopsPagination(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Shop.fromJson(e))
              .toList() ??
          [],
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

class Shop {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String? logo;
  final String? status;

  Shop({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.logo,
    this.status,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      logo: json['logo'],
      status: json['status'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
