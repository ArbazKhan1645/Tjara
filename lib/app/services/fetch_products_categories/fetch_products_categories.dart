import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/products/single_product_model.dart';
import 'package:tjara/app/services/auth/apis.dart';
import '../../models/categories/categories_model.dart';
import '../../repo/network_repository.dart';

class ProductService {
  static final ProductService instance = ProductService._internal();
  factory ProductService() => instance;
  ProductService._internal();

  final NetworkRepository _repository = NetworkRepository();

  Future<CategoryModel?> fetchCategories() async {
    try {
      final result = await _repository.fetchData<CategoryModel>(
        url:
            'https://api.tjara.com/api/product-attribute-items?hide_empty=True&limit=52&with=thumbnail,have_sub_categories&ids=',
        fromJson: (json) => CategoryModel.fromJson(json),
      );

      if (result.productAttributeItems == null) return null;

      // Prefetch images
      for (var el in result.productAttributeItems ?? []) {
        if (el.thumbnail?.media?.url != null) {
          prefetchImage(el.thumbnail!.media!.url!);
        }
      }

      // Cache data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cache_Categories', jsonEncode(result.toJson()));

      return result;
    } catch (e) {
      print("Error fetching categories: $e");
      return null;
    }
  }

  Future<ProductModel?> fetchProducts({int page = 1}) async {
    try {
      final url = 'https://api.tjara.com/api/products?page=$page';
      final result = await _repository.fetchData<ProductModel>(
        url: url,
        fromJson: (json) => ProductModel.fromJson(json),
      );

      // Cache data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cache_Products', jsonEncode(result.toJson()));

      return result;
    } catch (e) {
      print("Error fetching products: $e");
      return null;
    }
  }

  Future<ProductModel?> fetchCategoryProducts(String categoryId) async {
    try {
      final result =
          await CategoryApiService().fetchProducts(categoryId: categoryId);

      if (result is Map<String, dynamic>) {
        return ProductModel.fromJson(result);
      }

      return ProductModel(products: Products(currentPage: 1, data: []));
    } catch (e) {
      print("Error fetching category products: $e");
      return ProductModel(products: Products(currentPage: 1, data: []));
    }
  }

  Future<SingleModelClass?> fetchSingleProduct(String productId) async {
    final url = 'https://api.tjara.com/api/products/$productId';
    try {
      final res = await _repository.fetchData<SingleModelClass>(
          url: url, fromJson: (json) => SingleModelClass.fromJson(json));

      // Prefetch product images
      if (res.product?.gallery != null) {
        for (var ele in res.product!.gallery) {
          if (ele.media?.url != null) {
            prefetchImage(ele.media!.url);
          }
        }
      }

      return res;
    } catch (e) {
      return null;
    }
  }

  void prefetchImage(String url) {
    precacheImage(NetworkImage(url), Get.context!);
  }

  Future<CategoryModel?> getCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cache_Categories');
    if (cachedData != null) {
      return CategoryModel.fromJson(jsonDecode(cachedData));
    }
    return null;
  }

  Future<ProductModel?> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cache_Products');
    if (cachedData != null) {
      return ProductModel.fromJson(jsonDecode(cachedData));
    }
    return null;
  }
}
