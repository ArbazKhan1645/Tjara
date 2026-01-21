import 'package:get/get.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:tjara/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/wishlist/controllers/wishlist_service.dart';

class FlashDealBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController());
    }
    if (!Get.isRegistered<CartService>()) {
      Get.lazyPut<CartService>(() => CartService());
    }
    if (!Get.isRegistered<WishlistServiceController>()) {
      Get.lazyPut<WishlistServiceController>(() => WishlistServiceController());
    }
  }
}
