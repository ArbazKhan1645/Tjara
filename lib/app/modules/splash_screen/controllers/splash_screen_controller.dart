import 'dart:convert';

import 'package:get/get.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/repo/network_repository.dart';
import 'package:tjara/app/services/app/app_service.dart';

class SplashScreenController extends GetxController {
  final AppService _appService = AppService.instance;
  final NetworkRepository _repository = NetworkRepository();
  final DataService _dataService = DataService.instance;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchCategories();
    await fetchInitialProducts();
    Get.offAllNamed('/home');
  }

  Future<void> fetchCategories() async {
    try {
      final result = await _repository.fetchData<CategoryModel>(
        url:
            'https://api.tjara.com/api/product-attribute-items?hide_empty=True&limit=52&with=thumbnail,have_sub_categories&ids=',
        fromJson: (json) => CategoryModel.fromJson(json),
      );

      if (result.productAttributeItems == null) return;
      _dataService.categories = result;

      await _appService.sharedPreferences
          .setString('cache_Categories', jsonEncode(result.toJson()));

      // Prefetch category images
      for (var el in result.productAttributeItems ?? []) {
        if (el.thumbnail?.media?.url != null) {
          prefetchImage(el.thumbnail!.media!.url!);
        }
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchInitialProducts() async {
    try {
      final result = await _repository.fetchData<ProductModel>(
        url: 'https://api.tjara.com/api/products',
        fromJson: (json) => ProductModel.fromJson(json),
      );

      _dataService.products = result;

      // Cache to SharedPreferences
      await _appService.sharedPreferences
          .setString('cache_Products', jsonEncode(result.toJson()));
    } catch (e) {
      print("Error fetching products: $e");
    }
  }
}

class DataService {
  static final DataService instance = DataService._internal();
  DataService._internal();

  CategoryModel? categories;
  ProductModel? products;
}
