import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/dashboard_admin/controllers/dashboard_admin_controller.dart';

class DashboardAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
  }
}
