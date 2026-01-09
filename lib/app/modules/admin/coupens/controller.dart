// controllers/coupon_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/coupens/coupens_model.dart';
import 'package:tjara/app/modules/admin/coupens/service.dart';

class CouponController extends GetxController {
  // Observable variables
  final RxList<Coupon> coupons = <Coupon>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasReachedEnd = false.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalCoupons = 0.obs;
  final RxInt perPage = 10.obs;

  // Search and filter variables
  final RxString searchQuery = ''.obs;
  final RxString searchById = ''.obs;
  final RxString orderBy = 'created_at'.obs;
  final RxString order = 'desc'.obs;

  // Text controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController searchByIdController = TextEditingController();

  // Scroll controller for pagination
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
    _setupScrollListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchByIdController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (!isLoadingMore.value && !hasReachedEnd.value) {
          loadMoreCoupons();
        }
      }
    });
  }

  Future<void> fetchCoupons({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasReachedEnd.value = false;
        coupons.clear();
      }

      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await CouponService.getCoupons(
        search: searchQuery.value,
        searchById: searchById.value,
        orderBy: orderBy.value,
        order: order.value,
        page: currentPage.value,
        perPage: perPage.value,
      );

      if (response.success) {
        totalPages.value = response.coupons.lastPage;
        totalCoupons.value = response.coupons.total;

        if (refresh) {
          coupons.assignAll(response.coupons.data);
        } else {
          coupons.addAll(response.coupons.data);
        }

        if (currentPage.value >= totalPages.value) {
          hasReachedEnd.value = true;
        }
      } else {
        throw Exception('Failed to fetch coupons');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = _getErrorMessage(e);
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreCoupons() async {
    if (hasReachedEnd.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await CouponService.getCoupons(
        search: searchQuery.value,
        searchById: searchById.value,
        orderBy: orderBy.value,
        order: order.value,
        page: currentPage.value,
        perPage: perPage.value,
      );

      if (response.success) {
        if (response.coupons.data.isEmpty) {
          hasReachedEnd.value = true;
        } else {
          coupons.addAll(response.coupons.data);
          if (currentPage.value >= response.coupons.lastPage) {
            hasReachedEnd.value = true;
          }
        }
      }
    } catch (e) {
      currentPage.value--; // Revert page increment on error
      _showErrorSnackbar(_getErrorMessage(e));
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshCoupons() async {
    await fetchCoupons(refresh: true);
  }

  Future<void> searchCoupons(String query) async {
    searchQuery.value = query;
    await fetchCoupons(refresh: true);
  }

  Future<void> searchCouponsById(String id) async {
    searchById.value = id;
    await fetchCoupons(refresh: true);
  }

  void clearSearch() {
    searchController.clear();
    searchByIdController.clear();
    searchQuery.value = '';
    searchById.value = '';
    fetchCoupons(refresh: true);
  }

  Future<void> deleteCoupon(String couponId) async {
    try {
      // Show confirmation dialog
      final confirmed = await _showDeleteConfirmationDialog();
      if (!confirmed) return;

      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await CouponService.deleteCoupon(couponId);

      // Close loading dialog
      Get.back();

      if (success) {
        // Remove coupon from local list
        coupons.removeWhere((coupon) => coupon.id == couponId);
        totalCoupons.value--;

        _showSuccessSnackbar('Coupon deleted successfully');

        // Refresh if list is empty or needs updating
        if (coupons.isEmpty && currentPage.value > 1) {
          currentPage.value--;
          await fetchCoupons();
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      _showErrorSnackbar(_getErrorMessage(e));
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Coupon'),
            content: const Text(
              'Are you sure you want to delete this coupon? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void changeItemsPerPage(int newPerPage) {
    perPage.value = newPerPage;
    fetchCoupons(refresh: true);
  }

  void changeSortOrder(String newOrderBy, String newOrder) {
    orderBy.value = newOrderBy;
    order.value = newOrder;
    fetchCoupons(refresh: true);
  }

  String _getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return 'Network error. Please check your internet connection.';
    } else if (error is UnauthorizedException) {
      return 'You are not authorized to perform this action.';
    } else if (error is ForbiddenException) {
      return 'Access forbidden. You don\'t have permission.';
    } else if (error is NotFoundException) {
      return 'The requested resource was not found.';
    } else if (error is ServerException) {
      return 'Server error occurred. Please try again later.';
    } else if (error is ValidationException) {
      return 'Validation error: ${error.message}';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  // Utility methods for status and type formatting
  String getStatusText(Coupon coupon) {
    if (coupon.isExpired) {
      return 'Expired';
    } else if (coupon.isActiveNow) {
      return 'Active';
    } else {
      return coupon.status.toUpperCase();
    }
  }

  Color getStatusColor(Coupon coupon) {
    if (coupon.isExpired) {
      return Colors.red;
    } else if (coupon.isActiveNow) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  String getDiscountText(Coupon coupon) {
    if (coupon.discountType == 'percentage') {
      return '${coupon.discountValue}%';
    } else {
      return '\$${coupon.discountValue}';
    }
  }

  String getValidityPeriod(Coupon coupon) {
    final startDate = coupon.startDate;
    final endDate = coupon.expiryDate;
    return '${formatDate(startDate)} - ${formatDate(endDate)}';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
