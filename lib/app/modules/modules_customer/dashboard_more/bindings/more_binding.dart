import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_customer/dashboard_more/controllers/more_controller.dart';

class MoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoreController>(() => MoreController());
  }
}
