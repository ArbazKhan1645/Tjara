class SurveyModel {
  final String id;
  final String shopId;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isFeatured;
  final bool allowMultipleSubmissions;
  final bool showResultsAfterSubmit;
  final String thankYouMessage;
  final String thankYouMessageAr;
  final String? thumbnailId;
  final MediaModel? thumbnail;
  final List<QuestionModel> questions;
  final DateTime createdAt;
  final DateTime updatedAt;

  SurveyModel({
    required this.id,
    required this.shopId,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.status,
    this.startTime,
    this.endTime,
    required this.isFeatured,
    required this.allowMultipleSubmissions,
    required this.showResultsAfterSubmit,
    required this.thankYouMessage,
    required this.thankYouMessageAr,
    this.thumbnailId,
    this.thumbnail,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] ?? '',
      shopId: json['shop_id'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['title_ar'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      status: json['status'] ?? 'draft',
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'])
              : null,
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      isFeatured: json['is_featured'] ?? false,
      allowMultipleSubmissions: json['allow_multiple_submissions'] ?? false,
      showResultsAfterSubmit: json['show_results_after_submit'] ?? false,
      thankYouMessage: json['thank_you_message'] ?? '',
      thankYouMessageAr: json['thank_you_message_ar'] ?? '',
      thumbnailId: json['thumbnail_id'],
      thumbnail:
          json['thumbnail'] != null
              ? MediaModel.fromJson(json['thumbnail']['media'] ?? {})
              : null,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'title': title,
      'title_ar': titleAr,
      'description': description,
      'description_ar': descriptionAr,
      'status': status,
      if (startTime != null) 'start_time': startTime!.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
      'is_featured': isFeatured,
      'allow_multiple_submissions': allowMultipleSubmissions,
      'show_results_after_submit': showResultsAfterSubmit,
      'thank_you_message': thankYouMessage,
      'thank_you_message_ar': thankYouMessageAr,
      if (thumbnailId != null) 'thumbnail_id': thumbnailId,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class MediaModel {
  final String id;
  final String url;
  final String? optimizedMediaUrl;
  final String mediaType;
  final bool usingCdn;

  MediaModel({
    required this.id,
    required this.url,
    this.optimizedMediaUrl,
    required this.mediaType,
    required this.usingCdn,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      optimizedMediaUrl: json['optimized_media_url'],
      mediaType: json['media_type'] ?? 'image',
      usingCdn: json['using_cdn'] ?? false,
    );
  }
}

class QuestionModel {
  String? id;
  final String questionText;
  final String questionTextAr;
  final String questionType;
  final String description;
  final String descriptionAr;
  final String placeholder;
  final String placeholderAr;
  final bool isRequired;
  final int order;
  final String validationRules;
  final List<QuestionOption> options;

  QuestionModel({
    this.id,
    required this.questionText,
    required this.questionTextAr,
    required this.questionType,
    this.description = '',
    this.descriptionAr = '',
    this.placeholder = '',
    this.placeholderAr = '',
    this.isRequired = false,
    required this.order,
    this.validationRules = '',
    this.options = const [],
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      questionText: json['question_text'] ?? '',
      questionTextAr: json['question_text_ar'] ?? '',
      questionType: json['question_type'] ?? 'text',
      description: json['description'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      placeholder: json['placeholder'] ?? '',
      placeholderAr: json['placeholder_ar'] ?? '',
      isRequired: json['is_required'] ?? false,
      order: json['order'] ?? 0,
      validationRules: json['validation_rules'] ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((o) => QuestionOption.fromJson(o))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'question_text': questionText,
      'question_text_ar': questionTextAr,
      'question_type': questionType,
      'description': description,
      'description_ar': descriptionAr,
      'placeholder': placeholder,
      'placeholder_ar': placeholderAr,
      'is_required': isRequired,
      'order': order,
      'validation_rules': validationRules,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }

  QuestionModel copyWith({
    String? id,
    String? questionText,
    String? questionTextAr,
    String? questionType,
    String? description,
    String? descriptionAr,
    String? placeholder,
    String? placeholderAr,
    bool? isRequired,
    int? order,
    String? validationRules,
    List<QuestionOption>? options,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      questionTextAr: questionTextAr ?? this.questionTextAr,
      questionType: questionType ?? this.questionType,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      placeholder: placeholder ?? this.placeholder,
      placeholderAr: placeholderAr ?? this.placeholderAr,
      isRequired: isRequired ?? this.isRequired,
      order: order ?? this.order,
      validationRules: validationRules ?? this.validationRules,
      options: options ?? this.options,
    );
  }
}

class QuestionOption {
  final String? label;
  final String? value;
  final String? labelAr;

  QuestionOption({this.label, this.value, this.labelAr});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      label: json['label'],
      value: json['value'],
      labelAr: json['label_ar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'value': value, 'label_ar': labelAr};
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}
