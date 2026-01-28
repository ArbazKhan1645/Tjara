import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_customer/order_checkout/controllers/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
