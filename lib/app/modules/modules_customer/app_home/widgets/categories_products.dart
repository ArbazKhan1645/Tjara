import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';
import 'package:tjara/app/modules/modules_customer/app_home/widgets/other_product_grid.dart';

class CategoriesProductGrid extends StatefulWidget {
  const CategoriesProductGrid({super.key});
  @override
  State<CategoriesProductGrid> createState() => _CategoriesProductGridState();
}

class _CategoriesProductGridState extends State<CategoriesProductGrid> {
  static const _crossAxisCount = 2;
  static const _mainAxisSpacing = 10.0;
  static const _crossAxisSpacing = 5.0;
  static const _shimmerItemCount = 6;
  static const _shimmerHeight = 350.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.iscategoryLoading.value) {
          return _buildShimmerGrid();
        }
        if (controller.filterCategoryproducts.value.products?.data?.isEmpty ??
            true) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 36),
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Products Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or explore\nother categories.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }
        return _buildProductGrid(controller);
      },
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount,
          mainAxisSpacing: _mainAxisSpacing,
          crossAxisSpacing: _crossAxisSpacing,
          childAspectRatio: 0.64,
        ),
        itemCount: _shimmerItemCount,
        itemBuilder: (context, index) => const _ShimmerCard(),
      ),
    );
  }

  Widget _buildProductGrid(HomeController controller) {
    final products = controller.filterCategoryproducts.value.products!.data!;

    // Memory-efficient approach: paginate data in the UI level if not handled in controller
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Trigger pagination when close to bottom of the parent scrollable
        try {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            if (!controller.isCategorypaginationLoading) {
              controller.fetchMoreSearches(
                controller.selectedFilter.value,
                controller.minFilter.value,
                controller.maxFilter.value,
              );
            }
          }
        } catch (_) {}
        return false;
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: LazyLoadingGrid(
              totalItems: products.length,
              crossAxisCount: _crossAxisCount,
              mainAxisSpacing: _mainAxisSpacing,
              crossAxisSpacing: _crossAxisSpacing,
              itemBuilder: (context, index) {
                // Add bounds checking here as well
                if (index >= products.length) {
                  return const SizedBox.shrink();
                }

                return TemuProductCard(
                  isshownfromcategories: false,
                  key: ValueKey('product_${products[index].id}'),
                  product: products[index],
                );
              },
            ),
          ),
          // Bottom loading indicator when fetching more data on scroll
          if (controller.isCategorypaginationLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(width: 10),
                  Text('Loading more...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class LazyLoadingGrid extends StatelessWidget {
  final int totalItems;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Widget Function(BuildContext, int) itemBuilder;

  const LazyLoadingGrid({
    super.key,
    required this.totalItems,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(), // let parent scroll
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: 0.64,
      ),
      itemCount: totalItems,
      itemBuilder: itemBuilder,
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: _CategoriesProductGridState._shimmerHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
