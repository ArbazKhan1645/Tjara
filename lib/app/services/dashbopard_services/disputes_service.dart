// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:tjara/app/models/disputes/disputes_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class AdminDisputesService extends GetxService {
  static AdminDisputesService get to => Get.find();
  Future<AdminDisputesService> init() async {
    return this;
  }

  final String _baseApiUrl = 'https://api.libanbuy.com/api/order-disputes';
  final Logger _logger = Logger();

  // Reactive variables
  final disputesResponse = Rxn<DisputesResponse>();
  final RxList<DisputeData> disputes = <DisputeData>[].obs;
  final RxList<DisputeData> filteredDisputes = <DisputeData>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 15.obs;
  final RxInt totalPages = 0.obs;
  final RxInt totalItems = 0.obs;

  // Search and filtering
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxString sortBy = 'created_at'.obs;
  final RxString sortOrder = 'desc'.obs;

  // Controllers
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // Debounce timer for search
  Timer? _searchDebounce;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeService();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _initializeService() async {
    try {
      print('Failed to initialize disputes service1');
      await loadDisputes();
      _setupSearchListener();
    } catch (e) {
      _handleError('Failed to initialize disputes service', e);
    }
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        searchQuery.value = searchController.text.trim();
        _filterDisputes();
      });
    });
  }

  Future<void> loadDisputes({
    bool showLoader = true,
    bool isRefresh = false,
    String? userId,
  }) async {
    try {
      if (showLoader && !isRefresh) {
        isLoading.value = true;
      } else if (isRefresh) {
        isRefreshing.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      final response = await _fetchDisputesFromApi(userId: userId);

      if (response != null) {
        disputesResponse.value = response;
        disputes.assignAll(response.disputes?.data ?? []);
        totalItems.value = response.disputes?.total ?? 0;
        totalPages.value = ((totalItems.value / perPage.value).ceil());
        _filterDisputes();
      }
    } catch (e) {
      if (showLoader) {
        _handleError('Failed to load disputes', e);
      }
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<DisputesResponse?> _fetchDisputesFromApi({String? userId}) async {
    final LoginResponse? currentUser = AuthService.instance.authCustomer;

    if (currentUser?.user?.id == null) {
      return DisputesResponse(disputes: null);
    }

    if (currentUser?.user?.role == 'customers') {
      return DisputesResponse(disputes: null);
    }

    final uri = _buildApiUri(userId);

    final response = await http
        .get(
          uri,
          headers: {
            'X-Request-From': 'Dashboard',
            'Content-Type': 'application/json',
            'shop-id':
                AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
            'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
          },
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Request timeout'),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['disputes'] == null) {
        throw Exception('Invalid response format: disputes data missing');
      }

      return DisputesResponse.fromJson(data);
    } else if (response.statusCode == 404) {
      return DisputesResponse();
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Uri _buildApiUri(String? userId) {
    final Map<String, String> queryParams = {
      'per_page': perPage.value.toString(),
      'page': currentPage.value.toString(),
    };

    if (userId?.isNotEmpty == true) {
      queryParams.addAll({
        'filterByColumns[columns][0][column]': 'buyer_id',
        'filterByColumns[columns][0][value]': userId!,
        'filterByColumns[columns][0][operator]': '=',
      });
    }

    if (selectedStatus.value.isNotEmpty) {
      queryParams.addAll({
        'filterByColumns[columns][1][column]': 'status',
        'filterByColumns[columns][1][value]': selectedStatus.value,
        'filterByColumns[columns][1][operator]': '=',
      });
    }

    if (sortBy.value.isNotEmpty) {
      queryParams['sort'] = '${sortBy.value}:${sortOrder.value}';
    }

    return Uri.parse(_baseApiUrl).replace(queryParameters: queryParams);
  }

  void _filterDisputes() {
    if (searchQuery.value.isEmpty) {
      filteredDisputes.assignAll(disputes);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredDisputes.assignAll(
        disputes
            .where(
              (dispute) =>
                  dispute.id?.toString().toLowerCase().contains(query) ==
                      true ||
                  dispute.buyer?.user?.firstName?.toLowerCase().contains(
                        query,
                      ) ==
                      true ||
                  dispute.buyer?.user?.lastName?.toLowerCase().contains(
                        query,
                      ) ==
                      true ||
                  dispute.shop?.shop?.name?.toLowerCase().contains(query) ==
                      true ||
                  dispute.status?.toLowerCase().contains(query) == true,
            )
            .toList(),
      );
    }
  }

  void _handleError(String message, dynamic error) {
    _logger.e(message, error: error);
    hasError.value = true;
    errorMessage.value = error.toString();

    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }

  // Pagination methods
  List<int> get visiblePageNumbers {
    const int maxVisible = 5;
    final int current = currentPage.value;
    final int total = totalPages.value;

    if (total == 0) return [];

    int start = (current - maxVisible ~/ 2).clamp(1, total);
    final int end = (start + maxVisible - 1).clamp(1, total);

    // Adjust start if we're at the end
    if (end == total) {
      start = (total - maxVisible + 1).clamp(1, total);
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages.value || page == currentPage.value) {
      return;
    }

    currentPage.value = page;
    await loadDisputes(showLoader: false, userId: Get.arguments);
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

  // Search and filter methods
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterDisputes();
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    loadDisputes(showLoader: false, userId: Get.arguments);
  }

  void setSorting(String column, String order) {
    sortBy.value = column;
    sortOrder.value = order;
    currentPage.value = 1;
    loadDisputes(showLoader: false, userId: Get.arguments);
  }

  // Refresh methods
  Future<void> refreshDisputes() async {
    currentPage.value = 1;
    await loadDisputes(isRefresh: true, userId: Get.arguments);
  }

  // Utility methods
  bool get hasData => disputes.isNotEmpty;
  bool get hasFilteredData => filteredDisputes.isNotEmpty;
  bool get canGoNext => currentPage.value < totalPages.value;
  bool get canGoPrevious => currentPage.value > 1;

  String get paginationText {
    if (totalItems.value == 0) return 'No disputes found';

    final start = ((currentPage.value - 1) * perPage.value) + 1;
    final end = (currentPage.value * perPage.value).clamp(0, totalItems.value);

    return 'Showing $start-$end of ${totalItems.value} disputes';
  }
}
