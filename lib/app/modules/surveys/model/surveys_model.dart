class SurveysResponse {
  SurveysResponse({this.surveys});

  final Surveys? surveys;

  factory SurveysResponse.fromJson(Map<String, dynamic> json) {
    return SurveysResponse(
      surveys:
          json['surveys'] == null
              ? null
              : Surveys.fromJson(json['surveys'] as Map<String, dynamic>),
    );
  }
}

class Surveys {
  Surveys({
    this.data,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
    this.prevPageUrl,
    this.nextPageUrl,
    this.links,
  });

  final List<SurveyData>? data;
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final int? from;
  final int? to;
  final String? prevPageUrl;
  final String? nextPageUrl;
  final List<SurveyLink>? links;

  factory Surveys.fromJson(Map<String, dynamic> json) {
    return Surveys(
      data:
          json['data'] == null
              ? null
              : List<SurveyData>.from(
                (json['data'] as List).map(
                  (x) => SurveyData.fromJson(x as Map<String, dynamic>),
                ),
              ),
      currentPage: json['current_page'] as int?,
      lastPage: json['last_page'] as int?,
      perPage: json['per_page'] as int?,
      total: json['total'] as int?,
      from: json['from'] as int?,
      to: json['to'] as int?,
      prevPageUrl: json['prev_page_url'] as String?,
      nextPageUrl: json['next_page_url'] as String?,
      links:
          json['links'] == null
              ? null
              : List<SurveyLink>.from(
                (json['links'] as List).map(
                  (x) => SurveyLink.fromJson(x as Map<String, dynamic>),
                ),
              ),
    );
  }
}

class SurveyData {
  SurveyData({
    this.id,
    this.shopId,
    this.slug,
    this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    this.thumbnailId,
    this.thankYouMessage,
    this.thankYouMessageAr,
    this.status,
    this.isFeatured,
    this.startTime,
    this.endTime,
    this.allowMultipleSubmissions,
    this.showResultsAfterSubmit,
    this.createdAt,
    this.updatedAt,
    this.meta,
    this.thumbnail,
    this.questions,
  });

  final String? id;
  final String? shopId;
  final String? slug;
  final String? title;
  final String? titleAr;
  final String? description;
  final String? descriptionAr;
  final String? thumbnailId;
  final String? thankYouMessage;
  final String? thankYouMessageAr;
  final String? status;
  final bool? isFeatured;
  final String? startTime;
  final String? endTime;
  final bool? allowMultipleSubmissions;
  final bool? showResultsAfterSubmit;
  final String? createdAt;
  final String? updatedAt;
  final dynamic meta;
  final SurveyThumbnail? thumbnail;
  final List<SurveyQuestion>? questions;

  factory SurveyData.fromJson(Map<String, dynamic> json) {
    return SurveyData(
      id: json['id'] as String?,
      shopId: json['shop_id'] as String?,
      slug: json['slug'] as String?,
      title: json['title'] as String?,
      titleAr: json['title_ar'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      thumbnailId: json['thumbnail_id'] as String?,
      thankYouMessage: json['thank_you_message'] as String?,
      thankYouMessageAr: json['thank_you_message_ar'] as String?,
      status: json['status'] as String?,
      isFeatured: json['is_featured'] as bool?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      allowMultipleSubmissions: json['allow_multiple_submissions'] as bool?,
      showResultsAfterSubmit: json['show_results_after_submit'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      meta: json['meta'],
      thumbnail:
          json['thumbnail'] == null
              ? null
              : SurveyThumbnail.fromJson(
                json['thumbnail'] as Map<String, dynamic>,
              ),
      questions:
          json['questions'] == null
              ? null
              : List<SurveyQuestion>.from(
                (json['questions'] as List).map(
                  (x) => SurveyQuestion.fromJson(x as Map<String, dynamic>),
                ),
              ),
    );
  }
}

class SurveyThumbnail {
  SurveyThumbnail({this.media, this.cached});

  final SurveyMedia? media;
  final bool? cached;

  factory SurveyThumbnail.fromJson(Map<String, dynamic> json) {
    return SurveyThumbnail(
      media:
          json['media'] == null
              ? null
              : SurveyMedia.fromJson(json['media'] as Map<String, dynamic>),
      cached: json['cached'] as bool?,
    );
  }
}

class SurveyMedia {
  SurveyMedia({
    this.id,
    this.url,
    this.optimizedMediaUrl,
    this.mediaType,
    this.cdnUrl,
    this.optimizedMediaCdnUrl,
    this.cdnVideoId,
    this.cdnThumbnailUrl,
    this.cdnStoragePath,
    this.isStreaming,
    this.isUsed,
    this.createdAt,
    this.updatedAt,
    this.usingCdn,
  });

  final String? id;
  final String? url;
  final String? optimizedMediaUrl;
  final String? mediaType;
  final String? cdnUrl;
  final String? optimizedMediaCdnUrl;
  final String? cdnVideoId;
  final String? cdnThumbnailUrl;
  final String? cdnStoragePath;
  final bool? isStreaming;
  final dynamic isUsed;
  final String? createdAt;
  final String? updatedAt;
  final bool? usingCdn;

  factory SurveyMedia.fromJson(Map<String, dynamic> json) {
    return SurveyMedia(
      id: json['id'] as String?,
      url: json['url'] as String?,
      optimizedMediaUrl: json['optimized_media_url'] as String?,
      mediaType: json['media_type'] as String?,
      cdnUrl: json['cdn_url'] as String?,
      optimizedMediaCdnUrl: json['optimized_media_cdn_url'] as String?,
      cdnVideoId: json['cdn_video_id'] as String?,
      cdnThumbnailUrl: json['cdn_thumbnail_url'] as String?,
      cdnStoragePath: json['cdn_storage_path'] as String?,
      isStreaming: json['is_streaming'] as bool?,
      isUsed: json['is_used'],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      usingCdn: json['using_cdn'] as bool?,
    );
  }
}

class SurveyQuestion {
  SurveyQuestion({
    this.id,
    this.surveyId,
    this.questionText,
    this.questionTextAr,
    this.description,
    this.descriptionAr,
    this.questionType,
    this.options,
    this.isRequired,
    this.order,
    this.validationRules,
    this.placeholder,
    this.placeholderAr,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? surveyId;
  final String? questionText;
  final String? questionTextAr;
  final String? description;
  final String? descriptionAr;
  final String? questionType;
  final List<QuestionOption>? options;
  final bool? isRequired;
  final int? order;
  final String? validationRules;
  final String? placeholder;
  final String? placeholderAr;
  final String? createdAt;
  final String? updatedAt;

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'] as String?,
      surveyId: json['survey_id'] as String?,
      questionText: json['question_text'] as String?,
      questionTextAr: json['question_text_ar'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      questionType: json['question_type'] as String?,
      options:
          json['options'] == null
              ? null
              : List<QuestionOption>.from(
                (json['options'] as List).map(
                  (x) => QuestionOption.fromJson(x as Map<String, dynamic>),
                ),
              ),
      isRequired: json['is_required'] as bool?,
      order: json['order'] as int?,
      validationRules: json['validation_rules'] as String?,
      placeholder: json['placeholder'] as String?,
      placeholderAr: json['placeholder_ar'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class QuestionOption {
  QuestionOption({this.label, this.value, this.labelAr});

  final String? label;
  final String? value;
  final String? labelAr;

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      label: json['label'] as String?,
      value: json['value'] as String?,
      labelAr: json['label_ar'] as String?,
    );
  }
}

class SurveyLink {
  SurveyLink({this.url, this.label, this.active});

  final String? url;
  final String? label;
  final bool? active;

  factory SurveyLink.fromJson(Map<String, dynamic> json) {
    return SurveyLink(
      url: json['url'] as String?,
      label: json['label'] as String?,
      active: json['active'] as bool?,
    );
  }
}

// Submit Response Models
class SurveySubmitResponse {
  SurveySubmitResponse({
    this.message,
    this.thankYouMessage,
    this.responseId,
    this.results,
  });

  final String? message;
  final String? thankYouMessage;
  final String? responseId;
  final SurveyResults? results;

  factory SurveySubmitResponse.fromJson(Map<String, dynamic> json) {
    return SurveySubmitResponse(
      message: json['message'] as String?,
      thankYouMessage: json['thank_you_message'] as String?,
      responseId: json['response_id'] as String?,
      results:
          json['results'] == null
              ? null
              : SurveyResults.fromJson(json['results'] as Map<String, dynamic>),
    );
  }
}

class SurveyResults {
  SurveyResults({this.original});

  final SurveyResultsOriginal? original;

  factory SurveyResults.fromJson(Map<String, dynamic> json) {
    return SurveyResults(
      original:
          json['original'] == null
              ? null
              : SurveyResultsOriginal.fromJson(
                json['original'] as Map<String, dynamic>,
              ),
    );
  }
}

class SurveyResultsOriginal {
  SurveyResultsOriginal({this.survey, this.results});

  final SurveyStatsSummary? survey;
  final List<QuestionResult>? results;

  factory SurveyResultsOriginal.fromJson(Map<String, dynamic> json) {
    return SurveyResultsOriginal(
      survey:
          json['survey'] == null
              ? null
              : SurveyStatsSummary.fromJson(
                json['survey'] as Map<String, dynamic>,
              ),
      results:
          json['results'] == null
              ? null
              : List<QuestionResult>.from(
                (json['results'] as List).map(
                  (x) => QuestionResult.fromJson(x as Map<String, dynamic>),
                ),
              ),
    );
  }
}

class SurveyStatsSummary {
  SurveyStatsSummary({this.id, this.title, this.statistics});

  final String? id;
  final String? title;
  final SurveyStatistics? statistics;

  factory SurveyStatsSummary.fromJson(Map<String, dynamic> json) {
    return SurveyStatsSummary(
      id: json['id'] as String?,
      title: json['title'] as String?,
      statistics:
          json['statistics'] == null
              ? null
              : SurveyStatistics.fromJson(
                json['statistics'] as Map<String, dynamic>,
              ),
    );
  }
}

class SurveyStatistics {
  SurveyStatistics({
    this.totalResponses,
    this.uniqueUsers,
    this.anonymousResponses,
    this.totalQuestions,
  });

  final int? totalResponses;
  final int? uniqueUsers;
  final int? anonymousResponses;
  final int? totalQuestions;

  factory SurveyStatistics.fromJson(Map<String, dynamic> json) {
    return SurveyStatistics(
      totalResponses: json['total_responses'] as int?,
      uniqueUsers: json['unique_users'] as int?,
      anonymousResponses: json['anonymous_responses'] as int?,
      totalQuestions: json['total_questions'] as int?,
    );
  }
}

class QuestionResult {
  QuestionResult({
    this.questionId,
    this.questionText,
    this.questionType,
    this.analytics,
  });

  final String? questionId;
  final String? questionText;
  final String? questionType;
  final QuestionAnalytics? analytics;

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['question_id'] as String?,
      questionText: json['question_text'] as String?,
      questionType: json['question_type'] as String?,
      analytics:
          json['analytics'] == null
              ? null
              : QuestionAnalytics.fromJson(
                json['analytics'] as Map<String, dynamic>,
              ),
    );
  }
}

class QuestionAnalytics {
  QuestionAnalytics({this.totalResponses, this.answers});

  final int? totalResponses;
  final List<AnswerStats>? answers;

  factory QuestionAnalytics.fromJson(Map<String, dynamic> json) {
    return QuestionAnalytics(
      totalResponses: json['total_responses'] as int?,
      answers:
          json['answers'] == null
              ? null
              : List<AnswerStats>.from(
                (json['answers'] as List).map(
                  (x) => AnswerStats.fromJson(x as Map<String, dynamic>),
                ),
              ),
    );
  }
}

class AnswerStats {
  AnswerStats({this.answer, this.count, this.percentage});

  final dynamic answer;
  final int? count;
  final double? percentage;

  factory AnswerStats.fromJson(Map<String, dynamic> json) {
    return AnswerStats(
      answer: json['answer'],
      count: json['count'] as int?,
      percentage: (json['percentage'] as num?)?.toDouble(),
    );
  }
}
