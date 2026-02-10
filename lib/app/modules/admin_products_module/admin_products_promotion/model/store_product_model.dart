class StoreProduct {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? price;

  StoreProduct({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.price,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    String? thumbnailUrl;
    if (json['thumbnail'] != null && json['thumbnail']['media'] != null) {
      thumbnailUrl =
          json['thumbnail']['media']['optimized_media_url']?.toString() ??
              json['thumbnail']['media']['cdn_url']?.toString() ??
              json['thumbnail']['media']['url']?.toString();
    }
    return StoreProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      thumbnailUrl: thumbnailUrl,
      price: json['price']?.toString(),
    );
  }
}
