import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';

class MyCartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyCartController>(() => MyCartController());
  }
}
