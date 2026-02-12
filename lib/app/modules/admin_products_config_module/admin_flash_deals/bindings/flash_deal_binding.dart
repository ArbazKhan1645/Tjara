import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals/controller/flash_deal_controller.dart';

class FlashDealBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlashDealController>(() => FlashDealController());
  }
}
