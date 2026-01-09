class ContestModel {
  String? id;
  String? slug;
  String? shopId;
  String? winnerId;
  String? name;
  String? description;
  String? thumbnailId;
  bool? isFeatured;
  String? startTime;
  String? endTime;
  String? createdAt;
  String? updatedAt;
  Participants? participants;
  dynamic shop;
  Thumbnail? thumbnail;
  List<Question>? questions;
  Meta? meta;

  ContestModel({
    this.id,
    this.slug,
    this.shopId,
    this.winnerId,
    this.name,
    this.description,
    this.thumbnailId,
    this.isFeatured,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
    this.participants,
    this.shop,
    this.thumbnail,
    this.questions,
    this.meta,
  });

  factory ContestModel.fromJson(Map<String, dynamic> json) {
    return ContestModel(
      id: json['id'],
      slug: json['slug'],
      shopId: json['shop_id'],
      winnerId: json['winner_id'],
      name: json['name'],
      description: json['description'],
      thumbnailId: json['thumbnail_id'],
      isFeatured: json['is_featured'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      participants: json['participants'] != null
          ? Participants.fromJson(json['participants'])
          : null,
      // shop: json['shop'],
      thumbnail: json['thumbnail'] != null
          ? Thumbnail.fromJson(json['thumbnail'])
          : null,
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((i) => Question.fromJson(i))
              .toList()
          : null,
      // meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

class Participants {
  List<Participant>? participants;
  int? total;

  Participants({
    this.participants,
    this.total,
  });

  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((i) => Participant.fromJson(i))
              .toList()
          : null,
      total: json['total'],
    );
  }
}

class Participant {
  String? id;
  String? contestId;
  String? userId;
  String? answers;
  int? correctAnswers;
  int? totalQuestions;
  double? percentageCorrect; // This is a double
  bool? isEligibleForPrize;
  String? createdAt;
  String? updatedAt;
  ParticipantDetails? participant;

  Participant({
    this.id,
    this.contestId,
    this.userId,
    this.answers,
    this.correctAnswers,
    this.totalQuestions,
    this.percentageCorrect,
    this.isEligibleForPrize,
    this.createdAt,
    this.updatedAt,
    this.participant,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      contestId: json['contest_id'],
      userId: json['user_id'],
      answers: json['answers'],
      correctAnswers: json['correct_answers'],
      totalQuestions: json['total_questions'],
      // Convert int to double explicitly
      percentageCorrect: json['percentage_correct']?.toDouble(),
      isEligibleForPrize: json['is_eligible_for_prize'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      participant: json['participant'] != null
          ? ParticipantDetails.fromJson(json['participant'])
          : null,
    );
  }
}

class ParticipantDetails {
  String? id;
  String? prevId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? thumbnailId;
  String? authToken;
  String? phoneVerificationCode;
  String? emailVerifiedAt;
  String? role;
  String? status;
  String? createdAt;
  String? updatedAt;
  dynamic thumbnail;

  ParticipantDetails({
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
  });

  factory ParticipantDetails.fromJson(Map<String, dynamic> json) {
    return ParticipantDetails(
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
      thumbnail: json['thumbnail'],
    );
  }
}

class Thumbnail {
  Media? media;

  Thumbnail({
    this.media,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
    );
  }
}

class Media {
  String? id;
  String? url;
  String? optimizedMediaUrl;
  String? mediaType;
  bool? isUsed;
  String? createdAt;
  String? updatedAt;

  Media({
    this.id,
    this.url,
    this.optimizedMediaUrl,
    this.mediaType,
    this.isUsed,
    this.createdAt,
    this.updatedAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      url: json['url'],
      optimizedMediaUrl: json['optimized_media_url'],
      mediaType: json['media_type'],
      isUsed: json['is_used'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Question {
  String? id;
  String? contestId;
  String? question;
  String? option1;
  String? option2;
  String? option3;
  String? option4;
  String? correctAnswer;
  int? order;
  String? createdAt;
  String? updatedAt;

  Question({
    this.id,
    this.contestId,
    this.question,
    this.option1,
    this.option2,
    this.option3,
    this.option4,
    this.correctAnswer,
    this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      contestId: json['contest_id'],
      question: json['question'],
      option1: json['option_1'],
      option2: json['option_2'],
      option3: json['option_3'],
      option4: json['option_4'],
      correctAnswer: json['correct_answer'],
      order: json['order'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Meta {
  String? contestPrizeDetails;
  String? requiredCorrectAnswers;
  String? views;

  Meta({
    this.contestPrizeDetails,
    this.requiredCorrectAnswers,
    this.views,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      contestPrizeDetails: json['contest_prize_details'],
      requiredCorrectAnswers: json['required_correct_answers'],
      views: json['views'],
    );
  }
}
