import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_customer/product_detail_screen/controllers/product_detail_screen_controller.dart';

class ProductDetailScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductDetailScreenController>(
      () => ProductDetailScreenController(),
    );
  }
}
