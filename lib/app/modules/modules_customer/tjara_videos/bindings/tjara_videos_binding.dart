import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_customer/tjara_videos/controllers/tjara_videos_controller.dart';

class TjaraVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TjaraVideosController>(() => TjaraVideosController());
  }
}
