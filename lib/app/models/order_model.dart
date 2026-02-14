class Order {
  final String? id;
  final String? buyerId;
  final String? shopId;
  final double? orderTotal;
  final double? adminCommissionTotal;
  String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Buyer? buyer;
  final DatumShop? shop;
  final Transaction? transaction;
  final Map<String, dynamic>? meta;
  final List<OrderItemData>? orderItems;
  final Map<String, dynamic>? shippingBreakdown;
  final Map<String, dynamic>? customBuyerDetails;
  final Map<String, dynamic>? customAddressDetails;
  final List<dynamic>? simultaneousOrders;
  final BatchInfo? batchInfo;

  Order({
    this.id,
    this.buyerId,
    this.shopId,
    this.orderTotal,
    this.adminCommissionTotal,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.buyer,
    this.shop,
    this.transaction,
    this.meta,
    this.orderItems,
    this.shippingBreakdown,
    this.customBuyerDetails,
    this.customAddressDetails,
    this.simultaneousOrders,
    this.batchInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse embedded order items from 'items' or 'order_items'
    List<OrderItemData>? parsedItems;
    if (json['items'] != null && json['items'] is Map<String, dynamic>) {
      final itemsData = json['items'];
      if (itemsData['orderItems'] != null && itemsData['orderItems'] is List) {
        parsedItems =
            (itemsData['orderItems'] as List)
                .map(
                  (item) => OrderItemData.fromJson(
                    item is Map<String, dynamic>
                        ? item
                        : <String, dynamic>{},
                  ),
                )
                .toList();
      }
    } else if (json['order_items'] != null && json['order_items'] is List) {
      parsedItems =
          (json['order_items'] as List)
              .map(
                (item) => OrderItemData.fromJson(
                  item is Map<String, dynamic>
                      ? item
                      : <String, dynamic>{},
                ),
              )
              .toList();
    }

    return Order(
      id: json['id']?.toString(),
      buyerId: json['buyer_id']?.toString(),
      shopId: json['shop_id']?.toString(),
      orderTotal: json['order_total']?.toDouble(),
      adminCommissionTotal: json['admin_commission_total']?.toDouble(),
      status: json['status']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      buyer: json['buyer'] != null ? Buyer.fromJson(json['buyer']) : null,
      shop: json['shop'] != null ? DatumShop.fromJson(json['shop']) : null,
      transaction:
          json['transaction'] != null
              ? Transaction.fromJson(json['transaction'])
              : null,
      meta:
          json['meta'] is List<dynamic>
              ? null
              : json['meta'] != null
              ? Map<String, dynamic>.from(json['meta'])
              : null,
      orderItems: parsedItems,
      shippingBreakdown:
          json['shipping_breakdown'] != null &&
                  json['shipping_breakdown'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(json['shipping_breakdown'])
              : null,
      customBuyerDetails:
          json['custom_buyer_details'] != null &&
                  json['custom_buyer_details'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(json['custom_buyer_details'])
              : null,
      customAddressDetails:
          json['custom_address_details'] != null &&
                  json['custom_address_details'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(json['custom_address_details'])
              : null,
      simultaneousOrders:
          json['simultaneous_orders'] != null &&
                  json['simultaneous_orders'] is List
              ? json['simultaneous_orders'] as List<dynamic>
              : null,
      batchInfo: BatchInfo.fromOrderData(
        batchInfoJson: json['batch_info'],
        meta:
            json['meta'] is Map<String, dynamic>
                ? json['meta'] as Map<String, dynamic>
                : null,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'shop_id': shopId,
      'order_total': orderTotal,
      'admin_commission_total': adminCommissionTotal,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'buyer': buyer?.toJson(),
      'shop': shop?.toJson(),
      'transaction': transaction?.toJson(),
      'meta': meta,
      'order_items': orderItems?.map((e) => e.toJson()).toList(),
      'shipping_breakdown': shippingBreakdown,
      'custom_buyer_details': customBuyerDetails,
      'custom_address_details': customAddressDetails,
      'simultaneous_orders': simultaneousOrders,
      'batch_info': batchInfo?.toJson(),
    };
  }
}

class OrderItemData {
  final String? id;
  final String? orderId;
  final String? productId;
  final int? quantity;
  final double? price;
  final OrderProductData? product;
  final String? imageUrl;
  final List<dynamic>? reviews;

  OrderItemData({
    this.id,
    this.orderId,
    this.productId,
    this.quantity,
    this.price,
    this.product,
    this.imageUrl,
    this.reviews,
  });

  factory OrderItemData.fromJson(Map<String, dynamic> json) {
    return OrderItemData(
      id: json['id']?.toString(),
      orderId: json['order_id']?.toString(),
      productId: json['product_id']?.toString(),
      quantity:
          json['quantity'] is int
              ? json['quantity']
              : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      price:
          json['price'] is num
              ? json['price'].toDouble()
              : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      product:
          json['product'] != null && json['product'] is Map<String, dynamic>
              ? OrderProductData.fromJson(json['product'])
              : null,
      imageUrl:
          json['thumbnail']?['media']?['optimized_media_url']?.toString() ??
          json['thumbnail']?['media']?['url']?.toString(),
      reviews:
          json['reviews'] != null && json['reviews'] is List
              ? json['reviews'] as List<dynamic>
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'product': product?.toJson(),
      'reviews': reviews,
    };
  }
}

class OrderProductData {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final String? status;
  final String? slug;

  OrderProductData({
    this.id,
    this.name,
    this.description,
    this.price,
    this.status,
    this.slug,
  });

  factory OrderProductData.fromJson(Map<String, dynamic> json) {
    return OrderProductData(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Unknown Product',
      description: json['description']?.toString(),
      price:
          json['price'] is num
              ? json['price'].toDouble()
              : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString(),
      slug: json['slug']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'status': status,
      'slug': slug,
    };
  }
}

class BatchInfo {
  final String? sessionId;
  final int? totalOrders;
  final int? orderPosition;
  final List<Map<String, dynamic>>? orders;

  BatchInfo({
    this.sessionId,
    this.totalOrders,
    this.orderPosition,
    this.orders,
  });

  /// Build BatchInfo from batch_info API field (primary) or meta (fallback).
  /// batch_info structure: { batch_session_id, total_orders_in_batch,
  /// order_position_in_batch, simultaneous_orders: [...] }
  /// simultaneous_orders are stored as raw maps (not parsed into Order).
  static BatchInfo? fromOrderData({
    dynamic batchInfoJson,
    Map<String, dynamic>? meta,
  }) {
    // Primary: read from batchInfoJson map
    if (batchInfoJson != null && batchInfoJson is Map<String, dynamic>) {
      final map = batchInfoJson;
      final sessionId = map['batch_session_id']?.toString();
      final totalOrders =
          int.tryParse(map['total_orders_in_batch']?.toString() ?? '');
      final orderPosition =
          int.tryParse(map['order_position_in_batch']?.toString() ?? '');

      // Store simultaneous_orders as raw maps
      List<Map<String, dynamic>>? rawOrders;
      if (map['simultaneous_orders'] != null &&
          map['simultaneous_orders'] is List) {
        rawOrders =
            (map['simultaneous_orders'] as List)
                .whereType<Map<String, dynamic>>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
      }

      if ((sessionId == null || sessionId.isEmpty || sessionId == 'null') &&
          (rawOrders == null || rawOrders.isEmpty)) {
        return null;
      }

      return BatchInfo(
        sessionId: sessionId,
        totalOrders: totalOrders,
        orderPosition: orderPosition,
        orders: rawOrders,
      );
    }

    // Fallback: read from meta
    final sessionId = meta?['batch_session_id']?.toString();
    if (sessionId == null || sessionId.isEmpty || sessionId == 'null') {
      return null;
    }

    return BatchInfo(
      sessionId: sessionId,
      totalOrders:
          int.tryParse(meta?['total_orders_in_batch']?.toString() ?? ''),
      orderPosition:
          int.tryParse(meta?['order_position_in_batch']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batch_session_id': sessionId,
      'total_orders_in_batch': totalOrders,
      'order_position_in_batch': orderPosition,
      'simultaneous_orders': orders,
    };
  }
}

class Buyer {
  final User? user;

  Buyer({this.user});

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user?.toJson()};
  }
}

class User {
  final String? id;
  final dynamic prevId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? thumbnailId;
  final String? authToken;
  final String? phoneVerificationCode;
  final DateTime? emailVerifiedAt;
  final String? role;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Thumbnail? thumbnail;
  final DatumShop? shop;
  final Map<String, dynamic>? meta;
  final Address? address;

  User({
    this.id,
    this.prevId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.thumbnailId,
    this.authToken,
    this.phoneVerificationCode,
    this.emailVerifiedAt,
    this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.shop,
    this.meta,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      prevId: json['prev_id'],
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      thumbnailId: json['thumbnail_id']?.toString(),
      authToken: json['authToken']?.toString(),
      phoneVerificationCode: json['phone_verification_code']?.toString(),
      emailVerifiedAt:
          json['email_verified_at'] != null
              ? DateTime.tryParse(json['email_verified_at'].toString())
              : null,
      role: json['role']?.toString(),
      status: json['status']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      thumbnail:
          json['thumbnail'] != null && json['thumbnail'] is Map<String, dynamic>
              ? (json['thumbnail']['media'] != null ||
                      json['thumbnail']['message'] == null)
                  ? Thumbnail.fromJson(json['thumbnail'])
                  : null
              : null,
      shop:
          json['shop'] != null && json['shop'] is Map<String, dynamic>
              ? DatumShop.fromJson(json['shop'])
              : null,
      meta:
          json['meta'] != null ? Map<String, dynamic>.from(json['meta']) : null,
      address: _parseAddress(json['address']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prev_id': prevId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'thumbnail_id': thumbnailId,
      'authToken': authToken,
      'phone_verification_code': phoneVerificationCode,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'role': role,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'thumbnail': thumbnail?.toJson(),
      'shop': shop?.toJson(),
      'meta': meta,
      'address': address?.toJson(),
    };
  }

  static Address? _parseAddress(dynamic addressData) {
    if (addressData == null) return null;

    if (addressData is String && addressData.isEmpty) return null;

    if (addressData is Map<String, dynamic>) {
      if (addressData.containsKey('address') &&
          addressData['address'] is Map<String, dynamic>) {
        return Address.fromJson(addressData['address']);
      } else if (addressData.containsKey('id') ||
          addressData.containsKey('street_address')) {
        return Address.fromJson(addressData);
      }
    }

    return null;
  }
}

class Thumbnail {
  final String? message;
  final Media? media;

  Thumbnail({this.message, this.media});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      message: json['message']?.toString(),
      media:
          json['media'] != null && json['media'] is Map<String, dynamic>
              ? Media.fromJson(json['media'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'media': media?.toJson()};
  }
}

class Media {
  final String? id;
  final String? url;
  final String? optimizedMediaUrl;
  final String? mediaType;
  final bool? isUsed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Media({
    this.id,
    this.url,
    this.optimizedMediaUrl,
    this.mediaType,
    this.isUsed,
    this.createdAt,
    this.updatedAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id']?.toString(),
      url: json['url']?.toString(),
      optimizedMediaUrl: json['optimized_media_url']?.toString(),
      mediaType: json['media_type']?.toString(),
      isUsed: json['is_used'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'optimized_media_url': optimizedMediaUrl,
      'media_type': mediaType,
      'is_used': isUsed,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Shop {
  final String? id;
  final dynamic prevId;
  final String? userId;
  final String? membershipId;
  final DateTime? membershipStartDate;
  final DateTime? membershipEndDate;
  final String? slug;
  final String? name;
  final String? thumbnailId;
  final String? bannerImageId;
  final String? stripeAccountId;
  final double? balance;
  final String? description;
  final dynamic isVerified;
  final dynamic isFeatured;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Thumbnail? banner;
  final Thumbnail? thumbnail;
  final MembershipPlan? membership;
  final Map<String, dynamic>? meta;

  Shop({
    this.id,
    this.prevId,
    this.userId,
    this.membershipId,
    this.membershipStartDate,
    this.membershipEndDate,
    this.slug,
    this.name,
    this.thumbnailId,
    this.bannerImageId,
    this.stripeAccountId,
    this.balance,
    this.description,
    this.isVerified,
    this.isFeatured,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.banner,
    this.thumbnail,
    this.membership,
    this.meta,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id']?.toString(),
      prevId: json['prev_id'],
      userId: json['user_id']?.toString(),
      membershipId: json['membership_id']?.toString(),
      membershipStartDate:
          json['membership_start_date'] != null
              ? DateTime.tryParse(json['membership_start_date'].toString())
              : null,
      membershipEndDate:
          json['membership_end_date'] != null
              ? DateTime.tryParse(json['membership_end_date'].toString())
              : null,
      slug: json['slug']?.toString(),
      name: json['name']?.toString(),
      thumbnailId: json['thumbnail_id']?.toString(),
      bannerImageId: json['banner_image_id']?.toString(),
      stripeAccountId: json['stripe_account_id']?.toString(),
      balance: json['balance'] != null ? double.tryParse(json['balance'].toString()) : null,
      description: json['description']?.toString(),
      isVerified: json['is_verified'],
      isFeatured: json['is_featured'],
      status: json['status']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      banner:
          json['banner'] != null && json['banner'] is Map<String, dynamic>
              ? Thumbnail.fromJson(json['banner'])
              : null,
      thumbnail:
          json['thumbnail'] != null && json['thumbnail'] is Map<String, dynamic>
              ? Thumbnail.fromJson(json['thumbnail'])
              : null,
      membership:
          json['membership'] != null && json['membership'] is Map<String, dynamic>
              ? MembershipPlan.fromJson(json['membership'])
              : null,
      meta:
          json['meta'] != null && json['meta'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(json['meta'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prev_id': prevId,
      'user_id': userId,
      'membership_id': membershipId,
      'membership_start_date': membershipStartDate?.toIso8601String(),
      'membership_end_date': membershipEndDate?.toIso8601String(),
      'slug': slug,
      'name': name,
      'thumbnail_id': thumbnailId,
      'banner_image_id': bannerImageId,
      'stripe_account_id': stripeAccountId,
      'balance': balance,
      'description': description,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'banner': banner?.toJson(),
      'thumbnail': thumbnail?.toJson(),
      'membership': membership?.toJson(),
      'meta': meta,
    };
  }
}

class DatumShop {
  final String? message;
  final Shop? shop;

  DatumShop({this.message, this.shop});

  factory DatumShop.fromJson(Map<String, dynamic> json) {
    if (json['shop'] != null && json['shop'] is Map<String, dynamic>) {
      return DatumShop(shop: Shop.fromJson(json['shop']));
    } else if (json['name'] != null) {
      // Flat shop structure (e.g. from batch orders): {"id": "...", "name": "..."}
      return DatumShop(shop: Shop.fromJson(json));
    } else {
      return DatumShop(message: json['message']?.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'shop': shop?.toJson()};
  }
}

class MembershipPlan {
  final String? id;
  final String? slug;
  final String? userType;
  final String? name;
  final double? price;
  final String? description;
  final String? duration;
  final String? parentId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Thumbnail? thumbnail;
  final Map<String, dynamic>? features;

  MembershipPlan({
    this.id,
    this.slug,
    this.userType,
    this.name,
    this.price,
    this.description,
    this.duration,
    this.parentId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.features,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id']?.toString(),
      slug: json['slug']?.toString(),
      userType: json['user_type']?.toString(),
      name: json['name']?.toString(),
      price: json['price']?.toDouble(),
      description: json['description']?.toString(),
      duration: json['duration']?.toString(),
      parentId: json['parent_id']?.toString(),
      status: json['status']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      thumbnail:
          json['thumbnail'] != null && json['thumbnail'] is Map<String, dynamic>
              ? (json['thumbnail']['message'] == null ||
                      json['thumbnail']['media'] != null)
                  ? Thumbnail.fromJson(json['thumbnail'])
                  : null
              : null,
      features:
          json['features'] != null
              ? Map<String, dynamic>.from(json['features'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'user_type': userType,
      'name': name,
      'price': price,
      'description': description,
      'duration': duration,
      'parent_id': parentId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'thumbnail': thumbnail?.toJson(),
      'features': features,
    };
  }
}

class Transaction {
  final String? id;
  final String? userId;
  final String? orderId;
  final String? paymentIntentId;
  final String? paymentMethod;
  final String? paymentFor;
  final double? amount;
  final String? paymentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    this.id,
    this.userId,
    this.orderId,
    this.paymentIntentId,
    this.paymentMethod,
    this.paymentFor,
    this.amount,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      orderId: json['order_id']?.toString(),
      paymentIntentId: json['payment_intent_id']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentFor: json['payment_for']?.toString(),
      amount: json['amount']?.toDouble(),
      paymentStatus: json['payment_status']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'payment_intent_id': paymentIntentId,
      'payment_method': paymentMethod,
      'payment_for': paymentFor,
      'amount': amount,
      'payment_status': paymentStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Address {
  final String? id;
  final String? userId;
  final String? streetAddress;
  final String? postalCode;
  final String? cityId;
  final String? stateId;
  final String? countryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? country;
  final String? state;
  final String? city;

  Address({
    this.id,
    this.userId,
    this.streetAddress,
    this.postalCode,
    this.cityId,
    this.stateId,
    this.countryId,
    this.createdAt,
    this.updatedAt,
    this.country,
    this.state,
    this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      streetAddress: json['street_address']?.toString(),
      postalCode: json['postal_code']?.toString(),
      cityId: json['city_id']?.toString(),
      stateId: json['state_id']?.toString(),
      countryId: json['country_id']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'street_address': streetAddress,
      'postal_code': postalCode,
      'city_id': cityId,
      'state_id': stateId,
      'country_id': countryId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'country': country,
      'state': state,
      'city': city,
    };
  }
}
