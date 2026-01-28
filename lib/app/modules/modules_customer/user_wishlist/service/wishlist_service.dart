// ignore_for_file: depend_on_referenced_packages, avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/models/wishlists/wishlist_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/wishlist/wishlist_service.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:http/http.dart' as http;

class WishlistServiceController extends GetxService {
  static WishlistServiceController get instance =>
      Get.find<WishlistServiceController>();

  // Add loading state
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Add data loaded flag
  final RxBool _isDataLoaded = false.obs;
  bool get isDataLoaded => _isDataLoaded.value;

  Future<WishlistServiceController> init() async {
    // await initCall();
    return this;
  }

  Future<void> initCall() async {
    _isLoading.value = true;
    final LoginResponse? userCurrent = AuthService.instance.authCustomer;

    if (userCurrent?.user?.id == null) {
      _wishlistResponse.value = WishlistResponse(wishlistItems: []);
      _isDataLoaded.value = true;
    } else {
      await getWishlist(userCurrent?.user?.id.toString() ?? '');
    }
    _isLoading.value = false;
  }

  final Rx<WishlistResponse> _wishlistResponse =
      WishlistResponse(wishlistItems: []).obs;
  WishlistResponse get wishlistResponse => _wishlistResponse.value;

  // Make the observable accessible for real-time updates
  Rx<WishlistResponse> get wishlistResponseStream => _wishlistResponse;

  Future getWishlist(String userId, {bool showLoading = false}) async {
    return fetchWishlist(userId, showLoading: showLoading);
  }

  Future<void> fetchWishlist(String userId, {bool showLoading = false}) async {
    if (showLoading) _isLoading.value = true;

    try {
      final WishlistResponse? wishlist = await WishlistService().fetchWishlist(
        userId,
      );
      print(wishlist?.wishlistItems?.length);
      if (wishlist != null) {
        _wishlistResponse.value = wishlist;
      } else {
        _wishlistResponse.value = WishlistResponse(wishlistItems: []);
      }
      _isDataLoaded.value = true;
    } catch (e) {
      print('Error fetching wishlist: $e');
      if (!_isDataLoaded.value) {
        _wishlistResponse.value = WishlistResponse(wishlistItems: []);
      }
    }

    if (showLoading) _isLoading.value = false;
  }

  // Method to refresh wishlist (call this when navigating to wishlist screen)
  Future<void> refreshWishlist() async {
    final LoginResponse? userCurrent = AuthService.instance.authCustomer;
    if (userCurrent?.user?.id != null) {
      await getWishlist(userCurrent!.user!.id.toString(), showLoading: false);
    }
  }

  Future<void> addToWishlist(String productId, BuildContext context) async {
    final LoginResponse? userCurrent = AuthService.instance.authCustomer;
    try {
      if (userCurrent?.user?.id == null) {
        return;
      }

      final res = await http.post(
        Uri.parse('https://api.libanbuy.com/api/wishlist/insert'),
        headers: {
          'user-id': userCurrent?.user?.id.toString() ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "X-Request-From": "Website",
        },
        body: jsonEncode({
          "user-id": userCurrent?.user?.id.toString() ?? '',
          "product_id": productId,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (context.mounted) {
          NotificationHelper.showSuccess(
            context,
            'Success',
            'Product Added to wishlist',
          );
        }
        // Refresh the wishlist after adding an item
        await fetchWishlist(userCurrent?.user?.id.toString() ?? '');
        // Trigger dashboard wishlist count update
        _updateDashboardWishlistCount();
      }
    } catch (e) {
      NotificationHelper.showError(
        context,
        'Failed',
        'Product Failed to wishlist',
      );
    }
  }

  Future<void> removeFromWishlist(
    String wishlistId,
    BuildContext context,
  ) async {
    final LoginResponse? userCurrent = AuthService.instance.authCustomer;
    try {
      if (userCurrent?.user?.id == null) {
        return;
      }

      final res = await http.delete(
        Uri.parse('https://api.libanbuy.com/api/wishlist/$wishlistId/delete'),
        headers: {
          'user-id': userCurrent?.user?.id.toString() ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "X-Request-From": "Website",
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (context.mounted) {
          NotificationHelper.showSuccess(
            context,
            'Success',
            'product removed from wishlist',
          );
        }
        // Refresh the wishlist after removing an item
        await fetchWishlist(userCurrent?.user?.id.toString() ?? '');
        // Trigger dashboard wishlist count update
        _updateDashboardWishlistCount();
      }
    } catch (e) {
      NotificationHelper.showError(
        context,
        'Failed',
        'Product Failed to remove from wishlist',
      );
    }
  }

  // Helper method to check if product is in wishlist
  bool isProductInWishlist(String productId) {
    return _wishlistResponse.value.wishlistItems?.any(
          (item) => item.product?.id.toString() == productId,
        ) ??
        false;
  }

  // Helper method to get wishlist item by product ID
  WishlistItem? getWishlistItemByProductId(String productId) {
    return _wishlistResponse.value.wishlistItems?.firstWhereOrNull(
      (item) => item.product?.id.toString() == productId,
    );
  }

  /// Helper method to update dashboard wishlist count
  void _updateDashboardWishlistCount() {
    try {
      if (Get.isRegistered<DashboardController>()) {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.refreshWishlistCount();
      }
    } catch (e) {
      print('Error updating dashboard wishlist count: $e');
    }
  }
}
