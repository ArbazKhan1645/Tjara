class TransactionModel {
  Transactions? transactions;

  TransactionModel({this.transactions});

  TransactionModel.fromJson(Map<String, dynamic> json) {
    transactions = json['transactions'] != null
        ? Transactions.fromJson(json['transactions'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transactions != null) {
      data['transactions'] = transactions!.toJson();
    }
    return data;
  }
}

class Transactions {
  List<DataTransactions>? data;

  int? total;

  Transactions({this.data, this.total});

  Transactions.fromJson(Map<String, dynamic> json) {
   
    if (json['data'] != null) {
      data = <DataTransactions>[];
      json['data'].forEach((v) {
        data!.add(DataTransactions.fromJson(v));
      });
    }

    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    data['total'] = total;
    return data;
  }
}

class DataTransactions {
  String? id;
  String? userId;
  String? orderId;
  String? paymentIntentId;
  String? paymentMethod;
  Null paymentFor;
  int? amount;
  String? paymentStatus;
  String? createdAt;
  String? updatedAt;
  Buyer? buyer;

  DataTransactions({
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
    this.buyer,
  });

  DataTransactions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    paymentIntentId = json['payment_intent_id'];
    paymentMethod = json['payment_method'];
    paymentFor = json['payment_for'];
    amount = (json['amount'] as num?)?.toInt();
    paymentStatus = json['payment_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    buyer = json['buyer'] != null ? Buyer.fromJson(json['buyer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['order_id'] = orderId;
    data['payment_intent_id'] = paymentIntentId;
    data['payment_method'] = paymentMethod;
    data['payment_for'] = paymentFor;
    data['amount'] = amount;
    data['payment_status'] = paymentStatus;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (buyer != null) {
      data['buyer'] = buyer!.toJson();
    }

    return data;
  }
}

class Buyer {
  User? user;

  Buyer({this.user});

  Buyer.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  Null prevId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  Null thumbnailId;
  String? authToken;
  Null phoneVerificationCode;
  String? emailVerifiedAt;
  String? role;
  String? status;
  String? createdAt;
  String? updatedAt;

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
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;

    data['first_name'] = firstName;
    data['last_name'] = lastName;

    return data;
  }
}
