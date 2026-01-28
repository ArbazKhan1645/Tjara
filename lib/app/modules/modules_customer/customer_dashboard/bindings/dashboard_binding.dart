import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
