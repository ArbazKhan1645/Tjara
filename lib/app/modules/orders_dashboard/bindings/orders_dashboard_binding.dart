import 'package:get/get.dart';

import 'package:tjara/app/modules/orders_dashboard/controllers/orders_dashboard_controller.dart';

class OrdersDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersDashboardController>(
      () => OrdersDashboardController(),
    );
  }
}
