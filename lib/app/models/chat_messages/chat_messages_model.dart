// Helper function to safely parse integers
// ignore_for_file: unused_element, avoid_print

import 'package:tjara/app/models/products/products_model.dart';

int? parseIntSafely(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

// Helper function to safely parse doubles
double? parseDoubleSafely(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

// Helper function to safely parse strings
String? parseStringSafely(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

// Helper function to check if value is valid Map
bool isValidMap(dynamic value) {
  return value != null && value is Map<String, dynamic> && value.isNotEmpty;
}

class ProductChats {
  int? currentPage;
  List<ChatData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  ProductChats({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory ProductChats.fromJson(Map<String, dynamic> json) {
    return ProductChats(
      currentPage: parseIntSafely(json['current_page']),
      data:
          json['data'] != null && json['data'] is List
              ? (json['data'] as List)
                  .map((e) => ChatData.fromJson(e ?? {}))
                  .toList()
              : [],
      firstPageUrl: parseStringSafely(json['first_page_url']),
      from: parseIntSafely(json['from']),
      lastPage: parseIntSafely(json['last_page']),
      lastPageUrl: parseStringSafely(json['last_page_url']),
      links:
          json['links'] != null && json['links'] is List
              ? (json['links'] as List)
                  .map((e) => Link.fromJson(e ?? {}))
                  .toList()
              : [],
      nextPageUrl: parseStringSafely(json['next_page_url']),
      path: parseStringSafely(json['path']),
      perPage: parseIntSafely(json['per_page']),
      prevPageUrl: parseStringSafely(json['prev_page_url']),
      to: parseIntSafely(json['to']),
      total: parseIntSafely(json['total']),
    );
  }
}

class ChatData {
  String? id;
  String? productId;
  String? userId;
  String? createdAt;
  String? updatedAt;
  User? user;
  ProductDatum? product;
  String? lastMessage;

  ChatData({
    this.id,
    this.productId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.product,
    this.lastMessage,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    try {
      return ChatData(
        id: parseStringSafely(json['id']),
        productId: parseStringSafely(json['product_id']),
        userId: parseStringSafely(json['user_id']),
        createdAt: parseStringSafely(json['created_at']),
        updatedAt: parseStringSafely(json['updated_at']),
        user: _parseUser(json['user']),
        // product: _parseProduct(json['product']),
        lastMessage: parseStringSafely(json['last_message']),
      );
    } catch (e) {
      print('Error parsing ChatData: $e');
      rethrow;
    }
  }

  static User? _parseUser(dynamic userJson) {
    if (!isValidMap(userJson)) return null;

    try {
      final userMap = userJson as Map<String, dynamic>;
      // Check if nested user exists
      if (isValidMap(userMap['user'])) {
        return User.fromJson(userMap['user']);
      }
      return User.fromJson(userMap);
    } catch (e) {
      print('Error parsing user: $e');
      return null;
    }
  }

  static ProductDatum? _parseProduct(dynamic productJson) {
    if (!isValidMap(productJson)) return null;

    try {
      final productMap = productJson as Map<String, dynamic>;

      // Check if nested product exists
      if (isValidMap(productMap['product'])) {
        return ProductDatum.fromJson(productMap['product']);
      }
      return ProductDatum.fromJson(productMap);
    } catch (e) {
      print('Error parsing product: $e');
      return null;
    }
  }
}

class User {
  String? id;
  String? prevId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? thumbnailId;
  String? authToken;
  String? phoneVerificationCode;
  String? emailVerifiedAt;
  String? role;
  String? status;
  String? createdAt;
  String? updatedAt;
  Thumbnail? thumbnail;
  Shop? shop;
  Map<String, dynamic>? meta;
  Address? address;

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
    try {
      return User(
        id: parseStringSafely(json['id']),
        prevId: parseStringSafely(json['prev_id']),
        firstName: parseStringSafely(json['first_name']),
        lastName: parseStringSafely(json['last_name']),
        email: parseStringSafely(json['email']),
        phone: parseStringSafely(json['phone']),
        thumbnailId: parseStringSafely(json['thumbnail_id']),
        authToken: parseStringSafely(json['authToken']),
        phoneVerificationCode: parseStringSafely(
          json['phone_verification_code'],
        ),
        emailVerifiedAt: parseStringSafely(json['email_verified_at']),
        role: parseStringSafely(json['role']),
        status: parseStringSafely(json['status']),
        createdAt: parseStringSafely(json['created_at']),
        updatedAt: parseStringSafely(json['updated_at']),
        thumbnail: _parseThumbnail(json['thumbnail']),
        shop: _parseShop(json['shop']),
        meta:
            isValidMap(json['meta'])
                ? Map<String, dynamic>.from(json['meta'])
                : null,
        address: _parseAddress(json['address']),
      );
    } catch (e) {
      print('Error parsing User: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static Thumbnail? _parseThumbnail(dynamic thumbnailJson) {
    if (!isValidMap(thumbnailJson)) return null;
    try {
      return Thumbnail.fromJson(thumbnailJson as Map<String, dynamic>);
    } catch (e) {
      print('Error parsing thumbnail: $e');
      return null;
    }
  }

  static Shop? _parseShop(dynamic shopJson) {
    if (!isValidMap(shopJson)) return null;

    try {
      final shopMap = shopJson as Map<String, dynamic>;
      if (isValidMap(shopMap['shop'])) {
        return Shop.fromJson(shopMap['shop']);
      }
      return Shop.fromJson(shopMap);
    } catch (e) {
      print('Error parsing shop: $e');
      return null;
    }
  }

  static Address? _parseAddress(dynamic addressJson) {
    // Check for null or empty string
    if (addressJson == null || addressJson == "") return null;
    if (!isValidMap(addressJson)) return null;

    try {
      final addressMap = addressJson as Map<String, dynamic>;
      if (isValidMap(addressMap['address'])) {
        return Address.fromJson(addressMap['address']);
      }
      return Address.fromJson(addressMap);
    } catch (e) {
      print('Error parsing address: $e');
      return null;
    }
  }
}

class Thumbnail {
  String? message;

  Thumbnail({this.message});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(message: parseStringSafely(json['message']));
  }
}

class Shop {
  String? message;

  Shop({this.message});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(message: parseStringSafely(json['message']));
  }
}

class Address {
  String? id;
  String? userId;
  String? streetAddress;
  String? postalCode;
  String? cityId;
  String? stateId;
  String? countryId;
  String? createdAt;
  String? updatedAt;
  String? country;
  String? state;
  String? city;

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
      id: parseStringSafely(json['id']),
      userId: parseStringSafely(json['user_id']),
      streetAddress: parseStringSafely(json['street_address']),
      postalCode: parseStringSafely(json['postal_code']),
      cityId: parseStringSafely(json['city_id']),
      stateId: parseStringSafely(json['state_id']),
      countryId: parseStringSafely(json['country_id']),
      createdAt: parseStringSafely(json['created_at']),
      updatedAt: parseStringSafely(json['updated_at']),
      country: parseStringSafely(json['country']),
      state: parseStringSafely(json['state']),
      city: parseStringSafely(json['city']),
    );
  }
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({this.url, this.label, this.active});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: parseStringSafely(json['url']),
      label: parseStringSafely(json['label']),
      active: json['active'] as bool?,
    );
  }
}
