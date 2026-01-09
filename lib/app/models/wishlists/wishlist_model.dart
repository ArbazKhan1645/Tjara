import 'package:tjara/app/models/products/products_model.dart';

class WishlistResponse {
  List<WishlistItem>? wishlistItems;

  WishlistResponse({this.wishlistItems});

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      wishlistItems: (json['wishlistItems'] as List<dynamic>?)
          ?.map((item) => WishlistItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wishlistItems': wishlistItems?.map((item) => item.toJson()).toList(),
    };
  }
}

class WishlistItem {
  String? id;
  String? userId;
  String? productId;
  String? createdAt;
  String? updatedAt;
  ProductDatum? product;

  WishlistItem({
    this.id,
    this.userId,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      product: json['product'] != null
          ? ProductDatum.fromJson(json['product']['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product': product != null ? {'product': product!.toJson()} : null,
    };
  }
}
