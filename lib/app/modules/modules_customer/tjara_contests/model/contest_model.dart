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
  ShopModel? shop;
  Thumbnail? thumbnail;
  List<Question>? questions;
  Meta? meta;
  CommentsData? comments;

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
    this.comments,
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
      participants:
          json['participants'] != null
              ? Participants.fromJson(json['participants'])
              : null,
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
      thumbnail:
          json['thumbnail'] != null
              ? Thumbnail.fromJson(json['thumbnail'])
              : null,
      questions:
          json['questions'] != null
              ? (json['questions'] as List)
                  .map((i) => Question.fromJson(i))
                  .toList()
              : null,
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      comments:
          json['comments'] != null
              ? CommentsData.fromJson(json['comments'])
              : null,
    );
  }
}

class Participants {
  List<Participant>? participants;
  int? total;

  Participants({this.participants, this.total});

  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
      participants:
          json['participants'] != null
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
  double? percentageCorrect;
  bool? isEligibleForPrize;
  String? createdAt;
  String? updatedAt;
  ParticipantDetails? participant;
  List<AnswerDetail>? answersDetailed;

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
    this.answersDetailed,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      contestId: json['contest_id'],
      userId: json['user_id'],
      answers: json['answers'],
      correctAnswers: json['correct_answers'],
      totalQuestions: json['total_questions'],
      percentageCorrect: json['percentage_correct']?.toDouble(),
      isEligibleForPrize: json['is_eligible_for_prize'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      participant:
          json['participant'] != null
              ? ParticipantDetails.fromJson(json['participant'])
              : null,
      answersDetailed:
          json['answers_detailed'] != null
              ? (json['answers_detailed'] as List)
                  .map((i) => AnswerDetail.fromJson(i))
                  .toList()
              : null,
    );
  }
}

class AnswerDetail {
  String? questionId;
  String? questionType;
  String? question;
  String? questionImage;
  Map<String, String>? options;
  String? correctAnswer;
  String? givenAnswer;
  bool? isCorrect;

  AnswerDetail({
    this.questionId,
    this.questionType,
    this.question,
    this.questionImage,
    this.options,
    this.correctAnswer,
    this.givenAnswer,
    this.isCorrect,
  });

  factory AnswerDetail.fromJson(Map<String, dynamic> json) {
    return AnswerDetail(
      questionId: json['question_id'],
      questionType: json['question_type'],
      question: json['question'],
      questionImage: json['question_image'],
      options:
          json['options'] != null
              ? Map<String, String>.from(json['options'])
              : null,
      correctAnswer: json['correct_answer'],
      givenAnswer: json['given_answer'],
      isCorrect: json['is_correct'],
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
  bool? cached;

  Thumbnail({this.media, this.cached});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      media: json['media'] != null ? Media.fromJson(json['media']) : null,
      cached: json['cached'],
    );
  }
}

class Media {
  String? id;
  String? url;
  String? optimizedMediaUrl;
  String? mediaType;
  dynamic isUsed;
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
  String? questionType;
  String? question;
  String? questionImageId;
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
    this.questionType,
    this.question,
    this.questionImageId,
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
      questionType: json['question_type'],
      question: json['question'],
      questionImageId: json['question_image_id'],
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
  String? shareRequired;
  String? views;
  String? requiredCorrectAnswers;
  String? likes;
  String? contestPrizeDetails;

  Meta({
    this.shareRequired,
    this.views,
    this.requiredCorrectAnswers,
    this.likes,
    this.contestPrizeDetails,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      shareRequired: json['share_required'],
      views: json['views'],
      requiredCorrectAnswers: json['required_correct_answers'],
      likes: json['likes'],
      contestPrizeDetails: json['contest_prize_details'],
    );
  }
}

class ShopModel {
  ShopDetails? shop;
  String? message;

  ShopModel({this.shop, this.message});

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    // Check if it's an error message
    if (json['message'] != null) {
      return ShopModel(message: json['message']);
    }

    // Check if shop data exists
    if (json['shop'] != null) {
      return ShopModel(shop: ShopDetails.fromJson(json['shop']));
    }

    // If json itself is the shop data
    if (json['id'] != null) {
      return ShopModel(shop: ShopDetails.fromJson(json));
    }

    return ShopModel();
  }
}

class ShopDetails {
  String? id;
  String? prevId;
  String? userId;
  String? membershipId;
  String? membershipStartDate;
  String? membershipEndDate;
  String? slug;
  String? name;
  String? thumbnailId;
  String? bannerImageId;
  String? stripeAccountId;
  int? balance;
  String? description;
  int? isVerified;
  int? isFeatured;
  String? status;
  String? createdAt;
  String? updatedAt;
  Thumbnail? banner;
  Thumbnail? thumbnail;

  ShopDetails({
    this.id,
    this.prevId,
    this.userId,
    this.membershipId,
    this.membershipStartDate,
    this.membershipEndDate,
    this.slug,
    this.name,
    this.thumbnailId,
    this.bannerImageId,
    this.stripeAccountId,
    this.balance,
    this.description,
    this.isVerified,
    this.isFeatured,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.banner,
    this.thumbnail,
  });

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    return ShopDetails(
      id: json['id'],
      prevId: json['prev_id'],
      userId: json['user_id'],
      membershipId: json['membership_id'],
      membershipStartDate: json['membership_start_date'],
      membershipEndDate: json['membership_end_date'],
      slug: json['slug'],
      name: json['name'],
      thumbnailId: json['thumbnail_id'],
      bannerImageId: json['banner_image_id'],
      stripeAccountId: json['stripe_account_id'],
      balance: json['balance'],
      description: json['description'],
      isVerified: json['is_verified'],
      isFeatured: json['is_featured'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      banner:
          json['banner'] != null ? Thumbnail.fromJson(json['banner']) : null,
      thumbnail:
          json['thumbnail'] != null
              ? Thumbnail.fromJson(json['thumbnail'])
              : null,
    );
  }
}

class CommentsData {
  Comments? comments;

  CommentsData({this.comments});

  factory CommentsData.fromJson(Map<String, dynamic> json) {
    return CommentsData(
      comments:
          json['comments'] != null ? Comments.fromJson(json['comments']) : null,
    );
  }
}

class Comments {
  double? averageRating;
  int? totalComments;
  List<Comment>? comments;

  Comments({this.averageRating, this.totalComments, this.comments});

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      averageRating: json['average_rating']?.toDouble(),
      totalComments: json['total_comments'],
      comments:
          json['comments'] != null
              ? (json['comments'] as List)
                  .map((i) => Comment.fromJson(i))
                  .toList()
              : null,
    );
  }
}

class Comment {
  String? id;
  String? userId;
  String? contestId;
  dynamic rating;
  String? description;
  String? parentId;
  String? createdAt;
  String? updatedAt;
  CommentUser? user;
  List<Comment>? replies;

  Comment({
    this.id,
    this.userId,
    this.contestId,
    this.rating,
    this.description,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      contestId: json['contest_id'],
      rating: json['rating'],
      description: json['description'],
      parentId: json['parent_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? CommentUser.fromJson(json['user']) : null,
      replies:
          json['replies'] != null
              ? (json['replies'] as List)
                  .map((i) => Comment.fromJson(i))
                  .toList()
              : null,
    );
  }
}

class CommentUser {
  User? user;

  CommentUser({this.user});

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
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
  String? roles;
  String? status;
  String? createdAt;
  String? updatedAt;
  dynamic thumbnail;

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
    this.roles,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
      roles: json['roles'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      thumbnail: json['thumbnail'],
    );
  }
}
