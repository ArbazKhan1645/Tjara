import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';

class DashboardController extends GetxController {
  static DashboardController get instance => Get.find<DashboardController>();

  DateTime? lastPressed;

  RxInt selectedIndex = 0.obs;

  // Cart badge count
  final RxInt cartCount = 0.obs;
  // Wishlist badge count
  final RxInt wishlistCount = 0.obs;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Stream subscriptions for real-time updates
  StreamSubscription? _cartStreamSubscription;
  StreamSubscription? _wishlistStreamSubscription;

  void changeIndex(int index) {
    selectedIndex.value = index;

    update();
  }

  void reset() {
    selectedIndex.value = 0;
  }

  @override
  void onInit() {
    super.onInit();
    _safeFetchCartCount();
    _safeFetchWishlistCount();
    _setupRealtimeListeners();
  }

  /// Set up real-time listeners for cart and wishlist updates
  void _setupRealtimeListeners() {
    // Listen to cart stream for real-time cart count updates
    _cartStreamSubscription = _listenToCartStream();

    // Listen to wishlist updates for real-time wishlist count updates
    _wishlistStreamSubscription = _listenToWishlistUpdates();
  }

  /// Listen to cart stream and update cart count in real-time
  StreamSubscription _listenToCartStream() {
    try {
      if (Get.isRegistered<CartService>()) {
        final cartService = Get.find<CartService>();
        return cartService.cartStream.listen((cart) {
          // Calculate total items in cart
          int totalItems = 0;
          for (var cartItem in cart.cartItems) {
            totalItems += cartItem.items.length;
          }
          cartCount.value = totalItems;
          update();
        });
      }
    } catch (e) {
      print('Error setting up cart stream listener: $e');
    }
    return const Stream.empty().listen((_) {});
  }

  /// Listen to wishlist updates and refresh count in real-time
  StreamSubscription _listenToWishlistUpdates() {
    try {
      if (Get.isRegistered<WishlistServiceController>()) {
        final wishlistController = Get.find<WishlistServiceController>();
        return wishlistController.wishlistResponseStream.listen((wishlist) {
          // Update wishlist count based on current wishlist items
          wishlistCount.value = wishlist.wishlistItems?.length ?? 0;
          update();
        });
      }
    } catch (e) {
      print('Error setting up wishlist stream listener: $e');
    }
    return const Stream.empty().listen((_) {});
  }

  Future<void> _safeFetchCartCount() async {
    try {
      await fetchCartCount();
    } catch (_) {}
  }

  Future<void> fetchCartCount() async {
    try {
      final userId = AuthService.instance.authCustomer?.user?.id;
      if (userId == null || userId.isEmpty) {
        cartCount.value = 0;
        update();
        return;
      }

      final uri = Uri.parse('https://api.libanbuy.com/api/cart/count');
      final response = await http
          .get(
            uri,
            headers: {
              'X-Request-From': 'Application',
              'Content-Type': 'application/json',
              'user-id': userId,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            cartCount.value = (decoded['cartItemsCount'] as int? ?? 0);
          } else {
            cartCount.value = 0;
          }
        } catch (_) {
          cartCount.value = 0;
        }
      } else {
        cartCount.value = 0;
      }
      update();
    } catch (_) {
      cartCount.value = 0;
    } finally {
      update();
    }
  }

  Future<void> _safeFetchWishlistCount() async {
    try {
      await fetchWishlistCount();
    } catch (_) {}
  }

  Future<void> fetchWishlistCount() async {
    try {
      final userId = AuthService.instance.authCustomer?.user?.id;
      if (userId == null || userId.isEmpty) {
        wishlistCount.value = 0;
        update();
        return;
      }

      final uri = Uri.parse('https://api.libanbuy.com/api/wishlist/count');
      final response = await http
          .get(
            uri,
            headers: {
              'X-Request-From': 'Application',
              'Content-Type': 'application/json',
              'user-id': userId,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        int parsed = 0;
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            parsed =
                (decoded['wishlistCount'] ??
                        decoded['count'] ??
                        decoded['total'] ??
                        0)
                    as int? ??
                0;
          } else if (decoded is num) {
            parsed = decoded.toInt();
          }
        } catch (_) {}

        wishlistCount.value = parsed;
      } else {
        wishlistCount.value = 0;
      }
    } catch (_) {
      wishlistCount.value = 0;
    } finally {
      update();
    }
  }

  /// Manually refresh cart count (useful for immediate updates)
  Future<void> refreshCartCount() async {
    await fetchCartCount();
  }

  /// Manually refresh wishlist count (useful for immediate updates)
  Future<void> refreshWishlistCount() async {
    await fetchWishlistCount();
  }

  /// Refresh both counts
  Future<void> refreshAllCounts() async {
    await Future.wait([fetchCartCount(), fetchWishlistCount()]);
  }

  @override
  void onClose() {
    // Cancel stream subscriptions to prevent memory leaks
    _cartStreamSubscription?.cancel();
    _wishlistStreamSubscription?.cancel();
    super.onClose();
  }
}
