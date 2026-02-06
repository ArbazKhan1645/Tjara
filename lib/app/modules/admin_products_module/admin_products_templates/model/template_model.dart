class Template {
  final String id;
  final String name;
  final String? description;
  final String productIds;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  Template({
    required this.id,
    required this.name,
    this.description,
    required this.productIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      productIds: json['product_ids'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      createdBy: json['created_by'],
    );
  }

  List<String> get productIdsList {
    if (productIds.isEmpty) return [];
    return productIds.split(',').where((id) => id.isNotEmpty).toList();
  }

  int get productCount => productIdsList.length;
}

class TemplatesResponse {
  final TemplatesPagination templates;
  final String message;

  TemplatesResponse({
    required this.templates,
    required this.message,
  });

  factory TemplatesResponse.fromJson(Map<String, dynamic> json) {
    return TemplatesResponse(
      templates: TemplatesPagination.fromJson(json['templates'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class TemplatesPagination {
  final int currentPage;
  final List<Template> data;
  final int lastPage;
  final int total;

  TemplatesPagination({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory TemplatesPagination.fromJson(Map<String, dynamic> json) {
    return TemplatesPagination(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Template.fromJson(item))
              .toList() ??
          [],
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}
