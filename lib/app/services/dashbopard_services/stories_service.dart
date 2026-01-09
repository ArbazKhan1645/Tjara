// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:tjara/app/models/posts/posts_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

enum LoadingState { initial, loading, loaded, error, empty }

class StoriesService extends GetxService {
  final String _apiUrl = 'https://api.libanbuy.com/api/posts';

  Future<StoriesService> init() async {
    return this;
  }

  // Observable data
  final productsModel = Rxn<PostResponse>();
  final RxList<PostModel> adminProducts = <PostModel>[].obs;
  final RxList<PostModel> filteredProducts = <PostModel>[].obs;

  // Loading and pagination state
  final Rx<LoadingState> loadingState = LoadingState.initial.obs;
  final RxBool isSearching = false.obs;
  final RxBool isDeleting = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt perPage = 10.obs;
  final RxInt totalPages = 0.obs;
  final RxInt totalItems = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Controllers
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  // Debounce timer for search
  Worker? _searchWorker;

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _initializeSearchListener() {
    // Auto-search with debounce
    _searchWorker = debounce(
      searchQuery,
      (query) => _performSearch(query),
      time: const Duration(milliseconds: 500),
    );

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      filteredProducts.assignAll(adminProducts);
      return;
    }

    isSearching.value = true;
    try {
      await fetchProductsSearch(loaderType: false, searchKeyword: query);
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> fetchProducts({required bool loaderType}) async {
    if (loaderType) {
      loadingState.value = LoadingState.loading;
    }

    try {
      final current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        throw Exception('User not authenticated');
      }

      _initializeSearchListener();

      final uri = Uri.parse(_apiUrl).replace(
        queryParameters: {
          'per_page': perPage.value.toString(),
          'page': currentPage.value.toString(),
          '_t': DateTime.now().millisecondsSinceEpoch.toString(),
          'filterByColumns[filterJoin]': 'AND',
          'filterByColumns[columns][0][column]': 'post_type',
          'filterByColumns[columns][0][value]': 'shop_stories',
          'filterByColumns[columns][0][operator]': '=',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['posts'] == null) {
        throw Exception('Invalid response format');
      }

      final products = PostResponse.fromJson(data);
      productsModel.value = products;

      final newProducts = products.posts.data ?? [];
      adminProducts.assignAll(newProducts);
      filteredProducts.assignAll(newProducts);

      totalPages.value = products.posts.lastPage ?? 0;
      totalItems.value = products.posts.total ?? 0;

      // Update loading state based on data
      if (newProducts.isEmpty) {
        loadingState.value = LoadingState.empty;
      } else {
        loadingState.value = LoadingState.loaded;
      }

      errorMessage.value = '';
    } catch (e, stackTrace) {
      Logger().e('Error fetching products', error: e, stackTrace: stackTrace);
      errorMessage.value = _getErrorMessage(e);
      loadingState.value = LoadingState.error;
    }
  }

  Future<void> fetchProductsSearch({
    required bool loaderType,
    String? searchKeyword,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    if (loaderType) {
      loadingState.value = LoadingState.loading;
    }

    try {
      final current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        throw Exception('User not authenticated');
      }

      final query = <String, String>{
        'per_page': perPage.value.toString(),
        'page': currentPage.value.toString(),
        'filterByColumns[filterJoin]': 'AND',
        'filterByColumns[columns][0][column]': 'post_type',
        'filterByColumns[columns][0][value]': 'shop_stories',
        'filterByColumns[columns][0][operator]': '=',
      };

      if (searchKeyword != null && searchKeyword.isNotEmpty) {
        query['search'] = searchKeyword;
      }
      if (category != null && category.isNotEmpty) {
        query['category'] = category;
      }
      if (minPrice != null) {
        query['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        query['max_price'] = maxPrice.toString();
      }

      final uri = Uri.parse(_apiUrl).replace(queryParameters: query);

      final response = await http.get(
        uri,
        headers: {
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Search failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['posts'] == null) {
        throw Exception('Invalid search response');
      }

      final products = PostResponse.fromJson(data);
      productsModel.value = products;

      final searchResults = products.posts.data ?? [];
      adminProducts.assignAll(searchResults);
      filteredProducts.assignAll(searchResults);

      totalPages.value = products.posts.lastPage ?? 0;
      totalItems.value = products.posts.total ?? 0;

      if (searchResults.isEmpty) {
        loadingState.value = LoadingState.empty;
      } else {
        loadingState.value = LoadingState.loaded;
      }

      errorMessage.value = '';
    } catch (e, stackTrace) {
      Logger().e('Error searching products', error: e, stackTrace: stackTrace);
      errorMessage.value = _getErrorMessage(e);
      loadingState.value = LoadingState.error;
    }
  }

  Future<bool> deleteStory(String storyId) async {
    try {
      isDeleting.value = true;

      final current = AuthService.instance.authCustomer;
      if (current?.user?.id == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$_apiUrl/$storyId/delete'),
        headers: {
          'X-Request-From': 'Application',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Remove from local lists
        adminProducts.removeWhere((story) => story.id == storyId);
        filteredProducts.removeWhere((story) => story.id == storyId);

        return true;
      } else {
        throw Exception('Failed to delete story');
      }
    } catch (e) {
      Logger().e('Error deleting story', error: e);
      Get.snackbar(
        'Error',
        'Failed to delete story: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> refreshData() async {
    currentPage.value = 1;
    searchController.clear();
    searchQuery.value = '';
    await fetchProducts(loaderType: true);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filteredProducts.assignAll(adminProducts);
  }

  List<int> visiblePageNumbers() {
    const int maxVisible = 5;
    final int current = currentPage.value;
    final int total = totalPages.value;

    if (total == 0) return [];

    int start = (current - (maxVisible ~/ 2)).clamp(1, total);
    final int end = (start + maxVisible - 1).clamp(1, total);

    if (end - start < maxVisible - 1) {
      start = (end - maxVisible + 1).clamp(1, total);
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      currentPage.value = page;
      await fetchProducts(loaderType: false);
    }
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

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }

  // Getters for UI state
  bool get isLoading => loadingState.value == LoadingState.loading;
  bool get hasError => loadingState.value == LoadingState.error;
  bool get isEmpty => loadingState.value == LoadingState.empty;
  bool get hasData =>
      loadingState.value == LoadingState.loaded && filteredProducts.isNotEmpty;
  bool get canGoNext => currentPage.value < totalPages.value;
  bool get canGoPrevious => currentPage.value > 1;
}
