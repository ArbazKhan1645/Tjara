import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:tjara/app/modules/home/widgets/products_grid.dart';

class CategoriesProductGrid extends StatefulWidget {
  const CategoriesProductGrid({super.key});

  @override
  State<CategoriesProductGrid> createState() => _CategoriesProductGridState();
}

class _CategoriesProductGridState extends State<CategoriesProductGrid> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.iscategoryLoading.value) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: MasonryGridView.count(
              key: PageStorageKey<String>('productGridKey'),
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
        if (controller.filterCategoryproducts.value.products!.data!.isEmpty) {
          return Center(child: Text('No Products found of this category'));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            itemCount:
                controller.filterCategoryproducts.value.products!.data!.length,
            itemBuilder: (context, index) {
              final product = controller
                  .filterCategoryproducts.value.products!.data![index];
              return ProductCard(product: product, index: index);
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
