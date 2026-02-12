import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/wishlists/wishlist_model.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';

class WishlistController extends GetxController {
  WishlistResponse wishlistResponse = WishlistResponse();
  final WishlistServiceController wishlistController = Get.put(
    WishlistServiceController(),
  );
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    wishlistController.init();
    wishlistController.initCall();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
