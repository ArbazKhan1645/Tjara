import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/categories_admin/controllers/categories_admin_controller.dart';

class CategoriesAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesAdminController>(() => CategoriesAdminController());
  }
}
