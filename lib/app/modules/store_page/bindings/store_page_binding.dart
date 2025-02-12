import 'package:get/get.dart';

import '../controllers/store_page_controller.dart';

class StorePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorePageController>(
      () => StorePageController(),
    );
  }
}
