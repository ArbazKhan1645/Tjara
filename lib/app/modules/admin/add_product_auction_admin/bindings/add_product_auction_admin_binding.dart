import 'package:get/get.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/admin/categories_admin/controllers/categories_admin_controller.dart';

class AuctionAddProductAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuctionAddProductAdminController>(() => AuctionAddProductAdminController());
    Get.lazyPut<CategoriesAdminController>(() => CategoriesAdminController());
  }
}


