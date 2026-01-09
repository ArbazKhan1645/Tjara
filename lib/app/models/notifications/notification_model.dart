class NotificationModel {
  final String id;
  final String? forUser;
  final String? shopId;
  final String userId;
  final String title;
  final String description;
  final String? url;
  final String? readBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    this.forUser,
    this.shopId,
    required this.userId,
    required this.title,
    required this.description,
    this.url,
    this.readBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      forUser: json['for'],
      shopId: json['shop_id'],
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'],
      readBy: json['read_by'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
