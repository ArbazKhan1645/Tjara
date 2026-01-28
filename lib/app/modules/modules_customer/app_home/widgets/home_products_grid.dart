// ignore_for_file: deprecated_member_use, empty_catches, avoid_print, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/related_products_grid.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/views/product_detail_screen_view.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  // Enhanced constants for better UI
  static const _gridPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const _gridPhysics = NeverScrollableScrollPhysics();
  static const _gridCrossAxisCount = 2;
  static const _gridMainAxisSpacing = 12.0;
  static const _gridCrossAxisSpacing = 8.0;
  static const _gridItemHeight = 320.0; // Optimized height for grid layout

  // Cache filtered products to avoid repeated filtering
  List<ProductDatum>? _cachedProducts;
  int? _lastSelectedIndex;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'product_grid',
      builder: (controller) {
        if (controller.selectedIndexProducts.value != 0) {
          return _buildAuctionProductsGrid(
            controller,
            index: controller.selectedIndexProducts.value,
          );
        }
        return _buildRegularProductsGrid(controller);
      },
    );
  }

  Widget _buildAuctionProductsGrid(HomeController controller, {int? index}) {
    final allProducts = controller.products.value.products?.data ?? [];
    final filteredProducts = _filterProducts(allProducts, index ?? 0);

    // Show shimmer only when no items yet and loading (initial/tab switch)
    if (filteredProducts.isEmpty) {
      return controller.isLoading ? _buildShimmerGrid() : _buildEmptyWidget();
    }

    // Keep items on screen and show footer loader during pagination
    return Column(
      children: [
        _buildOptimizedProductGrid(
          products: filteredProducts,
          storageKey: 'filtered_grid_$index',
        ),
        if (controller.isLoading) _buildFooterLoader(),
      ],
    );
  }

  Widget _buildRegularProductsGrid(HomeController controller) {
    final selectedIndex = controller.selectedIndexProducts.value;
    final allProducts = controller.products.value.products?.data ?? [];
    final filteredProducts = _filterProducts(allProducts, selectedIndex);

    // Show shimmer only when no items yet and loading (initial load)
    if (filteredProducts.isEmpty) {
      return controller.isLoading ? _buildShimmerGrid() : _buildEmptyWidget();
    }

    // Cache the filtered products for performance
    if (_lastSelectedIndex != selectedIndex) {
      _cachedProducts = filteredProducts;
      _lastSelectedIndex = selectedIndex;
    }

    return Column(
      children: [
        _buildOptimizedProductGrid(
          products: _cachedProducts ?? filteredProducts,
          storageKey: 'regular_grid_$selectedIndex',
        ),
        if (controller.isLoading) _buildFooterLoader(),
      ],
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

  Widget _buildOptimizedProductGrid({
    required List<ProductDatum> products,
    required String storageKey,
  }) {
    return Padding(
      padding: _gridPadding,
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: _gridPhysics,
        crossAxisCount: _gridCrossAxisCount,
        mainAxisSpacing: _gridMainAxisSpacing,
        crossAxisSpacing: _gridCrossAxisSpacing,

        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            height: _gridItemHeight,
            child: ProductCard(
              key: ValueKey('product_${product.id}'),
              product: product,
              index: index,
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: _gridPadding,
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: _gridPhysics,
        crossAxisCount: _gridCrossAxisCount,
        mainAxisSpacing: _gridMainAxisSpacing,
        crossAxisSpacing: _gridCrossAxisSpacing,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        itemCount: 12,
        itemBuilder: (context, index) => const ShimmerProductCard(),
      ),
    );
  }

  Widget _buildFooterLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text(
            'Loading more products...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or check back later',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final ProductDatum product;
  final int index;
  final String wishlistId;
  final bool isWishListProduct;

  const ProductCard({
    super.key,
    required this.product,
    this.wishlistId = '',
    this.isWishListProduct = false,
    required this.index,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          print('url is:  ${widget.product.rating}');
          _navigateToProductDetail();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xffF97316), Color(0xffFFFFFF), Color(0xffFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content with padding
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImageSection(),
                      _buildProductDetails(),
                    ],
                  ),
                ),
              ),
              // Orange container at bottom - outside padding
              _buildBottomTable(
                widget.product.rating == null
                    ? '0.0'
                    : widget.product.rating.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: CachedImage(
              imageUrl:
                  widget.product.thumbnail?.media?.optimizedMediaUrl ??
                  widget.product.thumbnail?.media?.url ??
                  widget.product.thumbnail?.media?.localUrl ??
                  '',
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Featured badge
        if (widget.product.isFeatured.toString() == '1')
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'FEATURED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

        // Wishlist remove button - positioned at top right corner within the card
        if (widget.isWishListProduct)
          Positioned(
            right: 8, // Positioned within the card edge
            top: 8, // Positioned within the card edge
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316), // Orange background
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => removeWishlist(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProductName(),
          const SizedBox(height: 8),
          _buildPriceSection(),
        ],
      ),
    );
  }

  Widget _buildProductName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        widget.product.name?.toString() ?? 'No Name',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return _PriceWidget(product: widget.product);
  }

  Widget _buildBottomTable(String rating) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF97316), // Orange background
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Left side - Rating
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.yellow),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Middle separator
            Container(
              height: 16,
              width: 1,
              color: Colors.white.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            if (widget.product.productGroup?.toLowerCase() != 'car')
              // Right side - Sold count
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.product.meta?.views ?? '0'} Sold',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  void removeWishlist(BuildContext context) {
    if (widget.wishlistId.isEmpty) return;
    final WishlistServiceController wishlistController = Get.put(
      WishlistServiceController(),
    );
    wishlistController.removeFromWishlist(widget.wishlistId, context);
  }

  void _navigateToProductDetail() {
    Get.to(
      () => ProductDetailScreenView(product: widget.product),
      preventDuplicates: false,
    );
  }
}

class _PriceWidget extends StatefulWidget {
  final ProductDatum product;

  const _PriceWidget({required this.product});

  @override
  State<_PriceWidget> createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<_PriceWidget> {
  bool _isCartOperationInProgress = false;

  // Services
  CartService get _cartService => Get.find<CartService>();

  // Add to cart functionality
  Future<void> _addToCart() async {
    if (_isCartOperationInProgress) return;

    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      _showLoginDialog();
      return;
    }

    setState(() {
      _isCartOperationInProgress = true;
    });

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adding to cart...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final double price =
          double.tryParse(widget.product.price.toString()) ?? 0.0;

      final result = await _cartService.updateCart(
        widget.product.shopId ?? '',
        widget.product.id ?? '',
        1, // Default quantity
        price,
      );

      if (mounted) {
        _handleCartUpdateResult(result);
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showError(
          context,
          'Failed',
          'Failed to add item to cart',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCartOperationInProgress = false;
        });
      }
    }
  }

  void _handleCartUpdateResult(dynamic result) {
    if (!mounted) return;

    if (result is String) {
      NotificationHelper.showError(context, 'Failed', result);
    } else if (result is bool && result) {
      NotificationHelper.showSuccess(
        context,
        'Success',
        'Product Added to Cart',
      );

      // Refresh cart count badge
      try {
        (Get.isRegistered<DashboardController>()
                ? Get.find<DashboardController>()
                : Get.put(DashboardController()))
            .fetchCartCount();
      } catch (_) {}
    } else {
      NotificationHelper.showError(
        context,
        'Failed',
        'Product Failed to add to cart',
      );
    }
  }

  void _showLoginDialog() {
    showContactDialog(context, const LoginUi());
  }

  @override
  Widget build(BuildContext context) {
    final salePrice = widget.product.salePrice;
    final price = widget.product.price;
    final minPrice = widget.product.minPrice;
    final maxPrice = widget.product.maxPrice;

    // --- SALE PRICE SCENARIO ---
    if (salePrice != null && salePrice != 0 && salePrice != 0.00) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price section - can wrap
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Original Price (Strikethrough)
                Text(
                  "\$${(price ?? maxPrice ?? 0).toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                // Sale Price (White text on orange rounded container)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF97316),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "\$${salePrice.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Shopping cart icon - always on the right, never wraps
          GestureDetector(
            onTap: _isCartOperationInProgress ? null : _addToCart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1 / 2, color: Colors.orange),
              ),
              child:
                  _isCartOperationInProgress
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xffF97316),
                          ),
                        ),
                      )
                      : const Icon(
                        Icons.shopping_cart_sharp,
                        size: 18,
                        color: Color(0xffF97316),
                      ),
            ),
          ),
        ],
      );
    }

    // --- PRICE RANGE SCENARIO ---
    if (minPrice != null &&
        maxPrice != null &&
        minPrice != 0 &&
        maxPrice != 0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price section - can wrap
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF97316),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "\$${minPrice.toStringAsFixed(2)} - \$${maxPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Shopping cart icon - always on the right, never wraps
          GestureDetector(
            onTap: _isCartOperationInProgress ? null : _addToCart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1 / 2, color: Colors.orange),
              ),
              child:
                  _isCartOperationInProgress
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xffF97316),
                          ),
                        ),
                      )
                      : const Icon(
                        Icons.shopping_cart_sharp,
                        size: 18,
                        color: Color(0xffF97316),
                      ),
            ),
          ),
        ],
      );
    }

    // --- SINGLE PRICE SCENARIO ---
    if (price != null && price != 0.0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price section - can wrap
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF97316),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "\$${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Shopping cart icon - always on the right, never wraps
          GestureDetector(
            onTap: _isCartOperationInProgress ? null : _addToCart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1 / 2, color: Colors.orange),
              ),
              child:
                  _isCartOperationInProgress
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xffF97316),
                          ),
                        ),
                      )
                      : const Icon(
                        Icons.shopping_cart_sharp,
                        size: 18,
                        color: Color(0xffF97316),
                      ),
            ),
          ),
        ],
      );
    }

    // --- DEFAULT SCENARIO ---
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Text(
        "Ask the dealer",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
        ),
      ),
    );
  }
}

class CachedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage>
    with AutomaticKeepAliveClientMixin {
  ImageProvider? _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final url = widget.imageUrl.trim();

    if (url.isEmpty) {
      _setFallbackImage();
      return;
    }

    try {
      final image = await loadCachedImage(url);
      if (mounted) {
        setState(() {
          _imageProvider = image;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _setFallbackImage();
      }
    }
  }

  void _setFallbackImage() {
    setState(() {
      _imageProvider = const AssetImage('assets/images/tjara-logo (1).png');
      _isLoading = false;
      _hasError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        image: DecorationImage(
          image:
              _imageProvider ??
              const AssetImage('assets/images/tjara-logo (1).png'),
          fit: widget.fit,
          onError: _hasError ? null : (_, __) => _setFallbackImage(),
        ),
      ),
    );
  }
}
