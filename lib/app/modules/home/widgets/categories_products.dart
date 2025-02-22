import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
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
        if (controller.filterCategoryproducts.value.products!.data!.isEmpty) {
          return const Center(child: Text('No products available'));
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
}
