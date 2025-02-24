// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/home/widgets/products_grid.dart';
import 'package:tjara/app/modules/store_page/controllers/store_page_controller.dart';

class StoreProductGrid extends StatefulWidget {
  const StoreProductGrid({super.key});

  @override
  State<StoreProductGrid> createState() => _StoreProductGridState();
}

class _StoreProductGridState extends State<StoreProductGrid> {
  final StorePageController _storePageController =
      Get.put(StorePageController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StorePageController>(
      builder: (controller) {
        if (controller.products.value.products!.data!.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.value.products!.data!.isEmpty) {
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
            itemCount: controller.products.value.products!.data!.length,
            itemBuilder: (context, index) {
              final product = controller.products.value.products!.data![index];
              return ProductCard(product: product, index: index);
            },
          ),
        );
      },
    );
  }
}
