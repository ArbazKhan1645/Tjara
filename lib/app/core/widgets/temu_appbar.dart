// =============================================================================
// TEMU-STYLE REDESIGN V2 - EXACT MATCH TO TEMU APP
// =============================================================================
// Copy this entire file to: lib/app/modules/home/widgets/temu_style_widgets.dart
// =============================================================================

// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/views/product_detail_screen_view.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

// =============================================================================
// 1. TEMU APP BAR - Search with BLACK suffix icon background
// =============================================================================

class TemuAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TemuAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  State<TemuAppBar> createState() => _TemuAppBarState();
}

class _TemuAppBarState extends State<TemuAppBar> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _wasKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;
    if (_wasKeyboardVisible && !isKeyboardVisible) {
      _searchFocusNode.unfocus();
    }
    _wasKeyboardVisible = isKeyboardVisible;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF97316),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: widget.preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Full width search bar
              Expanded(child: _buildSearchBar()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Search icon on left
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(Icons.search, color: Colors.grey, size: 20),
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search Tjara...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                isDense: true,
              ),
              onSubmitted: _onSearch,
            ),
          ),
          // BLACK search button on right (like Temu)
          GestureDetector(
            onTap: () => _onSearch(_searchController.text),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.black, // BLACK background like Temu
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    _searchFocusNode.unfocus();
    DashboardController.instance.reset();
    final controller = Get.put(HomeController());
    controller.searchProducts(_searchController.text);
    controller.setSelectedCategory(ProductAttributeItems());
  }
}

// =============================================================================
// 2. TEMU CATEGORY TABS - WITH COLORED BACKGROUND (attached to app bar)
// =============================================================================

class TemuCategoryTabs extends StatelessWidget {
  const TemuCategoryTabs({super.key});

  static const List<String> categories = [
    "All",
    "On Sale",
    "Featured",
    "Cars",
    "Auctions",
    "Jobs",
    "Services",
    "Contests",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // Orange background for categories section
      color: const Color(0xFFF97316),
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 32,
        child: GetBuilder<HomeController>(
          builder: (controller) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: categories.length,
              itemBuilder:
                  (context, index) => _buildCategoryPill(controller, index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryPill(HomeController controller, int index) {
    return Obx(() {
      final isSelected = controller.selectedIndexProducts.value == index;

      return GestureDetector(
        onTap: () => _onCategoryTap(controller, index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            categories[index],
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFFF97316) : Colors.white,
            ),
          ),
        ),
      );
    });
  }

  void _onCategoryTap(HomeController controller, int index) {
    if (index == 5) {
      Get.toNamed(Routes.TJARA_JOBS);
    } else if (index == 6) {
      Get.toNamed(Routes.SERVICES);
    } else if (index == 7) {
      Get.toNamed(Routes.CONTESTS);
    } else {
      controller.setSelectedIndexProducts(index);
      if (index == 0) {
        controller.update(['product_grid']);
      } else {
        controller.startFilteredLoading();
        controller.loadFilteredFirstPage(index);
      }
    }
  }
}

// =============================================================================
// 3. TEMU PROMOTION BANNER - FULL WIDTH, NO PADDING, ATTACHED TO CATEGORIES
// =============================================================================

class TemuPromotionBanner extends StatefulWidget {
  const TemuPromotionBanner({super.key});

  @override
  State<TemuPromotionBanner> createState() => _TemuPromotionBannerState();
}

class _TemuPromotionBannerState extends State<TemuPromotionBanner> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final banners = ['s'];
        if (banners.isNotEmpty) {
          _currentPage = (_currentPage + 1) % 3;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final banners = [];

        if (banners.isEmpty) {
          return _buildDefaultBanner();
        }

        return SizedBox(
          // Small height, full width, no padding
          height: 100,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _buildBannerItem(banners[index]),
          ),
        );
      },
    );
  }

  Widget _buildDefaultBanner() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFF9A56)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          // Gift/decoration icons
          Positioned(
            left: 20,
            top: 10,
            child: Icon(
              Icons.card_giftcard,
              color: Colors.white.withOpacity(0.3),
              size: 40,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 10,
            child: Icon(
              Icons.celebration,
              color: Colors.white.withOpacity(0.3),
              size: 40,
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Year-End Sale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'UP\nTO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '80%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SHOP NOW >',
                    style: TextStyle(
                      color: Color(0xFFF97316),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(var banner) {
    final imageUrl =
        banner.image?.media?.optimizedMediaUrl ??
        banner.image?.media?.url ??
        '';

    if (imageUrl.isEmpty) return _buildDefaultBanner();

    return GestureDetector(
      onTap: () {
        // Handle banner tap
      },
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: FutureBuilder<ImageProvider>(
          future: loadCachedImage(imageUrl),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image(
                image: snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 100,
              );
            }
            return _buildDefaultBanner();
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 4. TEMU TRUST BADGES - Free shipping & Delivery guarantee
// =============================================================================

class TemuTrustBadges extends StatelessWidget {
  const TemuTrustBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Free Shipping
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.check, color: Color(0xFFF97316), size: 16),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free shipping',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'Limited-time offer',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delivery Guarantee
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: Color(0xFFF97316),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery guarantee',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'Refund for any issue',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 5. TEMU "WHY CHOOSE" BAR - Orange background bar
// =============================================================================

class TemuWhyChooseBar extends StatelessWidget {
  const TemuWhyChooseBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF97316),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Why choose Tjara?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Safe payments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.white, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 6. TEMU DEAL SECTIONS - Single product per section with gradient background
// =============================================================================

class TemuDealSections extends StatelessWidget {
  const TemuDealSections({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final products = controller.products.value.products?.data ?? [];
        final saleProducts =
            products
                .where((p) => p.salePrice != null && p.salePrice != 0)
                .toList();

        if (saleProducts.length < 2) return const SizedBox.shrink();

        return Container(
          // Gradient background - lighter at top
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF5F0), // Very light orange/peach at top
                Colors.white,
              ],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Clearance Deals - Left
              Expanded(
                child: _buildDealCard(
                  title: 'Clearance deals',
                  icon: Icons.local_fire_department,
                  iconColor: const Color(0xFFEF4444),
                  product: saleProducts[0],
                ),
              ),
              const SizedBox(width: 10),
              // Lightning Deals - Right
              Expanded(
                child: _buildDealCard(
                  title: 'Lightning deals',
                  icon: Icons.flash_on,
                  iconColor: const Color(0xFFF97316),
                  product:
                      saleProducts.length > 1
                          ? saleProducts[1]
                          : saleProducts[0],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDealCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required ProductDatum product,
  }) {
    final imageUrl =
        product.thumbnail?.media?.optimizedMediaUrl ??
        product.thumbnail?.media?.url ??
        '';
    final salePrice = product.salePrice ?? 0;
    final originalPrice = product.price ?? product.maxPrice ?? 0;
    final soldCount = int.tryParse(product.meta?.views ?? '0') ?? 0;

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreenView(product: product)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ],
              ),
            ),
            // Single large product image
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    child:
                        imageUrl.isNotEmpty
                            ? FutureBuilder<ImageProvider>(
                              future: loadCachedImage(imageUrl),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image(
                                    image: snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  );
                                }
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                            : Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.image,
                                color: Colors.grey.shade400,
                              ),
                            ),
                  ),
                  // "ONLY X LEFT" badge
                  if (soldCount > 50)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ONLY ${(100 - (soldCount % 100)).clamp(1, 20)} LEFT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Price row at bottom
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Sale price
                  const Text(
                    'Rs.',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  Text(
                    salePrice.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Original price
                  Text(
                    '${originalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 7. TEMU INFO BAR - Tax & Customs Policy bar
// =============================================================================

class TemuInfoBar extends StatelessWidget {
  const TemuInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'تدعم الأفراد عبر برنامج الموزعين',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const Text(' | ', style: TextStyle(color: Colors.grey)),
          Text(
            'تجارة لبنانية',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}

// =============================================================================
// 8. TEMU STAGGERED PRODUCTS GRID - Different heights based on image
// =============================================================================

class TemuProductsGrid extends StatefulWidget {
  const TemuProductsGrid({super.key});

  @override
  State<TemuProductsGrid> createState() => _TemuProductsGridState();
}

class _TemuProductsGridState extends State<TemuProductsGrid> {
  List<ProductDatum>? _cachedProducts;
  int? _lastSelectedIndex;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'product_grid',
      builder: (controller) {
        final selectedIndex = controller.selectedIndexProducts.value;
        final allProducts = controller.products.value.products?.data ?? [];
        final filteredProducts = _filterProducts(allProducts, selectedIndex);

        if (_lastSelectedIndex != selectedIndex) {
          _cachedProducts = filteredProducts;
          _lastSelectedIndex = selectedIndex;
        }

        if (filteredProducts.isEmpty && controller.isLoading) {
          return _buildShimmerGrid();
        }

        if (filteredProducts.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStaggeredGrid(_cachedProducts ?? filteredProducts),
            if (controller.isLoading) _buildLoadingIndicator(),
          ],
        );
      },
    );
  }

  List<ProductDatum> _filterProducts(
    List<ProductDatum> products,
    int selectedIndex,
  ) {
    switch (selectedIndex) {
      case 0:
        return products;
      case 1:
        return products
            .where((p) => p.salePrice != null && p.salePrice != 0.0)
            .toList();
      case 2:
        return products.where((p) => p.isFeatured.toString() == '1').toList();
      case 3:
        return products.where((p) => p.productGroup == 'car').toList();
      default:
        return products;
    }
  }

  Widget _buildStaggeredGrid(List<ProductDatum> products) {
    // Split into two columns for staggered effect
    final List<ProductDatum> leftColumn = [];
    final List<ProductDatum> rightColumn = [];

    for (int i = 0; i < products.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(products[i]);
      } else {
        rightColumn.add(products[i]);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            child: Column(
              children:
                  leftColumn.asMap().entries.map((entry) {
                    return TemuProductCard(
                      product: entry.value,
                      heightVariation: entry.key % 3, // Vary height
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(width: 8),
          // Right column - offset for staggered effect
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 30), // Offset for staggered look
                ...rightColumn.asMap().entries.map((entry) {
                  return TemuProductCard(
                    product: entry.value,
                    heightVariation: (entry.key + 1) % 3, // Different variation
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: List.generate(
                3,
                (index) => _buildShimmerCard(index % 3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 30),
                ...List.generate(
                  3,
                  (index) => _buildShimmerCard((index + 1) % 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(int heightVariation) {
    const baseHeight = 200.0;
    final height = baseHeight + (heightVariation * 40);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, width: 80, color: Colors.grey.shade300),
                  const Spacer(),
                  Container(height: 16, width: 60, color: Colors.grey.shade300),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(Color(0xFFF97316)),
      ),
    );
  }
}

// =============================================================================
// 9. TEMU PRODUCT CARD - Staggered height with exact Temu design
// =============================================================================

class TemuProductCard extends StatelessWidget {
  final ProductDatum product;
  final int heightVariation; // 0, 1, or 2 for different heights
  final bool isWishListProduct;
  final String wishlistId;

  const TemuProductCard({
    super.key,
    required this.product,
    this.heightVariation = 0,
    this.isWishListProduct = false,
    this.wishlistId = '',
  });

  @override
  Widget build(BuildContext context) {
    // Calculate image height based on variation
    const baseImageHeight = 150.0;
    final imageHeight = baseImageHeight + (heightVariation * 40);

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreenView(product: product)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - variable height
            _buildImageSection(imageHeight),
            // Product Details - fixed layout
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(double height) {
    final imageUrl =
        product.thumbnail?.media?.optimizedMediaUrl ??
        product.thumbnail?.media?.url ??
        '';

    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child:
                imageUrl.isNotEmpty
                    ? FutureBuilder<ImageProvider>(
                      future: loadCachedImage(imageUrl),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image(
                            image: snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: height,
                          );
                        }
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    )
                    : Container(
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.image,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    ),
          ),
        ),
        // Remove from wishlist button (if wishlist)
        if (isWishListProduct)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                if (wishlistId.isEmpty) return;
                final controller = Get.put(WishlistServiceController());
                controller.removeFromWishlist(wishlistId, Get.context!);
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.grey, size: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name ?? 'No Name',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          // Price row
          _buildPriceRow(),
          const SizedBox(height: 6),
          // Rating & Sold row with Add to Cart
          _buildRatingRow(),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    final salePrice = product.salePrice;
    final price = product.price;
    final minPrice = product.minPrice;
    final maxPrice = product.maxPrice;

    if (salePrice != null && salePrice != 0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'Rs.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF4444),
            ),
          ),
          Text(
            salePrice.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${(price ?? maxPrice ?? 0).toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }

    if (minPrice != null &&
        maxPrice != null &&
        minPrice != 0 &&
        maxPrice != 0) {
      return Text(
        '\$${minPrice.toStringAsFixed(0)} - \$${maxPrice.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      );
    }

    if (price != null && price != 0) {
      return Row(
        children: [
          Text(
            'Rs.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            price.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Ask dealer',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    final soldCount = int.tryParse(product.meta?.views ?? '0') ?? 0;
    final reviewCount = ((soldCount) * 0.3).toInt(); // Approximate reviews

    return Row(
      children: [
        // Stars
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 12,
              color: index < 4 ? Colors.amber.shade600 : Colors.grey.shade300,
            );
          }),
        ),
        const SizedBox(width: 4),
        // Review count
        Text(
          '$reviewCount',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
        const Spacer(),
        // Add to cart button (circle with cart icon like Temu)
        GestureDetector(
          onTap: () => _addToCart(),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.add_shopping_cart_outlined,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  void _addToCart() {
    if (AuthService.instance.authCustomerRx.value?.user == null) {
      showContactDialog(Get.context!, const LoginUi());
      return;
    }

    // final cartService = Get.find<CartService>();
    // cartService.add(
    //   productId: product.id ?? '',
    //   quantity: 1,
    //   price: product.salePrice ?? product.price ?? product.minPrice ?? 0,
    // );
    // Alerts.success('Added to cart!');
  }
}

// =============================================================================
// 10. TEMU BOTTOM NAV BAR - Flat design like Temu
// =============================================================================

class TemuBottomNavBar extends StatelessWidget {
  const TemuBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final isLoggedIn =
          AuthService.instance.authCustomerRx.value?.user != null;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  controller: controller,
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                ),
                _buildNavItem(
                  controller: controller,
                  index: 1,
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view,
                  label: 'Categories',
                ),
                if (isLoggedIn)
                  _buildNavItem(
                    controller: controller,
                    index: 2,
                    icon: Icons.favorite_outline,
                    activeIcon: Icons.favorite,
                    label: 'Wishlist',
                    badgeCount: controller.wishlistCount.value,
                  ),
                _buildNavItem(
                  controller: controller,
                  index: 3,
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'Cart',
                  badgeCount: controller.cartCount.value,
                ),
                _buildNavItem(
                  controller: controller,
                  index: 4,
                  icon: Icons.menu,
                  activeIcon: Icons.menu,
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({
    required DashboardController controller,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final color = isSelected ? const Color(0xFFF97316) : Colors.grey.shade600;

      return Expanded(
        child: InkWell(
          onTap: () => _handleNavItemTap(controller, index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(isSelected ? activeIcon : icon, color: color, size: 24),
                  if (badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 14,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _handleNavItemTap(DashboardController controller, int index) {
    switch (index) {
      case 0:
        final homeController = Get.find<HomeController>();
        homeController.selectedCategory = null;
        homeController.update();
        controller.changeIndex(0);
        break;
      case 1:
        controller.changeIndex(index);
        break;
      case 2:
        controller.changeIndex(index);
        break;
      case 3:
        final cartService = Get.find<CartService>();
        cartService.initcall();
        controller.changeIndex(3);
        break;
      case 4:
        if (AuthService.instance.authCustomerRx.value?.user == null) {
          showContactDialog(Get.context!, const LoginUi());
        } else {
          controller.changeIndex(4);
        }
        break;
    }
  }
}
