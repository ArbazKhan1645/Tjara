// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/authentication/screens/contact_us.dart';
import 'package:tjara/app/modules/authentication/screens/login.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/auction_products.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/views/product_detail_screen_view.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

/// Temu-style Products Grid Widget - LEFT SIDE EXACT MATCH
class ProductsGridWidget extends StatelessWidget {
  const ProductsGridWidget({super.key, required this.shownfromcatehoris});

  final bool shownfromcatehoris;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'product_grid',
      builder: (controller) {
        // final selectedIndex = controller.selectedIndexProducts.value;
        final allProducts = controller.products.value.products?.data ?? [];
        final filteredProducts = allProducts;

        if (filteredProducts.isEmpty && controller.isLoading) {
          return _buildShimmerGrid();
        }

        if (filteredProducts.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildProductsGrid(filteredProducts),
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

  Widget _buildProductsGrid(List<ProductDatum> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MasonryGridView.count(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        itemCount: products.length,
        itemBuilder: (context, index) {
          if (products[index].auctionStartTime != null &&
              products[index].auctionEndTime != null) {
            return AuctionProductCard(product: products[index]);
          }
          return TemuProductCard(
            isshownfromcategories: shownfromcatehoris,
            key: ValueKey('product_${products[index].id}'),
            product: products[index],
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        itemCount: 6,
        itemBuilder: (context, index) => const _ShimmerProductCard(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFF97316),
          ),
        ),
      ),
    );
  }
}

/// Exact Temu Product Card - LEFT SIDE LAYOUT
class TemuProductCard extends StatelessWidget {
  const TemuProductCard({
    super.key,
    required this.product,
    this.wishlistId = '',
    this.isWishListProduct = false,
    this.isshownfromcategories = false,
  });

  final ProductDatum product;
  final String wishlistId;
  final bool isWishListProduct;
  final bool isshownfromcategories;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section
            _buildImageSection(),

            // Info Section (3 lines layout)
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Main Image
        AspectRatio(
          aspectRatio: 1.0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: ProductImage(product: product),
          ),
        ),

        // Featured Badge
        if (product.isFeatured.toString() == '1')
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'FEATURED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

        // Sale Badge
        if (product.salePrice != null && product.salePrice != 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'Sale',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Wishlist Remove
        if (isWishListProduct)
          Positioned(
            top: 4,
            right: 4,
            child: Obx(() {
              final controller = Get.put(WishlistServiceController());
              final isThisRemoving =
                  controller.removingWishlistId.value == wishlistId;
              final isAnyRemoving =
                  controller.removingWishlistId.value != null;
              return GestureDetector(
                onTap: isAnyRemoving ? null : () => _removeFromWishlist(),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: isThisRemoving
                      ? const Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        )
                      : Icon(
                          Icons.close,
                          color: isAnyRemoving
                              ? Colors.grey.shade300
                              : Colors.grey,
                          size: 14,
                        ),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isshownfromcategories)
            // Line 1: Product Name
            Text(
              product.name ?? 'No Name',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade800,
                height: 1.2,
              ),
            ),

          const SizedBox(height: 3),

          // Line 2: Star Rating
          _buildStarRating(),

          const SizedBox(height: 3),

          // Line 3: Price + Sold + Cart
          _buildPriceAndCartRow(),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    const rating = 3.0;
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      children: [
        // Star icons
        ...List.generate(5, (index) {
          if (index < fullStars) {
            return const Icon(
              Icons.star,
              size: 12,
              color: Color.fromARGB(255, 0, 0, 0),
            );
          } else if (index == fullStars && hasHalfStar) {
            return Icon(
              Icons.star_half,
              size: 12,
              color: Colors.amber.shade700,
            );
          } else {
            return Icon(
              Icons.star_border,
              size: 12,
              color: Colors.grey.shade400,
            );
          }
        }),
        const SizedBox(width: 4),
        // Rating number
        Text(
          rating > 0 ? rating.toStringAsFixed(1) : '0',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndCartRow() {
    return Row(
      children: [
        // Price
        Expanded(child: _buildPriceDisplay()),

        if (product.stock == 0)
          const Text(
            'Sold Out',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          )
        else if (!isshownfromcategories)
          // Cart button (black shopping cart)
          Row(
            children: [
              const SizedBox(width: 2),

              // Sold count with fire icon
              _buildSoldCount(),

              const SizedBox(width: 2),
              _AddToCartButton(product: product),
            ],
          ),
      ],
    );
  }

  Widget _buildPriceDisplay() {
    final salePrice = product.salePrice;
    final price = product.price;
    final minPrice = product.minPrice;
    final maxPrice = product.maxPrice;

    // Sale Price (red/orange)
    if (salePrice != null && salePrice != 0) {
      return Wrap(
        children: [
          Text(
            '\$${salePrice.toStringAsFixed(2)}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,

            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '${(price ?? maxPrice ?? 0).toStringAsFixed(2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade400,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }

    // Price Range
    if (minPrice != null &&
        maxPrice != null &&
        minPrice != 0 &&
        maxPrice != 0) {
      return Text(
        '\$${maxPrice.toStringAsFixed(2)}',
        maxLines: 1,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade700,
        ),
      );
    }

    // Single Price
    if (price != null && price != 0) {
      return Text(
        '\$${price.toStringAsFixed(2)}',
        maxLines: 1,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade700,
        ),
      );
    }

    // Ask Dealer
    return Text(
      'Ask dealer',
      maxLines: 1,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildSoldCount() {
    final sold = product.meta?.sold ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration:
          isshownfromcategories
              ? null
              : BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.teal, Colors.teal],
                ),
              ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_outlined,
            size: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            '$sold sold',
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateDiscount() {
    final salePrice = product.salePrice ?? 0;
    final originalPrice = product.price ?? product.maxPrice ?? 0;
    if (originalPrice == 0) return 0;
    return (((originalPrice - salePrice) / originalPrice) * 100).round();
  }

  void _navigateToDetail() {
    Get.to(
      () => ProductDetailScreenView(product: product),
      preventDuplicates: false,
    );
  }

  void _removeFromWishlist() {
    if (wishlistId.isEmpty) return;
    final controller = Get.put(WishlistServiceController());
    controller.removeFromWishlist(wishlistId, Get.context!);
  }
}

/// Optimized Product Image with Smart Caching
class ProductImage extends StatefulWidget {
  const ProductImage({super.key, required this.product});

  final ProductDatum product;

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _getImageUrl() {
    return widget.product.thumbnail?.media?.cdnThumbnailUrl ??
        widget.product.thumbnail?.media?.optimizedMediaCdnUrl ??
        widget.product.thumbnail?.media?.cdnUrl ??
        widget.product.thumbnail?.media?.url ??
        widget.product.thumbnail?.media?.localUrl ??
        widget.product.thumbnail?.media?.optimizedMediaUrl ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final url = _getImageUrl();

    if (url.isEmpty) {
      return _buildFallbackImage();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,

      // Memory cache configuration
      memCacheWidth: 300,

      // Maximum cache duration
      maxHeightDiskCache: 400,
      maxWidthDiskCache: 400,

      // Placeholder while loading (lightweight)
      placeholder:
          (context, url) => Container(
            color: Colors.grey.shade100,
            alignment: Alignment.center,
          ),

      // Error handling with fallback
      errorWidget:
          (context, url, error) => Container(
            color: Colors.grey.shade100,
            alignment: Alignment.center,
          ),

      // Fade animation for smooth UX
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        image: const DecorationImage(
          image: AssetImage('assets/images/tjara-logo (1).png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Add to Cart Button - BLACK SHOPPING CART
class _AddToCartButton extends StatefulWidget {
  const _AddToCartButton({required this.product});
  final ProductDatum product;

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _addToCart,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange),
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey.shade700,
                  ),
                )
                : Icon(
                  Icons.shopping_basket_rounded,
                  color: Colors.orange.shade800,
                  size: 16,
                ),
      ),
    );
  }

  Future<void> _addToCart() async {
    final LoginResponse? currentUser = AuthService.instance.authCustomer;
    if (currentUser?.user == null) {
      showContactDialog(context, const LoginUi());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cartService = Get.find<CartService>();
      final double price =
          double.tryParse(widget.product.price.toString()) ?? 0.0;

      final result = await cartService.updateCart(
        widget.product.shopId ?? '',
        widget.product.id ?? '',
        1,
        price,
      );

      if (mounted) {
        if (result is String) {
          NotificationHelper.showError(context, 'Failed', result);
        } else if (result is bool && result) {
          NotificationHelper.showSuccess(context, 'Success', 'Added to cart');
          try {
            (Get.isRegistered<DashboardController>()
                    ? Get.find<DashboardController>()
                    : Get.put(DashboardController()))
                .fetchCartCount();
          } catch (_) {}
        }
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
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// Shimmer Card
class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) => const _ShimmerProductCard();
}
