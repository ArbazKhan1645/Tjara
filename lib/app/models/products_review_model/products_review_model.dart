// models/product_review_response.dart
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';

class ProductReviewResponse {
  final Reviews reviews;

  ProductReviewResponse({required this.reviews});

  factory ProductReviewResponse.fromJson(Map<String, dynamic> json) {
    return ProductReviewResponse(reviews: Reviews.fromJson(json['reviews']));
  }

  Map<String, dynamic> toJson() {
    return {'reviews': reviews.toJson()};
  }
}

// models/reviews.dart
class Reviews {
  final int currentPage;
  final List<ReviewData> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;

  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  Reviews({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,

    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Reviews.fromJson(Map<String, dynamic> json) {
    return Reviews(
      currentPage: json['current_page'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ReviewData.fromJson(item))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',

      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 15,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((item) => item.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,

      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}

// models/review_data.dart
class ReviewData {
  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String description;
  final String? thumbnailIds;
  final String createdAt;
  final String updatedAt;
  final UserData? user;
  final ProductData? product;

  ReviewData({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.description,
    this.thumbnailIds,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.product,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? '',
      rating: json['rating'] ?? 0,
      description: json['description'] ?? '',
      thumbnailIds: json['thumbnail_ids'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: UserData.fromJson(json['user'] ?? {}),
      product: ProductData.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'rating': rating,
      'description': description,
      'thumbnail_ids': thumbnailIds,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// models/user_data.dart
class UserData {
  final User user;

  UserData({required this.user});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(user: User.fromJson(json['user'] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson()};
  }
}

// models/product_data.dart
class ProductData {
  final ProductDatum product;

  ProductData({required this.product});

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(product: ProductDatum.fromJson(json['product'] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {'product': product.toJson()};
  }
}
