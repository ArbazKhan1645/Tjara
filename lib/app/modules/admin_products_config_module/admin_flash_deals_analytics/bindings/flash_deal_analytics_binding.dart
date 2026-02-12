import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals_analytics/controller/flash_deal_analytics_controller.dart';

class FlashDealAnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlashDealAnalyticsController>(
      () => FlashDealAnalyticsController(),
    );
  }
}
