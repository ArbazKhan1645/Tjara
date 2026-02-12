// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/models/chat_messages/chat_messages_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class ProductChatsService extends GetxService {
  static ProductChatsService get instance => Get.find<ProductChatsService>();

  // Reactive variables
  final Rx<ProductChats> productChats = ProductChats(data: []).obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMoreData = true.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 15.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxInt selectedFilter = 0.obs; // 0: All, 1: Active, 2: Inactive

  SharedPreferences? _prefs;
  final String baseApiUrl = "https://api.libanbuy.com/api/products/chats";

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();

    // Load cached data first
    await _loadCachedData();

    // Then fetch fresh data
    await fetchData(refresh: true);
  }

  Future<ProductChatsService> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadCachedData();
      await fetchData(refresh: true);
    } catch (e) {
      _handleError('Failed to initialize chat service', e);
      productChats.value = ProductChats(data: []);
    }
    return this;
  }

  Future<void> _loadCachedData() async {
    try {
      if (_prefs == null) return;

      final cachedData = _prefs!.getString('product_chats_page_1');
      if (cachedData != null && cachedData.isNotEmpty) {
        final responseJson = jsonDecode(cachedData);
        if (responseJson['ProductChats'] != null) {
          final parsedData = ProductChats.fromJson(
            responseJson['ProductChats'],
          );
          if (parsedData.data?.isNotEmpty == true) {
            productChats.value = parsedData;
            _updatePaginationInfo(parsedData);
            productChats.refresh();
          }
        }
      }
    } catch (e) {
      print('Error 2 loading cached data: $e');
    }
  }

  Future<void> fetchData({
    bool refresh = false,
    int? page,
    String? search,
    int? filter,
  }) async {
    try {
      // Reset if refreshing
      if (refresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        productChats.value = ProductChats(data: []);
      }

      final targetPage = page ?? currentPage.value;
      final isFirstPage = targetPage == 1;

      // Set loading states
      if (isFirstPage || refresh) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      // Update search and filter if provided
      if (search != null) searchQuery.value = search;
      if (filter != null) selectedFilter.value = filter;

      final user = AuthService.instance.authCustomer?.user;
      final queryParams = _buildQueryParams(targetPage);

      // Add user filter for non-admin users
      if (user?.id != null && user?.meta?.dashboardView == 'customer') {
        queryParams.addAll({
          'filterByColumns[columns][0][column]': 'user_id',
          'filterByColumns[columns][0][value]': user!.id!,
          'filterByColumns[columns][0][operator]': '=',
        });
      }

      // Add search filter if provided
      if (searchQuery.value.isNotEmpty) {
        queryParams.addAll({'search': searchQuery.value});
      }

      final uri = Uri.parse(baseApiUrl).replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              'dashboard-view':
                  AuthService
                      .instance
                      .authCustomer
                      ?.user
                      ?.meta
                      ?.dashboardView ??
                  '',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'shop-id':
                  AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
              'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
              'X-Request-From': 'Dashboard',
            },
          )
          .timeout(const Duration(seconds: 15));

      await _handleResponse(response, targetPage, refresh);
    } catch (e) {
      _handleError('Failed to fetch chat data', e);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Map<String, String> _buildQueryParams(int page) {
    return {'page': page.toString(), 'per_page': perPage.value.toString()};
  }

  Future<void> _handleResponse(
    http.Response response,
    int targetPage,
    bool refresh,
  ) async {
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        final responseJson = jsonDecode(response.body);

        if (responseJson['ProductChats'] != null) {
          final newData = ProductChats.fromJson(responseJson['ProductChats']);

          if (newData.data != null) {
            // Always replace data for page-based pagination
            productChats.value = newData;

            _updatePaginationInfo(newData);
            productChats.refresh();

            // Cache first page data
            if (targetPage == 1) {
              await _cacheData(response.body);
            }
          }
        }
      } catch (e) {
        _handleError('Failed to parse chat data', e);
      }
    } else if (response.statusCode == 404) {
      if (targetPage == 1) {
        productChats.value = ProductChats(data: []);
        hasMoreData.value = false;
      }
    } else {
      _handleError('Server error: ${response.statusCode}', response.body);
    }
  }

  void _updatePaginationInfo(ProductChats newData) {
    currentPage.value = newData.currentPage ?? 1;
    totalPages.value = newData.lastPage ?? 1;
    totalItems.value = newData.total ?? 0;
    hasMoreData.value =
        (newData.nextPageUrl?.isNotEmpty == true) &&
        (currentPage.value < totalPages.value);
  }

  Future<void> _cacheData(String responseBody) async {
    if (_prefs != null) {
      await _prefs!.setString('product_chats_page_1', responseBody);
    }
  }

  void _handleError(String message, dynamic error) {
    hasError.value = true;
    errorMessage.value = message;
    print('ProductChatsService Error: $message - $error');
  }

  // Public methods for pagination
  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages.value || isLoading.value) return;
    await fetchData(page: page);
  }

  Future<void> nextPage() async {
    if (currentPage.value < totalPages.value) {
      await goToPage(currentPage.value + 1);
    }
  }

  Future<void> previousPage() async {
    if (currentPage.value > 1) {
      await goToPage(currentPage.value - 1);
    }
  }

  Future<void> refreshData() async {
    await fetchData(page: currentPage.value);
  }

  Future<void> searchChats(String query) async {
    await fetchData(refresh: true, search: query);
  }

  Future<void> filterChats(int filterType) async {
    await fetchData(refresh: true, filter: filterType);
  }

  // Helper methods
  Future<void> clearCache() async {
    if (_prefs != null) {
      final keys = _prefs!.getKeys().where(
        (key) => key.startsWith('product_chats_'),
      );
      for (final key in keys) {
        await _prefs!.remove(key);
      }

      productChats.value = ProductChats(data: []);
      currentPage.value = 1;
      hasMoreData.value = true;
      productChats.refresh();
    }
  }

  // Getters
  int get messageCount => productChats.value.data?.length ?? 0;
  bool get hasMessages => messageCount > 0;
  bool get canGoNext => currentPage.value < totalPages.value;
  bool get canGoPrevious => currentPage.value > 1;

  // Get visible page numbers for pagination
  List<int> get visiblePages {
    final total = totalPages.value;
    final current = currentPage.value;

    if (total <= 7) {
      return List.generate(total, (index) => index + 1);
    }

    if (current <= 4) {
      return [1, 2, 3, 4, 5, -1, total]; // -1 represents ellipsis
    }

    if (current >= total - 3) {
      return [1, -1, total - 4, total - 3, total - 2, total - 1, total];
    }

    return [1, -1, current - 1, current, current + 1, -1, total];
  }

  // Computed properties
  List<ChatData> get filteredChats {
    final chats = productChats.value.data ?? [];
    if (selectedFilter.value == 0) return chats;

    return chats.where((chat) {
      switch (selectedFilter.value) {
        case 1: // Active users
          return chat.user?.status?.toLowerCase() == 'active';
        case 2: // Inactive users
          return chat.user?.status?.toLowerCase() != 'active';
        default:
          return true;
      }
    }).toList();
  }

  String get paginationInfo {
    if (totalItems.value == 0) return 'No results';

    final start = ((currentPage.value - 1) * perPage.value) + 1;
    final end = (currentPage.value * perPage.value).clamp(0, totalItems.value);

    return 'Showing $start-$end of ${totalItems.value} results';
  }

  // ==========================================
  // INBOX CHATS (Receive) - shop-id + user-id
  // ==========================================
  final Rx<ProductChats> inboxChats = ProductChats(data: []).obs;
  final RxBool isLoadingInbox = false.obs;
  final RxInt inboxCurrentPage = 1.obs;
  final RxInt inboxTotalPages = 1.obs;
  final RxInt inboxTotalItems = 0.obs;

  Future<void> fetchInboxData({
    bool refresh = false,
    int? page,
    String? search,
  }) async {
    try {
      if (refresh) {
        inboxCurrentPage.value = 1;
        inboxChats.value = ProductChats(data: []);
      }

      final targetPage = page ?? inboxCurrentPage.value;
      isLoadingInbox.value = true;

      final user = AuthService.instance.authCustomer?.user;
      final shopId = AuthService.instance.authCustomer?.user?.shop?.shop?.id;

      if (user?.id == null || shopId == null) {
        inboxChats.value = ProductChats(data: []);
        return;
      }

      final queryParams = {
        'page': targetPage.toString(),
        'per_page': perPage.value.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(baseApiUrl).replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              "Content-Type": "application/json",
              "X-Request-From": "Application",
              'shop-id': shopId,
              'user-id': user!.id!,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final responseJson = jsonDecode(response.body);

        if (responseJson['ProductChats'] != null) {
          final newData = ProductChats.fromJson(responseJson['ProductChats']);
          inboxChats.value = newData;
          inboxCurrentPage.value = newData.currentPage ?? 1;
          inboxTotalPages.value = newData.lastPage ?? 1;
          inboxTotalItems.value = newData.total ?? 0;
          inboxChats.refresh();
        }
      }
    } catch (e) {
      print('Inbox fetch error: $e');
    } finally {
      isLoadingInbox.value = false;
    }
  }

  // Inbox pagination
  Future<void> goToInboxPage(int page) async {
    if (page < 1 || page > inboxTotalPages.value || isLoadingInbox.value) {
      return;
    }
    await fetchInboxData(page: page);
  }

  Future<void> nextInboxPage() async {
    if (inboxCurrentPage.value < inboxTotalPages.value) {
      await goToInboxPage(inboxCurrentPage.value + 1);
    }
  }

  Future<void> previousInboxPage() async {
    if (inboxCurrentPage.value > 1) {
      await goToInboxPage(inboxCurrentPage.value - 1);
    }
  }

  // Inbox getters
  List<ChatData> get inboxChatsList => inboxChats.value.data ?? [];
  int get inboxMessageCount => inboxChatsList.length;
  bool get canGoNextInbox => inboxCurrentPage.value < inboxTotalPages.value;
  bool get canGoPreviousInbox => inboxCurrentPage.value > 1;

  String get inboxPaginationInfo {
    if (inboxTotalItems.value == 0) return 'No results';
    final start = ((inboxCurrentPage.value - 1) * perPage.value) + 1;
    final end = (inboxCurrentPage.value * perPage.value).clamp(
      0,
      inboxTotalItems.value,
    );
    return 'Showing $start-$end of ${inboxTotalItems.value} results';
  }

  List<int> get inboxVisiblePages {
    final total = inboxTotalPages.value;
    final current = inboxCurrentPage.value;

    if (total <= 7) {
      return List.generate(total, (index) => index + 1);
    }

    if (current <= 4) {
      return [1, 2, 3, 4, 5, -1, total];
    }

    if (current >= total - 3) {
      return [1, -1, total - 4, total - 3, total - 2, total - 1, total];
    }

    return [1, -1, current - 1, current, current + 1, -1, total];
  }
}
