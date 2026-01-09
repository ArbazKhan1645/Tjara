import 'package:get/get.dart';
import 'package:tjara/app/modules/admin/cars_admin/controllers/cars_admin_controller.dart';


class CarsAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CarsAdminController>(
          () => CarsAdminController(),
    );
  }
}


