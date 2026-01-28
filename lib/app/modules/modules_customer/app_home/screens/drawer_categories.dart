import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/core/widgets/appbar.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/related_products_grid.dart';
import 'package:tjara/app/repo/network_repository.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? selectedCategoryId;
  int selectedCategoryIndex = -1;
  bool isInitializing = true;
  bool hasTriedAllCategories = false;

  // ✅ Cache for subcategories
  static final Map<String, CategoryModel> _subCategoriesCache = {};
  static final Map<String, bool> _loadingStates = {};

  // ✅ NEW: Track categories that are confirmed empty (already handled)
  static final Set<String> _handledEmptyCategories = {};

  // ✅ NEW: Track if we already navigated away for current session
  bool _hasNavigatedAwayThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFirstValidCategory();
    });
  }

  Future<void> _initializeFirstValidCategory() async {
    final controller = Get.find<HomeController>();
    final allCategories = controller.allCategories;

    if (allCategories.isEmpty) {
      setState(() {
        isInitializing = false;
      });
      return;
    }

    for (int i = 0; i < allCategories.length; i++) {
      final categoryId = allCategories[i]["id"]?.toString() ?? '';
      if (categoryId.isNotEmpty) {
        // ✅ Skip already known empty categories
        if (_handledEmptyCategories.contains(categoryId)) {
          continue;
        }

        final hasSubcategories = await _checkIfCategoryHasSubcategories(
          categoryId,
        );
        if (hasSubcategories) {
          setState(() {
            selectedCategoryId = categoryId;
            selectedCategoryIndex = i;
            isInitializing = false;
          });
          return;
        } else {
          // ✅ Mark as empty so we don't check again
          _handledEmptyCategories.add(categoryId);
        }
      }
    }

    setState(() {
      hasTriedAllCategories = true;
      isInitializing = false;
    });
  }

  Future<bool> _checkIfCategoryHasSubcategories(String categoryId) async {
    // ✅ Check cache first
    if (_subCategoriesCache.containsKey(categoryId)) {
      final cached = _subCategoriesCache[categoryId]!;
      return (cached.productAttributeItems ?? []).isNotEmpty;
    }

    try {
      final NetworkRepository repository = NetworkRepository();
      final result = await repository
          .fetchData<CategoryModel>(
            url:
                'https://api.libanbuy.com/api/product-attribute-items?attribute_slug=categories&post_type=product&with=thumbnail,+parent&parent_id=$categoryId&hide_empty=true&order_by=name&order=ASC&limit=all',
            fromJson: (json) => CategoryModel.fromJson(json),
            forceRefresh: true,
          )
          .timeout(const Duration(seconds: 30));

      // ✅ Cache the result
      _subCategoriesCache[categoryId] = result;

      final items = result.productAttributeItems ?? [];
      return items.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ✅ NEW: Called by child when empty category needs handling
  void handleEmptyCategoryAndMoveNext(String categoryId) {
    // Mark this category as handled
    _handledEmptyCategories.add(categoryId);

    // ✅ Prevent multiple navigations in same session
    if (_hasNavigatedAwayThisSession) return;
    _hasNavigatedAwayThisSession = true;

    // Navigate away (handle empty subcategories)
    _performEmptyCategoryNavigation(categoryId);

    // ✅ Also find and set next valid category for when user returns
    _selectNextValidCategory();
  }

  void _performEmptyCategoryNavigation(String categoryId) {
    try {
      DashboardController.instance.reset();
      final controller = Get.find<HomeController>();
      controller.fetchCategoryProductsa(categoryId);

      final model = ProductAttributeItems();
      controller.setSelectedCategory(model);
    } catch (e) {
      debugPrint('Error handling empty subcategories: $e');
    }
  }

  void _selectNextValidCategory() {
    final controller = Get.find<HomeController>();
    final allCategories = controller.allCategories;

    // Find next category that's not in handledEmpty set
    for (int i = 0; i < allCategories.length; i++) {
      final categoryId = allCategories[i]["id"]?.toString() ?? '';
      if (categoryId.isNotEmpty &&
          !_handledEmptyCategories.contains(categoryId)) {
        // Check if we have it cached as having subcategories
        if (_subCategoriesCache.containsKey(categoryId)) {
          final cached = _subCategoriesCache[categoryId]!;
          if ((cached.productAttributeItems ?? []).isNotEmpty) {
            setState(() {
              selectedCategoryId = categoryId;
              selectedCategoryIndex = i;
            });
            return;
          }
        } else {
          // Not cached, assume it might have subcategories
          setState(() {
            selectedCategoryId = categoryId;
            selectedCategoryIndex = i;
          });
          return;
        }
      }
    }

    // All categories are empty
    setState(() {
      hasTriedAllCategories = true;
    });
  }

  // ✅ Reset navigation flag when screen becomes visible again
  void resetNavigationFlag() {
    _hasNavigatedAwayThisSession = false;
  }

  // ✅ Check if category is already known to be empty
  bool isCategoryKnownEmpty(String categoryId) {
    return _handledEmptyCategories.contains(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        final allCategories = controller.allCategories;
        final hasCategories = allCategories.isNotEmpty;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          extendBodyBehindAppBar: false,
          body: Stack(
            children: [
              // ✨ Gradient Background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.35,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFfea52d),
                        const Color(0xFFfea52d).withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).padding.top,
                    color: const Color(0xFFfda730),
                  ),
                  const CustomAppBar(
                    showWhitebackground: false,
                    showActions: false,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(color: Color(0xfffeeedf)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: Color(0xff0a8700),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Free Shipping',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff0a8700),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(' | ', style: TextStyle(color: Color(0xff0a8700))),
                        Text(
                          'Price adjustment within 30 days',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xff0a8700),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side - Categories list
                        Container(
                          width: 110,
                          color: const Color(0xFFf5f5f5),
                          child: _buildCategoriesList(
                            controller,
                            hasCategories,
                          ),
                        ),
                        // Right side - Subcategories grid
                        Expanded(child: _buildRightSide()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRightSide() {
    if (isInitializing) {
      return _buildShimmerLoading();
    }

    if (hasTriedAllCategories) {
      return const Center(
        child: Text(
          'Please select a category',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (selectedCategoryId != null) {
      // ✅ Check if this category is already known to be empty
      if (_handledEmptyCategories.contains(selectedCategoryId)) {
        // Don't even try to load, just show loading and move on
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _selectNextValidCategory();
        });
        return _buildShimmerLoading();
      }

      return _SubCategoriesSection(
        key: ValueKey(selectedCategoryId),
        parentName: _getSelectedCategoryName(), // ✅ Add this
        parentId: selectedCategoryId!,
        isUserSelected: selectedCategoryIndex != -1,
        parentState: this,
      );
    }

    return _buildShimmerLoading();
  }

  String _getSelectedCategoryName() {
    if (selectedCategoryIndex >= 0) {
      final controller = Get.find<HomeController>();
      if (selectedCategoryIndex < controller.allCategories.length) {
        return controller.allCategories[selectedCategoryIndex]["name"]
                ?.toString() ??
            '';
      }
    }
    return '';
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4, top: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 24,
              itemBuilder: (context, index) {
                return _buildShimmerItem();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEmptySubcategories(String categoryId) {
    try {
      DashboardController.instance.reset();
      final controller = Get.find<HomeController>();
      controller.fetchCategoryProductsa(categoryId);

      final model = ProductAttributeItems();
      controller.setSelectedCategory(model);
    } catch (e) {
      debugPrint('Error handling empty subcategories: $e');
    }
  }

  Widget _buildCategoriesList(HomeController controller, bool hasCategories) {
    if (!hasCategories) {
      return ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: controller.allCategories.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.allCategories.length) {
          return Container(height: 150);
        }

        final category = controller.allCategories[index];
        final categoryName = category["name"]?.toString() ?? 'Unnamed';
        final categoryId = category["id"]?.toString() ?? '';
        final isSelected = selectedCategoryIndex == index;

        // ✅ Show indicator if category is known empty
        final isKnownEmpty = _handledEmptyCategories.contains(categoryId);

        return GestureDetector(
          onTap: () {
            if (isKnownEmpty) {
              _handleEmptySubcategories(categoryId);
              return;
            }
            // ✅ Reset navigation flag when user manually selects
            _hasNavigatedAwayThisSession = false;

            setState(() {
              selectedCategoryId = categoryId;
              selectedCategoryIndex = index;
              hasTriedAllCategories = false;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: isSelected ? 0 : 10,
            ),
            color: isSelected ? Colors.white : Colors.transparent,
            child: Row(
              children: [
                if (isSelected)
                  Container(
                    width: 5,
                    height: 15,
                    color: const Color(0xFFF97316),
                  ),
                if (isSelected) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? const Color(0xFFF97316)
                              : isKnownEmpty
                              ? Colors.grey
                              : Colors.black87,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ========================================
// 🎨 Helper: Dynamic Color Generator
// ========================================
class CategoryColorHelper {
  static Color getColorFromName(String name) {
    final colors = [
      const Color(0xFF2C6B7A),
      const Color(0xFF4A90E2),
      const Color(0xFFF5A623),
      const Color(0xFF50C9CE),
      const Color(0xFF2D5E3F),
      const Color(0xFFE8A23D),
      const Color(0xFFE76F6F),
      const Color(0xFF9B59B6),
      const Color(0xFF3498DB),
      const Color(0xFFE67E22),
    ];

    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  static IconData getIconFromName(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('shoe') || lowerName.contains('foot')) {
      return Icons.shopping_bag;
    } else if (lowerName.contains('cloth') ||
        lowerName.contains('fashion') ||
        lowerName.contains('wear')) {
      return Icons.checkroom;
    } else if (lowerName.contains('food') || lowerName.contains('eat')) {
      return Icons.fastfood;
    } else if (lowerName.contains('game') || lowerName.contains('play')) {
      return Icons.videogame_asset;
    } else if (lowerName.contains('home') || lowerName.contains('furniture')) {
      return Icons.weekend;
    } else if (lowerName.contains('cook') || lowerName.contains('kitchen')) {
      return Icons.restaurant;
    } else if (lowerName.contains('green') || lowerName.contains('eco')) {
      return Icons.eco;
    } else if (lowerName.contains('car') || lowerName.contains('auto')) {
      return Icons.directions_car;
    } else if (lowerName.contains('beauty') || lowerName.contains('makeup')) {
      return Icons.face;
    } else if (lowerName.contains('electronic') || lowerName.contains('tech')) {
      return Icons.devices;
    }

    return Icons.category;
  }
}

// ========================================
// 🎯 OPTIMIZED: Subcategory Section with State Management
// ========================================
final NetworkRepository _repository = NetworkRepository();

class _SubCategoriesSection extends StatefulWidget {
  final String parentId;
  final String parentName; // ✅ Add this
  final bool isUserSelected;
  final _CategoriesScreenState parentState;

  const _SubCategoriesSection({
    super.key,
    required this.parentId,
    required this.parentName, // ✅ Add this
    required this.isUserSelected,
    required this.parentState,
  });

  @override
  State<_SubCategoriesSection> createState() => _SubCategoriesSectionState();
}

class _SubCategoriesSectionState extends State<_SubCategoriesSection> {
  // ✅ State variables
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<ProductAttributeItems> _subcategories = [];

  // ✅ NEW: Track if we've already handled empty state
  bool _hasHandledEmpty = false;

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  Future<void> _loadSubCategories() async {
    // ✅ Check if already known to be empty
    if (widget.parentState.isCategoryKnownEmpty(widget.parentId)) {
      // Already handled, just trigger navigation without UI update
      if (widget.isUserSelected && !_hasHandledEmpty) {
        _hasHandledEmpty = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.parentState.handleEmptyCategoryAndMoveNext(widget.parentId);
        });
      }
      // Keep showing loading - don't update state to empty
      return;
    }

    // Check cache first
    if (_CategoriesScreenState._subCategoriesCache.containsKey(
      widget.parentId,
    )) {
      final cached =
          _CategoriesScreenState._subCategoriesCache[widget.parentId]!;
      final items = cached.productAttributeItems ?? [];

      if (items.isEmpty) {
        // ✅ Cached as empty - handle without showing "No categories" UI
        _handleEmptyResult();
        return;
      }

      setState(() {
        _subcategories = items;
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    // Check if already loading
    if (_CategoriesScreenState._loadingStates[widget.parentId] == true) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_CategoriesScreenState._subCategoriesCache.containsKey(
        widget.parentId,
      )) {
        final cached =
            _CategoriesScreenState._subCategoriesCache[widget.parentId]!;
        final items = cached.productAttributeItems ?? [];

        if (items.isEmpty) {
          _handleEmptyResult();
          return;
        }

        setState(() {
          _subcategories = items;
          _isLoading = false;
          _hasError = false;
        });
        return;
      }
    }

    // Fetch from API
    try {
      _CategoriesScreenState._loadingStates[widget.parentId] = true;

      final result = await _repository
          .fetchData<CategoryModel>(
            url:
                'https://api.libanbuy.com/api/product-attribute-items?hide_empty=True&limit=52&with=thumbnail&parent_id=${widget.parentId}',
            fromJson: (json) => CategoryModel.fromJson(json),
            forceRefresh: false,
          )
          .timeout(const Duration(seconds: 30));

      final items = result.productAttributeItems ?? [];

      // Cache the result
      _CategoriesScreenState._subCategoriesCache[widget.parentId] = result;

      if (items.isNotEmpty) {
        _prefetchImagesCategories(result);

        if (mounted) {
          setState(() {
            _subcategories = items;
            _isLoading = false;
            _hasError = false;
          });
        }
      } else {
        // ✅ Empty result - handle BEFORE updating UI
        _handleEmptyResult();
      }

      _CategoriesScreenState._loadingStates[widget.parentId] = false;
    } catch (e) {
      _CategoriesScreenState._loadingStates[widget.parentId] = false;

      if (mounted) {
        // ✅ On error for user-selected category, handle as empty
        if (widget.isUserSelected) {
          _handleEmptyResult();
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Error loading subcategories: $e';
          });
        }
      }
    }
  }

  // ✅ NEW: Unified empty result handler
  void _handleEmptyResult() {
    if (_hasHandledEmpty) return;
    _hasHandledEmpty = true;

    if (widget.isUserSelected) {
      // ✅ USER TAPPED: Navigate away, don't show "No categories"
      // Keep loading state - user will see loading, then navigate away
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.parentState.handleEmptyCategoryAndMoveNext(widget.parentId);
        }
      });
    } else {
      // ✅ INIT CALL: Move to next category silently
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.parentState._selectNextValidCategory();
        }
      });
    }
  }

  Future<void> _prefetchImagesCategories(CategoryModel response) async {
    try {
      await compute(_prefetchImagesIsolateCategories, response);
    } catch (e) {
      debugPrint('Image prefetching error: $e');
    }
  }

  static void _prefetchImagesIsolateCategories(CategoryModel response) {
    final items = response.productAttributeItems ?? [];
    for (var el in items) {
      try {
        final url = el.thumbnail?.media?.url;
        if (url != null && url.isNotEmpty) {
          prefetchImageIsolate(url);
        }
      } catch (e) {
        debugPrint('Error prefetching image: $e');
      }
    }
  }

  var dashbaordController = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (dashbaordController.selectedIndex.value != 1) {
        return const SizedBox.shrink();
      }

      // ✅ Loading state - also shown when handling empty
      if (_isLoading) {
        return _buildShimmerLoading();
      }

      // ✅ Error state (only for non-user-selected, as user-selected errors are handled as empty)
      if (_hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                'Failed to load subcategories',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                    _hasHandledEmpty = false;
                  });
                  _loadSubCategories();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      // ✅ Empty state - should rarely show now (only if all categories exhausted)
      if (_subcategories.isEmpty) {
        // If we haven't handled yet, keep showing loading
        if (!_hasHandledEmpty) {
          return _buildShimmerLoading();
        }

        return const Center(
          child: Text(
            'No subcategories available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      // ✅ Success state - Display data
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 4, top: 12),
              child: Text(
                'Shop by Category',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = _subcategories[index];
                  return _SubCategoryItem(subcategory: subcategory);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 8, top: 16),
              child: Text(
                'Trending Products',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),

            RelatedProductGrid(
              search: widget.parentId,
              isshownfromcategories: true,
            ),
            // ProductsGridWidget(shownfromcatehoris: true),
          ],
        ),
      );
    });
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4, top: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 24,
              itemBuilder: (context, index) {
                return _buildShimmerItem();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// ✨ Subcategory Item
// ========================================
class _SubCategoryItem extends StatelessWidget {
  final ProductAttributeItems? subcategory;

  const _SubCategoryItem({required this.subcategory});

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        subcategory?.thumbnail?.media?.cdnThumbnailUrl ??
        subcategory?.thumbnail?.media?.optimizedMediaCdnUrl ??
        subcategory?.thumbnail?.media?.localUrl ??
        subcategory?.thumbnail?.media?.optimizedMediaCdnUrl ??
        subcategory?.thumbnail?.media?.cdnUrl ??
        subcategory?.thumbnail?.media?.url ??
        '';

    final String name = subcategory?.name ?? 'Unknown';
    final String id = subcategory?.id?.toString() ?? '';

    final bgColor = CategoryColorHelper.getColorFromName(name);
    final fallbackIcon = CategoryColorHelper.getIconFromName(name);

    return GestureDetector(
      onTap: () {
        try {
          DashboardController.instance.reset();
          final controller = Get.find<HomeController>();

          if (id.isNotEmpty) {
            controller.fetchCategoryProductsa(id);
          }

          final model = subcategory ?? ProductAttributeItems();
          controller.setSelectedCategory(model);
        } catch (e) {
          debugPrint('Error selecting subcategory: $e');
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: bgColor.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child:
                  imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                        cacheManager: PersistentCacheManager(),
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                _buildIconPlaceholder(fallbackIcon, bgColor),
                        errorWidget:
                            (context, url, error) =>
                                _buildIconPlaceholder(fallbackIcon, bgColor),
                      )
                      : _buildIconPlaceholder(fallbackIcon, bgColor),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPlaceholder(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
      ),
      child: Center(child: Icon(icon, size: 32, color: Colors.white)),
    );
  }
}
