// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/locators/cache_images.dart';
import '../../../models/categories/categories_model.dart';
import '../../../models/products/products_model.dart';
import '../../../models/products/single_product_model.dart';
import '../../../repo/network_repository.dart';
import '../../../services/app/app_service.dart';

class HomeController extends GetxController {
  ProductAttributeItems? selectedCategory;

  final ScrollController scrollController = ScrollController();
  bool isLoading = false;
  int page = 2;
  var categories = CategoryModel(productAttributeItems: []).obs;
  var products =
      (ProductModel(products: Products(currentPage: 1, data: []))).obs;
  final AppService _appService = AppService.instance;
  final NetworkRepository _repository = NetworkRepository();
  late final BehaviorSubject<CategoryModel?> _categoriesCache;
  late final BehaviorSubject<ProductModel?> _productsCache;
  BehaviorSubject<CategoryModel?>? get categoriesSubject => _categoriesCache;
  BehaviorSubject<ProductModel?>? get productsSubject => _productsCache;

  setSelectedCategory(ProductAttributeItems val) {
    selectedCategory = val;
    update();
  }

  @override
  void onInit() {
    _categoriesCache = BehaviorSubject.seeded(null);
    _productsCache = BehaviorSubject.seeded(null);
    _initializeCategories();
    _initializeProducts();
    fetchCategories();
    fetchInitialProducts();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 0) {
        if (!isLoading) {
          fetchMoreProducts();
          print('loadinf');
        } else {
          print('loadinf2');
        }
      }
    });
    super.onInit();
  }

  void _initializeCategories() {
    final cachedData =
        _appService.sharedPreferences.getString('cache_Categories');
    if (cachedData != null) {
      final cachedCategories = CategoryModel.fromJson(jsonDecode(cachedData));
      _categoriesCache.add(cachedCategories);
      categories.value = cachedCategories;
      update();
    }
  }

  void _initializeProducts() {
    final productsData =
        _appService.sharedPreferences.getString('cache_Products');
    if (productsData != null) {
      final cachedProducts = ProductModel.fromJson(jsonDecode(productsData));
      _productsCache.add(cachedProducts);
      products.value = cachedProducts;
      update();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final result = await _repository.fetchData<CategoryModel>(
        url:
            'https://api.tjara.com/api/product-attribute-items?hide_empty=true&limit=52&with=thumbnail,have_sub_categories&ids=',
        fromJson: (json) => CategoryModel.fromJson(json),
      );

      if (result.productAttributeItems == null) return;
      final cachedItems = _categoriesCache.value?.productAttributeItems ?? [];
      final newItems = result.productAttributeItems!;
      final updatedItems = _mergeAndFilterCategories(cachedItems, newItems);
      final updatedModel = CategoryModel(productAttributeItems: updatedItems);
      _categoriesCache.add(updatedModel);
      categories.value = updatedModel;

      for (var el in categories.value.productAttributeItems ?? []) {
        if (el.thumbnail?.media?.url != null) {
          prefetchImage(el.thumbnail!.media!.url!);
        }
      }
      await _appService.sharedPreferences
          .setString('cache_Categories', jsonEncode(updatedModel.toJson()));
      update();
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  List<ProductAttributeItems> _mergeAndFilterCategories(
      List<ProductAttributeItems> cached,
      List<ProductAttributeItems> newItems) {
    final Map<String, ProductAttributeItems> mergedMap = {};

    for (var item in cached) {
      mergedMap[item.id.toString()] = item;
    }

    for (var item in newItems) {
      mergedMap[item.id.toString()] = item;
    }

    final filteredItems = mergedMap.entries
        .where((entry) => newItems.any((apiItem) => apiItem.id == entry.key))
        .map((entry) => entry.value)
        .toList();

    return filteredItems;
  }

  Future<void> fetchInitialProducts() async {
    final url = 'https://api.tjara.com/api/products';
    try {
      final result = await _repository.fetchData<ProductModel>(
          url: url, fromJson: (json) => ProductModel.fromJson(json));
      _productsCache.add(result);
      products.value = result;
      update();
      await _appService.sharedPreferences
          .setString('cache_Products', jsonEncode(result.toJson()));
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchMoreProducts() async {
    final url = 'https://api.tjara.com/api/products?page=$page';
    try {
      isLoading = true;
      final result = await _repository.fetchData<ProductModel>(
          url: url, fromJson: (json) => ProductModel.fromJson(json));
      _productsCache.add(result);
      products.value.products!.data!.addAll(result.products!.data ?? []);
      page = page + 1;
      isLoading = false;
      update();
      await _appService.sharedPreferences
          .setString('cache_Products', jsonEncode(result.toJson()));
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<SingleModelClass?> fetchSingleProducts(String productId) async {
    final url = 'https://api.tjara.com/api/products/$productId';
    try {
      final res = await _repository.fetchData<SingleModelClass>(
          url: url, fromJson: (json) => SingleModelClass.fromJson(json));
      return res;
    } catch (e) {
      rethrow;
    }
  }
}
