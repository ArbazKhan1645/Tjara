import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
