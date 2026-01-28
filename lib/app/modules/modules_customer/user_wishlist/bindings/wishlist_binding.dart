import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_customer/user_wishlist/controllers/wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WishlistController>(() => WishlistController());
  }
}
