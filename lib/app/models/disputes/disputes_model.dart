import 'package:tjara/app/models/order_model.dart' hide User;
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';

class DisputesResponse {
  DisputesResponse({this.disputes});

  final Disputes? disputes;

  factory DisputesResponse.fromJson(Map<String, dynamic> json) {
    return DisputesResponse(
      disputes:
          json['disputes'] == null
              ? null
              : Disputes.fromJson(json['disputes'] as Map<String, dynamic>),
    );
  }
}

class Disputes {
  Disputes({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  final int? currentPage;
  final List<DisputeData>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  factory Disputes.fromJson(Map<String, dynamic> json) {
    return Disputes(
      currentPage: json['current_page'] as int?,
      data:
          json['data'] == null
              ? null
              : List<DisputeData>.from(
                (json['data'] as List).map(
                  (x) => DisputeData.fromJson(x as Map<String, dynamic>),
                ),
              ),
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int?,
      lastPageUrl: json['last_page_url'] as String?,
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String?,
      perPage: json['per_page'] as int?,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int?,
      total: json['total'] as int?,
    );
  }
}

class DisputeData {
  DisputeData({
    this.id,
    this.orderId,
    this.buyerId,
    this.shopId,
    this.reason,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.buyer,
    this.shop,
    this.order,
  });

  final String? id;
  final String? orderId;
  final String? buyerId;
  final String? shopId;
  final String? reason;
  final String? description;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final Buyer? buyer;
  final Shop? shop;
  final Order? order;

  factory DisputeData.fromJson(Map<String, dynamic> json) {
    return DisputeData(
      id: json['id']?.toString(),
      orderId: json['order_id']?.toString(),
      buyerId: json['buyer_id']?.toString(),
      shopId: json['shop_id']?.toString(),
      reason: json['reason']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      buyer:
          json['buyer'] != null
              ? Buyer.fromJson(json['buyer'] as Map<String, dynamic>)
              : null,
      // shop:
      //     json['shop'] != null
      //         ? Shop.fromJson(json['shop'] as Map<String, dynamic>)
      //         : null,
      order: _parseOrder(json['order']),
    );
  }

  static Order? _parseOrder(dynamic orderData) {
    if (orderData == null) return null;
    if (orderData is! Map) return null;

    final orderMap = orderData as Map<String, dynamic>;
    if (orderMap['order'] == null) return null;
    if (orderMap['order'] is! Map) return null;

    return Order.fromJson(orderMap['order'] as Map<String, dynamic>);
  }
}

class Buyer {
  Buyer({this.user});

  final User? user;

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      user:
          json['user'] == null
              ? null
              : User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class Shop {
  Shop({this.shop, this.message});

  final ShopShop? shop;
  final String? message;

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shop:
          json['shop'] == null
              ? null
              : ShopShop.fromJson(json['shop'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }
}
