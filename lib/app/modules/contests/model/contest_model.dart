// contest_model.dart
// class ContestModel {
//   final String? id;
//   final String? slug;
//   final String? shopId;
//   final String? winnerId;
//   final String? name;
//   final String? description;
//   final String? thumbnailId;
//   final bool? isFeatured;
//   final String? startTime;
//   final String? endTime;
//   final String? createdAt;
//   final String? updatedAt;
//   final ThumbnailModel? thumbnail;
//   final ShopModel? shop;
//   final dynamic rating;
//   final MetaModel? meta;

//   ContestModel({
//     this.id,
//     this.slug,
//     this.shopId,
//     this.winnerId,
//     this.name,
//     this.description,
//     this.thumbnailId,
//     this.isFeatured,
//     this.startTime,
//     this.endTime,
//     this.createdAt,
//     this.updatedAt,
//     this.thumbnail,
//     this.shop,
//     this.rating,
//     this.meta,
//   });

//   factory ContestModel.fromJson(Map<String, dynamic> json) {
//     return ContestModel(
//       id: json['id'],
//       slug: json['slug'],
//       shopId: json['shop_id'],
//       winnerId: json['winner_id'],
//       name: json['name'],
//       description: json['description'],
//       thumbnailId: json['thumbnail_id'],
//       isFeatured: json['is_featured'],
//       startTime: json['start_time'],
//       endTime: json['end_time'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       thumbnail: json['thumbnail'] != null
//           ? ThumbnailModel.fromJson(json['thumbnail'])
//           : null,
//       shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
//       // rating: json['rating'],
//       // meta: json['meta'] != null ? MetaModel.fromJson(json['meta']) : null,
//     );
//   }
// }

import 'package:tjara/app/modules/contests/model/selected_contest_model.dart';

class ThumbnailModel {
  final MediaModel? media;

  ThumbnailModel({this.media});

  factory ThumbnailModel.fromJson(Map<String, dynamic> json) {
    return ThumbnailModel(
      media: json['media'] != null ? MediaModel.fromJson(json['media']) : null,
    );
  }
}

class MediaModel {
  final String? id;
  final String? url;
  final String? optimizedMediaUrl;
  final String? mediaType;
  final dynamic isUsed;
  final String? createdAt;
  final String? updatedAt;

  MediaModel({
    this.id,
    this.url,
    this.optimizedMediaUrl,
    this.mediaType,
    this.isUsed,
    this.createdAt,
    this.updatedAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'],
      url: json['url'],
      optimizedMediaUrl: json['optimized_media_url'],
      mediaType: json['media_type'],
      isUsed: json['is_used'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ShopModel {
  final ShopDetailsModel? shop;

  ShopModel({this.shop});

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      shop: json['shop'] != null ? ShopDetailsModel.fromJson(json['shop']) : null,
    );
  }
}

class ShopDetailsModel {
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
  final ThumbnailModel? banner;
  final ThumbnailModel? thumbnail;
  final MembershipModel? membership;
  final MetaShopModel? meta;

  ShopDetailsModel({
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

  factory ShopDetailsModel.fromJson(Map<String, dynamic> json) {
    return ShopDetailsModel(
      id: json['id'],
      prevId: json['prev_id'],
      userId: json['user_id'],
      membershipId: json['membership_id'],
      membershipStartDate: json['membership_start_date'],
      membershipEndDate: json['membership_end_date'],
      slug: json['slug'],
      name: json['name'],
      thumbnailId: json['thumbnail_id'],
      bannerImageId: json['banner_image_id'],
      stripeAccountId: json['stripe_account_id'],
      balance: json['balance'],
      description: json['description'],
      isVerified: json['is_verified'],
      isFeatured: json['is_featured'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      banner: json['banner'] != null ? ThumbnailModel.fromJson(json['banner']) : null,
      thumbnail: json['thumbnail'] != null
          ? ThumbnailModel.fromJson(json['thumbnail'])
          : null,
      membership: json['membership'] != null
          ? MembershipModel.fromJson(json['membership'])
          : null,
      meta: json['meta'] != null ? MetaShopModel.fromJson(json['meta']) : null,
    );
  }
}

class MembershipModel {
  final MembershipPlanModel? membershipPlan;

  MembershipModel({this.membershipPlan});

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      membershipPlan: json['membership_plan'] != null
          ? MembershipPlanModel.fromJson(json['membership_plan'])
          : null,
    );
  }
}

class MembershipPlanModel {
  final String? id;
  final String? slug;
  final String? userType;
  final String? name;
  final int? price;
  final String? description;
  final String? duration;
  final String? parentId;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final dynamic thumbnail;
  final FeaturesModel? features;

  MembershipPlanModel({
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

  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) {
    return MembershipPlanModel(
      id: json['id'],
      slug: json['slug'],
      userType: json['user_type'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      duration: json['duration'],
      parentId: json['parent_id'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      thumbnail: json['thumbnail'],
      features: json['features'] != null
          ? FeaturesModel.fromJson(json['features'])
          : null,
    );
  }
}

class FeaturesModel {
  final List<dynamic>? membershipPlanFeatures;

  FeaturesModel({this.membershipPlanFeatures});

  factory FeaturesModel.fromJson(Map<String, dynamic> json) {
    return FeaturesModel(
      membershipPlanFeatures: json['membership_plan_features'],
    );
  }
}

class MetaShopModel {
  final String? freeShippingTargetAmount;
  final String? shippingFees;
  final String? shippingCompany;
  final String? shippingTimeFrom;
  final String? isEligibleForDiscounts;
  final String? shippingTimeTo;
  final String? whatsapp;
  final String? phone;

  MetaShopModel({
    this.freeShippingTargetAmount,
    this.shippingFees,
    this.shippingCompany,
    this.shippingTimeFrom,
    this.isEligibleForDiscounts,
    this.shippingTimeTo,
    this.whatsapp,
    this.phone,
  });

  factory MetaShopModel.fromJson(Map<String, dynamic> json) {
    return MetaShopModel(
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

class MetaModel {
  final String? contestPrizeDetails;
  final String? requiredCorrectAnswers;
  final String? views;

  MetaModel({
    this.contestPrizeDetails,
    this.requiredCorrectAnswers,
    this.views,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      contestPrizeDetails: json['contest_prize_details'],
      requiredCorrectAnswers: json['required_correct_answers'],
      views: json['views'],
    );
  }
}

class ContestsResponse {
  final ContestsPagination? contests;

  ContestsResponse({this.contests});

  factory ContestsResponse.fromJson(Map<String, dynamic> json) {
    return ContestsResponse(
      contests: json['contests'] != null
          ? ContestsPagination.fromJson(json['contests'])
          : null,
    );
  }
}

class ContestsPagination {
  final int? currentPage;
  final List<ContestModel>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<LinkModel>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  ContestsPagination({
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

  factory ContestsPagination.fromJson(Map<String, dynamic> json) {
    final List<ContestModel> contestList = [];
    if (json['data'] != null) {
      json['data'].forEach((contest) {
        contestList.add(ContestModel.fromJson(contest));
      });
    }

    final List<LinkModel> linksList = [];
    if (json['links'] != null) {
      json['links'].forEach((link) {
        linksList.add(LinkModel.fromJson(link));
      });
    }

    return ContestsPagination(
      currentPage: json['current_page'],
      data: contestList,
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: linksList,
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class LinkModel {
  final String? url;
  final String? label;
  final bool? active;

  LinkModel({
    this.url,
    this.label,
    this.active,
  });

  factory LinkModel.fromJson(Map<String, dynamic> json) {
    return LinkModel(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}