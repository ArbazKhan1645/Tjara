import 'package:get/get.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/resseller_programs_my/model.dart';
import 'package:tjara/app/modules/modules_admin/myshop/service.dart';
import 'package:tjara/app/modules/modules_admin/reseller_programs/service.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class BalanceService extends GetxService {
  static BalanceService get to => Get.find();
  Future<BalanceService> init() async {
    fetchShopData();
    fetchResellerProgram();
    return this;
  }

  final Rx<ShopShop?> shop = Rx<ShopShop?>(null);
  final ShopService _shopService = ShopService();
  final ResellerService _resellerService = ResellerService();
  var resellerProgram = Rxn<ResellerProgramModel>();
  final String shopId =
      AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '';

  Future<void> fetchShopData() async {
    try {
      final response = await _shopService.getShop(shopId);

      if (response != null) {
        shop.value = response;
      } else {
        throw Exception('Shop data not found');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchResellerProgram() async {
    try {
      final userId =
          AuthService.instance.authCustomer?.user?.id ??
          '121d6d13-a26f-49ff-8786-a3b203dc3068';
      // Using the user ID from the provided data
      // const userId = '121d6d13-a26f-49ff-8786-a3b203dc3068';

      final program = await _resellerService.getResellerProgram(userId);
      resellerProgram.value = program;

      // After getting the reseller program, fetch referral members
    } catch (e) {
      print(e);
    }
  }
}
