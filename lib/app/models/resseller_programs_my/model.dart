// models/reseller_program_model.dart
class ResellerProgramModel {
  final String id;
  final String userId;
  final String? membershipId;
  final String? membershipStartDate;
  final String? membershipEndDate;
  final String referralCode;
  final String? referredBy;
  final double balance;
  final String status;
  final String? createdAt;
  final String updatedAt;
  final Owner owner;
  final String? verified_member;
  final Referrer? referrer;
  final List<TeamMemberOrder>? teamMemberOrders;
  final Membership? membership;

  ResellerProgramModel({
    required this.id,
    required this.userId,
    this.membershipId,
    this.membershipStartDate,
    this.membershipEndDate,
    this.teamMemberOrders,
    required this.referralCode,
    this.referredBy,
    required this.balance,
    required this.status,
    this.verified_member,
    this.createdAt,
    required this.updatedAt,
    required this.owner,
    this.referrer,
    this.membership,
  });

  factory ResellerProgramModel.fromJson(Map<String, dynamic> json) {
    // Handle different JSON structures
    Map<String, dynamic> resellerProgram;
    
    if (json.containsKey('reseller_program')) {
      // First API format (single reseller program)
      resellerProgram = json['reseller_program'];
    } else {
      // Second API format (direct reseller program object)
      resellerProgram = json;
    }
    
    return ResellerProgramModel(
      id: resellerProgram['id'] ?? '',
      userId: resellerProgram['user_id'] ?? '',
      membershipId: resellerProgram['membership_id'],
      membershipStartDate: resellerProgram['membership_start_date'],
      membershipEndDate: resellerProgram['membership_end_date'],
      verified_member: resellerProgram['verified_member'],
      referralCode: resellerProgram['referral_code'] ?? '',
      referredBy: resellerProgram['referred_by'],
      balance: (resellerProgram['balance'] ?? 0).toDouble(),
      status: resellerProgram['status'] ?? '',
      createdAt: resellerProgram['created_at'],
      updatedAt: resellerProgram['updated_at'] ?? '',
            teamMemberOrders: resellerProgram['team_member_orders'] != null
          ? (resellerProgram['team_member_orders'] as List)
              .map((i) => TeamMemberOrder.fromJson(i))
              .toList()
          : null,
      owner: Owner.fromJson(resellerProgram['owner']),
      referrer: resellerProgram['referrer'] != null && 
                resellerProgram['referrer'] is Map &&
                !resellerProgram['referrer'].containsKey('message')
          ? Referrer.fromJson(resellerProgram['referrer'])
          : null,
      membership: resellerProgram['membership'] != null &&
                  resellerProgram['membership'] is Map &&
                  !resellerProgram['membership'].containsKey('message')
          ? Membership.fromJson(resellerProgram['membership'])
          : null,
    );
  }
}

class TeamMemberOrder {
  final String id;
  final String buyerId;
  final String shopId;
  final double orderTotal;
  final double adminCommissionTotal;
  final String status;
  final String createdAt;
  final String updatedAt;
  final OrderMeta meta;

  TeamMemberOrder({
    required this.id,
    required this.buyerId,
    required this.shopId,
    required this.orderTotal,
    required this.adminCommissionTotal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.meta,
  });

  factory TeamMemberOrder.fromJson(Map<String, dynamic> json) {
    return TeamMemberOrder(
      id: json['id'] ?? '',
      buyerId: json['buyer_id'] ?? '',
      shopId: json['shop_id'] ?? '',
      orderTotal: (json['order_total'] ?? 0).toDouble(),
      adminCommissionTotal: (json['admin_commission_total'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      meta: OrderMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class OrderMeta {
  final String? orderId;
  final String? shippingTotal;
  final String? cancellationReason;
  final String? cancelledAt;
  final String? initialTotal;
  final String? discountTotal;
  // Add other dynamic fields as needed

  OrderMeta({
    this.orderId,
    this.shippingTotal,
    this.cancellationReason,
    this.cancelledAt,
    this.initialTotal,
    this.discountTotal,
  });

  factory OrderMeta.fromJson(Map<String, dynamic> json) {
    return OrderMeta(
      orderId: json['order_id'],
      shippingTotal: json['shipping_total'],
      cancellationReason: json['cancellation_reason'],
      cancelledAt: json['cancelled_at'],
      initialTotal: json['initial_total'],
      discountTotal: json['discount_total'],
    );
  }
}
class Owner {
  final User user;

  Owner({required this.user});

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String status;
  final Shop? shop;
  final UserMeta? meta;
  final UserAddress? address;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.shop,
    this.meta,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      shop: json['shop'] != null && json['shop'] is Map && json['shop'].containsKey('shop') 
          ? Shop.fromJson(json['shop']['shop']) 
          : null,
      meta: json['meta'] != null && json['meta'] is Map 
          ? UserMeta.fromJson(json['meta']) 
          : null,
      address: json['address'] != null && json['address'] is Map
          ? (json['address'].containsKey('address') 
              ? UserAddress.fromJson(json['address']['address'])
              : UserAddress.fromJson(json['address']))
          : null,
    );
  }
}

class Shop {
  final String id;
  final String name;
  final String slug;
  final double balance;
  final String description;
  final bool isVerified;
  final bool isFeatured;
  final String status;

  Shop({
    required this.id,
    required this.name,
    required this.slug,
    required this.balance,
    required this.description,
    required this.isVerified,
    required this.isFeatured,
    required this.status,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      isVerified: json['is_verified'] == 1,
      isFeatured: json['is_featured'] == 1,
      status: json['status'] ?? '',
    );
  }
}

class UserMeta {
  final String role;
  final String dashboardView;
  final String userId;
  final String? nextUserIdCounter;

  UserMeta({
    required this.role,
    required this.dashboardView,
    required this.userId,
    this.nextUserIdCounter,
  });

  factory UserMeta.fromJson(Map<String, dynamic> json) {
    return UserMeta(
      role: json['role'] ?? '',
      dashboardView: json['dashboard-view'] ?? '',
      userId: json['user_id'] ?? '',
      nextUserIdCounter: json['next_user_id_counter'],
    );
  }
}

class UserAddress {
  final String id;
  final String streetAddress;
  final String postalCode;
  final String country;
  final String state;
  final String city;

  UserAddress({
    required this.id,
    required this.streetAddress,
    required this.postalCode,
    required this.country,
    required this.state,
    required this.city,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] ?? '',
      streetAddress: json['street_address'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
    );
  }
}

class Referrer {
  final User? user;
  final String? message;

  Referrer({this.user, this.message});

  factory Referrer.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('message')) {
      return Referrer(message: json['message']);
    } else if (json.containsKey('user')) {
      return Referrer(user: User.fromJson(json['user']));
    } else {
      return Referrer(message: 'Unknown referrer format');
    }
  }
}

class Membership {
  final String? message;
  final MembershipPlan? membershipPlan;

  Membership({this.message, this.membershipPlan});

  factory Membership.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('message')) {
      return Membership(message: json['message']);
    } else if (json.containsKey('membership_plan')) {
      return Membership(membershipPlan: MembershipPlan.fromJson(json['membership_plan']));
    } else {
      return Membership(message: 'Unknown membership format');
    }
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
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] ?? '',
      slug: json['slug'] ?? '',
      userType: json['user_type'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      parentId: json['parent_id'],
      status: json['status'] ?? '',
    );
  }
}

// Response wrapper for paginated referral members
class ResellerProgramsResponse {
  final List<ResellerProgramModel> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  ResellerProgramsResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory ResellerProgramsResponse.fromJson(Map<String, dynamic> json) {
    final resellerPrograms = json['reseller_programs'];
    final dataList = resellerPrograms['data'] as List;
    
    return ResellerProgramsResponse(
      data: dataList.map((item) => ResellerProgramModel.fromJson(item)).toList(),
      currentPage: resellerPrograms['current_page'] ?? 1,
      lastPage: resellerPrograms['last_page'] ?? 1,
      total: resellerPrograms['total'] ?? 0,
      perPage: resellerPrograms['per_page'] ?? 15,
    );
  }
}