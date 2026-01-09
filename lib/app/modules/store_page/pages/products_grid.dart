// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/home/views/product.dart';
import 'package:tjara/app/modules/store_page/controllers/store_page_controller.dart';

class StoreProductGrid extends StatefulWidget {
  const StoreProductGrid({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  State<StoreProductGrid> createState() => _StoreProductGridState();
}

class _StoreProductGridState extends State<StoreProductGrid>
    with AutomaticKeepAliveClientMixin {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageStorage(
      bucket: _bucket,
      child: GetBuilder<StorePageController>(
        builder: (controller) {
          return Obx(() {
            // Initial loading state - show only shimmer
            if (controller.isLoading.value &&
                (controller.products.value.products?.data ?? []).isEmpty) {
              return _buildInitialLoadingState();
            }

            // Search loading state
            if (controller.isSearching.value) {
              return _buildSearchLoadingState();
            }

            // No products state
            if (controller
                    .filterCategoryproducts
                    .value
                    .products
                    ?.data
                    ?.isEmpty ??
                true) {
              return _buildEmptyState();
            }

            // Products loaded state
            return _buildProductsGrid(controller);
          });
        },
      ),
    );
  }

  Widget _buildInitialLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: MasonryGridView.count(
        key: const PageStorageKey<String>('initialLoadingKey'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildShimmerCard();
        },
      ),
    );
  }

  Widget _buildSearchLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          // Search indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Searching products...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Shimmer grid for search
          MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildShimmerCard();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(StorePageController controller) {
    final products = controller.filterCategoryproducts.value.products!.data!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          // Products grid
          MasonryGridView.count(
            key: const PageStorageKey<String>('storeproductGridKey'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return TemuProductCard(
                isshownfromcategories: false,
                key: ValueKey('product_${products[index].id}'),
                product: products[index],
              );
            },
          ),

          // Pagination loading indicator
          if (controller.isLoading.value && products.isNotEmpty)
            _buildPaginationLoadingIndicator(),

          // End of results indicator
          if (!controller.hasMoreData.value && products.isNotEmpty) Container(),
        ],
      ),
    );
  }

  Widget _buildPaginationLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Loading more products...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 20),
          // // Show shimmer cards for pagination
          // MasonryGridView.count(
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   crossAxisCount: 2,
          //   mainAxisSpacing: 20,
          //   crossAxisSpacing: 10,
          //   itemCount: 2,
          //   itemBuilder: (context, index) {
          //     return _buildShimmerCard();
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildEndOfResultsIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'ve reached the end!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No more products to load',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle placeholder
                  Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price placeholder
                  Container(
                    height: 18,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
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
