import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_promotion/controller/admin_promotion_controller.dart';

class AdminPromotionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminPromotionController>(() => AdminPromotionController());
  }
}
