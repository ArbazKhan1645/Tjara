import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';

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
