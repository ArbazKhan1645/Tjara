// ignore_for_file: avoid_print, depend_on_referenced_packages, constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/posts/posts_model.dart';
import 'package:tjara/app/services/auth/apis.dart';
import 'package:tjara/app/services/websettings_service/websetting_service.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/models/banners_model.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/products/single_product_model.dart';
import 'package:tjara/app/models/superdeals_temp_model.dart' as superdeals;
import 'package:tjara/app/repo/network_repository.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  //image cache
  final ImageProvider cachedShoeImage = const AssetImage(
    'assets/images/—Pngtree—sports shoes_15910407.png',
  );
  preCacheImage() {
    if (Get.context == null) return;
    precacheImage(cachedShoeImage, Get.context!);
  }

  // Initialization state management
  RxBool isInitializing = false.obs;
  RxBool hasInitializationError = false.obs;
  RxString initializationError = ''.obs;
  RxInt initializationRetryCount = 0.obs;
  static const int maxRetryAttempts = 3;
  static const Duration apiTimeout = Duration(seconds: 30);

  // Core observables
  var dealsproducts =
      (ProductModel(products: Products(currentPage: 1, data: []))).obs;
  final RxInt selectedIndexProducts = 0.obs;

  // Super Deals specific states
  RxBool isLoadingDeals = false.obs;
  RxBool hasDealsError = false.obs;
  RxString dealsError = ''.obs;
  var superDeals = (superdeals.SuperDeals()).obs;

  // Banners for when timer expires
  var homePageBanners = (Banners(posts: Posts(data: []))).obs;
  RxBool isLoadingBanners = false.obs;
  RxBool hasBannersError = false.obs;
  var categories = CategoryModel(productAttributeItems: []).obs;
  var products =
      (ProductModel(products: Products(currentPage: 1, data: []))).obs;
  var categoryproducts =
      (ProductModel(products: Products(currentPage: 1, data: []))).obs;
  var filterCategoryproducts =
      (ProductModel(products: Products(currentPage: 1, data: []))).obs;

  // UI state
  List<Map<String, dynamic>> categoryList = [];
  late int midIndex;
  List<Map<String, dynamic>> topCategories = [];
  List<Map<String, dynamic>> bottomCategories = [];
  List<Map<String, dynamic>> allCategories = [];
  ProductAttributeItems? selectedCategory;

  // Controllers and pagination
  final ScrollController categoryScrollController = ScrollController();
  final ScrollController scrollController = ScrollController();
  final ScrollController categoryPaginationScrollController =
      ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(-1);

  // Loading states
  bool isLoading = false;
  bool isCategorypaginationLoading = false;
  int page = 2;
  int pageFiltered = 2;
  int pageCategoryPagination = 2;
  bool hasReachedEndOfPagination = false;
  RxBool iscategoryLoading = false.obs;

  // Filters
  RxString selectedFilter = 'Most Recent'.obs;
  RxDouble minFilter = 0.0.obs;
  RxDouble maxFilter = (100000.0).obs;

  // Track if we're viewing Super Deals for pagination
  bool isViewingSuperDeals = false;

  // Scroll progress
  static const double kInitialScrollProgress = 0.2;
  RxDouble scrollProgress = 0.2.obs;

  // Services
  final NetworkRepository _repository = NetworkRepository();
  late final BehaviorSubject<CategoryModel?> _categoriesCache;
  late final BehaviorSubject<ProductModel?> _productsCache;
  BehaviorSubject<CategoryModel?>? get categoriesSubject => _categoriesCache;
  BehaviorSubject<ProductModel?>? get productsSubject => _productsCache;

  // Posts management
  static const String _CACHE_KEY = 'cached_posts';
  static const int _CACHE_EXPIRATION_HOURS = 4;
  var posts = (const PostResponse()).obs;
  var isLoadingPosts = false.obs;
  var hasError = false.obs;

  /// Enhanced initialization with comprehensive error handling and retry mechanism
  Future<HomeController> oninits() async {
    if (isInitializing.value) {
      print('Initialization already in progress, waiting...');
      while (isInitializing.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return this;
    }

    isInitializing.value = true;
    hasInitializationError.value = false;
    initializationError.value = '';

    try {
      preCacheImage();
      print('Starting HomeController initialization...');

      // Initialize core components first
      await _initializeCoreComponents();

      // Run initialization tasks with proper error handling and fallbacks
      await _runInitializationSequence();

      initializationRetryCount.value = 0;
      hasInitializationError.value = false;
      print('HomeController initialization completed successfully');
    } catch (e, stackTrace) {
      print('Critical initialization error: $e');
      print('Stack trace: $stackTrace');

      hasInitializationError.value = true;
      initializationError.value = e.toString();
      initializationRetryCount.value++;

      // Attempt retry if under max attempts
      if (initializationRetryCount.value < maxRetryAttempts) {
        print(
          'Retrying initialization (attempt ${initializationRetryCount.value + 1})...',
        );
        await Future.delayed(
          Duration(seconds: 2 * initializationRetryCount.value),
        );
        isInitializing.value = false;
        return oninits(); // Recursive retry
      } else {
        print('Max retry attempts reached. Loading cached data as fallback...');
        await _loadCachedDataAsFallback();
      }
    } finally {
      isInitializing.value = false;
      update();
    }

    return this;
  }

  /// Initialize core components that are required for basic functionality
  Future<void> _initializeCoreComponents() async {
    try {
      // Initialize caches
      _categoriesCache = BehaviorSubject.seeded(null);
      _productsCache = BehaviorSubject.seeded(null);

      // Initialize scroll listeners
      _initializeScrollListeners();

      print('Core components initialized successfully');
    } catch (e) {
      print('Error initializing core components: $e');
      rethrow;
    }
  }

  /// Run the main initialization sequence with proper error handling
  Future<void> _runInitializationSequence() async {
    try {
      // Critical path: Categories and Products (required for basic functionality)
      await _initializeCriticalData();

      // Non-critical path: Posts and Deals (can fail without breaking core functionality)
      // await _initializeNonCriticalData();
    } catch (e) {
      print('Error in initialization sequence: $e');
      rethrow;
    }
  }

  /// Initialize critical data that's required for core app functionality
  Future<void> _initializeCriticalData() async {
    try {
      // Track success of critical operations
      bool categoriesSuccess = false;
      bool productsSuccess = false;

      // Run critical operations with individual error handling
      final futures = <Future<void>>[];

      // Categories initialization
      futures.add(
        _initializeCategoriesWithFallback()
            .then((_) {
              categoriesSuccess = true;
              print('Categories initialized successfully');
            })
            .catchError((e) {
              print('Categories initialization failed: $e');
            }),
      );

      // Super Deals initialization (now critical for better UX)
      futures.add(
        _initializeDealsProductsWithFallback()
            .then((_) {
              print('Super Deals initialized successfully');
            })
            .catchError((e) {
              print('Super Deals initialization failed: $e');
            }),
      );

      // Products initialization
      futures.add(
        _initializeProductsWithFallback()
            .then((_) {
              productsSuccess = true;
              print('Products initialized successfully');
            })
            .catchError((e) {
              print('Products initialization failed: $e');
            }),
      );

      // Wait for all critical operations to complete
      await Future.wait(futures, eagerError: false);

      // Ensure at least one critical component loaded
      if (!categoriesSuccess && !productsSuccess) {
        throw Exception('Both categories and products failed to load');
      }

      if (!categoriesSuccess) {
        print(
          'Warning: Categories failed to load, but products loaded successfully',
        );
      }

      if (!productsSuccess) {
        print(
          'Warning: Products failed to load, but categories loaded successfully',
        );
      }

      print(
        'Critical data initialization completed (Categories: $categoriesSuccess, Products: $productsSuccess)',
      );
    } catch (e) {
      print('Critical data initialization failed: $e');
      rethrow;
    }
  }

  /// Initialize non-critical data that enhances the experience but isn't required
  Future<void> _initializeNonCriticalData() async {
    try {
      // Run non-critical operations without blocking initialization
      unawaited(_initializePostsWithFallback());
      // Super Deals moved to critical initialization for better reliability

      print('Non-critical data initialization started');
    } catch (e) {
      print('Non-critical data initialization error: $e');
      // Don't rethrow - this shouldn't break initialization
    }
  }

  void _initializeScrollListeners() {
    try {
      scrollController.addListener(() {
        try {
          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 0) {
            if (!isLoading) {
              fetchMoreProducts();
            }
          }
        } catch (e) {
          print('Error in scroll listener: $e');
        }
      });

      categoryPaginationScrollController.addListener(() {
        try {
          if (categoryPaginationScrollController.position.pixels >=
              categoryPaginationScrollController.position.maxScrollExtent -
                  100) {
            if (!isCategorypaginationLoading) {
              print('object $pageCategoryPagination');
              fetchMoreSearches(
                selectedFilter.value,
                minFilter.value,
                maxFilter.value,
              );
            }
          }
        } catch (e) {
          print('Error in category pagination scroll listener: $e');
        }
      });

      categoryScrollController.addListener(() {
        try {
          updateScrollProgress();
        } catch (e) {
          print('Error in category scroll listener: $e');
        }
      });

      print('Scroll listeners initialized successfully');
    } catch (e) {
      print('Error initializing scroll listeners: $e');
    }
  }

  Future<void> _initializePostsWithFallback() async {
    try {
      await fetchLatestPost(forceRefresh: false).timeout(
        apiTimeout,
        onTimeout: () {
          print('Posts fetch timeout, continuing with cached data');
          return null;
        },
      );
    } catch (e) {
      print('Error fetching posts: $e');
      // Load cached posts as fallback
      try {
        final cachedPosts = await _getCachedPosts();
        if (cachedPosts != null) {
          posts.value = cachedPosts;
        }
      } catch (cacheError) {
        print('Error loading cached posts: $cacheError');
      }
    }
  }

  Future<void> _initializeCategoriesWithFallback() async {
    try {
      await _fetchCategoriesFromApi().timeout(
        apiTimeout,
        onTimeout: () {
          throw TimeoutException('Categories fetch timeout');
        },
      );
    } catch (e) {
      print('Error fetching categories from API: $e');
      await _loadCachedCategories();

      if (categories.value.productAttributeItems?.isEmpty ?? true) {
        throw Exception('Failed to load categories and no cache available');
      }
    }
  }

  Future<void> _initializeDealsProductsWithFallback() async {
    try {
      await fetchDealsProducts().timeout(
        apiTimeout,
        onTimeout: () {
          print('Deals products fetch timeout, continuing...');
        },
      );
    } catch (e) {
      print('Error fetching deals products: $e');
      // Load cached deals as fallback
      await _loadCachedDealsProducts();
    }
  }

  Future<void> _initializeProductsWithFallback() async {
    try {
      await fetchInitialProducts().timeout(
        apiTimeout,
        onTimeout: () {
          throw TimeoutException('Products fetch timeout');
        },
      );
    } catch (e) {
      print('Error fetching initial products: $e');
      await _loadCachedProducts();

      if (products.value.products?.data?.isEmpty ?? true) {
        throw Exception('Failed to load products and no cache available');
      }
    }
  }

  Future<void> _loadCachedDataAsFallback() async {
    print('Loading cached data as fallback...');
    try {
      final futures = <Future<void>>[
        _loadCachedCategories(),
        _loadCachedProducts(),
        _loadCachedDealsProducts(),
      ];

      // Load cached posts
      // futures.add(
      //   _getCachedPosts().then((cached) {
      //     if (cached != null) posts.value = cached;
      //   }),
      // );

      await Future.wait(futures, eagerError: false);
      print('Cached data loaded successfully');
    } catch (e) {
      print('Error loading cached data: $e');
    }
  }

  Future<List<ProductDatum>> _fetchSuperDealProduct() async {
    const url =
        "https://api.libanbuy.com/api/products/flash-deals?with=gallery,attribute_items,rating,video,meta&fetchNewDeals=true";

    final headers = {
      'X-Request-From': 'Application',
      'Content-Type': 'application/json',
    };

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(apiTimeout);

    if (response.statusCode != 200) return [];

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) return [];

    final superDeal = superdeals.SuperDeals.fromMap(decoded);

    final isActive =
        superDeal.dealStatus == "active" && superDeal.product != null;

    if (!isActive) return [];

    superdealAvailable.value = superDeal;

    return [_convertSuperDealsProductToProductDatum(superDeal.product!)];
  }

  var superdealAvailable = (superdeals.SuperDeals()).obs;

  Future<List<ProductDatum>> _fetchLightningDealsProducts() async {
    const url =
        "https://api.libanbuy.com/api/products?request_for=LIGHTNING_DEALS_SECTION"
        "&with=thumbnail,shop"
        "&includeFlashDeals=true"
        "&filterByColumns[filterJoin]=AND"
        "&filterByColumns[columns][0][column]=is_deal"
        "&filterByColumns[columns][0][value]=1"
        "&filterByColumns[columns][0][operator]=%3D"
        "&filterByColumns[columns][1][column]=status"
        "&filterByColumns[columns][1][operator]=%3D"
        "&filterByColumns[columns][1][value]=active"
        "&filterByMetaFields[filterJoin]=AND"
        "&filterByMetaFields[fields][0][key]=sold"
        "&filterByMetaFields[fields][0][operator]=%3E"
        "&filterByMetaFields[fields][0][value]=0"
        "&orderBy=super_deals_products_sort_order"
        "&per_page=5";

    final headers = {
      'X-Request-From': 'Application',
      'Content-Type': 'application/json',
    };

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(apiTimeout);

    if (response.statusCode != 200) return [];

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) return [];

    final model = ProductModel.fromJson(decoded);

    return model.products?.data ?? [];
  }

  Future<void> fetchDealsProducts() async {
    try {
      isLoadingDeals.value = true;
      hasDealsError.value = false;
      dealsError.value = '';

      /// 🔥 DONO APIs EK SATH CALL
      final results = await Future.wait([
        _fetchSuperDealProduct(),
        _fetchLightningDealsProducts(),
      ]);

      /// Combine both lists
      final combinedProducts = <ProductDatum>[...results[0], ...results[1]];

      dealsproducts.value = ProductModel(
        products: Products(currentPage: 1, data: combinedProducts),
      );

      debugPrint('🔥 Total Combined Deals: ${combinedProducts.length}');
    } catch (e) {
      debugPrint('❌ Combined Deals Error: $e');
      hasDealsError.value = true;
      dealsError.value = e.toString();
      await _loadCachedDealsProducts();
    } finally {
      isLoadingDeals.value = false;
    }
  }

  // Helper method to convert SuperDeals Product to ProductDatum
  ProductDatum _convertSuperDealsProductToProductDatum(
    superdeals.Product product,
  ) {
    try {
      // Convert Product to Map and then use ProductDatum.fromJson
      final productMap = Map<String, dynamic>.from(product.toMap());

      // Convert the shop structure to match ProductDatum's expected format
      if (productMap['shop'] != null && productMap['shop'] is Map) {
        productMap['shop'] = {'shop': productMap['shop']};
      }

      // Convert meta from List<Meta> to Map format for DatumMeta
      if (productMap['meta'] != null) {
        if (productMap['meta'] is List) {
          // Convert List<Meta> to Map by extracting key-value pairs
          final metaList = productMap['meta'] as List;
          final metaMap = <String, dynamic>{};

          // Extract product_id from first meta item if available
          String? extractedProductId;

          for (var metaItem in metaList) {
            if (metaItem is Map) {
              // Get product_id from meta item
              extractedProductId ??= metaItem['product_id']?.toString();

              final key = metaItem['key']?.toString();
              final value = metaItem['value'];
              if (key != null && value != null) {
                // Map the key-value pairs directly
                metaMap[key] = value;
              }
            }
          }

          // Set product_id if available
          if (metaMap['product_id'] == null) {
            if (extractedProductId != null) {
              metaMap['product_id'] = extractedProductId;
            } else if (product.id != null) {
              metaMap['product_id'] = product.id;
            }
          }

          productMap['meta'] = metaMap;
        } else if (productMap['meta'] is! Map) {
          // If meta is neither List nor Map, remove it
          debugPrint('⚠️ Meta field is not List or Map, removing it');
          productMap.remove('meta');
        }
      }

      // Handle applied_promotions - ensure it's a List
      if (productMap['applied_promotions'] != null &&
          productMap['applied_promotions'] is! List) {
        productMap['applied_promotions'] = [];
      }

      // Parse dates if they exist
      if (productMap['created_at'] != null &&
          productMap['created_at'] is String) {
        try {
          productMap['created_at'] =
              DateTime.parse(productMap['created_at']).toIso8601String();
        } catch (e) {
          debugPrint('⚠️ Error parsing created_at: $e');
        }
      }
      if (productMap['updated_at'] != null &&
          productMap['updated_at'] is String) {
        try {
          productMap['updated_at'] =
              DateTime.parse(productMap['updated_at']).toIso8601String();
        } catch (e) {
          debugPrint('⚠️ Error parsing updated_at: $e');
        }
      }

      debugPrint('📦 Converting product map to ProductDatum...');
      return ProductDatum.fromJson(productMap);
    } catch (e, stackTrace) {
      debugPrint('❌ Error converting SuperDeals Product to ProductDatum: $e');
      debugPrint('📦 Stack trace: $stackTrace');
      rethrow;
    }
  }

  void setSelectedIndexProducts(int index) {
    selectedIndexProducts.value = index;
  }

  // Callback for TabController - set from home_view.dart
  void Function(int index)? onTabChangeCallback;

  // Called when flash deal expires from ProductDetailScreen
  void navigateToTabOnFlashDealExpiry(int tabIndex) {
    selectedIndexProducts.value = tabIndex;
    onTabChangeCallback?.call(tabIndex);
  }

  // Retry method for Super Deals
  Future<void> retryDealsProducts() async {
    print('🔄 Retrying Super Deals fetch...');
    await fetchDealsProducts();
  }

  // Check if flash deals section should be shown
  bool get shouldShowFlashDeals {
    final deals = superdealAvailable.value;

    // Don't show if sequence is completed
    if (deals.dealStatus == "sequence_completed") return false;

    // Don't show if there's no product
    if (deals.product == null) return false;

    // Show if we have a product and deal status is not "sequence_completed"
    // This includes "active" status and any other status with a valid product
    return true;
  }

  // Fetch home page hero banners
  Future<void> fetchHomePageBanners() async {
    try {
      isLoadingBanners.value = true;
      hasBannersError.value = false;

      const fetchUrl =
          "https://api.libanbuy.com/api/posts?with=video&filterByColumns[filterJoin]=OR&filterByColumns[columns][0][column]=post_type&filterByColumns[columns][0][value]=home_page_hero_banners&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][0][banner_status]=active&orderBy=ids&order[]=629e56ae-d378-459e-8edb-8476774c61da&order[]=e3985021-9450-45bd-89a2-7dca0ef1e31e&order[]=c446596e-d9db-4aa2-83b2-1489be8806d9&order[]=87540a70-9674-49ff-979d-3d6183a3744d&order[]=46758353-d0a5-4118-9f1a-26bc720d017c&order[]=2f0a4d17-48c5-4ab3-9b04-4adc578adb4c&order[]=6b956818-2e38-4f24-80ec-e556e5a24ab0&per_page=20";

      // Headers to send with the request
      final headers = {
        'X-Request-From': 'Application',
        'Content-Type': 'application/json',
      };

      // Make direct HTTP call with required headers
      final response = await http
          .get(Uri.parse(fetchUrl), headers: headers)
          .timeout(
            apiTimeout,
            onTimeout: () {
              throw TimeoutException('Banners API timeout');
            },
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch banners: ${response.statusCode} ${response.reasonPhrase}',
        );
      }

      // Parse response
      Map<String, dynamic> responseData;
      try {
        final decodedResponse = jsonDecode(response.body);

        // Handle both Map and List responses
        if (decodedResponse is List) {
          debugPrint(
            '⚠️ API returned a List with ${decodedResponse.length} items',
          );
          if (decodedResponse.isEmpty) {
            throw Exception('Banners API returned an empty list');
          }
          final firstItem = decodedResponse.first;
          if (firstItem is Map<String, dynamic>) {
            responseData = firstItem;
          } else {
            throw Exception(
              'First item in list is not a Map: ${firstItem.runtimeType}',
            );
          }
        } else if (decodedResponse is Map<String, dynamic>) {
          responseData = decodedResponse;
        } else {
          debugPrint(
            '❌ Unexpected response type: ${decodedResponse.runtimeType}',
          );
          throw Exception(
            'Unexpected response type: ${decodedResponse.runtimeType}',
          );
        }
      } catch (e) {
        debugPrint('❌ Error parsing response: $e');
        debugPrint(
          '📦 Response body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}',
        );
        rethrow;
      }

      final result = Banners.fromMap(responseData);
      homePageBanners.value = result;
    } catch (e) {
      debugPrint('❌ Error fetching home page banners: $e');
      hasBannersError.value = true;
    } finally {
      isLoadingBanners.value = false;
    }
  }

  void _calculateCategories(List<Map<String, dynamic>> categoryList) {
    try {
      allCategories = categoryList;
      midIndex = (categoryList.length / 2).ceil();
      topCategories = categoryList.sublist(0, midIndex);
      bottomCategories = categoryList.sublist(midIndex);
    } catch (e) {
      print('Error calculating categories: $e');
      allCategories = categoryList;
      topCategories = categoryList;
      bottomCategories = [];
    }
  }

  void updateScrollProgress() {
    try {
      if (!categoryScrollController.hasClients ||
          categoryScrollController.position.maxScrollExtent == 0) {
        scrollProgress.value = 0.0;
        return;
      }
      final progress =
          categoryScrollController.offset /
          categoryScrollController.position.maxScrollExtent;
      scrollProgress.value =
          (progress.isNaN ? kInitialScrollProgress : progress).clamp(0.2, 1.0);
    } catch (e) {
      print('Error updating scroll progress: $e');
    }
  }

  initializeCategoryList() {
    try {
      final filteredCategories = categories.value.productAttributeItems?.where(
        (e) => e.name != null,
      );

      categoryList =
          filteredCategories
              ?.map(
                (e) => {
                  "icon": e.thumbnail?.media?.url ?? '',
                  "name": e.name!,
                  'id': e.id!,
                  'model': e,
                },
              )
              .toList() ??
          [];

      _calculateCategories(categoryList);
    } catch (e) {
      print('Error initializing category list: $e');
      categoryList = [];
    }
    update();
  }

  initializedcategories() async {
    try {
      await initializeCategoryList();
    } catch (e) {
      print('Error in initializedcategories: $e');
    }
  }

  setSelectedCategory(ProductAttributeItems val) {
    selectedCategory = val;
    update();
  }

  Future<void> _fetchCategoriesFromApi() async {
    try {
      final WebsiteOptionsService optionsService =
          Get.find<WebsiteOptionsService>();

      // Ensure website options are loaded
      if (optionsService.websiteOptions == null) {
        await optionsService.fetchWebsiteOptions().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Website options timeout');
          },
        );
      }

      String? categoriesIds = optionsService.websiteOptions?.headerCategories;

      // Retry once if header categories not found
      if (categoriesIds == null || categoriesIds.isEmpty) {
        await optionsService.fetchWebsiteOptions();
        categoriesIds = optionsService.websiteOptions?.headerCategories;
        if (categoriesIds == null || categoriesIds.isEmpty) {
          throw Exception("Header categories not available");
        }
      }

      // Prepare API URL with category IDs
      final List<String> categoriesList = categoriesIds.split(',');

      // Debug each category ID

      // Check for empty or invalid IDs
      final List<String> validCategories =
          categoriesList.where((id) => id.trim().isNotEmpty).toList();

      // Use hardcoded URL instead of dynamic construction
      const String fetchUrl =
          "https://api.libanbuy.com/api/product-attribute-items?attribute_type=categories&hide_empty=true&limit=50&with=thumbnail,have_sub_categories&ids[]=2759cb74-bd88-4647-ab3c-f9d9e6afb24b&ids[]=58c4b6f8-96d0-4a86-83de-626ccbdd4082&ids[]=ad8be14b-2b32-455b-85f9-626561e4a2b6&ids[]=e07b12fe-df94-4b55-8eed-4f044c7e06df&ids[]=27590706-8e3d-45bf-81cf-3f68efec73c2&ids[]=f74cdd98-fab6-410f-a8a9-89f2abc4ba2d&ids[]=001f11eb-243a-4593-9536-1a855e187d7d&ids[]=0a8d2e22-e386-4951-af10-0d0ae5a3f4bc&ids[]=0cad9a78-46e1-4871-aa8a-2c0fa8a18d03&ids[]=1dc9226e-dc4c-421f-87be-7cecb2dfe388&ids[]=79932ac9-d780-4d81-b82b-dc0ef4834588&ids[]=ed338938-a99f-41dc-929a-1e7ae2179c9a&ids[]=d3c7745b-1560-49ba-9fd1-a29c3b325359&ids[]=b5a88162-6df7-494f-9dad-4cbd01bf30dc&ids[]=c840a4bf-1d01-4719-ac0a-385683f6866f&ids[]=9abe9e53-041a-4e10-96f2-754aa48d98ad&ids[]=7ae9c97a-fd74-44f8-b734-126d998d5917&ids[]=e0b57cab-6b8d-42d4-ab0e-e50c4584bf11&ids[]=6503ad85-7f9b-4efc-98df-d9d702f27685&ids[]=52a2b88d-2131-4d06-a35f-fc40cbe37134";

      // Fetch data with timeout
      final result = await _repository
          .fetchData<CategoryModel>(
            url: fetchUrl,
            fromJson: (json) => CategoryModel.fromJson(json),
            forceRefresh: true,
          )
          .timeout(
            apiTimeout,
            onTimeout: () {
              throw TimeoutException('Categories API timeout');
            },
          );

      // Process results

      if (result.productAttributeItems == null) {
        throw Exception("Invalid category data received");
      }

      // Merge with cached data and update
      final cachedItems = _categoriesCache.value?.productAttributeItems ?? [];
      final newItems = result.productAttributeItems!;

      final updatedItems = _mergeAndFilterCategories(cachedItems, newItems);

      final updatedModel = CategoryModel(productAttributeItems: updatedItems);

      // Update the cache and UI
      _categoriesCache.value = updatedModel;
      categories.value = updatedModel;

      // Process UI data
      await initializedcategories();

      // Background tasks
      unawaited(_cacheCategories(updatedModel));
      unawaited(_prefetchImagesCategories(categories.value));
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> _prefetchImagesCategories(CategoryModel response) async {
    try {
      compute(_prefetchImagesIsolateCategories, response);
    } catch (e) {
      print('Error prefetching category images: $e');
    }
  }

  static void _prefetchImagesIsolateCategories(CategoryModel response) {
    for (var el
        in response.productAttributeItems ?? <ProductAttributeItems>[]) {
      if (el.thumbnail?.media?.url != null) {
        prefetchImageIsolate(el.thumbnail?.media?.url ?? '');
      }
    }
  }

  List<ProductAttributeItems> _mergeAndFilterCategories(
    List<ProductAttributeItems> cached,
    List<ProductAttributeItems> newItems,
  ) {
    try {
      final Map<String, ProductAttributeItems> mergedMap = {};

      for (var item in cached) {
        mergedMap[item.id.toString()] = item;
      }

      for (var item in newItems) {
        mergedMap[item.id.toString()] = item;
      }

      final filteredItems =
          mergedMap.entries
              .where(
                (entry) => newItems.any((apiItem) => apiItem.id == entry.key),
              )
              .map((entry) => entry.value)
              .toList();

      return filteredItems;
    } catch (e) {
      print('Error merging categories: $e');
      return newItems;
    }
  }

  Future<void> fetchInitialProducts() async {
    const url =
        'https://api.libanbuy.com/api/products?request_for=SHOP_PRODUCTS_SECTION&with=thumbnail,shop,variations&filterJoin=AND&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=status&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][0][value]=active&orderBy=created_at&order=desc&per_page=16&page=1';
    try {
      isLoading = true;
      update(['product_grid']); // Show loading immediately

      final result = await _repository
          .fetchData<ProductModel>(
            url: url,
            fromJson: (json) => ProductModel.fromJson(json),
            forceRefresh: true, // Use cache for faster loading
          )
          .timeout(
            apiTimeout,
            onTimeout: () {
              throw TimeoutException('Products API timeout');
            },
          );

      _productsCache.add(result);
      products.value = result;

      // Background tasks
      unawaited(_prefetchImagesProducts(products.value));
      unawaited(_cacheProducts(result));
    } catch (e) {
      print("Error fetching fetchInitialProducts: $e");
      rethrow;
    } finally {
      isLoading = false;
      update(['product_grid']); // Hide loading and show products
    }
  }

  Future<void> _prefetchImagesProducts(ProductModel response) async {
    try {
      compute(_prefetchImagesIsolateProducts, response);
    } catch (e) {
      print('Error prefetching product images: $e');
    }
  }

  static void _prefetchImagesIsolateProducts(ProductModel response) {
    for (var e in (response.products?.data ?? <ProductDatum>[])) {
      prefetchImageIsolate(e.thumbnail?.media?.url ?? '');
    }
  }

  // Enhanced caching methods
  Future<void> _cacheCategories(CategoryModel categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = json.encode({
        'data': categories.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await prefs.setString('cached_categories', cachedData);
    } catch (e) {
      print('Error caching categories: $e');
    }
  }

  Future<void> _loadCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_categories');

      if (cachedData != null) {
        final data = json.decode(cachedData);
        final timestamp = DateTime.parse(data['timestamp']);

        // Use cache if less than 2 hours old
        if (DateTime.now().difference(timestamp).inHours < 2) {
          final cachedCategories = CategoryModel.fromJson(data['data']);
          categories.value = cachedCategories;
          _categoriesCache.value = cachedCategories;
          await initializedcategories();
          print('Loaded categories from cache');
        }
      }
    } catch (e) {
      print('Error loading cached categories: $e');
    }
  }

  Future<void> _cacheProducts(ProductModel products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = json.encode({
        'data': products.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await prefs.setString('cached_products', cachedData);
    } catch (e) {
      print('Error caching products: $e');
    }
  }

  Future<void> _loadCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_products');

      if (cachedData != null) {
        final data = json.decode(cachedData);
        final timestamp = DateTime.parse(data['timestamp']);

        // Use cache if less than 1 hour old
        if (DateTime.now().difference(timestamp).inMinutes < 60) {
          final cachedProducts = ProductModel.fromJson(data['data']);
          products.value = cachedProducts;
          _productsCache.add(cachedProducts);
          print('Loaded products from cache');
        }
      }
    } catch (e) {
      print('Error loading cached products: $e');
    }
  }

  Future<void> _cacheDealsProducts(ProductModel dealsProducts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = json.encode({
        'data': dealsProducts.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await prefs.setString('cached_deals_products', cachedData);
    } catch (e) {
      print('Error caching deals products: $e');
    }
  }

  Future<void> _loadCachedDealsProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_deals_products');

      if (cachedData != null) {
        final data = json.decode(cachedData);
        final timestamp = DateTime.parse(data['timestamp']);

        // Use cache if less than 2 hours old
        if (DateTime.now().difference(timestamp).inHours < 2) {
          final cachedDealsProducts = ProductModel.fromJson(data['data']);
          dealsproducts.value = cachedDealsProducts;
          print('Loaded deals products from cache');
        }
      }
    } catch (e) {
      print('Error loading cached deals products: $e');
    }
  }

  // Enhanced API methods with retry mechanism
  Future<ProductModel> searchRelatedProducts(
    String search, {
    int? page = 1,
    isCategoryUUID = false,
    isDealsection = false,
  }) async {
    String url;
    if (isDealsection) {
      url =
          'https://api.libanbuy.com/api/products?request_for=FLASH_DEALS_ENDED_DEALS_SECTION&with=image,shop&includeFlashDeals=true&filterJoin=AND&filterByColumns%5BfilterJoin%5D=AND&filterByColumns%5Bcolumns%5D%5B0%5D%5Bcolumn%5D=is_deal&filterByColumns%5Bcolumns%5D%5B0%5D%5Boperator%5D=%3D&filterByColumns%5Bcolumns%5D%5B0%5D%5Bvalue%5D=1&filterByMetaFields%5BfilterJoin%5D=AND&filterByMetaFields%5Bfields%5D%5B0%5D%5Bkey%5D=sold&filterByMetaFields%5Bfields%5D%5B0%5D%5Boperator%5D=%3E&filterByMetaFields%5Bfields%5D%5B0%5D%5Bvalue%5D=0&page=1&per_page=10&orderBy=created_at&order=desc';
    } else if (isCategoryUUID) {
      url =
          'https://api.libanbuy.com/api/products?request_for=SHOP_PRODUCTS_SECTION&with=thumbnail,shop,variations,rating,analytics&filterJoin=OR&page=1&per_page=24&filterByColumns[filterJoin]=AND&filterByAttributes[filterJoin]=AND&filterByAttributes[attributes][0][key]=categories&filterByAttributes[attributes][0][value]=$search&filterByAttributes[attributes][0][operator]=%3D';
    } else {
      url =
          'https://api.libanbuy.com/api/products?search=$search&page=1&per_page=40';
    }

    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final result = await _repository
            .fetchData<ProductModel>(
              url: url,
              fromJson: (json) => ProductModel.fromJson(json),
              forceRefresh: true,
            )
            .timeout(
              apiTimeout,
              onTimeout: () {
                throw TimeoutException('Search API timeout');
              },
            );

        for (var e in (result.products?.data ?? <ProductDatum>[])) {
          prefetchImageIsolate(e.thumbnail?.media?.url ?? '');
        }
        return result;
      } catch (e) {
        print("Error fetching related products (attempt ${attempt + 1}): $e");
        if (attempt == 2) rethrow;
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }

    throw Exception('Failed to search related products after 3 attempts');
  }

  Future<void> searchProducts(String search, {int? page = 1}) async {
    final url =
        'https://api.libanbuy.com/api/products?with=thumbnail,shop,variations,rating&filterJoin=OR&page=1&per_page=16&orderBy=relevance&order=desc&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=price&filterByColumns[columns][0][value]=100000000&filterByColumns[columns][0][operator]=%3C%3D&filterByColumns[columns][1][column]=status&filterByColumns[columns][1][value]=active&filterByColumns[columns][1][operator]=%3D&search=$search';
    try {
      selectedFilter.value = 'Most Recent';
      minFilter.value = 0;
      maxFilter.value = 0;
      pageCategoryPagination = 2;
      isViewingSuperDeals = false; // No longer viewing Super Deals
      _searchController.text = search;
      iscategoryLoading.value = true;

      final result = await _repository
          .fetchData<ProductModel>(
            url: url,
            fromJson: (json) => ProductModel.fromJson(json),
            forceRefresh: true,
          )
          .timeout(apiTimeout);

      categoryproducts.value = result;
      filterCategoryproducts.value = result;

      for (var e
          in (categoryproducts.value.products?.data ?? <ProductDatum>[])) {
        prefetchImageIsolate(e.thumbnail?.media?.url ?? '');
      }
    } catch (e) {
      print("Error fetching searchProducts: $e");
    } finally {
      iscategoryLoading.value = false;
      update();
    }
  }

  Future<void> searchSuperDealsProducts() async {
    const url =
        'https://api.libanbuy.com/api/products?request_for=LIGHTNING_DEALS_SECTION&with=thumbnail,shop&includeFlashDeals=true&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=is_deal&filterByColumns[columns][0][value]=1&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][1][column]=status&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=active&filterByMetaFields[filterJoin]=AND&filterByMetaFields[fields][0][key]=sold&filterByMetaFields[fields][0][operator]=%3E&filterByMetaFields[fields][0][value]=0&time_info[current_time]=2025-10-13T17:33:51.606Z&time_info[timezone]=Asia%2FKarachi&time_info[timezone_offset]=-300&time_info[timestamp]=1760376831606&orderBy=ids&order[]=9bec554f-ac00-4e64-9ba3-7e37fcf498fd&order[]=58392141-5507-49ea-ad30-3a7685e381de&order[]=b6071953-13b3-46b7-849c-bfcedc216670&order[]=3b253757-0070-478b-a4e0-a5f5323e9919&order[]=7d2b93b6-e108-4152-9493-0a542fb0f786&order[]=457b7452-d593-4405-98fc-fd44ab751e2c&order[]=dda3a9eb-74e4-4ec3-a252-221c5bff2dd5&order[]=d5edd2d0-e2c9-4017-9e2e-3a805d2852af&order[]=a17902ad-cf41-4e24-97ec-de6e4f022f7e&order[]=91eed342-4b8d-4332-aad4-ef0aeea30e30&order[]=47a5681d-9ecf-4906-bec5-b722236fa147&order[]=5ba626e1-e7f0-43d9-834f-a00a4876889f&order[]=e6b7cb06-8a90-4124-8f83-1a3d4775fe62&order[]=915af87e-b67b-4837-b9b2-28d04b9d2b58&order[]=0b316b4e-e67f-46d5-9537-e35f5734f51f&order[]=e1021419-1476-4eed-9905-08781868bbcd&order[]=62b06126-23bb-42e5-930a-d169ed18870e&order[]=aca2c032-e2b4-4177-bc2a-7d59876e8b5b&order[]=6c393ec7-827a-42e7-a017-8984a1396b60&order[]=77a0954a-e14a-4f15-bc74-a430bd2efbf3&order[]=e82c2601-6955-432d-834d-9be9fb1d737c&order[]=76152226-bf5d-4472-b5db-cd087353c875&order[]=719a8dcd-0fcd-46ca-8f2b-76cdbdaf2183&order[]=4eb768c0-c0fc-4362-b623-801910dd7964&order[]=4c7249bd-5a7c-4640-a54e-ba96473d5599&order[]=ab6c6635-845d-4002-ad52-b4b28d486dd7&order[]=52c904e5-14ab-4e75-b11c-f3be495c30b8&order[]=3144511e-0ff5-41a7-9ef1-cd9d16712476&order[]=589ea167-e211-4971-a9cf-7884909b472b&order[]=e9af2cf4-6255-4fb7-b1b8-a91e2e3c74d0&order[]=5f0b5e71-8118-4760-9831-e1eb530f6fc6&order[]=bebdecbc-bebf-4ac9-ba78-b26978d19f88&order[]=dd2ad39d-56ca-443e-bda5-d5e198e3f83a&order[]=6fad0534-28d4-4838-8b72-daf468c53798&order[]=c84b1b23-5ef5-40d2-91e9-82a2fac95689&order[]=bdcfa7a7-ed82-48e2-b441-898ea0a177af&order[]=367ff7a7-b1fc-4511-a368-7408b5b5892b&order[]=ae45e4c1-cd17-4174-9b6b-ff39bc812d9e&order[]=6a9587fd-ae8f-4938-a4cc-55c8268238e6&order[]=973e14d5-ea9e-4433-9e81-c6ae706d125f&order[]=f861fb7a-9520-4be0-9c3a-e04da63f7ac8&order[]=35cb4009-378a-42b1-b0c3-2c12165fd01d&order[]=714d15f5-1629-4794-848f-0bc629dcf48c&order[]=19c1daff-08d6-468d-b780-985d9864fd8b&order[]=608aa296-1709-4be2-9e66-8c04efe4bc6d&order[]=564abd67-eafa-4dd2-9c78-b7bf03c1ca45&order[]=b0f65d06-244f-48d1-a8f5-8508e92a644b&order[]=2e57eb2f-5b04-4d8e-a208-29f0abf94573&order[]=1da03af0-a137-4bfb-b1c5-7b11e83ffe8d&order[]=12e6c9de-0489-4459-ae57-7e4af7b61d44&order[]=84d3dec6-54c9-43c6-aa20-08fb263278e1&order[]=ab9ec450-3917-4c5d-8c77-83856b50cede&order[]=8f5d72e8-da14-48e4-a7bc-b70644813a23&order[]=a8dc1277-7a9c-47c8-a544-7ea7defc54dd&order[]=0523f51b-9196-4682-88a6-97cff5cfd318&order[]=e8522e65-4811-4d29-82fd-4c0cae4049c5&per_page=40';

    try {
      // Set flag to indicate we're viewing Super Deals
      isViewingSuperDeals = true;
      pageCategoryPagination =
          2; // Reset pagination to page 2 (since we're loading page 1 now)
      hasReachedEndOfPagination = false; // Reset pagination end flag

      iscategoryLoading.value = true;
      final result = await _repository
          .fetchData<ProductModel>(
            url: url,
            fromJson: (json) => ProductModel.fromJson(json),
            forceRefresh: true,
          )
          .timeout(apiTimeout);

      categoryproducts.value = result;
      filterCategoryproducts.value = result;

      for (var e
          in (categoryproducts.value.products?.data ?? <ProductDatum>[])) {
        prefetchImageIsolate(e.thumbnail?.media?.url ?? '');
      }
    } catch (e) {
      print("Error fetching searchSuperDealsProducts: $e");
    } finally {
      iscategoryLoading.value = false;
      update();
    }
  }

  Future<void> fetchMoreSearches(
    String sortBy,
    double _selectedMinPrice,
    double _selectedMaxPrice,
  ) async {
    // Check if we've reached the end of pagination
    if (hasReachedEndOfPagination) {
      print('Already reached end of pagination');
      return;
    }

    String baseUrl;

    // If viewing Super Deals, use Lightning Deals API with pagination
    if (isViewingSuperDeals) {
      baseUrl =
          'https://api.libanbuy.com/api/products?request_for=LIGHTNING_DEALS_SECTION&with=thumbnail,shop&includeFlashDeals=true&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=is_deal&filterByColumns[columns][0][value]=1&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][1][column]=status&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=active&filterByMetaFields[filterJoin]=AND&filterByMetaFields[fields][0][key]=sold&filterByMetaFields[fields][0][operator]=%3E&filterByMetaFields[fields][0][value]=0&time_info[current_time]=2025-10-13T17:33:51.606Z&time_info[timezone]=Asia%2FKarachi&time_info[timezone_offset]=-300&time_info[timestamp]=1760376831606&orderBy=ids&order[]=9bec554f-ac00-4e64-9ba3-7e37fcf498fd&order[]=58392141-5507-49ea-ad30-3a7685e381de&order[]=b6071953-13b3-46b7-849c-bfcedc216670&order[]=3b253757-0070-478b-a4e0-a5f5323e9919&order[]=7d2b93b6-e108-4152-9493-0a542fb0f786&order[]=457b7452-d593-4405-98fc-fd44ab751e2c&order[]=dda3a9eb-74e4-4ec3-a252-221c5bff2dd5&order[]=d5edd2d0-e2c9-4017-9e2e-3a805d2852af&order[]=a17902ad-cf41-4e24-97ec-de6e4f022f7e&order[]=91eed342-4b8d-4332-aad4-ef0aeea30e30&order[]=47a5681d-9ecf-4906-bec5-b722236fa147&order[]=5ba626e1-e7f0-43d9-834f-a00a4876889f&order[]=e6b7cb06-8a90-4124-8f83-1a3d4775fe62&order[]=915af87e-b67b-4837-b9b2-28d04b9d2b58&order[]=0b316b4e-e67f-46d5-9537-e35f5734f51f&order[]=e1021419-1476-4eed-9905-08781868bbcd&order[]=62b06126-23bb-42e5-930a-d169ed18870e&order[]=aca2c032-e2b4-4177-bc2a-7d59876e8b5b&order[]=6c393ec7-827a-42e7-a017-8984a1396b60&order[]=77a0954a-e14a-4f15-bc74-a430bd2efbf3&order[]=e82c2601-6955-432d-834d-9be9fb1d737c&order[]=76152226-bf5d-4472-b5db-cd087353c875&order[]=719a8dcd-0fcd-46ca-8f2b-76cdbdaf2183&order[]=4eb768c0-c0fc-4362-b623-801910dd7964&order[]=4c7249bd-5a7c-4640-a54e-ba96473d5599&order[]=ab6c6635-845d-4002-ad52-b4b28d486dd7&order[]=52c904e5-14ab-4e75-b11c-f3be495c30b8&order[]=3144511e-0ff5-41a7-9ef1-cd9d16712476&order[]=589ea167-e211-4971-a9cf-7884909b472b&order[]=e9af2cf4-6255-4fb7-b1b8-a91e2e3c74d0&order[]=5f0b5e71-8118-4760-9831-e1eb530f6fc6&order[]=bebdecbc-bebf-4ac9-ba78-b26978d19f88&order[]=dd2ad39d-56ca-443e-bda5-d5e198e3f83a&order[]=6fad0534-28d4-4838-8b72-daf468c53798&order[]=c84b1b23-5ef5-40d2-91e9-82a2fac95689&order[]=bdcfa7a7-ed82-48e2-b441-898ea0a177af&order[]=367ff7a7-b1fc-4511-a368-7408b5b5892b&order[]=ae45e4c1-cd17-4174-9b6b-ff39bc812d9e&order[]=6a9587fd-ae8f-4938-a4cc-55c8268238e6&order[]=973e14d5-ea9e-4433-9e81-c6ae706d125f&order[]=f861fb7a-9520-4be0-9c3a-e04da63f7ac8&order[]=35cb4009-378a-42b1-b0c3-2c12165fd01d&order[]=714d15f5-1629-4794-848f-0bc629dcf48c&order[]=19c1daff-08d6-468d-b780-985d9864fd8b&order[]=608aa296-1709-4be2-9e66-8c04efe4bc6d&order[]=564abd67-eafa-4dd2-9c78-b7bf03c1ca45&order[]=b0f65d06-244f-48d1-a8f5-8508e92a644b&order[]=2e57eb2f-5b04-4d8e-a208-29f0abf94573&order[]=1da03af0-a137-4bfb-b1c5-7b11e83ffe8d&order[]=12e6c9de-0489-4459-ae57-7e4af7b61d44&order[]=84d3dec6-54c9-43c6-aa20-08fb263278e1&order[]=ab9ec450-3917-4c5d-8c77-83856b50cede&order[]=8f5d72e8-da14-48e4-a7bc-b70644813a23&order[]=a8dc1277-7a9c-47c8-a544-7ea7defc54dd&order[]=0523f51b-9196-4682-88a6-97cff5cfd318&order[]=e8522e65-4811-4d29-82fd-4c0cae4049c5&per_page=40&page=$pageCategoryPagination';
    } else {
      // Default behavior for categories/search
      baseUrl =
          "https://api.libanbuy.com/api/products?with=thumbnail,shop,variations,rating&filterJoin=OR&page=$pageCategoryPagination&per_page=16";

      // Sorting
      if (sortBy == "Low to high (price)") {
        baseUrl += "&orderBy=price&order=asc";
      } else if (sortBy == "High to low (price)") {
        baseUrl += "&orderBy=price&order=desc";
      } else if (sortBy == "Featured Products") {
        baseUrl +=
            "&customOrder=featured_products_first&orderBy=is_featured&order=desc";
      } else {
        baseUrl += "&orderBy=created_at&order=desc";
      }

      // Filters
      final String filters =
          "&filterByColumns[filterJoin]=AND"
          "&filterByColumns[columns][0][column]=price"
          "&filterByColumns[columns][0][value]=$_selectedMinPrice"
          "&filterByColumns[columns][0][operator]=%3E%3D"
          "&filterByColumns[columns][1][column]=price"
          "&filterByColumns[columns][1][value]=${_selectedMaxPrice == 0.0 ? 100000 : _selectedMaxPrice}"
          "&filterByColumns[columns][1][operator]=%3C%3D"
          "&filterByColumns[columns][2][column]=product_group"
          "&filterByColumns[columns][2][value]=car"
          "&filterByColumns[columns][2][operator]=${selectedCategory?.postType == 'car' ? "%3D" : "!%3D"}"
          "&filterByColumns[columns][3][column]=status"
          "&filterByColumns[columns][3][value]=active"
          "&filterByColumns[columns][3][operator]=%3D";

      // Apply search + category combinations
      if (_searchController.text.isEmpty && selectedCategory?.id != null) {
        baseUrl +=
            "$filters&filterByAttributes[filterJoin]=AND&filterByAttributes[attributes][0][key]=categories&filterByAttributes[attributes][0][value]=${selectedCategory?.id}&filterByAttributes[attributes][0][operator]=%3D";
      } else if (_searchController.text.isNotEmpty &&
          selectedCategory?.id == null) {
        baseUrl += "$filters&search=${_searchController.text}";
      } else if (_searchController.text.isNotEmpty &&
          selectedCategory?.id != null) {
        baseUrl +=
            "$filters&filterByAttributes[filterJoin]=AND&filterByAttributes[attributes][0][key]=categories&filterByAttributes[attributes][0][value]=${selectedCategory?.id}&filterByAttributes[attributes][0][operator]=%3D&search=${_searchController.text}";
      } else {
        baseUrl += filters;
      }
    }

    try {
      if (isCategorypaginationLoading) return;
      isCategorypaginationLoading = true;
      // Trigger UI update so loaders can show immediately
      update();
      final result = await _repository
          .fetchData<ProductModel>(
            url: baseUrl,
            fromJson: (json) => ProductModel.fromJson(json),
          )
          .timeout(apiTimeout);

      // Check if API returned any products
      final newProducts = result.products?.data ?? [];

      // If no new products returned, we've reached the end
      if (newProducts.isEmpty) {
        print('No more products available - reached end of pagination');
        hasReachedEndOfPagination = true;
        return;
      }

      // Safely append products
      if (filterCategoryproducts.value.products?.data != null) {
        filterCategoryproducts.value.products!.data!.addAll(newProducts);
      }

      pageCategoryPagination++;
    } catch (e) {
      print("Error fetching fetchMoreSearches: $e");
    } finally {
      isCategorypaginationLoading = false;
      update();
    }
  }

  Future<void> fetchCategoryProductsa(String categoryId) async {
    try {
      _searchController.clear();
      selectedFilter.value = 'Most Recent';
      minFilter.value = 0;
      maxFilter.value = 0;
      // Reset pagination state for new category
      hasReachedEndOfPagination = false;
      pageCategoryPagination = 2;
      isViewingSuperDeals = false; // No longer viewing Super Deals
      await fetchProducts(categoryId);
    } catch (e) {
      print('Error in fetchCategoryProductsa: $e');
    }
  }

  Future<void> fetchProducts(String categoryId) async {
    try {
      iscategoryLoading.value = true;

      // Prepare request
      // final requestUrl = "${CategoryApiService.baseUrl}?categoryId=$categoryId";
      // final headers = {"Content-Type": "application/json"};

      // Log request details
      // print("📌 Fetching Products...");
      // print("➡️ URL: $requestUrl");
      // print("➡️ Headers: $headers");

      // API Call
      final ress = await CategoryApiService()
          .fetchProducts(
            categoryId: categoryId,
            product_group_car:
                selectedCategory?.postType == 'car' ? true : false,
          )
          .timeout(apiTimeout);

      // Check and parse response
      if (ress is Map<String, dynamic>) {
        categoryproducts.value = ProductModel.fromJson(ress);
        filterCategoryproducts.value = ProductModel.fromJson(ress);

        final productsList = categoryproducts.value.products?.data ?? [];

        // Prefetch images
        for (var e in productsList) {
          final imageUrl = e.thumbnail?.media?.url ?? '';

          prefetchImageIsolate(imageUrl);
        }
      } else {
        print(
          "⚠️ Unexpected response format, initializing empty ProductModel.",
        );
        categoryproducts.value = ProductModel(
          products: Products(currentPage: 1, data: []),
        );
        filterCategoryproducts.value = ProductModel(
          products: Products(currentPage: 1, data: []),
        );
      }
    } catch (e, stacktrace) {
      print('❌ Error fetching products: $e');
      print("🧵 Stacktrace: $stacktrace");

      // Reset state to empty
      categoryproducts.value = ProductModel(
        products: Products(currentPage: 1, data: []),
      );
      filterCategoryproducts.value = ProductModel(
        products: Products(currentPage: 1, data: []),
      );
    } finally {
      iscategoryLoading.value = false;

      update();
    }
  }

  void resetProducts() {
    categoryproducts.value = ProductModel(
      products: Products(currentPage: 1, data: []),
    );
    filterCategoryproducts.value = ProductModel(
      products: Products(currentPage: 1, data: []),
    );
  }

  void filterCategoryProductss(
    String sortBy,
    double _selectedMinPrice,
    double _selectedMaxPrice,
    BuildContext context,
  ) async {
    try {
      filterCategoryproducts.value = ProductModel(
        products: Products(currentPage: 1, data: []),
      );
      selectedFilter.value = sortBy;
      iscategoryLoading.value = true;
      update();
      pageCategoryPagination = 2;
      isViewingSuperDeals =
          false; // Applying filters means we're no longer in Super Deals mode

      String baseUrl =
          "https://api.libanbuy.com/api/products?with=thumbnail,shop,variations,rating&filterJoin=OR&page=1&per_page=16";

      // Sorting conditions
      if (sortBy == "Low to high (price)") {
        baseUrl += "&orderBy=price&order=asc";
      } else if (sortBy == "High to low (price)") {
        baseUrl += "&orderBy=price&order=desc";
      } else if (sortBy == "Featured Products") {
        baseUrl +=
            "&customOrder=featured_products_first&orderBy=is_featured&order=desc";
      } else {
        baseUrl += "&orderBy=created_at&order=desc";
      }

      // Common filters
      final String filters =
          "&filterByColumns[filterJoin]=AND"
          "&filterByColumns[columns][0][column]=price"
          "&filterByColumns[columns][0][value]=$_selectedMinPrice"
          "&filterByColumns[columns][0][operator]=%3E%3D"
          "&filterByColumns[columns][1][column]=price"
          "&filterByColumns[columns][1][value]=${_selectedMaxPrice == 0.0 ? 100000 : _selectedMaxPrice}"
          "&filterByColumns[columns][1][operator]=%3C%3D"
          "&filterByColumns[columns][2][column]=product_group"
          "&filterByColumns[columns][2][value]=car"
          "&filterByColumns[columns][2][operator]=${selectedCategory?.postType == 'car' ? "%3D" : "!%3D"}"
          "&filterByColumns[columns][3][column]=status"
          "&filterByColumns[columns][3][value]=active"
          "&filterByColumns[columns][3][operator]=%3D";

      // Apply search and category logic
      if (_searchController.text.isEmpty && selectedCategory?.id != null) {
        baseUrl +=
            "$filters&filterByAttributes[filterJoin]=AND&filterByAttributes[attributes][0][key]=categories&filterByAttributes[attributes][0][value]=${selectedCategory?.id}&filterByAttributes[attributes][0][operator]=%3D";
      } else if (_searchController.text.isNotEmpty &&
          selectedCategory?.id == null) {
        baseUrl += "$filters&search=${_searchController.text}";
      } else if (_searchController.text.isNotEmpty &&
          selectedCategory?.id != null) {
        baseUrl +=
            "$filters&filterByAttributes[filterJoin]=AND&filterByAttributes[attributes][0][key]=categories&filterByAttributes[attributes][0][value]=${selectedCategory?.id}&filterByAttributes[attributes][0][operator]=%3D&search=${_searchController.text}";
      } else {
        baseUrl += filters;
      }

      final result = await _repository
          .fetchData<ProductModel>(
            url: baseUrl,
            fromJson: (json) => ProductModel.fromJson(json),
            forceRefresh: true,
          )
          .timeout(apiTimeout);

      categoryproducts.value = result;
      filterCategoryproducts.value = result;
    } catch (e) {
      print('Error in filterCategoryProductss: $e');
      if (context.mounted) {
        NotificationHelper.showError(
          context,
          'Filters Search',
          'No products found',
        );
      }
      categoryproducts.value = ProductModel(products: Products(data: []));
      filterCategoryproducts.value = ProductModel(products: Products(data: []));
    } finally {
      iscategoryLoading.value = false;
      update();
    }
  }

  Future<void> fetchMoreProducts() async {
    try {
      if (isLoading) return;
      isLoading = true;
      // Trigger grid to show footer loader immediately
      update(['product_grid']);

      // All products
      if (selectedIndexProducts.value == 0) {
        final url =
            'https://api.libanbuy.com/api/products?request_for=SHOP_PRODUCTS_SECTION&with=thumbnail,shop,variations&filterJoin=AND&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=status&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][0][value]=active&orderBy=created_at&order=desc&per_page=12&page=$page';
        final result = await _repository
            .fetchData<ProductModel>(
              url: url,
              fromJson: (json) => ProductModel.fromJson(json),
            )
            .timeout(apiTimeout);

        _productsCache.add(result);

        if (products.value.products?.data != null) {
          products.value.products!.data!.addAll(result.products?.data ?? []);
        }

        page = page + 1;
      } else {
        // Filtered products (On Sale, Featured, Cars, Hot Auctions)
        final filterUrl = _buildFilteredUrl(
          selectedIndexProducts.value,
          pageFiltered,
        );

        final result = await _repository
            .fetchData<ProductModel>(
              url: filterUrl,
              forceRefresh: true,
              fromJson: (json) => ProductModel.fromJson(json),
            )
            .timeout(apiTimeout);

        if (products.value.products?.data != null) {
          products.value.products!.data!.addAll(result.products?.data ?? []);
        }

        pageFiltered = pageFiltered + 1;
      }
    } catch (e) {
      print("Error fetching fetchMoreProducts: $e");
    } finally {
      isLoading = false;
      // Update grid to remove footer loader and show appended items
      update(['product_grid']);
    }
  }

  // Build filtered URLs with pagination
  String _buildFilteredUrl(int index, int pageNumber) {
    const baseUrl = 'https://api.libanbuy.com/api/products';
    final commonParams =
        '?with=thumbnail,shop&filterByColumns[filterJoin]=AND&per_page=12&page=$pageNumber';

    switch (index) {
      case 1: // On Sale
        return 'https://api.libanbuy.com/api/products?request_for=SHOP_PRODUCTS_SECTION&with=thumbnail,shop,variations,rating&filterJoin=OR&time_info[current_time]=2025-09-25T13:22:36.569Z&time_info[timezone]=Asia%2FKarachi&time_info[timezone_offset]=-300&time_info[timestamp]=1758806556569&page=$pageNumber&per_page=16&customOrder=featured_sale_products_first&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=sale_price&filterByColumns[columns][0][value]=1&filterByColumns[columns][0][operator]=%3E&filterByColumns[columns][1][column]=price&filterByColumns[columns][1][value]=100000000&filterByColumns[columns][1][operator]=%3C%3D&filterByColumns[columns][2][column]=product_group&filterByColumns[columns][2][value]=car&filterByColumns[columns][2][operator]=!%3D&filterByColumns[columns][3][column]=status&filterByColumns[columns][3][value]=active&filterByColumns[columns][3][operator]=%3D';
      case 2: // Featured
        return '$baseUrl$commonParams&filterByColumns[columns][0][column]=is_featured&filterByColumns[columns][0][value]=1&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][1][column]=status&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=active';
      case 3: // Cars

        return '$baseUrl$commonParams&filterByColumns[columns][0][column]=product_group&filterByColumns[columns][0][value]=car&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][1][column]=status&filterByColumns[columns][1][operator]=%3D&filterByColumns[columns][1][value]=active';
      case 4: // Hot Auctions
        return '$baseUrl$commonParams&filterByColumns[columns][0][column]=product_type&filterByColumns[columns][0][value]=auction&filterByColumns[columns][0][operator]=%3D';

      default:
        return '$baseUrl?page=$pageNumber&per_page=14';
    }
  }

  // Load first page for filtered tabs
  Future<void> loadFilteredFirstPage(int index) async {
    try {
      isLoading = true;
      pageFiltered = 2;
      final url = _buildFilteredUrl(index, 1);
      final result = await _repository
          .fetchData<ProductModel>(
            forceRefresh: true,
            url: url,
            fromJson: (json) => ProductModel.fromJson(json),
          )
          .timeout(apiTimeout);

      // Replace current products with filtered page 1
      products.value = result;
      update(['product_grid']);
    } catch (e) {
      print('Error loading filtered first page: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Prepare UI for filtered loading (clear list and show shimmer)
  void startFilteredLoading() {
    try {
      isLoading = true;
      products.value = ProductModel(
        products: Products(currentPage: 1, data: []),
      );
      update(['product_grid']);
    } catch (_) {}
  }

  Future<List<ProductDatum>> fetchAuctionProducts(String url) async {
    try {
      final result = await _repository
          .fetchData<ProductModel>(
            url: url,
            fromJson: (json) => ProductModel.fromJson(json),
          )
          .timeout(apiTimeout);

      return result.products?.data ?? [];
    } catch (e) {
      print('Error fetching auction products: $e');
      rethrow;
    }
  }

  Future<SingleModelClass?> fetchSingleProducts(String productId) async {
    final baseUrl = 'https://api.libanbuy.com/api/products/$productId';
    const query = 'with=gallery';
    final url = '$baseUrl?$query';

    try {
      final res = await _repository
          .fetchData<SingleModelClass>(
            url: url,
            fromJson: (json) {
              return SingleModelClass.fromJson(json);
            },
            forceRefresh: true,
          )
          .timeout(apiTimeout);

      if (res.product?.gallery != null) {
        for (var ele in res.product!.gallery) {
          if (ele.media?.url != null) {
            prefetchImageIsolate(ele.media!.url ?? '');
          }
        }
      }
      return res;
    } catch (e) {
      print('Error fetching single product: $e');
      rethrow;
    }
  }

  // Posts management with enhanced error handling
  Future<PostResponse?> fetchLatestPost({bool forceRefresh = false}) async {
    // Check if we can use cached data first
    if (!forceRefresh) {
      final cachedData = await _getCachedPosts();
      if (cachedData != null) {
        posts.value = cachedData;
        return cachedData;
      }
    }

    // Load cached data for immediate UI update
    final cachedData = await _getCachedPosts();
    if (cachedData != null) {
      posts.value = cachedData;
      update();
    }

    isLoadingPosts.value = true;
    hasError.value = false;

    const String url =
        "https://api.libanbuy.com/api/posts?with=thumbnail,shop&filterJoin=OR&orderBy=created_at&order=desc&page=1&per_page=18&filterByColumns[filterJoin]=AND&filterByColumns[column][0][key]=post_type&filterByColumns[column][0][value]=shop_stories&filterByColumns[column][0][operator]==&with=video&likes=2";

    try {
      final response = await http
          .get(Uri.parse(url), headers: {'X-Request-From': 'Application'})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Posts API timeout');
            },
          );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final res = PostResponse.fromJson(jsonResponse);

        // Sort posts
        res.posts.data.sort((a, b) {
          final int updatedAtComparison = a.updatedAt.compareTo(b.updatedAt);
          if (updatedAtComparison == 0) {
            return a.createdAt.compareTo(b.createdAt);
          }
          return updatedAtComparison;
        });

        // Remove inactive posts
        res.posts.data.removeWhere((ele) => ele.status != 'active');

        // Cache and prefetch in background
        unawaited(_cachePosts(res));
        unawaited(_prefetchImages(res));

        posts.value = res;
        isLoadingPosts.value = false;
        return res;
      } else {
        hasError.value = true;
        final cachedData = await _getCachedPosts();
        if (cachedData != null) {
          posts.value = cachedData;
        }
        isLoadingPosts.value = false;
        return null;
      }
    } catch (e) {
      print("Error fetching posts: $e");
      hasError.value = true;

      // Return cached data if available
      final cachedData = await _getCachedPosts();
      if (cachedData != null) {
        posts.value = cachedData;
      }

      isLoadingPosts.value = false;
      return cachedData;
    } finally {
      update();
    }
  }

  Future<void> _prefetchImages(PostResponse response) async {
    try {
      compute(_prefetchImagesIsolate, response);
    } catch (e) {
      print('Error prefetching post images: $e');
    }
  }

  static void _prefetchImagesIsolate(PostResponse response) {
    for (var ele in response.posts.data) {
      if (ele.thumbnail?.media?.url != null) {
        prefetchImageIsolate(ele.thumbnail?.media?.url ?? '');
      }
    }
  }

  Future<void> _cachePosts(PostResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPostsJson = json.encode({
        'data': response.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await prefs.setString(_CACHE_KEY, cachedPostsJson);
    } catch (e) {
      print('Error caching posts: $e');
    }
  }

  Future<PostResponse?> _getCachedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPostsJson = prefs.getString(_CACHE_KEY);

      if (cachedPostsJson != null) {
        final cachedData = json.decode(cachedPostsJson);
        final timestamp = DateTime.parse(cachedData['timestamp']);

        // Check if cache is still valid
        if (DateTime.now().difference(timestamp).inHours <
            _CACHE_EXPIRATION_HOURS) {
          return PostResponse.fromJson(cachedData['data']);
        }
      }
    } catch (e) {
      print('Error loading cached posts: $e');
    }
    return null;
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_CACHE_KEY),
        prefs.remove('cached_categories'),
        prefs.remove('cached_products'),
        prefs.remove('cached_deals_products'),
      ]);
      print('All caches cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Public method to retry initialization if needed
  Future<void> retryInitialization() async {
    if (isInitializing.value) return;

    initializationRetryCount.value = 0;
    await oninits();
  }

  @override
  void onClose() {
    try {
      categoryScrollController.dispose();
      scrollController.dispose();
      categoryPaginationScrollController.dispose();
      _searchController.dispose();
      selectedIndex.dispose();
      _categoriesCache.close();
      _productsCache.close();
    } catch (e) {
      print('Error disposing HomeController: $e');
    }
    super.onClose();
  }
}
