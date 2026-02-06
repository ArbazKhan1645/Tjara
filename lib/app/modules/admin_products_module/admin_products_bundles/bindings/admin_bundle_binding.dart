import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_bundles/controller/admin_bundle_controller.dart';

class AdminBundleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminBundleController>(() => AdminBundleController());
  }
}
