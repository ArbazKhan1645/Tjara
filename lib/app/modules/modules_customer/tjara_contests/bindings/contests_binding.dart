import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_customer/tjara_contests/controllers/contests_controller.dart';

class ContestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContestController>(() => ContestController());
  }
}
