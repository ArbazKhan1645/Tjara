import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart'
    hide User;
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';
import 'package:tjara/app/modules/contests/model/contest_model.dart';
import 'package:tjara/app/modules/contests/model/fd.dart';
import 'package:tjara/app/modules/contests/service/context_share.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

enum LoadingStatus { initial, loading, loaded, error }

class ContestController extends GetxController {
  // List state
  final Rx<LoadingStatus> status = LoadingStatus.initial.obs;
  final RxList<ContestModel> contests = <ContestModel>[].obs;
  final RxString errorMessage = ''.obs;

  // Single contest state
  final Rx<ContestModel?> selectedModel = Rx<ContestModel?>(null);
  final Rx<ContestModel> contest = ContestModel().obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  // User answers state
  final RxMap<String, String> userAnswers = <String, String>{}.obs;
  final RxBool isSubmitting = false.obs;

  // Comment state
  final RxBool isCommentLoading = false.obs;

  // Like state
  final RxBool isLikeLoading = false.obs;
  final RxSet<String> likedContestIds = <String>{}.obs;

  final String baseUrl = 'https://api.libanbuy.com/api';
  final storage = GetStorage();

  // Storage key for liked contests
  static const String _likedContestsKey = 'liked_contest_ids';

  String get userId {
    try {
      final token = Get.find<AuthService>().authCustomer?.user?.id ?? '';
      return token;
    } catch (e) {
      return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadLikedContests();
    fetchContests();
  }

  /// Load liked contest IDs from local storage
  void _loadLikedContests() {
    try {
      final savedLikes = storage.read<List>(_likedContestsKey);
      if (savedLikes != null) {
        likedContestIds.addAll(savedLikes.cast<String>());
      }
    } catch (e) {
      // Ignore errors, start with empty set
    }
  }

  /// Save liked contest IDs to local storage
  void _saveLikedContests() {
    try {
      storage.write(_likedContestsKey, likedContestIds.toList());
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Check if current contest is liked by user
  bool isContestLiked([String? contestId]) {
    final id = contestId ?? contest.value.id;
    if (id == null) return false;
    return likedContestIds.contains(id);
  }

  /// Handles back navigation properly
  /// If selectedModel is not null, clears it first
  /// Otherwise performs actual Get.back()
  bool handleBackNavigation() {
    if (selectedModel.value != null) {
      clearSelectedModel();
      return false; // Indicates we handled it internally
    }
    return true; // Indicates caller should do Get.back()
  }

  /// Clears the selected model and resets related state
  void clearSelectedModel() {
    selectedModel.value = null;
    userAnswers.clear();
    error.value = '';
    update();
  }

  Future<void> fetchContests() async {
    try {
      status.value = LoadingStatus.loading;
      errorMessage.value = '';

      final uri = Uri.parse(
        '$baseUrl/contests?with=image,shop&orderBy=created_at&order=desc&_t=${DateTime.now().microsecondsSinceEpoch}',
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final contestsResponse = ContestsResponse.fromJson(jsonData);

        if (contestsResponse.contests?.data != null) {
          contests.value = contestsResponse.contests!.data!;
          status.value = LoadingStatus.loaded;
        } else {
          _setError('No contests available');
        }
      } else {
        _setError('Failed to load contests (${response.statusCode})');
      }
    } on SocketException catch (_) {
      _setError('No internet connection. Please check your network.');
    } on TimeoutException catch (_) {
      _setError('Connection timeout. Please try again.');
    } on FormatException catch (_) {
      _setError('Invalid response from server.');
    } catch (e) {
      _setError('Something went wrong. Please try again.');
    }
  }

  Future<void> fetchContest(String slug) async {
    if (slug.isEmpty) {
      error.value = 'Invalid contest ID';
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';

      final uri = Uri.parse('$baseUrl/contests/$slug?with=comments');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['contest'] != null) {
          contest.value = ContestModel.fromJson(jsonData['contest']);
          _checkUserParticipation();
        } else {
          error.value = 'Contest not found';
        }
      } else if (response.statusCode == 404) {
        error.value = 'Contest not found';
      } else {
        error.value = 'Failed to load contest';
      }
    } on SocketException catch (_) {
      error.value = 'No internet connection';
    } on TimeoutException catch (_) {
      error.value = 'Connection timeout';
    } on FormatException catch (_) {
      error.value = 'Invalid response from server';
    } catch (e) {
      error.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  void _showLoginDialog() {
    showContactDialog(Get.context!, const LoginUi());
  }

  Future<void> submitAnswers() async {
    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      _showLoginDialog();
      return;
    }
    if (userAnswers.isEmpty) {
      _showSnackbar('Error', 'Please answer all questions', isError: true);
      return;
    }

    final questionCount = contest.value.questions?.length ?? 0;
    if (questionCount != userAnswers.length) {
      _showSnackbar(
        'Error',
        'Please answer all $questionCount questions',
        isError: true,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final answers =
          userAnswers.entries
              .map((e) => {"question_id": e.key, "answer": e.value})
              .toList();

      final uri = Uri.parse(
        '$baseUrl/contests/${contest.value.id}/participations/insert',
      );

      if (contest.value.meta?.shareRequired == '1') {
        HapticFeedback.lightImpact();
        await RewardShareService.showShareDialog(
          context: Get.context!,
          contestName: contest.value.name ?? '',
          contestUrl:
              'https://libanbuy.com/contests/${contest.value.slug ?? ''}',
          onShare: () async {
            Get.back();
            final response = await http
                .post(
                  uri,
                  headers: _headers,
                  body: json.encode({"answers": answers}),
                )
                .timeout(const Duration(seconds: 15));

            if (response.statusCode == 200 || response.statusCode == 201) {
              _showSnackbar(
                'Success',
                'Answers submitted successfully!',
                isError: false,
              );
              userAnswers.clear();
              await fetchContest(contest.value.slug ?? contest.value.id ?? '');
            } else {
              String errorMsg = 'Submission failed';
              try {
                final errorData = json.decode(response.body);
                errorMsg = errorData['message'] ?? errorMsg;
              } catch (_) {}
              _showSnackbar('Error', errorMsg, isError: true);
            }
            Get.back();
          },
        );
        return;
      } else {
        final response = await http
            .post(
              uri,
              headers: _headers,
              body: json.encode({"answers": answers}),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showSnackbar(
            'Success',
            'Answers submitted successfully!',
            isError: false,
          );
          userAnswers.clear();
          await fetchContest(contest.value.slug ?? contest.value.id ?? '');
        } else {
          String errorMsg = 'Submission failed';
          try {
            final errorData = json.decode(response.body);
            errorMsg = errorData['message'] ?? errorMsg;
          } catch (_) {}
          _showSnackbar('Error', errorMsg, isError: true);
        }
      }
    } on SocketException catch (_) {
      _showSnackbar('Error', 'No internet connection', isError: true);
    } on TimeoutException catch (_) {
      _showSnackbar('Error', 'Connection timeout', isError: true);
    } catch (e) {
      _showSnackbar('Error', 'Failed to submit answers', isError: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> toggleLike() async {
    final contestId = contest.value.id;
    if (contestId == null || isLikeLoading.value) return;

    final isCurrentlyLiked = isContestLiked(contestId);
    final currentLikes = int.tryParse(contest.value.meta?.likes ?? '0') ?? 0;
    final newLikes =
        isCurrentlyLiked
            ? (currentLikes > 0 ? currentLikes - 1 : 0)
            : currentLikes + 1;

    try {
      isLikeLoading.value = true;

      // Optimistic update - update UI immediately
      if (isCurrentlyLiked) {
        likedContestIds.remove(contestId);
      } else {
        likedContestIds.add(contestId);
      }
      _saveLikedContests();

      if (contest.value.meta != null) {
        contest.value.meta!.likes = newLikes.toString();
        contest.refresh();
      }

      // Make API call
      final uri = Uri.parse('$baseUrl/contests/$contestId/meta/update');
      final response = await http
          .put(
            uri,
            headers: _headers,
            body: json.encode({"key": "likes", "value": newLikes.toString()}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        // Revert on failure
        _revertLike(contestId, isCurrentlyLiked, currentLikes);
      }
    } on SocketException catch (_) {
      _revertLike(contestId, isCurrentlyLiked, currentLikes);
      _showSnackbar('Error', 'No internet connection', isError: true);
    } on TimeoutException catch (_) {
      _revertLike(contestId, isCurrentlyLiked, currentLikes);
      _showSnackbar('Error', 'Connection timeout', isError: true);
    } catch (e) {
      _revertLike(contestId, isCurrentlyLiked, currentLikes);
      _showSnackbar('Error', 'Failed to update like', isError: true);
    } finally {
      isLikeLoading.value = false;
    }
  }

  /// Revert like state on API failure
  void _revertLike(String contestId, bool wasLiked, int originalLikes) {
    if (wasLiked) {
      likedContestIds.add(contestId);
    } else {
      likedContestIds.remove(contestId);
    }
    _saveLikedContests();

    if (contest.value.meta != null) {
      contest.value.meta!.likes = originalLikes.toString();
      contest.refresh();
    }
  }

  Future<void> addComment(String description, {String? parentId}) async {
    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty) return;

    try {
      isCommentLoading.value = true;

      final uri = Uri.parse('$baseUrl/contests/comments/insert');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: json.encode({
              "contest_id": contest.value.id,
              "description": trimmedDescription,
              "parent_id": parentId,
              "user-id": _headers['user-id'],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackbar('Success', 'Comment added!', isError: false);

        // Parse response to get the new comment
        final responseData = json.decode(response.body);
        Comment? newComment;

        if (responseData['comment'] != null) {
          newComment = Comment.fromJson(responseData['comment']);
        } else {
          // Create optimistic comment if API doesn't return it
          newComment = _createOptimisticComment(trimmedDescription, parentId);
        }

        // Add comment to local list without full page refresh
        _addCommentToList(newComment, parentId);
      } else {
        _showSnackbar('Error', 'Failed to add comment', isError: true);
      }
    } on SocketException catch (_) {
      _showSnackbar('Error', 'No internet connection', isError: true);
    } on TimeoutException catch (_) {
      _showSnackbar('Error', 'Connection timeout', isError: true);
    } catch (e) {
      _showSnackbar('Error', 'Failed to add comment', isError: true);
    } finally {
      isCommentLoading.value = false;
    }
  }

  /// Creates an optimistic comment object for immediate UI update
  Comment _createOptimisticComment(String description, String? parentId) {
    String? currentUserFirstName;
    String? currentUserLastName;
    String? currentUserId;

    try {
      final authService = Get.find<AuthService>();
      currentUserId = authService.authCustomer?.user?.id;
      currentUserFirstName = authService.authCustomer?.user?.firstName ?? 'You';
      currentUserLastName = authService.authCustomer?.user?.lastName ?? '';
    } catch (e) {
      currentUserFirstName = 'You';
      currentUserLastName = '';
    }

    return Comment(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUserId ?? userId,
      contestId: contest.value.id,
      description: description,
      parentId: parentId,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      user: CommentUser(
        user: User(
          id: currentUserId ?? userId,
          firstName: currentUserFirstName,
          lastName: currentUserLastName,
        ),
      ),
      replies: [],
    );
  }

  /// Adds comment to local list and refreshes UI
  void _addCommentToList(Comment newComment, String? parentId) {
    // Initialize comments structure if null
    if (contest.value.comments == null) {
      contest.value.comments = CommentsData(
        comments: Comments(averageRating: 0, totalComments: 0, comments: []),
      );
    }

    if (contest.value.comments?.comments == null) {
      contest.value.comments!.comments = Comments(
        averageRating: 0,
        totalComments: 0,
        comments: [],
      );
    }

    if (contest.value.comments!.comments!.comments == null) {
      contest.value.comments!.comments!.comments = [];
    }

    if (parentId != null) {
      // Add as reply to existing comment
      _addReplyToComment(
        contest.value.comments!.comments!.comments!,
        parentId,
        newComment,
      );
    } else {
      // Add as new top-level comment at the beginning
      contest.value.comments!.comments!.comments!.insert(0, newComment);
    }

    // Update total count
    final currentTotal = contest.value.comments!.comments!.totalComments ?? 0;
    contest.value.comments!.comments!.totalComments = currentTotal + 1;

    // Refresh the observable to trigger UI update
    contest.refresh();
  }

  /// Recursively finds parent comment and adds reply
  bool _addReplyToComment(
    List<Comment> comments,
    String parentId,
    Comment reply,
  ) {
    for (var comment in comments) {
      if (comment.id == parentId) {
        comment.replies ??= [];
        comment.replies!.insert(0, reply);
        return true;
      }
      if (comment.replies != null && comment.replies!.isNotEmpty) {
        if (_addReplyToComment(comment.replies!, parentId, reply)) {
          return true;
        }
      }
    }
    return false;
  }

  void selectAnswer(String questionId, String answer) {
    userAnswers[questionId] = answer;
  }

  bool hasUserParticipated() {
    if (userId.isEmpty) return false;
    final participants = contest.value.participants?.participants ?? [];
    return participants.any((p) => p.userId == userId);
  }

  Participant? getUserParticipation() {
    if (userId.isEmpty) return null;
    final participants = contest.value.participants?.participants ?? [];
    try {
      return participants.firstWhere((p) => p.userId == userId);
    } catch (e) {
      return null;
    }
  }

  bool isContestExpired() {
    if (contest.value.endTime == null) return false;
    try {
      return DateTime.parse(contest.value.endTime!).isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool isContestActive() {
    final startTime = contest.value.startTime;
    final endTime = contest.value.endTime;
    if (startTime == null || endTime == null) return false;

    try {
      final now = DateTime.now();
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      return now.isAfter(start) && now.isBefore(end);
    } catch (e) {
      return false;
    }
  }

  Duration? getTimeRemaining() {
    if (contest.value.endTime == null) return null;
    try {
      final end = DateTime.parse(contest.value.endTime!);
      final now = DateTime.now();
      return end.isAfter(now) ? end.difference(now) : null;
    } catch (e) {
      return null;
    }
  }

  void _checkUserParticipation() {
    final userParticipation = getUserParticipation();
    if (userParticipation != null && userParticipation.answers != null) {
      try {
        final answers = json.decode(userParticipation.answers!) as List;
        for (var answer in answers) {
          if (answer['question_id'] != null && answer['given_answer'] != null) {
            userAnswers[answer['question_id']] = answer['given_answer'];
          }
        }
      } catch (e) {
        // Silently ignore parsing errors
      }
    }
  }

  void _setError(String message) {
    status.value = LoadingStatus.error;
    errorMessage.value = message;
  }

  void _showSnackbar(String title, String message, {required bool isError}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade600 : Colors.teal.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'X-Request-From': 'Website',
      'pragma': 'no-cache',
    };

    try {
      final token = Get.find<AuthService>().authCustomer?.user?.id ?? '';
      if (token.isNotEmpty) {
        headers['user-id'] = token;
      }
    } catch (e) {
      // Auth service not available
    }

    return headers;
  }

  void setSelectedModel(ContestModel? model) {
    selectedModel.value = model;
    if (model != null) {
      userAnswers.clear();
      error.value = '';
    }
    update();
  }

  void retryFetch() => fetchContests();

  String getFormattedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  void onClose() {
    userAnswers.clear();
    super.onClose();
  }
}
