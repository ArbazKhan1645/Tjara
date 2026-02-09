import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/surveys/model.dart';
import 'package:tjara/app/modules/modules_admin/admin/surveys/service.dart';
import 'package:tjara/main.dart';

class SurveyController extends GetxController {
  final SurveyService _service = SurveyService();

  // Observable lists
  final RxList<SurveyModel> surveys = <SurveyModel>[].obs;
  final Rx<PaginationMeta?> paginationMeta = Rx<PaginationMeta?>(null);

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSaving = false.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMorePages = true.obs;

  // Status options
  final List<String> statusOptions = ['all', 'draft', 'published', 'closed'];

  @override
  void onInit() {
    super.onInit();
    fetchSurveys();
  }

  /// Fetch surveys with filters
  Future<void> fetchSurveys({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      surveys.clear();
    }

    try {
      isLoading.value = true;

      final result = await _service.getSurveys(
        page: currentPage.value,
        perPage: 20,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        status:
            selectedStatus.value == 'all' || selectedStatus.value.isEmpty
                ? null
                : selectedStatus.value,
      );

      final fetchedSurveys = result['surveys'] as List<SurveyModel>;
      final meta = result['meta'] as PaginationMeta;

      if (isRefresh) {
        surveys.value = fetchedSurveys;
      } else {
        surveys.addAll(fetchedSurveys);
      }

      paginationMeta.value = meta;
      hasMorePages.value = meta.hasMorePages;
    } catch (e) {
      _showErrorSnackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more surveys (pagination)
  Future<void> loadMore() async {
    if (!hasMorePages.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;
      await fetchSurveys();
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Search surveys
  void searchSurveys(String query) {
    searchQuery.value = query;
    fetchSurveys(isRefresh: true);
  }

  /// Filter by status
  void filterByStatus(String status) {
    selectedStatus.value = status;
    fetchSurveys(isRefresh: true);
  }

  /// Refresh surveys
  Future<void> refreshSurveys() async {
    await fetchSurveys(isRefresh: true);
  }

  /// Create survey
  Future<bool> createSurvey({
    required String shopId,
    required String title,
    required String titleAr,
    required String description,
    required String descriptionAr,
    File? thumbnailFile,
    DateTime? startTime,
    DateTime? endTime,
    bool isFeatured = false,
    bool allowMultipleSubmissions = false,
    bool showResultsAfterSubmit = false,
    String thankYouMessage = '',
    String thankYouMessageAr = '',
    List<QuestionModel> questions = const [],
    String status = 'draft',
  }) async {
    try {
      isSaving.value = true;

      String? thumbnailId;
      if (thumbnailFile != null) {
        thumbnailId = await uploadMedia([thumbnailFile]);
        if (thumbnailId.isEmpty) {
          throw Exception('Failed to upload thumbnail');
        }
      }

      final surveyData = {
        'shop_id': shopId,
        'title': title,
        'title_ar': titleAr,
        'description': description,
        'description_ar': descriptionAr,
        'status': status,
        if (startTime != null) 'start_time': startTime.toIso8601String(),
        if (endTime != null) 'end_time': endTime.toIso8601String(),
        'is_featured': isFeatured,
        'allow_multiple_submissions': allowMultipleSubmissions,
        'show_results_after_submit': showResultsAfterSubmit,
        'thank_you_message': thankYouMessage,
        'thank_you_message_ar': thankYouMessageAr,
        if (thumbnailId != null) 'thumbnail_id': thumbnailId,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

      final success = await _service.createSurvey(surveyData);

      if (success) {
        await fetchSurveys(isRefresh: true);
        Get.back();
        _showSuccessSnackbar('Success', 'Survey created successfully');
        return true;
      }
      return false;
    } catch (e) {
      _showErrorSnackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update survey
  Future<bool> updateSurvey({
    required String surveyId,
    required String shopId,
    required String title,
    required String titleAr,
    required String description,
    required String descriptionAr,
    File? thumbnailFile,
    String? existingThumbnailId,
    DateTime? startTime,
    DateTime? endTime,
    bool isFeatured = false,
    bool allowMultipleSubmissions = false,
    bool showResultsAfterSubmit = false,
    String thankYouMessage = '',
    String thankYouMessageAr = '',
    List<QuestionModel> questions = const [],
    String status = 'draft',
  }) async {
    try {
      isSaving.value = true;

      String? thumbnailId = existingThumbnailId;
      if (thumbnailFile != null) {
        thumbnailId = await uploadMedia([thumbnailFile]);
        if (thumbnailId.isEmpty) {
          throw Exception('Failed to upload thumbnail');
        }
      }

      final surveyData = {
        'shop_id': shopId,
        'title': title,
        'title_ar': titleAr,
        'description': description,
        'description_ar': descriptionAr,
        'status': status,
        if (startTime != null) 'start_time': startTime.toIso8601String(),
        if (endTime != null) 'end_time': endTime.toIso8601String(),
        'is_featured': isFeatured,
        'allow_multiple_submissions': allowMultipleSubmissions,
        'show_results_after_submit': showResultsAfterSubmit,
        'thank_you_message': thankYouMessage,
        'thank_you_message_ar': thankYouMessageAr,
        if (thumbnailId != null) 'thumbnail_id': thumbnailId,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

      final success = await _service.updateSurvey(surveyId, surveyData);

      if (success) {
        await fetchSurveys(isRefresh: true);
        Get.back();
        _showSuccessSnackbar('Success', 'Survey updated successfully');

        return true;
      } else {
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete survey
  Future<void> deleteSurvey(String surveyId, String title) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$title"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _service.deleteSurvey(surveyId);
        if (success) {
          _showSuccessSnackbar('Success', 'Survey deleted successfully');
          await fetchSurveys(isRefresh: true);
        }
      } catch (e) {
        _showErrorSnackbar('Error', e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        backgroundColor: const Color(0xFF009688),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
        isDismissible: true,
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 4),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
        isDismissible: true,
      ),
    );
  }
}
