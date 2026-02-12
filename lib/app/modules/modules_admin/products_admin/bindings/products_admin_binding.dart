import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/controllers/products_admin_controller.dart';

class ProductsAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsAdminController>(() => ProductsAdminController());
  }
}
