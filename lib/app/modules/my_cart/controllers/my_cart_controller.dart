// ignore_for_file: avoid_print

import 'dart:async';

import 'package:get/get.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/models/cart/cart_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class MyCartController extends GetxController {
  // Future<CartModel> getCart(String userId) async {
  //   const String url = 'https://api.tjara.com/api/cart';

  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {'user-id': userId},
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       CartModel cart = CartModel.fromJson(data);
  //       return cart;
  //     } else if (response.statusCode == 404) {
  //       print('Cart not found. Check the API endpoint.');
  //     } else {
  //       print('Error: ${response.statusCode}, ${response.body}');
  //     }
  //   } catch (e) {
  //     print('HTTP error: $e');
  //   }
  // }

  // CartService cartService = CartService();

  // @override
  // void onInit() {

  //   super.onInit();
  // }
}

class CartService extends GetxService {
  static CartService get instance => Get.find<CartService>();
  Future<CartService> init() async {
    initcall();
    return this;
  }

  initcall() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LoginResponse? usercurrent = AuthService.instance.authCustomer;
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
    print('object is $userId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedCart = prefs.getString(_cartKey);
    print('object is $cachedCart');
    if (cachedCart != null) {
      CartModel cart = CartModel.fromJson(jsonDecode(cachedCart));
      _cartStreamController.add(cart);
    }

    return _fetchAndCacheCart(userId);
  }

  Future<CartModel> _fetchAndCacheCart(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.tjara.com/api/cart'),
        headers: {'user-id': userId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        CartModel cart = CartModel.fromJson(data);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(_cartKey, jsonEncode(data));
        _cartStreamController.add(cart);

        return cart;
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('HTTP errorsssss: $e');
    }

    return CartModel(cartItems: []);
  }

  Future<void> updateCart(
      String shopId, String productId, int quantity, double price) async {
    try {
      LoginResponse? usercurrent = AuthService.instance.authCustomer;
      if (usercurrent?.user?.id == null) {
        return;
      }
      var res = await http.post(
        Uri.parse('https://api.tjara.com/api/cart/add-to-cart'),
        headers: {
          'user-id': usercurrent?.user?.id.toString() ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "shop_id": shopId,
          "product_id": productId,
          "quantity": quantity,
          "price": price ?? 0
        }),
      );
      print("Status Code: ${res.statusCode}");
      print("Response Headers: ${res.headers}");
      print("Response Body: ${res.body}");

      await initcall();
    } on Exception catch (e) {
      await initcall();
    }
  }

  Future<void> deleteCart(cartId) async {
    try {
      LoginResponse? usercurrent = AuthService.instance.authCustomer;
      if (usercurrent?.user?.id == null) {
        return;
      }
      var res = await http.delete(
        Uri.parse('https://api.tjara.com/api/cart/$cartId/delete'),
        headers: {
          'user-id': usercurrent?.user?.id.toString() ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print("Status Code: ${res.statusCode}");
      print("Response Headers: ${res.headers}");
      print("Response Body: ${res.body}");

      await initcall();
    } on Exception catch (e) {
      await initcall();
    }
  }

  Future<void> updatecar(cartId, int quantity) async {
    try {
      LoginResponse? usercurrent = AuthService.instance.authCustomer;
      if (usercurrent?.user?.id == null) {
        return;
      }
      var res = await http.put(
        Uri.parse('https://api.tjara.com/api/cart/$cartId/update'),
        headers: {
          'user-id': usercurrent?.user?.id.toString() ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"quantity": quantity}),
      );
      print("Status Code: ${res.statusCode}");
      print("Response Headers: ${res.headers}");
      print("Response Body: ${res.body}");

      await initcall();
    } on Exception catch (e) {
      await initcall();
    }
  }
}
