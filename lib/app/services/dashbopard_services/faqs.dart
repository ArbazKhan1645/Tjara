// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/core/dialogs/loading_dialog.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class AdminDashboardFaqsService extends GetxService {
  final String _apiUrl = 'https://api.libanbuy.com/api/faqs';

  var orders = <Order>[].obs;
  var tempOrders = <Order>[].obs;
  final scrollController = ScrollController();

  RxBool isLoading = false.obs;
  RxBool secondaryIsLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxInt perPage = 10.obs;
  RxInt totalPages = 0.obs;

  Future<AdminDashboardFaqsService> init() async {
    return this;
  }

  Future<void> fetchOrders({required bool loaderType}) async {
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
      // final log = Logger();
      // final data = jsonDecode(response.body);

      // log.d(data['orders']['data'][0]);
      // log.d("Another Test ====");
      isLoading.value = false;
      hideLoaderDialog();

      // final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        totalPages.value = data['orders']['total'] ?? 0;

        final List<Order> fetchedOrders =
            (data['orders']['data'] as List)
                .map((order) => Order.fromJson(order))
                .toList();
        orders.assignAll(fetchedOrders);
        _saveOrdersToCache(fetchedOrders);
      } else {
        isLoading.value = false;
        hideLoaderDialog();
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      isLoading.value = false;
      hideLoaderDialog();
      final cachedOrders = await _getOrdersFromCache();
      if (cachedOrders.isNotEmpty) {
        orders.assignAll(cachedOrders);
      }
    }
  }

  Future<void> _saveOrdersToCache(List<Order> orders) async {
    // SharedPreferences _prefs = await SharedPreferences.getInstance();
    // final List<String> orderStrings =
    //     orders.map((order) => json.encode(order.toJson())).toList();
    // await _prefs.setStringList('orders', orderStrings);
  }

  Future<List<Order>> _getOrdersFromCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? orderStrings = prefs.getStringList('orders');
    if (orderStrings != null) {
      return orderStrings
          .map((orderString) => Order.fromJson(json.decode(orderString)))
          .toList();
    }
    return [];
  }

  // page number for pagination ...
  List<int> visiblePageNumbers() {
    const int maxVisible = 5;
    final int current = currentPage.value;

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
    fetchOrders(loaderType: false);
  }

  Future<void> nextPage() => goToPage(currentPage.value + 1);
  Future<void> previousPage() => goToPage(currentPage.value - 1);

  void hideLoaderDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
