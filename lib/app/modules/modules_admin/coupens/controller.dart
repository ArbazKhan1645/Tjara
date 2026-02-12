// controllers/coupon_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/coupens/coupens_model.dart';
import 'package:tjara/app/modules/modules_admin/coupens/add_coupen.dart';
import 'package:tjara/app/modules/modules_admin/coupens/edit_controller.dart';
import 'package:tjara/app/modules/modules_admin/coupens/service.dart';

class CouponController extends GetxController {
  final RxList<Coupon> coupons = <Coupon>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasReachedEnd = false.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalCoupons = 0.obs;
  final RxInt perPage = 10.obs;

  final RxString searchQuery = ''.obs;
  final RxString searchById = ''.obs;
  final RxString orderBy = 'created_at'.obs;
  final RxString order = 'desc'.obs;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController searchByIdController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchByIdController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchCoupons({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasReachedEnd.value = false;
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
        coupons.assignAll(response.coupons.data);

        if (currentPage.value >= totalPages.value) {
          hasReachedEnd.value = true;
        }
      } else {
        throw Exception('Failed to fetch coupons');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = _getErrorMessage(e);
    } finally {
      isLoading.value = false;
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

  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;
    currentPage.value = page;
    fetchCoupons();
  }

  Future<void> deleteCoupon(String couponId) async {
    try {
      final confirmed = await _showDeleteConfirmationDialog();
      if (!confirmed) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.teal)),
        barrierDismissible: false,
      );

      final success = await CouponService.deleteCoupon(couponId);

      Get.back();

      if (success) {
        coupons.removeWhere((coupon) => coupon.id == couponId);
        totalCoupons.value--;

        _showSuccessSnackbar('Coupon deleted successfully');

        if (coupons.isEmpty && currentPage.value > 1) {
          currentPage.value--;
          await fetchCoupons();
        }
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      _showErrorSnackbar(_getErrorMessage(e));
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Delete Coupon',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to delete this coupon? This action cannot be undone.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void navigateToAddCoupon() async {
    Get.delete<EditCouponController>(force: true);
    final result = await Get.to(() => AddCouponPage());
    if (result == true) {
      fetchCoupons(refresh: true);
    }
  }

  void navigateToEditCoupon(Coupon coupon) async {
    Get.delete<EditCouponController>(force: true);
    final result = await Get.to(() => AddCouponPage(), arguments: coupon);
    if (result == true) {
      fetchCoupons(refresh: true);
    }
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
      return const Color(0xFFEF4444);
    } else if (coupon.isActiveNow) {
      return const Color(0xFF22C55E);
    } else {
      return const Color(0xFFF59E0B);
    }
  }

  IconData getStatusIcon(Coupon coupon) {
    if (coupon.isExpired) {
      return Icons.cancel_outlined;
    } else if (coupon.isActiveNow) {
      return Icons.check_circle_outline;
    } else {
      return Icons.schedule;
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
    return '${formatDate(coupon.startDate)} - ${formatDate(coupon.expiryDate)}';
  }

  String formatDate(DateTime date) {
    const months = [
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
  }
}
