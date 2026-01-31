// ignore_for_file: avoid_print, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/cart/cart_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';

class MyCartController extends GetxController {}

class CartService extends GetxService {
  static CartService get instance => Get.find<CartService>();

  Future<bool> isProductInCart(String productId) async {
    if (productId.isEmpty) return false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedCart = prefs.getString(_cartKey);
    if (cachedCart != null) {
      final CartModel cart = CartModel.fromJson(jsonDecode(cachedCart));
      if (cart.cartItems.isNotEmpty) {
        // Check through each cart item's items list for the product ID
        for (var cartItem in cart.cartItems) {
          // Check if any item in the items list has the matching productId
          if (cartItem.items.any((item) => item.productId == productId)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  Future<CartService> init() async {
    // initcall();
    return this;
  }

  Future<void> initcall() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final LoginResponse? usercurrent = AuthService.instance.authCustomer;
    if (usercurrent?.user?.id == null) {
      prefs.clear();
      _cartStreamController.add(CartModel(cartItems: []));
    } else {
      getCart(usercurrent?.user?.id.toString() ?? '');
    }
  }

  static const String _cartKey = 'cached_cart';
  final StreamController<CartModel> _cartStreamController =
      StreamController.broadcast();

  Stream<CartModel> get cartStream => _cartStreamController.stream;

  Future<CartModel> getCart(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedCart = prefs.getString(_cartKey);

    if (cachedCart != null) {
      final CartModel cart = CartModel.fromJson(jsonDecode(cachedCart));
      _cartStreamController.add(cart);
    }

    return _fetchAndCacheCart(userId);
  }

  Future<CartModel> _fetchAndCacheCart(String userId) async {
    try {
      print("🛒 [CART] Fetching cart for userId: $userId");

      final url = Uri.parse(
        'https://api.libanbuy.com/api/cart?_t=${DateTime.now().millisecondsSinceEpoch}&page=cart',
      );

      final headers = {
        'user-id': userId,
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
        "X-Request-From": "Website",
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          final CartModel cart = CartModel.fromJson(data);

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cartKey, jsonEncode(data));

          _cartStreamController.add(cart);

          return cart;
        } catch (jsonError) {
          print("❌ [CART] JSON parsing error: $jsonError");
        }
      } else {
        print(
          "❌ [CART] Failed request. Status: ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e, stack) {
      print("🔥 [CART] HTTP error while fetching cart: $e");
      print("🔥 [CART] Stacktrace: $stack");
    }

    print("⚠️ [CART] Returning empty cart due to error.");
    return CartModel(cartItems: []);
  }

  Future<dynamic> updateCart(
    String shopId,
    String productId,
    int quantity,
    double price, {
    String? variationId,
  }) async {
    try {
      final LoginResponse? usercurrent = AuthService.instance.authCustomer;
      if (usercurrent?.user?.id == null) {
        return false;
      }
      final Map<String, dynamic> requestBody = {
        "shop_id": shopId,
        "product_id": productId,
        "quantity": quantity,
      };
      // "price": price

      // Only add variation_id if it's not null and not empty
      if (variationId != null && variationId.isNotEmpty) {
        requestBody["variation_id"] = variationId;
      }

      final res = await http.post(
        Uri.parse('https://api.libanbuy.com/api/cart/add-to-cart'),
        headers: {
          'user-id': usercurrent?.user?.id.toString() ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "X-Request-From": "Application",
        },
        body: jsonEncode(requestBody),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await initcall();
        // Trigger dashboard cart count update
        _updateDashboardCartCount();
        return true;
      } else {
        final Map<String, dynamic> data = jsonDecode(res.body);
        // Extract message field safely
        final String message = data['message']?.toString() ?? "Unknown error";
        return message;
      }
    } on Exception {
      await initcall();
      return false;
    }
  }

  Future<void> deleteCart(String cartId, BuildContext context) async {
    try {
      final LoginResponse? usercurrent = AuthService.instance.authCustomer;
      if (usercurrent?.user?.id == null) {
        return;
      }
      final res = await http.delete(
        Uri.parse('https://api.libanbuy.com/api/cart/$cartId/delete'),
        headers: {
          'user-id': usercurrent?.user?.id.toString() ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "X-Request-From": "Application",
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        NotificationHelper.showSuccess(
          context,
          'Success',
          'Product Quantity Updated',
        );
      } else {
        NotificationHelper.showError(context, 'Failed', res.body.toString());
      }

      await initcall();
      // Trigger dashboard cart count update
      _updateDashboardCartCount();
    } on Exception {
      await initcall();
      // Trigger dashboard cart count update
      _updateDashboardCartCount();
    }
  }

  Future<void> updatecar(
    String cartId,
    int quantity,
    BuildContext context,
  ) async {
    try {
      final LoginResponse? usercurrent = AuthService.instance.authCustomer;
      if (usercurrent?.user?.id == null) {
        return;
      }
      final res = await http.put(
        Uri.parse('https://api.libanbuy.com/api/cart/$cartId/update'),
        headers: {
          'user-id': usercurrent?.user?.id.toString() ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "X-Request-From": "Application",
        },
        body: jsonEncode({"quantity": quantity}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        NotificationHelper.showSuccess(
          context,
          'Success',
          'Product Quantity Updated',
        );
      } else {
        NotificationHelper.showError(context, 'Failed', res.body.toString());
      }

      await initcall();
      // Trigger dashboard cart count update
      _updateDashboardCartCount();
    } on Exception {
      await initcall();
      // Trigger dashboard cart count update
      _updateDashboardCartCount();
    }
  }

  /// Helper method to update dashboard cart count
  void _updateDashboardCartCount() {
    try {
      if (Get.isRegistered<DashboardController>()) {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.refreshCartCount();
      }
    } catch (e) {
      print('Error updating dashboard cart count: $e');
    }
  }
}
