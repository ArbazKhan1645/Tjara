class CountryModel {
  List<Countries>? countries;

  CountryModel({this.countries});

  CountryModel.fromJson(Map<String, dynamic> json) {
    if (json['countries'] != null) {
      countries = <Countries>[];
      json['countries'].forEach((v) {
        countries!.add(Countries.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (countries != null) {
      data['countries'] = countries!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Countries {
  String? id;
  String? name;
  String? countryCode;
  String? currency;
  String? currencyCode;
  String? createdAt;
  String? updatedAt;

  Countries(
      {this.id,
      this.name,
      this.countryCode,
      this.currency,
      this.currencyCode,
      this.createdAt,
      this.updatedAt});

  Countries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    countryCode = json['country_code'];
    currency = json['currency'];
    currencyCode = json['currency_code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['country_code'] = countryCode;
    data['currency'] = currency;
    data['currency_code'] = currencyCode;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
