import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/core/utils/helpers/demo_products.dart';
import 'package:tjara/app/models/products/products_model.dart';

class AppService extends GetxService {
  static AppService get instance => Get.find<AppService>();

  /// Observable variables
  final RxBool isLoading = true.obs;
  final RxBool isInitialized = false.obs;
  final Rxn<ProductModel> productModel = Rxn<ProductModel>();
  final RxString errorMessage = ''.obs;

  static const String _initKey = 'app_initialized';

  /// Call this on app start
  Future<AppService> init() async {
    // await initializeApp();
    return this;
  }

  /// Initialization logic
  Future<void> initializeApp() async {
    isLoading.value = true;
    errorMessage.value = '';
    final prefs = await SharedPreferences.getInstance();
    final bool alreadyInitialized = prefs.getBool(_initKey) ?? false;
    final bool hasInternet = await _checkInternet();

    if (hasInternet) {
      try {
        final realData = await _fetchFromApi();
        productModel.value = realData;
        await prefs.setBool(_initKey, true);
        isInitialized.value = true;
      } catch (e) {
        if (!alreadyInitialized) {
          productModel.value = _loadDemoProducts();
        } else {
          errorMessage.value = 'Failed to load products.';
        }
      }
    } else {
      if (!alreadyInitialized) {
        productModel.value = _loadDemoProducts();
      } else {
        errorMessage.value = 'No internet and no cache available.';
      }
    }

    isLoading.value = false;
  }

  static Future<bool> _checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  static Future<ProductModel> _fetchFromApi() async {
    await Future.delayed(const Duration(seconds: 2));
    throw Exception("API call not implemented.");
    // return ProductModel.fromJson(apiResponse);
  }

  static ProductModel _loadDemoProducts() {
    return demoProducts;
  }
}
