// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/services/auth/apis.dart';

class StorePageController extends GetxController {
  ProductAttributeItems? selectedCategory;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // Enhanced state variables
  var isLoading = false.obs;
  var isSearching = false.obs;
  var isPaginationLoading = false.obs;
  var hasMoreData = true.obs;
  var currentPage = 1.obs;
  var searchQuery = ''.obs;

  var categories = CategoryModel(productAttributeItems: []).obs;
  var products = ProductModel(products: Products(currentPage: 1, data: [])).obs;
  var filterCategoryproducts =
      ProductModel(products: Products(currentPage: 1, data: [])).obs;

  // Debouncer for search
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void onInit() {
    if (Get.arguments == null) return;
    final String? shopId = Get.arguments?['shopid'] as String?;

    if (shopId != null) {
      currentSHop = Get.arguments?['ShopShop'] as ShopShop?;
      initState(shopId);
    }

    // Add scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isPaginationLoading.value &&
          !isLoading.value &&
          hasMoreData.value) {
        _loadMoreProducts();
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    _debouncer._timer?.cancel();
    super.onClose();
  }

  ShopShop? currentSHop = ShopShop();

  initState(String shopid) {
    fetchInitialProducts(shopid);
  }

  Future<void> fetchInitialProducts(String shopId) async {
    try {
      // Set initial loading state
      isLoading.value = true;
      currentPage.value = 1;
      hasMoreData.value = true;

      // Clear previous data
      products.value = ProductModel(
        products: Products(currentPage: 1, data: []),
      );
      filterCategoryproducts.value = ProductModel(
        products: Products(currentPage: 1, data: []),
      );

      final result = await CategoryApiService().fetchProductsOfShop(
        page: currentPage.value,
        shopId: shopId,
        search: searchQuery.value,
      );

      if (result is Map<String, dynamic>) {
        products.value = ProductModel.fromJson(result);

        // Prefetch images for better UX
        _prefetchProductImages(products.value.products?.data ?? []);

        // Set current filter products same as main products
        filterCategoryproducts.value = ProductModel(
          products: Products(
            currentPage: products.value.products?.currentPage ?? 1,
            data: List.from(products.value.products?.data ?? []),
          ),
        );

        // Check if we have more data
        hasMoreData.value = (products.value.products?.data?.length ?? 0) >= 10;
      } else {
        products.value = ProductModel(
          products: Products(currentPage: 1, data: []),
        );
        filterCategoryproducts.value = products.value;
        hasMoreData.value = false;
      }
    } catch (e) {
      print('Error fetching initial products: $e');
      _handleError();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (isPaginationLoading.value || !hasMoreData.value || isSearching.value) {
      return;
    }

    try {
      isPaginationLoading.value = true;
      isLoading.value = true; // Keep this for UI compatibility
      currentPage.value++;

      final result = await CategoryApiService().fetchProductsOfShop(
        page: currentPage.value,
        shopId: currentSHop?.id,
        search: searchQuery.value,
      );

      if (result is Map<String, dynamic>) {
        final newProducts = ProductModel.fromJson(result);
        final newProductsList = newProducts.products?.data ?? [];

        if (newProductsList.isNotEmpty) {
          // Prefetch images
          _prefetchProductImages(newProductsList);

          // Append new data to existing list
          final List<ProductDatum> combinedList = [
            ...products.value.products?.data ?? [],
            ...newProductsList,
          ];

          products.value = ProductModel(
            products: Products(
              currentPage:
                  newProducts.products?.currentPage ?? currentPage.value,
              data: combinedList,
            ),
          );

          // Also update filtered products if not in search mode
          if (searchQuery.value.isEmpty) {
            filterCategoryproducts.value = products.value;
          }

          // Check if we have more data
          hasMoreData.value = newProductsList.length >= 10;
        } else {
          hasMoreData.value = false;
        }
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      print('Error loading more products: $e');
      currentPage.value--; // Revert page count on error
      _showErrorSnackbar('Failed to load more products');
    } finally {
      isPaginationLoading.value = false;
      isLoading.value = false;
      update();
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query.trim();

    if (searchQuery.value.isEmpty) {
      clearSearch();
      return;
    }

    _debouncer.run(() {
      fetchProductsWithSearch();
    });
  }

  Future<void> fetchProductsWithSearch() async {
    try {
      isSearching.value = true;
      isLoading.value = false; // Don't show main loading for search

      // Reset pagination when searching
      currentPage.value = 1;
      hasMoreData.value = true;

      final result = await CategoryApiService().fetchProductsOfShop(
        page: currentPage.value,
        shopId: currentSHop?.id,
        search: searchQuery.value,
      );

      if (result is Map<String, dynamic>) {
        final searchResults = ProductModel.fromJson(result);

        // Prefetch images for search results
        _prefetchProductImages(searchResults.products?.data ?? []);

        // Update the filter products with search results
        filterCategoryproducts.value = searchResults;

        // Update main products as well for consistency
        products.value = searchResults;

        // Check if we have more data for search results
        hasMoreData.value = (searchResults.products?.data?.length ?? 0) >= 10;
      } else {
        filterCategoryproducts.value = ProductModel(
          products: Products(currentPage: 1, data: []),
        );
        products.value = filterCategoryproducts.value;
        hasMoreData.value = false;
      }
    } catch (e) {
      print('Error searching products: $e');
      _showErrorSnackbar('Search failed. Please try again.');
    } finally {
      isSearching.value = false;
      update();
    }
  }

  void filterCategoryProductss(String sortBy) {
    if (filterCategoryproducts.value.products?.data != null) {
      var productList =
          List<ProductDatum>.from(
            filterCategoryproducts.value.products!.data!,
          ).where((e) => e.price != null).toList();

      switch (sortBy) {
        case "Low to high (price)":
          productList.sort((a, b) => a.price!.compareTo(b.price!));
          break;
        case "High to low (price)":
          productList.sort((a, b) => b.price!.compareTo(a.price!));
          break;
        case "Featured Products":
          productList =
              filterCategoryproducts.value.products?.data
                  ?.where((e) => e.isFeatured == 1)
                  .toList() ??
              [];
          break;
      }

      // Create a new instance with sorted data
      filterCategoryproducts.value = ProductModel(
        products: Products(
          currentPage: filterCategoryproducts.value.products?.currentPage ?? 1,
          data: productList,
        ),
      );
    }
    update();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;

    // Restore original products
    filterCategoryproducts.value = products.value;
    update();
  }

  Future<void> refreshProducts() async {
    await fetchInitialProducts(currentSHop?.id ?? '');
  }

  void setSelectedCategory(ProductAttributeItems val) {
    selectedCategory = val;
    update();
  }

  // Helper methods
  void _prefetchProductImages(List<ProductDatum> products) {
    for (var product in products) {
      if (product.thumbnail?.media?.url != null) {
        prefetchImageIsolate(product.thumbnail?.media?.url ?? '');
      }
    }
  }

  void _handleError() {
    products.value = ProductModel(products: Products(currentPage: 1, data: []));
    filterCategoryproducts.value = products.value;
    hasMoreData.value = false;
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
    );
  }

  // Getters for UI state
  bool get isInitialLoading =>
      isLoading.value && (products.value.products?.data?.isEmpty ?? true);

  bool get hasProducts =>
      (filterCategoryproducts.value.products?.data?.isNotEmpty ?? false);

  bool get isRefreshing => isLoading.value && hasProducts;
}

// Enhanced Debouncer utility class
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}
