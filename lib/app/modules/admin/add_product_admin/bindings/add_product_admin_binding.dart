import 'package:get/get.dart';
import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/admin/categories_admin/controllers/categories_admin_controller.dart';

class AddProductAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductAdminController>(() => AddProductAdminController());
    Get.lazyPut<CategoriesAdminController>(() => CategoriesAdminController());
  }
}


