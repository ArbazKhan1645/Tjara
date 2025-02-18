import 'package:get/get.dart';

import '../controllers/product_detail_screen_controller.dart';

class ProductDetailScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductDetailScreenController>(
      () => ProductDetailScreenController(),
    );
  }
}
