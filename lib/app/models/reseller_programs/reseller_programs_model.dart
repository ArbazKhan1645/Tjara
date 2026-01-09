class ResellerProgramResponse {
  ResellerPrograms? resellerPrograms;
  ResellerProgramResponse({this.resellerPrograms});
  factory ResellerProgramResponse.fromJson(Map<String, dynamic>? json) {
    return ResellerProgramResponse(
      resellerPrograms: json?['reseller_programs'] != null
          ? ResellerPrograms.fromJson(json!['reseller_programs'])
          : null,
    );
  }
}

class ResellerPrograms {
  final int currentPage;
  final List<ResellerProgram> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  ResellerPrograms({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ResellerPrograms.fromJson(Map<String, dynamic> json) {
    return ResellerPrograms(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List)
          .map((item) => ResellerProgram.fromJson(item))
          .toList(),
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List)
          .map((link) => PaginationLink.fromJson(link))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 15,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}

class ResellerProgram {
  final String id;
  final String userId;
  final String? membershipId;
  final DateTime? membershipStartDate;
  final DateTime? membershipEndDate;
  final String referralCode;
  final String referredBy;
  final double balance;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Referrer referrer;
  final Owner owner;

  ResellerProgram({
    required this.id,
    required this.userId,
    this.membershipId,
    this.membershipStartDate,
    this.membershipEndDate,
    required this.referralCode,
    required this.referredBy,
    required this.balance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.referrer,
    required this.owner,
  });

  factory ResellerProgram.fromJson(Map<String, dynamic> json) {
    return ResellerProgram(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      membershipId: json['membership_id'],
      membershipStartDate: json['membership_start_date'] != null
          ? DateTime.parse(json['membership_start_date'])
          : null,
      membershipEndDate: json['membership_end_date'] != null
          ? DateTime.parse(json['membership_end_date'])
          : null,
      referralCode: json['referral_code'] ?? '',
      referredBy: json['referred_by'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      referrer: Referrer.fromJson(json['referrer'] ?? {}),
      owner: Owner.fromJson(json['owner'] ?? {}),
    );
  }
}

class Referrer {
  final User user;

  Referrer({required this.user});

  factory Referrer.fromJson(Map<String, dynamic> json) {
    return Referrer(
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class Owner {
  final User user;

  Owner({required this.user});

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  final String id;
  final String? prevId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? thumbnailId;
  final String authToken;
  final String? phoneVerificationCode;
  final DateTime? emailVerifiedAt;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Thumbnail? thumbnail;
  final Shop? shop;
  final UserMeta? meta;
  final UserAddress? address;

  User({
    required this.id,
    this.prevId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.thumbnailId,
    required this.authToken,
    this.phoneVerificationCode,
    this.emailVerifiedAt,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnail,
    this.shop,
    this.meta,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      prevId: json['prev_id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      thumbnailId: json['thumbnail_id'],
      authToken: json['authToken'] ?? '',
      phoneVerificationCode: json['phone_verification_code'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      thumbnail: json['thumbnail'] != null &&
              json['thumbnail'] is Map &&
              !json['thumbnail'].containsKey('message')
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
      shop: json['shop'] != null &&
              json['shop'] is Map &&
              !json['shop'].containsKey('message')
          ? Shop.fromJson(json['shop'])
          : null,
      meta: json['meta'] != null ? UserMeta.fromJson(json['meta']) : null,
      address: json['address'] != null && json['address'] is Map
          ? UserAddress.fromJson(json['address'])
          : null,
    );
  }

  String get fullName => '$firstName $lastName';
}

class Thumbnail {
  final Media? media;

  Thumbnail({this.media});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
    );
  }
}

class Media {
  final String id;
  final String url;
  final String? optimizedMediaUrl;
  final String mediaType;
  final String? cdnUrl;
  final String? optimizedMediaCdnUrl;
  final String? cdnVideoId;
  final String? cdnThumbnailUrl;
  final String? cdnStoragePath;
  final bool isStreaming;
  final dynamic isUsed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> copies;
  final bool usingCdn;

  Media({
    required this.id,
    required this.url,
    this.optimizedMediaUrl,
    required this.mediaType,
    this.cdnUrl,
    this.optimizedMediaCdnUrl,
    this.cdnVideoId,
    this.cdnThumbnailUrl,
    this.cdnStoragePath,
    required this.isStreaming,
    this.isUsed,
    required this.createdAt,
    required this.updatedAt,
    required this.copies,
    required this.usingCdn,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      optimizedMediaUrl: json['optimized_media_url'],
      mediaType: json['media_type'] ?? '',
      cdnUrl: json['cdn_url'],
      optimizedMediaCdnUrl: json['optimized_media_cdn_url'],
      cdnVideoId: json['cdn_video_id'],
      cdnThumbnailUrl: json['cdn_thumbnail_url'],
      cdnStoragePath: json['cdn_storage_path'],
      isStreaming: json['is_streaming'] ?? false,
      isUsed: json['is_used'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      copies: json['copies'] ?? [],
      usingCdn: json['using_cdn'] ?? false,
    );
  }
}

class Shop {
  final ShopData shop;

  Shop({required this.shop});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shop: ShopData.fromJson(json['shop'] ?? {}),
    );
  }
}

class ShopData {
  final String id;
  final String? prevId;
  final String userId;
  final String? membershipId;
  final String? membershipStartDate;
  final String? membershipEndDate;
  final String slug;
  final String name;
  final String? thumbnailId;
  final String? bannerImageId;
  final String? stripeAccountId;
  final double balance;
  final String description;
  final int isVerified;
  final int isFeatured;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ShopBanner? banner;
  final ShopThumbnail? thumbnail;
  final Membership? membership;
  final ShopMeta meta;

  ShopData({
    required this.id,
    this.prevId,
    required this.userId,
    this.membershipId,
    this.membershipStartDate,
    this.membershipEndDate,
    required this.slug,
    required this.name,
    this.thumbnailId,
    this.bannerImageId,
    this.stripeAccountId,
    required this.balance,
    required this.description,
    required this.isVerified,
    required this.isFeatured,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.banner,
    this.thumbnail,
    this.membership,
    required this.meta,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      id: json['id'] ?? '',
      prevId: json['prev_id'],
      userId: json['user_id'] ?? '',
      membershipId: json['membership_id'],
      membershipStartDate: json['membership_start_date'],
      membershipEndDate: json['membership_end_date'],
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      thumbnailId: json['thumbnail_id'],
      bannerImageId: json['banner_image_id'],
      stripeAccountId: json['stripe_account_id'],
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      isVerified: json['is_verified'] ?? 0,
      isFeatured: json['is_featured'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      banner: json['banner'] != null &&
              json['banner'] is Map &&
              !json['banner'].containsKey('message')
          ? ShopBanner.fromJson(json['banner'])
          : null,
      thumbnail: json['thumbnail'] != null &&
              json['thumbnail'] is Map &&
              !json['thumbnail'].containsKey('message')
          ? ShopThumbnail.fromJson(json['thumbnail'])
          : null,
      membership: json['membership'] != null &&
              json['membership'] is Map &&
              !json['membership'].containsKey('message')
          ? Membership.fromJson(json['membership'])
          : null,
      meta: ShopMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class ShopBanner {
  final Media media;

  ShopBanner({required this.media});

  factory ShopBanner.fromJson(Map<String, dynamic> json) {
    return ShopBanner(
      media: Media.fromJson(json['media'] ?? {}),
    );
  }
}

class ShopThumbnail {
  final Media media;

  ShopThumbnail({required this.media});

  factory ShopThumbnail.fromJson(Map<String, dynamic> json) {
    return ShopThumbnail(
      media: Media.fromJson(json['media'] ?? {}),
    );
  }
}

class Membership {
  final MembershipPlan membershipPlan;

  Membership({required this.membershipPlan});

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      membershipPlan: MembershipPlan.fromJson(json['membership_plan'] ?? {}),
    );
  }
}

class MembershipPlan {
  final String id;
  final String slug;
  final String userType;
  final String name;
  final double price;
  final String description;
  final String duration;
  final String? parentId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Thumbnail? thumbnail;
  final MembershipFeatures features;

  MembershipPlan({
    required this.id,
    required this.slug,
    required this.userType,
    required this.name,
    required this.price,
    required this.description,
    required this.duration,
    this.parentId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    required this.features,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      userType: json['user_type'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      parentId: json['parent_id'],
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      thumbnail: json['thumbnail'] != null &&
              json['thumbnail'] is Map &&
              !json['thumbnail'].containsKey('message')
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
      features: MembershipFeatures.fromJson(json['features'] ?? {}),
    );
  }
}

class MembershipFeatures {
  final List<dynamic> membershipPlanFeatures;

  MembershipFeatures({required this.membershipPlanFeatures});

  factory MembershipFeatures.fromJson(Map<String, dynamic> json) {
    return MembershipFeatures(
      membershipPlanFeatures: json['membership_plan_features'] ?? [],
    );
  }
}

class ShopMeta {
  final String? freeShippingTargetAmount;
  final String? shippingFees;
  final String? shippingCompany;
  final String? shippingTimeFrom;
  final String? isEligibleForDiscounts;
  final String? shippingTimeTo;
  final String? whatsapp;
  final String? phone;

  ShopMeta({
    this.freeShippingTargetAmount,
    this.shippingFees,
    this.shippingCompany,
    this.shippingTimeFrom,
    this.isEligibleForDiscounts,
    this.shippingTimeTo,
    this.whatsapp,
    this.phone,
  });

  factory ShopMeta.fromJson(Map<String, dynamic> json) {
    return ShopMeta(
      freeShippingTargetAmount: json['free_shipping_target_amount'],
      shippingFees: json['shipping_fees'],
      shippingCompany: json['shipping_company'],
      shippingTimeFrom: json['shipping_time_from'],
      isEligibleForDiscounts: json['is_eligible_for_discounts'],
      shippingTimeTo: json['shipping_time_to'],
      whatsapp: json['whatsapp'],
      phone: json['phone'],
    );
  }
}

class UserMeta {
  final String? role;
  final String? dashboardView;
  final String? userId;
  final String? nextUserIdCounter;

  UserMeta({
    this.role,
    this.dashboardView,
    this.userId,
    this.nextUserIdCounter,
  });

  factory UserMeta.fromJson(Map<String, dynamic> json) {
    return UserMeta(
      role: json['role'],
      dashboardView: json['dashboard-view'],
      userId: json['user_id'],
      nextUserIdCounter: json['next_user_id_counter'],
    );
  }
}

class UserAddress {
  final AddressData address;

  UserAddress({required this.address});

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('address')) {
      return UserAddress(
        address: AddressData.fromJson(json['address'] ?? {}),
      );
    } else if (json is String) {
      return UserAddress(
        address: AddressData.empty(),
      );
    } else {
      return UserAddress(
        address: AddressData.fromJson(json),
      );
    }
  }
}

class AddressData {
  final String id;
  final String userId;
  final String streetAddress;
  final String postalCode;
  final String cityId;
  final String stateId;
  final String countryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String country;
  final String state;
  final String city;

  AddressData({
    required this.id,
    required this.userId,
    required this.streetAddress,
    required this.postalCode,
    required this.cityId,
    required this.stateId,
    required this.countryId,
    required this.createdAt,
    required this.updatedAt,
    required this.country,
    required this.state,
    required this.city,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      streetAddress: json['street_address'] ?? '',
      postalCode: json['postal_code'] ?? '',
      cityId: json['city_id'] ?? '',
      stateId: json['state_id'] ?? '',
      countryId: json['country_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
    );
  }

  factory AddressData.empty() {
    return AddressData(
      id: '',
      userId: '',
      streetAddress: '',
      postalCode: '',
      cityId: '',
      stateId: '',
      countryId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      country: '',
      state: '',
      city: '',
    );
  }

  String get fullAddress {
    return '$streetAddress, $city, $state, $country'
        .replaceAll(' ,', ',')
        .trim();
  }
}
