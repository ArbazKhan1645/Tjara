import 'dart:convert';

import 'package:logger/logger.dart';

// Main response wrapper
class ApiResponse {
  final UserListResponse users;

  ApiResponse({required this.users});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(users: UserListResponse.fromJson(json['users']));
  }

  ApiResponse copyWith({UserListResponse? users}) {
    return ApiResponse(users: users ?? this.users);
  }
}

class UserListResponse {
  final int currentPage;
  final List<User> data;
  final int lastPage;
  final String? nextPageUrl;
  final int total;
  final String? firstPageUrl;
  final int? from;
  final String? lastPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;

  UserListResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.nextPageUrl,
    required this.total,
    this.firstPageUrl,
    this.from,
    this.lastPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      currentPage: json['current_page'],
      data: (json['data'] as List).map((e) => User.fromJson(e)).toList(),
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
      total: json['total'],
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPageUrl: json['last_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
    );
  }

  UserListResponse copyWith({
    int? currentPage,
    List<User>? data,
    int? lastPage,
    String? nextPageUrl,
    int? total,
    String? firstPageUrl,
    int? from,
    String? lastPageUrl,
    String? path,
    int? perPage,
    String? prevPageUrl,
    int? to,
  }) {
    return UserListResponse(
      currentPage: currentPage ?? this.currentPage,
      data: data ?? this.data,
      lastPage: lastPage ?? this.lastPage,
      nextPageUrl: nextPageUrl ?? this.nextPageUrl,
      total: total ?? this.total,
      firstPageUrl: firstPageUrl ?? this.firstPageUrl,
      from: from ?? this.from,
      lastPageUrl: lastPageUrl ?? this.lastPageUrl,
      path: path ?? this.path,
      perPage: perPage ?? this.perPage,
      prevPageUrl: prevPageUrl ?? this.prevPageUrl,
      to: to ?? this.to,
    );
  }
}

class LoginResponse {
  final String? message;
  final String? token;
  final String? role;
  final User? user;

  LoginResponse({this.message, this.token, this.role, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      token: json['token'],
      role: json['role'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'role': role,
      'user': user?.toJson(),
    };
  }

  LoginResponse copyWith({
    String? message,
    String? token,
    String? role,
    User? user,
  }) {
    return LoginResponse(
      message: message ?? this.message,
      token: token ?? this.token,
      role: role ?? this.role,
      user: user ?? this.user,
    );
  }
}

class User {
  final String? id;
  final String? prevId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? thumbnailId;
  final String? authToken;
  final String? phoneVerificationCode; // Changed to String
  final String? emailVerifiedAt;
  final String? role;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final Thumbnail? thumbnail;
  final Meta? meta;
  final Address? address;
  final Shop? shop; // Added shop field

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
    this.meta,
    this.address,
    this.shop,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      prevId: json['prev_id']?.toString(),
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      thumbnailId: json['thumbnail_id']?.toString(),
      authToken: json['authToken'],
      phoneVerificationCode:
          json['phone_verification_code']?.toString(), // Convert to string
      emailVerifiedAt: json['email_verified_at'],
      role: json['role'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      thumbnail:
          json['thumbnail'] != null
              ? Thumbnail.fromJson(json['thumbnail'])
              : null,
      meta:
          json['meta'] != null
              ? json['meta'] is List
                  ? null
                  : Meta.fromJson(json['meta'])
              : null,
      address:
          json['address'] is Map<String, dynamic>
              ? (json['address']['address'] is Map<String, dynamic>
                  ? Address.fromJson(json['address']['address'])
                  : Address.fromJson(json['address']))
              : null,
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
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
      'email_verified_at': emailVerifiedAt,
      'role': role,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'thumbnail': thumbnail?.toJson(),
      'meta': meta?.toJson(),
      'address': address?.toJson(),
      'shop': shop?.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? prevId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? thumbnailId,
    String? authToken,
    String? phoneVerificationCode,
    String? emailVerifiedAt,
    String? role,
    String? status,
    String? createdAt,
    String? updatedAt,
    Thumbnail? thumbnail,
    Meta? meta,
    Address? address,
    Shop? shop,
  }) {
    return User(
      id: id ?? this.id,
      prevId: prevId ?? this.prevId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      authToken: authToken ?? this.authToken,
      phoneVerificationCode:
          phoneVerificationCode ?? this.phoneVerificationCode,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnail: thumbnail ?? this.thumbnail,
      meta: meta ?? this.meta,
      address: address ?? this.address,
      shop: shop ?? this.shop,
    );
  }
}

class Thumbnail {
  final String? message;

  Thumbnail({this.message});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(message: json['message']);
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  Thumbnail copyWith({String? message}) {
    return Thumbnail(message: message ?? this.message);
  }
}

class Meta {
  final String? dashboardView;
  final String? userId; // Changed to String to handle both int and string
  final String? role;
  final String? registrationStatus; // Added missing field
  final String? acquisitionSource; // Added missing field
  final String? acquisitionMedium; // Added missing field
  final String? firstOrderDiscount; // Added missing field

  Meta({
    this.dashboardView,
    this.userId,
    this.role,
    this.registrationStatus,
    this.acquisitionSource,
    this.acquisitionMedium,
    this.firstOrderDiscount,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      dashboardView: json['dashboard-view'],
      userId: json['user_id']?.toString(), // Convert to string
      role: json['role'],
      registrationStatus: json['registration_status'],
      acquisitionSource: json['acquisition_source'],
      acquisitionMedium: json['acquisition_medium'],
      firstOrderDiscount: json['first_order_discount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboard-view': dashboardView,
      'user_id': userId,
      'role': role,
      'registration_status': registrationStatus,
      'acquisition_source': acquisitionSource,
      'acquisition_medium': acquisitionMedium,
      'first_order_discount': firstOrderDiscount,
    };
  }

  Meta copyWith({
    String? dashboardView,
    String? userId,
    String? role,
    String? registrationStatus,
    String? acquisitionSource,
    String? acquisitionMedium,
    String? firstOrderDiscount,
  }) {
    return Meta(
      dashboardView: dashboardView ?? this.dashboardView,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      acquisitionSource: acquisitionSource ?? this.acquisitionSource,
      acquisitionMedium: acquisitionMedium ?? this.acquisitionMedium,
      firstOrderDiscount: firstOrderDiscount ?? this.firstOrderDiscount,
    );
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
  final String? createdAt;
  final String? updatedAt;
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
      streetAddress: json['street_address'],
      postalCode: json['postal_code'],
      cityId: json['city_id']?.toString(),
      stateId: json['state_id']?.toString(),
      countryId: json['country_id']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
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
      'created_at': createdAt,
      'updated_at': updatedAt,
      'country': country,
      'state': state,
      'city': city,
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? streetAddress,
    String? postalCode,
    String? cityId,
    String? stateId,
    String? countryId,
    String? createdAt,
    String? updatedAt,
    String? country,
    String? state,
    String? city,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      streetAddress: streetAddress ?? this.streetAddress,
      postalCode: postalCode ?? this.postalCode,
      cityId: cityId ?? this.cityId,
      stateId: stateId ?? this.stateId,
      countryId: countryId ?? this.countryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
    );
  }
}

// New Shop model
class Shop {
  final ShopDetails? shop;

  Shop({this.shop});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shop: json['shop'] != null ? ShopDetails.fromJson(json['shop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'shop': shop?.toJson()};
  }

  Shop copyWith({ShopDetails? shop}) {
    return Shop(shop: shop ?? this.shop);
  }
}

class ShopDetails {
  final String? id;
  final String? prevId;
  final String? userId;
  final String? membershipId;
  final String? membershipStartDate;
  final String? membershipEndDate;
  final String? slug;
  final String? name;
  final String? thumbnailId;
  final String? bannerImageId;
  final String? stripeAccountId;
  final int? balance;
  final String? description;
  final int? isVerified;
  final int? isFeatured;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final Thumbnail? banner;
  final Thumbnail? thumbnail;
  final Membership? membership;
  final ShopMeta? meta;

  ShopDetails({
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

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    return ShopDetails(
      id: json['id']?.toString(),
      prevId: json['prev_id']?.toString(),
      userId: json['user_id']?.toString(),
      membershipId: json['membership_id']?.toString(),
      membershipStartDate: json['membership_start_date'],
      membershipEndDate: json['membership_end_date'],
      slug: json['slug'],
      name: json['name'],
      thumbnailId: json['thumbnail_id']?.toString(),
      bannerImageId: json['banner_image_id']?.toString(),
      stripeAccountId: json['stripe_account_id'],
      balance: json['balance'],
      description: json['description'],
      isVerified: json['is_verified'],
      isFeatured: json['is_featured'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      banner:
          json['banner'] != null ? Thumbnail.fromJson(json['banner']) : null,
      thumbnail:
          json['thumbnail'] != null
              ? Thumbnail.fromJson(json['thumbnail'])
              : null,
      membership:
          json['membership'] != null
              ? Membership.fromJson(json['membership'])
              : null,
      meta:
          json['meta'] != null
              ? json['meta'] is List
                  ? null
                  : ShopMeta.fromJson(json['meta'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prev_id': prevId,
      'user_id': userId,
      'membership_id': membershipId,
      'membership_start_date': membershipStartDate,
      'membership_end_date': membershipEndDate,
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
      'created_at': createdAt,
      'updated_at': updatedAt,
      'banner': banner?.toJson(),
      'thumbnail': thumbnail?.toJson(),
      'membership': membership?.toJson(),
      'meta': meta?.toJson(),
    };
  }

  ShopDetails copyWith({
    String? id,
    String? prevId,
    String? userId,
    String? membershipId,
    String? membershipStartDate,
    String? membershipEndDate,
    String? slug,
    String? name,
    String? thumbnailId,
    String? bannerImageId,
    String? stripeAccountId,
    int? balance,
    String? description,
    int? isVerified,
    int? isFeatured,
    String? status,
    String? createdAt,
    String? updatedAt,
    Thumbnail? banner,
    Thumbnail? thumbnail,
    Membership? membership,
    ShopMeta? meta,
  }) {
    return ShopDetails(
      id: id ?? this.id,
      prevId: prevId ?? this.prevId,
      userId: userId ?? this.userId,
      membershipId: membershipId ?? this.membershipId,
      membershipStartDate: membershipStartDate ?? this.membershipStartDate,
      membershipEndDate: membershipEndDate ?? this.membershipEndDate,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      thumbnailId: thumbnailId ?? this.thumbnailId,
      bannerImageId: bannerImageId ?? this.bannerImageId,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      banner: banner ?? this.banner,
      thumbnail: thumbnail ?? this.thumbnail,
      membership: membership ?? this.membership,
      meta: meta ?? this.meta,
    );
  }
}

class Membership {
  final String? message;

  Membership({this.message});

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(message: json['message']);
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  Membership copyWith({String? message}) {
    return Membership(message: message ?? this.message);
  }
}

class ShopMeta {
  final String? phone;

  ShopMeta({this.phone});

  factory ShopMeta.fromJson(Map<String, dynamic> json) {
    return ShopMeta(phone: json['phone']);
  }

  Map<String, dynamic> toJson() {
    return {'phone': phone};
  }

  ShopMeta copyWith({String? phone}) {
    return ShopMeta(phone: phone ?? this.phone);
  }
}

// Updated parsing functions
ApiResponse parseUserListResponse(String jsonString) {
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  final log = Logger();
  log.d(jsonData);
  return ApiResponse.fromJson(jsonData);
}

LoginResponse parseLoginResponse(String jsonString) {
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  final log = Logger();
  log.d(jsonData);
  return LoginResponse.fromJson(jsonData);
}
