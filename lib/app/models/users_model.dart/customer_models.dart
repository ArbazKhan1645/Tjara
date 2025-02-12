class CustomerModel {
  final int? id;
  final String? createdAt;
  final String? updatedAt;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? buildingNumber;
  final String? street;
  final String? city;
  final String? country;
  final String? zipCode;
  final String? roles;
  final String? accountName;
  final String? accountNumber;
  final int? sortCode;

  CustomerModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.buildingNumber,
    this.street,
    this.city,
    this.country,
    this.zipCode,
    this.roles,
    this.accountName,
    this.accountNumber,
    this.sortCode,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      firstName: json['first_name'] ?? 'N/A',
      lastName: json['last_name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      buildingNumber: json['building_number'] ?? 'N/A',
      street: json['street'] ?? 'N/A',
      city: json['city'] ?? 'N/A',
      country: json['country'] ?? 'N/A',
      zipCode: json['zip_code'] ?? 'N/A',
      roles: json['roles'] ?? 'user',
      accountName: json['account_name'] ?? 'N/A',
      accountNumber: json['account_number'] ?? 'N/A',
      sortCode: json['sort_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'building_number': buildingNumber,
      'street': street,
      'city': city,
      'country': country,
      'zip_code': zipCode,
      'roles': roles,
      'account_name': accountName,
      'account_number': accountNumber,
      'sort_code': sortCode,
    };
  }

  // CopyWith function
  CustomerModel copyWith({
    int? id,
    String? createdAt,
    String? updatedAt,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? buildingNumber,
    String? street,
    String? city,
    String? country,
    String? zipCode,
    String? roles,
    String? accountName,
    String? accountNumber,
    int? sortCode,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      roles: roles ?? this.roles,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      sortCode: sortCode ?? this.sortCode,
    );
  }
}
