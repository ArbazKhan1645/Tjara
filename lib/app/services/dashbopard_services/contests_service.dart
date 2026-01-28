// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:tjara/app/modules/modules_customer/tjara_contests/model/contest_model.dart';
import 'package:tjara/app/modules/modules_customer/tjara_contests/model/fd.dart';

import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class ContestsService extends GetxService {
  static const String _apiUrl = 'https://api.libanbuy.com/api/contests';
  static const Duration _searchDebounceTime = Duration(milliseconds: 500);
  static const int _defaultPerPage = 10;

  // Reactive variables
  final _contestsResponse = Rxn<ContestsResponse>();
  final _contests = <ContestModel>[].obs;
  final _isLoading = false.obs;
  final _isSearching = false.obs;
  final _currentPage = 1.obs;
  final _totalPages = 0.obs;
  final _totalItems = 0.obs;
  final _perPage = _defaultPerPage.obs;
  final _searchQuery = ''.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;

  // Controllers
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  // Private variables
  Timer? _searchDebounceTimer;
  final Logger _logger = Logger();

  // Getters
  ContestsResponse? get contestsResponse => _contestsResponse.value;
  List<ContestModel> get contests => _contests.toList();
  bool get isLoading => _isLoading.value;
  bool get isSearching => _isSearching.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalItems => _totalItems.value;
  int get perPage => _perPage.value;
  String get searchQuery => _searchQuery.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get hasData => _contests.isNotEmpty;
  bool get canLoadMore => _currentPage.value < _totalPages.value;
  bool get hasPreviousPage => _currentPage.value > 1;
  bool get hasNextPage => _currentPage.value < _totalPages.value;

  @override
  void onInit() {
    super.onInit();

    _loadInitialData();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Initialize the service and load initial data
  Future<ContestsService> init() async {
    // await _loadInitialData();
    return this;
  }

  /// Setup search listener with debounce
  void _setupSearchListener() {
    searchController.addListener(() {
      final query = searchController.text.trim();
      if (query != _searchQuery.value) {
        _searchQuery.value = query;
        _debounceSearch();
      }
    });
  }

  /// Debounce search to avoid excessive API calls
  void _debounceSearch() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounceTime, () {
      _performSearch();
    });
  }

  /// Load initial data
  Future<void> _loadInitialData() async {
    await fetchContests(showLoader: true);
  }

  /// Perform search operation
  Future<void> _performSearch() async {
    _currentPage.value = 1;
    await fetchContests(showLoader: false, isSearch: true);
  }

  /// Main method to fetch contests
  Future<void> fetchContests({
    bool showLoader = false,
    bool isSearch = false,
    bool isLoadMore = false,
  }) async {
    try {
      // Set loading states
      if (showLoader) {
        _isLoading.value = true;
      } else if (isSearch) {
        _isSearching.value = true;
      }

      // Clear error state
      _hasError.value = false;
      _errorMessage.value = '';

      // Validate authentication
      final currentUser = AuthService.instance.authCustomer;
      if (currentUser?.user?.id == null) {
        return;
      }

      if (currentUser?.user?.role != 'admin') {
        return;
      }

      // Build query parameters
      final queryParams = _buildQueryParameters();
      final uri = Uri.parse(_apiUrl).replace(queryParameters: queryParams);

      // Make API request
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Request timeout'),
          );

      // Handle response
      await _handleResponse(response, isLoadMore);
      _setupSearchListener();
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
    } finally {
      _isLoading.value = false;
      _isSearching.value = false;
    }
  }

  /// Build query parameters for API request
  Map<String, String> _buildQueryParameters() {
    final params = <String, String>{
      'per_page': _perPage.value.toString(),
      'page': _currentPage.value.toString(),
    };

    if (_searchQuery.value.isNotEmpty) {
      params['search'] = _searchQuery.value;
    }

    return params;
  }

  /// Build request headers
  Map<String, String> _buildHeaders() {
    return {
      'X-Request-From': 'Application',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Handle API response
  Future<void> _handleResponse(http.Response response, bool isLoadMore) async {
    if (response.statusCode != 200) {
      throw HttpException('Failed to load contests: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    // Validate response structure
    if (data['contests'] == null) {
      throw Exception('Invalid response: contests data is missing');
    }

    // Parse response
    final contestsResponse = ContestsResponse.fromJson(data);
    _contestsResponse.value = contestsResponse;

    // Update contests list
    final newContests = contestsResponse.contests?.data ?? [];
    if (isLoadMore) {
      _contests.addAll(newContests);
    } else {
      _contests.assignAll(newContests);
    }

    // Update pagination info
    _updatePaginationInfo(data);
  }

  /// Update pagination information
  void _updatePaginationInfo(Map<String, dynamic> data) {
    final contestsData = data['contests'] as Map<String, dynamic>?;
    if (contestsData != null) {
      _totalPages.value = contestsData['last_page'] ?? 0;
      _totalItems.value = contestsData['total'] ?? 0;
      _currentPage.value = contestsData['current_page'] ?? 1;
    }
  }

  /// Handle errors
  void _handleError(dynamic error, StackTrace stackTrace) {
    _hasError.value = true;
    _errorMessage.value = _getErrorMessage(error);

    _logger.e('Error fetching contests', error: error, stackTrace: stackTrace);

    // Show user-friendly error message
    if (Get.context != null) {
      Get.snackbar(
        'Error',
        _errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Request timeout. Please try again.';
    } else if (error is HttpException) {
      return error.message;
    } else if (error.toString().contains('User not authenticated')) {
      return 'Please login to continue';
    } else {
      return 'Failed to load contests. Please try again.';
    }
  }

  /// Refresh contests data
  Future<void> refreshContests() async {
    _currentPage.value = 1;
    await fetchContests(showLoader: true);
  }

  /// Load more contests (pagination)
  Future<void> loadMoreContests() async {
    if (canLoadMore && !isLoading) {
      _currentPage.value++;
      await fetchContests(isLoadMore: true);
    }
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= _totalPages.value && page != _currentPage.value) {
      _currentPage.value = page;
      await fetchContests(showLoader: false);
    }
  }

  /// Go to next page
  Future<void> nextPage() async {
    if (hasNextPage) {
      await goToPage(_currentPage.value + 1);
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      await goToPage(_currentPage.value - 1);
    }
  }

  /// Get visible page numbers for pagination
  List<int> getVisiblePageNumbers() {
    const int maxVisible = 7;
    final int current = _currentPage.value;
    final int total = _totalPages.value;

    if (total <= maxVisible) {
      return List.generate(total, (index) => index + 1);
    }

    int start = current - (maxVisible ~/ 2);
    int end = current + (maxVisible ~/ 2);

    if (start < 1) {
      start = 1;
      end = maxVisible;
    } else if (end > total) {
      end = total;
      start = total - maxVisible + 1;
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  /// Update per page value
  void updatePerPage(int newPerPage) {
    if (newPerPage != _perPage.value) {
      _perPage.value = newPerPage;
      _currentPage.value = 1;
      fetchContests(showLoader: false);
    }
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    _searchQuery.value = '';
    _currentPage.value = 1;
    fetchContests(showLoader: false);
  }

  /// Get pagination info string
  String getPaginationInfo() {
    if (_totalItems.value == 0) return 'No contests found';

    final start = (_currentPage.value - 1) * _perPage.value + 1;
    final end = (_currentPage.value * _perPage.value).clamp(
      0,
      _totalItems.value,
    );

    return 'Showing $start-$end of ${_totalItems.value} contests';
  }
}

/// Custom exception for HTTP errors
class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}

/// Extension to add timeout to HTTP requests
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
