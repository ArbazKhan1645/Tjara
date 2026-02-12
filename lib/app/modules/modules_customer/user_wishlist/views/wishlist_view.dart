// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/appbar.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/other_product_grid.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/related_products_grid.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/controllers/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return const WishlistScreen();
  }
}

class WishlistScreen extends GetView<WishlistController> {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          // ✨ Gradient Background (Top portion only)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200, // Fixed height for gradient area
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFfea52d), // Orange top
                    const Color(
                      0xFFfea52d,
                    ).withOpacity(0.0), // Fade to transparent
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const CustomAppBar(
                  showWhitebackground: false,
                  showActions: false,
                ),
                Expanded(
                  child: GetBuilder<WishlistController>(
                    init: WishlistController(),
                    builder: (controller) => _buildWishlistContent(controller),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final String _randomLetter = String.fromCharCode(
    65 + Random().nextInt(26),
  );

  Widget _buildWishlistContent(WishlistController controller) {
    return CustomScrollView(
      controller: controller.scrollController,
      slivers: [
        // Products Grid
        Obx(() {
          final wishlistItems =
              controller.wishlistController.wishlistResponse.wishlistItems;
          final isLoading = controller.wishlistController.isLoading;
          final isDataLoaded = controller.wishlistController.isDataLoaded;

          if (isLoading && !isDataLoaded) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (wishlistItems == null || wishlistItems.isEmpty) {
            return SliverToBoxAdapter(child: _buildEmptyState());
          }

          return SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 12,
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final product = wishlistItems[index].product;
                  if (product == null) return const SizedBox.shrink();

                  return TemuProductCard(
                    wishlistId: wishlistItems[index].id.toString(),
                    isWishListProduct: true,
                    isshownfromcategories: false,
                    key: ValueKey('product_${product.id}'),
                    product: product,
                  );
                },
              ),
            ),
          );
        }),

        // Section header for related products
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFfea52d),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recommended for you',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Related Products (always visible)
        const SliverToBoxAdapter(
          child: RelatedProductGrid(isdealsection: false, search: 'a'),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 300)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFfea52d).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 40,
              color: Color(0xFFfea52d),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Save items you love to find them later',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              DashboardController.instance.reset();
            },
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFfea52d),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
