// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/appbar.dart';
import 'package:tjara/app/modules/home/views/product.dart';
import 'package:tjara/app/modules/wishlist/controllers/wishlist_controller.dart';

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
                    const Color(0xFFfea52d).withOpacity(0.0), // Fade to transparent
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

  Widget _buildWishlistContent(WishlistController controller) {
    return CustomScrollView(
      slivers: [
        // Header with icon and title
        // SliverToBoxAdapter(
        //   child: Container(
        //     padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        //     child: Row(
        //       children: [
        //         // ✨ Wishlist icon with gradient background
        //         Container(
        //           width: 56,
        //           height: 56,
        //           decoration: BoxDecoration(
        //             gradient: LinearGradient(
        //               begin: Alignment.topLeft,
        //               end: Alignment.bottomRight,
        //               colors: [Color(0xFFfea52d), Color(0xFFf97316)],
        //             ),
        //             shape: BoxShape.circle,
        //             boxShadow: [
        //               BoxShadow(
        //                 color: Color(0xFFfea52d).withOpacity(0.3),
        //                 blurRadius: 12,
        //                 offset: Offset(0, 4),
        //               ),
        //             ],
        //           ),
        //           child: Icon(Icons.favorite, color: Colors.white, size: 28),
        //         ),
        //         const SizedBox(width: 16),
        //         Expanded(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 'My Favourites',
        //                 style: TextStyle(
        //                   fontSize: 22,
        //                   fontWeight: FontWeight.bold,
        //                   color: Colors.black87,
        //                 ),
        //               ),
        //               Obx(() {
        //                 final count =
        //                     controller
        //                         .wishlistController
        //                         .wishlistResponse
        //                         .wishlistItems
        //                         ?.length ??
        //                     0;
        //                 return Text(
        //                   '$count ${count == 1 ? 'item' : 'items'}',
        //                   style: TextStyle(
        //                     fontSize: 14,
        //                     color: Colors.grey.shade600,
        //                   ),
        //                 );
        //               }),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

        // Products Grid
        Obx(() {
          final wishlistItems =
              controller.wishlistController.wishlistResponse.wishlistItems;
          final isLoading = controller.wishlistController.isLoading;
          final isDataLoaded = controller.wishlistController.isDataLoaded;

          if (isLoading && !isDataLoaded) {
            return const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (wishlistItems == null || wishlistItems.isEmpty) {
            return SliverFillRemaining(child: _buildEmptyState());
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 12,
              childCount: wishlistItems.length,
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
          );
        }),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ✨ Better Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFfea52d).withOpacity(0.2),
                  const Color(0xFFf97316).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 60,
              color: Color(0xFFfea52d),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save items you love to find them later',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFfea52d),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
