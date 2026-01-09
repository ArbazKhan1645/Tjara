import 'package:tjara/app/models/products/products_model.dart';

class WithdrawelModel {
  Withdrawals? withdrawals;

  WithdrawelModel({this.withdrawals});

  WithdrawelModel.fromJson(Map<String, dynamic> json) {
    withdrawals = json['withdrawals'] != null
        ? Withdrawals.fromJson(json['withdrawals'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (withdrawals != null) {
      data['withdrawals'] = withdrawals!.toJson();
    }
    return data;
  }
}

class Withdrawals {
  List<Data>? data;

  int? total;

  Withdrawals({this.data, this.total});

  Withdrawals.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  String? id;
  String? shopId;
  String? amount;
  String? status;
  String? createdAt;
  String? updatedAt;
  ShopShop? shop;

  Data(
      {this.id,
      this.shopId,
      this.amount,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.shop});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shopId = json['shop_id'];
    amount = json['amount'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    shop = json['shop'] != null ? ShopShop.fromJson(json['shop']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['shop_id'] = shopId;
    data['amount'] = amount;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    return data;
  }
}
