import 'package:get/get.dart';

import 'package:tjara/app/modules/wishlist/controllers/wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WishlistController>(
      () => WishlistController(),
    );
  }
}
