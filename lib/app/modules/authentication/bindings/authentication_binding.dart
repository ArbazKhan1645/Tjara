import 'package:get/get.dart';

import 'package:tjara/app/modules/authentication/controllers/authentication_controller.dart';

class AuthenticationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthenticationController>(() => AuthenticationController());
  }
}
