import 'package:get/get.dart';

import 'package:tjara/app/modules/store_page/controllers/store_page_controller.dart';

class StorePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorePageController>(
      () => StorePageController(),
    );
  }
}
