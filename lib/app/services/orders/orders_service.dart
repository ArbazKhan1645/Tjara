// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class OrderService extends GetxService {
  final String _baseApiUrl = 'https://api.libanbuy.com/api/orders';

  var orders = <Order>[].obs;
  var isLoading = false.obs;
  var hasMorePages = true.obs;
  var currentPage = 1.obs;
  var totalPages = 0.obs;
  var totalOrders = 0.obs;

  // Pagination settings
  final int perPage = 10;

  // Request debouncing and caching
  Timer? _debounceTimer;
  Completer<void>? _loadingCompleter;
  final Map<int, List<Order>> _pageCache = {};
  String? _lastUserId;
  bool _isUserSpecific = false;

  Future<OrderService> init() async {
    return this;
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://api.libanbuy.com/api/orders/$orderId/delete'),
        headers: {"X-Request-From": "Application"},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        orders.removeWhere((order) => order.id.toString() == orderId);
        totalOrders.value = totalOrders.value - 1;
        _pageCache.clear();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete order');
      }
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }

  /// Fetch orders with detailed logging
  Future<void> fetchOrders({
    int page = 1,
    bool refresh = false,
    String userId = '',
    Map<String, String>? queryOverrides,
  }) async {
    if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
      return _loadingCompleter!.future;
    }

    _loadingCompleter = Completer<void>();

    try {
      final LoginResponse? current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        _loadingCompleter!.complete();
        return;
      }

      // Clear cache if user context changed
      if (_lastUserId != userId) {
        _pageCache.clear();
        _lastUserId = userId;
        _isUserSpecific = userId.isNotEmpty;
      }

      if (!refresh && _pageCache.containsKey(page)) {
        final cachedOrders = _pageCache[page]!;
        if (page == 1) {
          orders.assignAll(cachedOrders);
        } else {
          final existingIds = orders.map((o) => o.id).toSet();
          final newOrders =
              cachedOrders.where((o) => !existingIds.contains(o.id)).toList();
          orders.addAll(newOrders);
        }
        _loadingCompleter!.complete();
        return;
      }

      isLoading.value = true;

      if (refresh) {
        if (page == 1) {
          currentPage.value = 1;
          orders.clear();
          hasMorePages.value = true;
          _pageCache.clear();
        } else {
          _pageCache.remove(page);
        }
      }

      if (page < 1) page = 1;

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

        if (userId.isNotEmpty &&
            current?.user?.id != null &&
            current?.user?.role == 'customer') {
          final String targetUserId =
              (userId == current!.user!.id!) ? current.user!.id! : userId;
          queryParams.addAll({
            'filterByColumns[columns][0][column]': 'buyer_id',
            'filterByColumns[columns][0][value]': targetUserId,
            'filterByColumns[columns][0][operator]': '=',
          });
        }
      }

      final uri = Uri.parse(_baseApiUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'X-Request-From': 'Dashboard',
          if (current?.user?.role != 'customer')
            'shop-id':
                AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final ordersData = data['orders'];

        final int currentPageFromApi = ordersData['current_page'] ?? page;
        final int lastPage = ordersData['last_page'] ?? 1;
        final int total = ordersData['total'] ?? 0;

        final List<Order> fetchedOrders =
            (ordersData['data'] as List)
                .map((order) => Order.fromJson(order))
                .toList();

        currentPage.value = page;
        totalPages.value = lastPage;
        totalOrders.value = total;
        hasMorePages.value = page < lastPage;

        _pageCache[currentPageFromApi] = List.from(fetchedOrders);

        if (refresh) {
          orders.assignAll(fetchedOrders);
        } else {
          orders.assignAll(fetchedOrders);
        }

        orders.sort((a, b) {
          final aOrderId = a.meta?['order_id']?.toString() ?? '0';
          final bOrderId = b.meta?['order_id']?.toString() ?? '0';
          return bOrderId.compareTo(aOrderId);
        });

        if (page == 1) {
          await _saveOrdersToCache(orders);
        }
      } else if (response.statusCode == 404) {
        if (refresh || page == 1) {
          orders.clear();
        }
        hasMorePages.value = false;
        currentPage.value = page;
        totalPages.value = page;
        totalOrders.value = 0;
      } else {
        throw Exception(
          'Failed to load orders: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('🔥 Error in fetchOrders: $e');
      if (page == 1) {
        final cachedOrders = await _getOrdersFromCache();
        if (cachedOrders.isNotEmpty) {
          orders.assignAll(cachedOrders);
          print('💾 Loaded orders from cache instead');
        }
      }
      rethrow;
    } finally {
      isLoading.value = false;
      if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
        _loadingCompleter!.complete();
      }
      _loadingCompleter = null;
    }
  }

  /// Fetch placed orders (no changes here, same as your code)
  Future<void> fetchPlacedOrders({
    int page = 1,
    bool refresh = false,
    String userId = '',
  }) async {
    // unchanged...
    return;
  }

  /// Load next page with debouncing
  Future<void> loadNextPage() async {
    if (!hasMorePages.value || isLoading.value) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        if (_isUserSpecific) {
          await fetchPlacedOrders(
            page: currentPage.value + 1,
            userId: _lastUserId ?? '',
          );
        } else {
          await fetchOrders(
            page: currentPage.value + 1,
            userId: _lastUserId ?? '',
          );
        }
      } catch (e) {
        print('Error loading next page: $e');
      }
    });
  }

  Future<void> refreshOrders() async {
    _pageCache.clear();
    try {
      if (_isUserSpecific) {
        await fetchPlacedOrders(
          page: 1,
          refresh: true,
          userId: _lastUserId ?? '',
        );
      } else {
        await fetchOrders(page: 1, refresh: true, userId: _lastUserId ?? '');
      }
    } catch (e) {
      print('Error refreshing orders: $e');
      rethrow;
    }
  }

  Future<void> loadPage(int page) async {
    if (page < 1 || page > totalPages.value) return;
    try {
      if (_isUserSpecific) {
        await fetchPlacedOrders(
          page: page,
          refresh: page == 1,
          userId: _lastUserId ?? '',
        );
      } else {
        await fetchOrders(
          page: page,
          refresh: page == 1,
          userId: _lastUserId ?? '',
        );
      }
    } catch (e) {
      print('Error loading page $page: $e');
      rethrow;
    }
  }

  Future<void> _saveOrdersToCache(List<Order> ordersToCache) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> orderStrings = [];
      for (final order in ordersToCache) {
        try {
          final jsonString = json.encode(order.toJson());
          orderStrings.add(jsonString);
        } catch (e) {
          print('Error serializing order ${order.id}: $e');
          continue;
        }
      }
      await prefs.setStringList('orders', orderStrings);
      await prefs.setInt('total_orders', totalOrders.value);
      await prefs.setInt('current_page', currentPage.value);
      await prefs.setInt('total_pages', totalPages.value);
      await prefs.setBool('has_more_pages', hasMorePages.value);
      await prefs.setString('last_user_id', _lastUserId ?? '');
      await prefs.setBool('is_user_specific', _isUserSpecific);
      print('💾 Orders cached successfully: ${orderStrings.length}');
    } catch (e) {
      print('Error saving orders to cache: $e');
    }
  }

  Future<List<Order>> _getOrdersFromCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? orderStrings = prefs.getStringList('orders');
      if (orderStrings != null && orderStrings.isNotEmpty) {
        totalOrders.value = prefs.getInt('total_orders') ?? 0;
        currentPage.value = prefs.getInt('current_page') ?? 1;
        totalPages.value = prefs.getInt('total_pages') ?? 0;
        hasMorePages.value = prefs.getBool('has_more_pages') ?? true;
        _lastUserId = prefs.getString('last_user_id');
        _isUserSpecific = prefs.getBool('is_user_specific') ?? false;
        final List<Order> cachedOrders = [];
        for (final orderString in orderStrings) {
          try {
            final orderJson = json.decode(orderString);
            cachedOrders.add(Order.fromJson(orderJson));
          } catch (e) {
            print('Error deserializing cached order: $e');
            continue;
          }
        }
        print('💾 Loaded ${cachedOrders.length} orders from cache');
        return cachedOrders;
      }
    } catch (e) {
      print('Error loading orders from cache: $e');
    }
    return [];
  }

  void resetPagination() {
    currentPage.value = 1;
    totalPages.value = 0;
    totalOrders.value = 0;
    hasMorePages.value = true;
    orders.clear();
    _pageCache.clear();
    _lastUserId = null;
    _isUserSpecific = false;
    _debounceTimer?.cancel();
    if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
      _loadingCompleter!.complete();
      _loadingCompleter = null;
    }
  }

  Map<String, dynamic> getPaginationInfo() {
    return {
      'currentPage': currentPage.value,
      'totalPages': totalPages.value,
      'totalOrders': totalOrders.value,
      'hasMorePages': hasMorePages.value,
      'ordersCount': orders.length,
      'perPage': perPage,
      'isLoading': isLoading.value,
      'isUserSpecific': _isUserSpecific,
      'cacheSize': _pageCache.length,
    };
  }

  Future<void> clearAllCaches() async {
    _pageCache.clear();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('orders');
      await prefs.remove('total_orders');
      await prefs.remove('current_page');
      await prefs.remove('total_pages');
      await prefs.remove('has_more_pages');
      await prefs.remove('last_user_id');
      await prefs.remove('is_user_specific');
      print('🗑️ All caches cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
      _loadingCompleter!.complete();
    }
    super.onClose();
  }
}
