import 'package:tjara/app/models/media_model/media_model.dart';
import 'package:tjara/app/models/products/products_model.dart';

class PostModel {
  final String id;
  final String slug;
  final String shopId;
  final String name;
  final String description;
  final String thumbnailId;
  final String postType;
  final String status;
  final String languageId;
  final String parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Video? video;
  final Thumbnail? thumbnail;
  final DatumShop? shop;
  final Language? language;
  final PostMeta? meta;

  PostModel({
    required this.id,
    required this.slug,
    required this.shopId,
    required this.name,
    this.description = '',
    required this.thumbnailId,
    required this.postType,
    required this.status,
    required this.languageId,
    this.parentId = '',
    required this.createdAt,
    required this.updatedAt,
    this.video,
    this.thumbnail,
    this.shop,
    this.language,
    this.meta,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      shopId: json['shop_id'] ?? '',
      name: json['name'] ?? '',
      description:
          json['description']?.toString() ?? '', // Handle potential null
      thumbnailId: json['thumbnail_id'] ?? '',
      postType: json['post_type'] ?? '',
      status: json['status'] ?? '',
      languageId: json['language_id'] ?? '',
      // parentId: json['parent_id']?.toString() ?? '', // Handle potential null
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      video: json['video'] != null ? Video.fromJson(json['video']) : null,
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
      shop: json['shop'] != null 
          ? DatumShop.fromJson(json['shop'])
          : null,
      // language:
      //     json['language'] != null ? Language.fromJson(json['language']) : null,
      meta: (json['meta'] != null && json['meta'] is! List<dynamic>)
          ? PostMeta.fromJson(json['meta'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['slug'] = slug;
    data['shop_id'] = shopId;
    data['name'] = name;
    data['description'] = description;
    data['thumbnail_id'] = thumbnailId;
    data['post_type'] = postType;
    data['status'] = status;
    data['language_id'] = languageId;
    data['parent_id'] = parentId;
    data['created_at'] = createdAt.toIso8601String();
    data['updated_at'] = updatedAt.toIso8601String();
    if (video != null) data['video'] = video!.toJson();
    if (thumbnail != null) data['thumbnail'] = thumbnail!.toJson();
    if (shop != null) data['shop'] = shop!.toJson();
    if (meta != null) data['meta'] = meta!.toJson();

    return data;
  }
}

class Video {
  final MediaUniversalModel? media;

  const Video({this.media});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      media: json['media'] != null
          ? MediaUniversalModel.fromJson(json['media'])
          : MediaUniversalModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media': media!.toJson(),
    };
  }
}

class Thumbnail {
  final MediaUniversalModel? media;

  const Thumbnail({this.media});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      media: json['media'] != null
          ? MediaUniversalModel.fromJson(json['media'])
          : MediaUniversalModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media': media!.toJson(),
    };
  }
}

class Shop {
  final ShopData? shop;

  const Shop({this.shop});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shop: json['shop'] != null ? ShopData.fromJson(json['shop']) : ShopData(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop': shop!.toJson(),
    };
  }
}

class ShopData {
  final String id;
  final String prevId;
  final String userId;
  final String membershipId;
  final String membershipStartDate;
  final String membershipEndDate;
  final String slug;
  final String name;
  final String thumbnailId;
  final String bannerImageId;
  final String stripeAccountId;
  final int balance;
  final String description;
  final int isVerified;
  final int isFeatured;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Banner? banner;
  final Thumbnail? thumbnail;
  final Membership? membership;
  final ShopMeta? meta;

  ShopData({
    this.id = '',
    this.prevId = '',
    this.userId = '',
    this.membershipId = '',
    this.membershipStartDate = '',
    this.membershipEndDate = '',
    this.slug = '',
    this.name = '',
    this.thumbnailId = '',
    this.bannerImageId = '',
    this.stripeAccountId = '',
    this.balance = 0,
    this.description = '',
    this.isVerified = 0,
    this.isFeatured = 0,
    this.status = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.banner,
    this.thumbnail,
    this.membership,
    this.meta,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      id: json['id'] ?? '',
      prevId: json['prev_id'] ?? '',
      userId: json['user_id'] ?? '',
      membershipId: json['membership_id'] ?? '',
      membershipStartDate: json['membership_start_date'] ?? '',
      membershipEndDate: json['membership_end_date'] ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      thumbnailId: json['thumbnail_id'] ?? '',
      bannerImageId: json['banner_image_id'] ?? '',
      stripeAccountId: json['stripe_account_id'] ?? '',
      balance: json['balance'] ?? 0,
      description: json['description'] ?? '',
      isVerified: json['is_verified'] ?? 0,
      isFeatured: json['is_featured'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      banner:
          json['banner'] != null ? Banner.fromJson(json['banner']) : const Banner(),
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : const Thumbnail(),
      membership: json['membership'] != null
          ? Membership.fromJson(json['membership'])
          : const Membership(),
      meta: json['meta'] != null ? ShopMeta.fromJson(json['meta']) : const ShopMeta(),
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'banner': banner!.toJson(),
      'thumbnail': thumbnail!.toJson(),
      'membership': membership!.toJson(),
      'meta': meta!.toJson(),
    };
  }
}

class Banner {
  final MediaUniversalModel? media;

  const Banner({this.media});

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      media: json['media'] != null
          ? MediaUniversalModel.fromJson(json['media'])
          : MediaUniversalModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media': media!.toJson(),
    };
  }
}

class Membership {
  final MembershipPlan? membershipPlan;

  const Membership({this.membershipPlan});

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      membershipPlan: json['membership_plan'] != null
          ? MembershipPlan.fromJson(json['membership_plan'])
          : const MembershipPlan(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'membership_plan': membershipPlan!.toJson(),
    };
  }
}

class MembershipPlan {
  final String id;
  final String slug;
  final String userType;
  final String name;
  final int price;
  final String description;
  final String duration;
  final String parentId;
  final String status;
  final dynamic createdAt;
  final dynamic updatedAt;
  final MembershipThumbnail? thumbnail;
  final Features? features;

  const MembershipPlan({
    this.id = '',
    this.slug = '',
    this.userType = '',
    this.name = '',
    this.price = 0,
    this.description = '',
    this.duration = '',
    this.parentId = '',
    this.status = '',
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
    this.features,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      userType: json['user_type'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      parentId: json['parent_id'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      thumbnail: json['thumbnail'] != null
          ? MembershipThumbnail.fromJson(json['thumbnail'])
          : const MembershipThumbnail(),
      features: json['features'] != null
          ? Features.fromJson(json['features'])
          : const Features(),
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
      'created_at': createdAt,
      'updated_at': updatedAt,
      'thumbnail': thumbnail!.toJson(),
      'features': features!.toJson(),
    };
  }
}

class MembershipThumbnail {
  final String message;

  const MembershipThumbnail({this.message = ''});

  factory MembershipThumbnail.fromJson(Map<String, dynamic> json) {
    return MembershipThumbnail(
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class Features {
  final List<dynamic> membershipPlanFeatures;

  const Features({this.membershipPlanFeatures = const []});

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      membershipPlanFeatures: json['membership_plan_features'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'membership_plan_features': membershipPlanFeatures,
    };
  }
}

class ShopMeta {
  final String freeShippingTargetAmount;
  final String shippingFees;
  final String shippingCompany;
  final String shippingTimeFrom;
  final String isEligibleForDiscounts;
  final String shippingTimeTo;
  final String whatsapp;
  final String phone;

  const ShopMeta({
    this.freeShippingTargetAmount = '',
    this.shippingFees = '',
    this.shippingCompany = '',
    this.shippingTimeFrom = '',
    this.isEligibleForDiscounts = '',
    this.shippingTimeTo = '',
    this.whatsapp = '',
    this.phone = '',
  });

  factory ShopMeta.fromJson(Map<String, dynamic> json) {
    return ShopMeta(
      freeShippingTargetAmount: json['free_shipping_target_amount'] ?? '',
      shippingFees: json['shipping_fees'] ?? '',
      shippingCompany: json['shipping_company'] ?? '',
      shippingTimeFrom: json['shipping_time_from'] ?? '',
      isEligibleForDiscounts: json['is_eligible_for_discounts'] ?? '',
      shippingTimeTo: json['shipping_time_to'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'free_shipping_target_amount': freeShippingTargetAmount,
      'shipping_fees': shippingFees,
      'shipping_company': shippingCompany,
      'shipping_time_from': shippingTimeFrom,
      'is_eligible_for_discounts': isEligibleForDiscounts,
      'shipping_time_to': shippingTimeTo,
      'whatsapp': whatsapp,
      'phone': phone,
    };
  }
}

class Language {
  final String id;
  final String code;
  final String name;
  final String nativeName;
  final String dir;
  final String flag;
  final bool isDefault;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Language({
    this.id = '',
    this.code = '',
    this.name = '',
    this.nativeName = '',
    this.dir = '',
    this.flag = '',
    this.isDefault = false,
    this.isActive = false,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      nativeName: json['native_name'] ?? '',
      dir: json['dir'] ?? '',
      flag: json['flag'] ?? '',
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'native_name': nativeName,
      'dir': dir,
      'flag': flag,
      'is_default': isDefault,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class PostMeta {
  final String? videoId;
  String? views;
  String? likes;
  final String? link;
  final String? buttonText;
  final String? buttonUrl;
  final Map<String, dynamic> additionalData;

  PostMeta({
    this.videoId,
    this.views,
    this.likes,
    this.link,
    this.buttonText,
    this.buttonUrl,
    this.additionalData = const {},
  });

  factory PostMeta.fromJson(Map<String, dynamic> json) {
    // Create a copy of the json to remove known fields
    final additionalData = Map<String, dynamic>.from(json)
      ..removeWhere((key, _) =>
          key == 'video_id' ||
          key == 'views' ||
          key == 'likes' ||
          key == 'link' ||
          key == 'button_text' ||
          key == 'button_url');

    return PostMeta(
      videoId: json['video_id']?.toString(),
      views: json['views']?.toString(),
      likes: json['likes']?.toString(),
      link: json['link']?.toString(),
      buttonText: json['button_text']?.toString(),
      buttonUrl: json['button_url']?.toString(),
      additionalData: additionalData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'views': views,
      'likes': likes,
      'link': link,
      'button_text': buttonText,
      'button_url': buttonUrl,
      ...additionalData,
    };
  }
}


class PostPagination {
  final int currentPage;
  final List<PostModel> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final String nextPageUrl;
  final String path;
  final int perPage;
  final String prevPageUrl;
  final int to;
  final int total;

  const PostPagination({
    this.currentPage = 1,
    this.data = const [],
    this.firstPageUrl = '',
    this.from = 0,
    this.lastPage = 1,
    this.lastPageUrl = '',
    this.links = const [],
    this.nextPageUrl = '',
    this.path = '',
    this.perPage = 10,
    this.prevPageUrl = '',
    this.to = 0,
    this.total = 0,
  });

  factory PostPagination.fromJson(Map<String, dynamic> json) {
    return PostPagination(
      // currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List)
          .map((item) => PostModel.fromJson(item))
          .toList(),
      // firstPageUrl: json['first_page_url'] ?? '',
      // from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      // lastPageUrl: json['last_page_url'] ?? '',
      // links: (json['links'] as List).map((link) => Link.fromJson(link)).toList(),
      // nextPageUrl: json['next_page_url'] ?? '',
      // path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      // prevPageUrl: json['prev_page_url'] ?? '',
      // to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((post) => post.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'links': links.map((link) => link.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}

class Link {
  final String url;
  final String label;
  final bool active;

  const Link({
    this.url = '',
    this.label = '',
    this.active = false,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'] ?? '',
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}

class PostResponse {
  final PostPagination posts;

  const PostResponse({this.posts = const PostPagination()});

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      posts: PostPagination.fromJson(json['posts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.toJson(),
    };
  }
}
