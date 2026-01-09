import 'package:get/get.dart';

import 'package:tjara/app/modules/my_account/controllers/my_account_controller.dart';

class MyAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyAccountController>(
      () => MyAccountController(),
    );
  }
}
