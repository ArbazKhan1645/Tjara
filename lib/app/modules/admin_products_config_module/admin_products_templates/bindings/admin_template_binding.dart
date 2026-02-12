import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_templates/controller/admin_template_controller.dart';

class AdminTemplateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminTemplateController>(() => AdminTemplateController());
  }
}
