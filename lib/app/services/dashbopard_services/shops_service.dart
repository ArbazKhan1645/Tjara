import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:tjara/app/core/dialogs/loading_dialog.dart';

import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/shops/shops_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class AdminShopsService extends GetxService {
  final String _apiUrl = 'https://api.libanbuy.com/api/shops';

  final productsModel = Rxn<ShopResponse>();
  final RxList<ShopShop>? adminProducts = <ShopShop>[].obs;

  var tempOrders = <Order>[].obs;
  final scrollController = ScrollController();

  RxBool isLoading = false.obs;
  RxBool secondaryIsLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxInt perPage = 10.obs;
  RxInt totalPages = 0.obs;

  Future<AdminShopsService> init() async {
    return this;
  }

  Future<void> fetchProducts({required bool loaderType}) async {
    if (currentPage.value == 1 && loaderType == true) {
      isLoading.value = true;
    } else if (loaderType == false) {
      showTopLoaderDialog();
    }

    try {
      final LoginResponse? current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        return;
      }

      final uri = Uri.parse(_apiUrl).replace(
        queryParameters: {
          'per_page': perPage.value.toString(),
          'page': currentPage.value.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {'X-Request-From': 'Application'},
      );

      // Check if response is successful before decoding
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load orders with status: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      // Validate required fields exist
      if (data['shops'] == null) {
        throw Exception('Products data is missing from response');
      }

      final products = ShopResponse.fromJson(data['shops']);
      productsModel.value = products;
      // Extract the product list from it and assign to adminProducts
      if (productsModel.value?.data != null) {
        adminProducts!.assignAll(productsModel.value!.data);
      }

      // Safely access nested data
      totalPages.value = data['shops']?['total'] ?? 0;

      _saveOrdersToCache(productsModel.value);
    } catch (e, stackTrace) {
      Logger().e('Error fetching products', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to load products: ${e.toString()}');
    } finally {
      isLoading.value = false;
      hideLoaderDialog();
    }
  }

  Future<void> _saveOrdersToCache(ShopResponse? products) async {}

  // page number for pagination ...
  List<int> visiblePageNumbers() {
    const int maxVisible = 5;
    final int current = currentPage.value;

    if (totalPages.value == 0) return []; // 👈 Prevent invalid range

    // Ensure start is at least 1
    int start = current - (maxVisible ~/ 2);
    if (start < 1) start = 1;

    // Calculate end and adjust start if needed
    int end = start + maxVisible - 1;
    if (end > totalPages.value) {
      end = totalPages.value;
      start = (end - maxVisible + 1).clamp(1, totalPages.value);
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
    fetchProducts(loaderType: false);
  }

  Future<void> nextPage() => goToPage(currentPage.value + 1);
  Future<void> previousPage() => goToPage(currentPage.value - 1);

  void hideLoaderDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<void> exportData({required BuildContext context}) async {}

  Future<void> saveCsv({required BuildContext context}) async {}
}
