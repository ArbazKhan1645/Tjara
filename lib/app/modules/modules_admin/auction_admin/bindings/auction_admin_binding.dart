import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/auction_admin/controllers/auction_admin_controller.dart';

class AuctionAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuctionAdminController>(() => AuctionAdminController());
  }
}
