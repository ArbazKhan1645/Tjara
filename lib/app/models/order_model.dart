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
  });

  factory Order.fromJson(Map<String, dynamic> json) {
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
    return Shop(id: json['id']?.toString(), name: json['name']?.toString());
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
    if (json['shop'] == null) {
      return DatumShop(message: json['message']?.toString());
    } else {
      return DatumShop(shop: Shop.fromJson(json['shop']));
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
