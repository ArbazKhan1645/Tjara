// To parse this JSON data, do
//
//     final shopData = shopDataFromJson(jsonString);

import 'dart:convert';

ShopData shopDataFromJson(String str) => ShopData.fromJson(json.decode(str));

String shopDataToJson(ShopData data) => json.encode(data.toJson());

class ShopData {
  Shops? shops;

  ShopData({this.shops});

  factory ShopData.fromJson(Map<String, dynamic> json) => ShopData(
    shops: json["shops"] == null ? null : Shops.fromJson(json["shops"]),
  );

  Map<String, dynamic> toJson() => {"shops": shops?.toJson()};
}

class Shops {
  int? currentPage;
  List<Datum>? data;
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

  Shops({
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
  factory Shops.fromJson(Map<String, dynamic> json) => Shops(
    currentPage: (json["current_page"] as num?)?.toInt(),
    data:
        json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: (json["from"] as num?)?.toInt(),
    lastPage: (json["last_page"] as num?)?.toInt(),
    lastPageUrl: json["last_page_url"],
    links:
        json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: (json["per_page"] as num?)?.toInt(),
    prevPageUrl: json["prev_page_url"],
    to: (json["to"] as num?)?.toInt(),
    total: (json["total"] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links":
        links == null ? [] : List<dynamic>.from(links!.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Shop {
  Datum? shop;

  Shop({this.shop});

  factory Shop.fromJson(Map<String, dynamic> json) =>
      Shop(shop: json["shop"] == null ? null : Datum.fromJson(json["shop"]));

  Map<String, dynamic> toJson() => {"shop": shop?.toJson()};
}

class User {
  String? id;
  dynamic prevId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  dynamic thumbnailId;
  String? authToken;
  int? phoneVerificationCode;
  String? emailVerifiedAt;
  String? role;
  String? status;
  String? createdAt;
  String? updatedAt;
  Banner? thumbnail;
  Shop? shop;
  UserMeta? meta;
  dynamic address;

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

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    prevId: json["prev_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    phone: json["phone"],
    thumbnailId: json["thumbnail_id"],
    authToken: json["authToken"],
    phoneVerificationCode: json["phone_verification_code"],
    emailVerifiedAt: json["email_verified_at"],
    role: json["role"],
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    thumbnail:
        json["thumbnail"] == null ? null : Banner.fromJson(json["thumbnail"]),
    shop: json["shop"] == null ? null : Shop.fromJson(json["shop"]),
    meta: json["meta"] == null ? null : UserMeta.fromJson(json["meta"]),
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "prev_id": prevId,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "thumbnail_id": thumbnailId,
    "authToken": authToken,
    "phone_verification_code": phoneVerificationCode,
    "email_verified_at": emailVerifiedAt,
    "role": role,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "thumbnail": thumbnail?.toJson(),
    "shop": shop?.toJson(),
    "meta": meta?.toJson(),
    "address": address,
  };
}

class Owner {
  User? user;

  Owner({this.user});

  factory Owner.fromJson(Map<String, dynamic> json) =>
      Owner(user: json["user"] == null ? null : User.fromJson(json["user"]));

  Map<String, dynamic> toJson() => {"user": user?.toJson()};
}

class Datum {
  String? id;
  dynamic prevId;
  String? userId;
  dynamic membershipId;
  dynamic membershipStartDate;
  dynamic membershipEndDate;
  String? slug;
  String? name;
  dynamic thumbnailId;
  dynamic bannerImageId;
  dynamic stripeAccountId;
  int? balance;
  String? description;
  int? isVerified;
  int? isFeatured;
  String? status;
  String? createdAt;
  String? updatedAt;
  Banner? thumbnail;
  Owner? owner;
  Banner? banner;
  Banner? membership;
  DatumMeta? meta;

  Datum({
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
    this.thumbnail,
    this.owner,
    this.banner,
    this.membership,
    this.meta,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    prevId: json["prev_id"],
    userId: json["user_id"],
    membershipId: json["membership_id"],
    membershipStartDate: json["membership_start_date"],
    membershipEndDate: json["membership_end_date"],
    slug: json["slug"],
    name: json["name"],
    thumbnailId: json["thumbnail_id"],
    bannerImageId: json["banner_image_id"],
    stripeAccountId: json["stripe_account_id"],
    balance: (json["balance"] as num?)?.toInt(),
    description: json["description"],
    isVerified: (json["is_verified"] as num?)?.toInt(),
    isFeatured: (json["is_featured"] as num?)?.toInt(),
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    thumbnail:
        json["thumbnail"] == null ? null : Banner.fromJson(json["thumbnail"]),
    owner: json["owner"] == null ? null : Owner.fromJson(json["owner"]),
    banner: json["banner"] == null ? null : Banner.fromJson(json["banner"]),
    membership:
        json["membership"] == null ? null : Banner.fromJson(json["membership"]),
    meta:
        json["meta"] == null
            ? null
            : json["meta"] is List
            ? null
            : DatumMeta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "prev_id": prevId,
    "user_id": userId,
    "membership_id": membershipId,
    "membership_start_date": membershipStartDate,
    "membership_end_date": membershipEndDate,
    "slug": slug,
    "name": name,
    "thumbnail_id": thumbnailId,
    "banner_image_id": bannerImageId,
    "stripe_account_id": stripeAccountId,
    "balance": balance,
    "description": description,
    "is_verified": isVerified,
    "is_featured": isFeatured,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "thumbnail": thumbnail?.toJson(),
    "owner": owner?.toJson(),
    "banner": banner?.toJson(),
    "membership": membership?.toJson(),
    "meta": meta?.toJson(),
  };
}

class PurpleAddress {
  FluffyAddress? address;

  PurpleAddress({this.address});

  factory PurpleAddress.fromJson(Map<String, dynamic> json) => PurpleAddress(
    address:
        json["address"] == null
            ? null
            : FluffyAddress.fromJson(json["address"]),
  );

  Map<String, dynamic> toJson() => {"address": address?.toJson()};
}

class FluffyAddress {
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

  FluffyAddress({
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

  factory FluffyAddress.fromJson(Map<String, dynamic> json) => FluffyAddress(
    id: json["id"],
    userId: json["user_id"],
    streetAddress: json["street_address"],
    postalCode: json["postal_code"],
    cityId: json["city_id"],
    stateId: json["state_id"],
    countryId: json["country_id"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    country: json["country"],
    state: json["state"],
    city: json["city"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "street_address": streetAddress,
    "postal_code": postalCode,
    "city_id": cityId,
    "state_id": stateId,
    "country_id": countryId,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "country": country,
    "state": state,
    "city": city,
  };
}

class UserMeta {
  String? dashboardView;
  String? userId;

  UserMeta({this.dashboardView, this.userId});

  factory UserMeta.fromJson(Map<String, dynamic> json) =>
      UserMeta(dashboardView: json["dashboard-view"], userId: json["user_id"]);

  Map<String, dynamic> toJson() => {
    "dashboard-view": dashboardView,
    "user_id": userId,
  };
}

class Banner {
  String? message;

  Banner({this.message});

  factory Banner.fromJson(Map<String, dynamic> json) =>
      Banner(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}

class DatumMeta {
  String? phone;

  DatumMeta({this.phone});

  factory DatumMeta.fromJson(Map<String, dynamic> json) =>
      DatumMeta(phone: json["phone"]);

  Map<String, dynamic> toJson() => {"phone": phone};
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({this.url, this.label, this.active});

  factory Link.fromJson(Map<String, dynamic> json) =>
      Link(url: json["url"], label: json["label"], active: json["active"]);

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}