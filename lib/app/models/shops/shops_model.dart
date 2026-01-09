import 'package:tjara/app/models/products/products_model.dart';

class ShopResponse {
  final int currentPage;
  final List<ShopShop> data;
  final int lastPage;
  final String? nextPageUrl;

  ShopResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.nextPageUrl,
  });

  factory ShopResponse.fromJson(Map<String, dynamic> json) {
    return ShopResponse(
      currentPage: json['current_page'],
      data: (json['data'] as List).map((e) => ShopShop.fromJson(e)).toList(),
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
    );
  }
}