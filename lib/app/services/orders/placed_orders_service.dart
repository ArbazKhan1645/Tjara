// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class PlacedOrderService extends GetxService {
  final String _baseApiUrl = 'https://api.libanbuy.com/api/orders';

  var orders = <Order>[].obs;
  var isLoading = false.obs;
  var hasMorePages = true.obs;
  var currentPage = 1.obs;
  var totalPages = 0.obs;
  var totalOrders = 0.obs;

  // Pagination settings
  final int perPage = 15;

  Future<PlacedOrderService> init() async {
    return this;
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://api.libanbuy.com/api/orders/$orderId/delete'),
        headers: {"X-Request-From": "Application"},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove the deleted order from the local list
        orders.removeWhere((order) => order.id.toString() == orderId);
        totalOrders.value = totalOrders.value - 1;
      } else {
        // Handle error response
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete order');
      }
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }

  /// Fetch orders with pagination
  /// [page] - Page number to fetch (default: 1)
  /// [refresh] - Whether to refresh the list (clear existing orders)
  Future<void> fetchOrders({
    int page = 1,
    bool refresh = false,
    String userId = '',
    Map<String, String>? queryOverrides,
  }) async {
    try {
      final LoginResponse? current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        return;
      }

      // Set loading state
      isLoading.value = true;

      // If refreshing, reset pagination state
      if (refresh) {
        currentPage.value = 1;
        orders.clear();
        hasMorePages.value = true;
        page = 1;
      }
      // Initialize query parameters
      // Base query parameters
      // Base query parameters
      final Map<String, String> queryParams;
      if (queryOverrides != null) {
        queryParams = Map<String, String>.from(queryOverrides);
        queryParams['per_page'] = perPage.toString();
        queryParams['page'] = page.toString();
      } else {
        queryParams = {
          'per_page': perPage.toString(),
          'page': page.toString(),
        };

        // Add filter if user is not admin
        queryParams.addAll({
          'filterByColumns[columns][0][column]': 'buyer_id',
          'filterByColumns[columns][0][value]': current!.user!.id!,
          'filterByColumns[columns][0][operator]': '=',
        });
      }

      // Construct final URI
      final uri = Uri.parse(_baseApiUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'X-Request-From': 'Application'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final ordersData = data['orders'];

        // Parse pagination metadata
        final int currentPageFromApi = ordersData['current_page'] ?? page;
        final int lastPage = ordersData['last_page'] ?? 1;
        final int total = ordersData['total'] ?? 0;

        // Parse orders
        final List<Order> fetchedOrders =
            (ordersData['data'] as List)
                .map((order) => Order.fromJson(order))
                .toList();

        // Update pagination state
        currentPage.value = currentPageFromApi;
        totalPages.value = lastPage;
        totalOrders.value = total;
        hasMorePages.value = currentPageFromApi < lastPage;

        // Add or replace orders
        if (refresh || page == 1) {
          orders.assignAll(fetchedOrders);
        } else {
          orders.addAll(fetchedOrders);
        }

        // Cache the orders (you might want to cache all pages or just the current one)
        if (page == 1) {
          _saveOrdersToCache(orders);
        }
      } else if (response.statusCode == 404) {
        orders.clear();
        hasMorePages.value = false;
        currentPage.value = 0;
        totalPages.value = 0;
        totalOrders.value = 0;
        throw Exception('No Orders Found for this account: ${response.body}');
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');

      // If this is the first page and we have an error, try to load from cache
      if (page == 1) {
        final cachedOrders = await _getOrdersFromCache();
        if (cachedOrders.isNotEmpty) {
          orders.assignAll(cachedOrders);
        }
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load next page of orders
  Future<void> loadNextPage() async {
    if (!hasMorePages.value || isLoading.value) {
      return;
    }

    await fetchOrders(page: currentPage.value + 1);
  }

  /// Refresh orders (load first page and clear existing)
  Future<void> refreshOrders() async {
    await fetchOrders(page: 1, refresh: true);
  }

  /// Load specific page
  Future<void> loadPage(int page) async {
    if (page < 1 || page > totalPages.value) {
      return;
    }

    await fetchOrders(page: page, refresh: page == 1);
  }

  Future<void> _saveOrdersToCache(List<Order> orders) async {
    try {} catch (e) {
      print('Error saving orders to cache: $e');
    }
  }

  Future<List<Order>> _getOrdersFromCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? orderStrings = prefs.getStringList('placed_orders');

      if (orderStrings != null) {
        // Restore pagination metadata
        totalOrders.value = prefs.getInt('placed_total_orders') ?? 0;
        currentPage.value = prefs.getInt('placed_current_page') ?? 1;
        totalPages.value = prefs.getInt('placed_total_pages') ?? 0;

        return orderStrings
            .map((orderString) => Order.fromJson(json.decode(orderString)))
            .toList();
      }
    } catch (e) {
      print('Error loading orders from cache: $e');
    }
    return [];
  }

  /// Reset pagination state
  void resetPagination() {
    currentPage.value = 1;
    totalPages.value = 0;
    totalOrders.value = 0;
    hasMorePages.value = true;
    orders.clear();
  }

  /// Get pagination info
  Map<String, dynamic> getPaginationInfo() {
    return {
      'currentPage': currentPage.value,
      'totalPages': totalPages.value,
      'totalOrders': totalOrders.value,
      'hasMorePages': hasMorePages.value,
      'ordersCount': orders.length,
      'perPage': perPage,
    };
  }
}
