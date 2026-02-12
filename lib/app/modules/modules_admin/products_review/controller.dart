// controllers/product_review_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/products_review_model/products_review_model.dart';
import 'package:tjara/app/modules/modules_admin/products_review/service.dart';

enum ReviewLoadingState { initial, loading, loaded, error, loadingMore }

class ProductReviewController extends GetxController {
  // Observable variables
  final _loadingState = ReviewLoadingState.initial.obs;
  final _reviews = <ReviewData>[].obs;
  final _currentPage = 1.obs;
  final _totalPages = 1.obs;
  final _totalReviews = 0.obs;
  final _perPage = 15.obs;
  final _errorMessage = ''.obs;
  final _hasMoreData = true.obs;
  final _isDeleting = <String, bool>{}.obs;

  // Search and filter
  final _searchQuery = ''.obs;
  final _filteredReviews = <ReviewData>[].obs;
  final searchController = TextEditingController();

  // Getters
  ReviewLoadingState get loadingState => _loadingState.value;
  List<ReviewData> get reviews =>
      _filteredReviews.isNotEmpty ? _filteredReviews : _reviews;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalReviews => _totalReviews.value;
  int get perPage => _perPage.value;
  String get errorMessage => _errorMessage.value;
  bool get hasMoreData => _hasMoreData.value;
  bool get hasData => _reviews.isNotEmpty;
  bool get isLoading => _loadingState.value == ReviewLoadingState.loading;
  bool get isLoadingMore =>
      _loadingState.value == ReviewLoadingState.loadingMore;
  bool get hasError => _loadingState.value == ReviewLoadingState.error;
  String get searchQuery => _searchQuery.value;

  bool isDeleting(String reviewId) => _isDeleting[reviewId] ?? false;

  @override
  void onInit() {
    super.onInit();
    loadReviews();

    // Setup search listener
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    _searchQuery.value = searchController.text;
    _filterReviews();
  }

  void _filterReviews() {
    if (_searchQuery.value.isEmpty) {
      _filteredReviews.clear();
      return;
    }

    final query = _searchQuery.value.toLowerCase();
    _filteredReviews.value =
        _reviews.where((review) {
          final queryLower = query.toLowerCase();

          final userFirstName =
              review.user?.user.firstName?.toLowerCase() ?? '';
          final productName = review.product?.product.name?.toLowerCase() ?? '';
          final description = review.description.toLowerCase() ?? '';
          final userEmail = review.user?.user.email?.toLowerCase() ?? '';

          return userFirstName.contains(queryLower) ||
              productName.contains(queryLower) ||
              description.contains(queryLower) ||
              userEmail.contains(queryLower);
        }).toList();
  }

  Future<void> loadReviews({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _hasMoreData.value = true;
        _reviews.clear();
        _filteredReviews.clear();
      }

      _loadingState.value =
          refresh || _reviews.isEmpty
              ? ReviewLoadingState.loading
              : ReviewLoadingState.loadingMore;
      _errorMessage.value = '';

      final response = await ProductReviewService.getReviews(
        page: _currentPage.value,
        perPage: _perPage.value,
      );

      _updateReviewData(response.reviews);
      _loadingState.value = ReviewLoadingState.loaded;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _loadingState.value = ReviewLoadingState.error;

      // Show error snackbar
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _updateReviewData(Reviews reviewsData) {
    if (_currentPage.value == 1) {
      _reviews.value = reviewsData.data;
    } else {
      _reviews.addAll(reviewsData.data);
    }

    _totalPages.value = reviewsData.lastPage;
    _totalReviews.value = reviewsData.total;
    _hasMoreData.value = _currentPage.value < _totalPages.value;

    // Reapply filter if search is active
    if (_searchQuery.value.isNotEmpty) {
      _filterReviews();
    }
  }

  Future<void> loadMoreReviews() async {
    if (_hasMoreData.value && !isLoadingMore) {
      _currentPage.value++;
      await loadReviews();
    }
  }

  Future<void> refreshReviews() async {
    await loadReviews(refresh: true);
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      _isDeleting[reviewId] = true;
      update(['delete_$reviewId']);

      final success = await ProductReviewService.deleteReview(reviewId);

      if (success) {
        // Remove from local list
        _reviews.removeWhere((review) => review.id == reviewId);
        _filteredReviews.removeWhere((review) => review.id == reviewId);
        _totalReviews.value--;

        Get.snackbar(
          'Success',
          'Review deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar(
        'Error',
        'Failed to delete review: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isDeleting[reviewId] = false;
      update(['delete_$reviewId']);
    }
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery.value = '';
    _filterReviews();
  }

  MaterialColor getRatingColor() {
    return Colors.amber;
  }

  String getRatingStars(int rating) {
    String stars = '';
    for (int i = 0; i < rating; i++) {
      stars += '⭐';
    }
    return stars;
  }

  String getFormattedDate(String date) {
    return DateFormat('d MMMM, y').format(DateTime.parse(date));
  }

  void showDeleteConfirmation(ReviewData review) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Review'),
        content: Text(
          'Are you sure you want to delete "${review.description}"?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteReview(review.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
