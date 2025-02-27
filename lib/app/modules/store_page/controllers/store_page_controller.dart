// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/services/auth/apis.dart';

class StorePageController extends GetxController {
  ProductAttributeItems? selectedCategory;
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  int page = 2;
  var categories = CategoryModel(productAttributeItems: []).obs;
  var products =
      (ProductModel(products: Products(currentPage: 1, data: []))).obs;
  var categoryproducts =
      (ProductModel(products: Products(currentPage: 1, data: []))).obs;
  var filterCategoryproducts =
      (ProductModel(products: Products(currentPage: 1, data: []))).obs;
  late final BehaviorSubject<CategoryModel?> _categoriesCache;
  late final BehaviorSubject<ProductModel?> _productsCache;
  BehaviorSubject<CategoryModel?>? get categoriesSubject => _categoriesCache;
  BehaviorSubject<ProductModel?>? get productsSubject => _productsCache;

  @override
  void onInit() {
    _categoriesCache = BehaviorSubject.seeded(null);
    _productsCache = BehaviorSubject.seeded(null);
    if (Get.arguments == null) return;
    String? shopId = Get.arguments?['shopid'] as String?;

    if (shopId != null) {
      currentSHop = Get.arguments?['ShopShop'] as ShopShop?;
      initState(shopId);
    }
    super.onInit();
  }

  ShopShop? currentSHop = ShopShop();

  initState(String shopid) {
    fetchCategoryProduct(shopid);
    // scrollController.addListener(() {
    //   if (scrollController.position.pixels >=
    //       scrollController.position.maxScrollExtent - 0) {
    //     if (!isLoading) {
    //       // fetchCategoryProduct(shopid);
    //     }
    //   }
    // });
  }

  Future<void> fetchCategoryProduct(String shopId) async {
    fetchProducts(shopId);
  }

  Future<void> fetchProducts(String shopId) async {
    final ress = await CategoryApiService().fetchProductsOfShop(shopId: shopId);
    if (ress is Map<String, dynamic>) {
      products.value = ProductModel.fromJson(ress);

      for (var el in products.value.products?.data ?? <ProductDatum>[]) {
        if (el.thumbnail?.media?.url != null) {
          prefetchImage(el.thumbnail!.media!.url!);
        }
      }

      filterCategoryproducts.value = categoryproducts.value;
      update();
    } else {
      products.value =
          ProductModel(products: Products(currentPage: 1, data: []));
      filterCategoryproducts.value = products.value;
      update();
    }
  }

  void filterCategoryProductss(String sortBy) {
    filterCategoryproducts.value = categoryproducts.value;
    if (filterCategoryproducts.value.products?.data != null) {
      var productList = filterCategoryproducts.value.products!.data!
          .where((e) => e.price != null)
          .toList();
      if (sortBy == "Low to high (price)") {
        productList.sort((a, b) => a.price!.compareTo(b.price!));
      } else if (sortBy == "High to low (price)") {
        productList.sort((a, b) => b.price!.compareTo(a.price!));
      } else if (sortBy == "Featured Products") {
        productList = categoryproducts.value.products?.data
                ?.where((e) => e.isFeatured == 1)
                .toList() ??
            [];
      }
      filterCategoryproducts.value.products!.data = productList;
    }
    update();
  }

  setSelectedCategory(ProductAttributeItems val) {
    selectedCategory = val;
    update();
  }
}
