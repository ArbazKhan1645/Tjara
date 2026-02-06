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

class AdminDashboardService extends GetxService {
  final String _apiUrl = 'https://api.libanbuy.com/api/orders';

  var orders = <Order>[].obs;
  var tempOrders = <Order>[].obs;
  final scrollController = ScrollController();

  RxBool isLoading = false.obs;
  RxBool secondaryIsLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxInt perPage = 10.obs;
  RxInt totalPages = 0.obs;

  Future<AdminDashboardService> init() async {
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
      if (current?.user?.id == null) return;

      final Map<String, String> queryParams = {
        /// 🔹 ORDER TYPE
        'ordersType': 'received-orders',

        /// 🔹 SEARCH
        'dateFilter': 'all',
        'search': '',
        'searchByBuyerName': '',
        'searchByPhoneNumber': '',

        /// 🔹 META FIELD FILTERS
        'filterByMetaFields[filterJoin]': 'AND',

        // is_testing IS_EMPTY
        'filterByMetaFields[fields][0][key]': 'is_testing',
        'filterByMetaFields[fields][0][value]': '1',
        'filterByMetaFields[fields][0][operator]': 'IS_EMPTY',

        // is_soft_deleted IS_EMPTY
        'filterByMetaFields[fields][1][key]': 'is_soft_deleted',
        'filterByMetaFields[fields][1][value]': '1',
        'filterByMetaFields[fields][1][operator]': 'IS_EMPTY',

        /// 🔹 RELATIONS
        'with': 'thumbnail,shop,order_items',
        'include_batch_info': 'true',

        /// 🔹 COLUMN FILTER JOIN
        'filterJoin': 'AND',

        /// 🔹 SORTING
        'orderBy': 'created_at',
        'order': 'desc',

        /// 🔹 PAGINATION
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      };

      /// 🔹 NON-ADMIN BUYER FILTER
      if (current!.user!.role != 'admin') {
        queryParams.addAll({
          'filterByColumns[columns][0][column]': 'buyer_id',
          'filterByColumns[columns][0][value]': current.user!.id!,
          'filterByColumns[columns][0][operator]': '=',
        });
      }

      final uri = Uri.parse(_apiUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      isLoading.value = false;
      hideLoaderDialog();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final ordersJson = data['orders'];

        /// 🔥 PAGINATION FIX
        currentPage.value = ordersJson['current_page'] ?? 1;
        perPage.value = ordersJson['per_page'] ?? 10;
        totalPages.value = ordersJson['last_page'] ?? 1;

        final List<Order> fetchedOrders =
            (ordersJson['data'] as List)
                .map((order) => Order.fromJson(order))
                .toList();

        orders.assignAll(fetchedOrders);
        _saveOrdersToCache(fetchedOrders);
      } else {
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
