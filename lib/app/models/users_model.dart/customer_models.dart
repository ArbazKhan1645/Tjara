import 'dart:convert';

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
  final String? phoneVerificationCode;
  final String? emailVerifiedAt;
  final String? role;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final Thumbnail? thumbnail;
  final Meta? meta;
  final String? address;

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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      prevId: json['prev_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      thumbnailId: json['thumbnail_id'],
      authToken: json['authToken'],
      phoneVerificationCode: json['phone_verification_code'],
      emailVerifiedAt: json['email_verified_at'],
      role: json['role'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      address: json['address'],
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
      'address': address,
    };
  }
}

class Thumbnail {
  final String? message;

  Thumbnail({this.message});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class Meta {
  final String? dashboardView;

  Meta({this.dashboardView});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      dashboardView: json['dashboard-view'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboard-view': dashboardView,
    };
  }
}

LoginResponse parseLoginResponse(String jsonString) {
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  return LoginResponse.fromJson(jsonData);
}
