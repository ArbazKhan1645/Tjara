class MobilePhone {
  final String id; 
  final String name; 
  final String brand; 
  final String model;
  final double price; 
  final String imageUrl;
  final double rating; 
  final int reviewsCount; 
  final String storageCapacity; 
  final String ram;
  final String color; 
  final String batteryCapacity; 
  final String processor; 
  final String displaySize; 
  final String displayType; 
  final String operatingSystem; 
  final List<String> features;
  final DateTime launchDate;
  final bool isAvailable; 
  final List<String> sellers; 

  // Constructor
  MobilePhone({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.storageCapacity,
    required this.ram,
    required this.color,
    required this.batteryCapacity,
    required this.processor,
    required this.displaySize,
    required this.displayType,
    required this.operatingSystem,
    required this.features,
    required this.launchDate,
    required this.isAvailable,
    required this.sellers,
  });

  // Factory method for creating a MobilePhone object from JSON
  factory MobilePhone.fromJson(Map<String, dynamic> json) {
    return MobilePhone(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      rating: json['rating'].toDouble(),
      reviewsCount: json['reviewsCount'],
      storageCapacity: json['storageCapacity'],
      ram: json['ram'],
      color: json['color'],
      batteryCapacity: json['batteryCapacity'],
      processor: json['processor'],
      displaySize: json['displaySize'],
      displayType: json['displayType'],
      operatingSystem: json['operatingSystem'],
      features: List<String>.from(json['features']),
      launchDate: DateTime.parse(json['launchDate']),
      isAvailable: json['isAvailable'],
      sellers: List<String>.from(json['sellers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'storageCapacity': storageCapacity,
      'ram': ram,
      'color': color,
      'batteryCapacity': batteryCapacity,
      'processor': processor,
      'displaySize': displaySize,
      'displayType': displayType,
      'operatingSystem': operatingSystem,
      'features': features,
      'launchDate': launchDate.toIso8601String(),
      'isAvailable': isAvailable,
      'sellers': sellers,
    };
  }
}
