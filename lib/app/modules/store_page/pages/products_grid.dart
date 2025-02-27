// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/home/widgets/products_grid.dart';
import 'package:tjara/app/modules/store_page/controllers/store_page_controller.dart';

class StoreProductGrid extends StatefulWidget {
  const StoreProductGrid({super.key});

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
            if ((controller.products.value.products?.data ?? []).isEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

            if (controller.products.value.products!.data!.isEmpty) {
              return const Center(child: Text('No products available'));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: MasonryGridView.count(
                key: PageStorageKey<String>('storeproductGridKey'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                itemCount: controller.products.value.products!.data!.length,
                itemBuilder: (context, index) {
                  final product =
                      controller.products.value.products!.data![index];
                  return ProductCard(
                      key: PageStorageKey('store_product_${product.id}'),
                      product: product,
                      index: index);
                },
              ),
            );
          },
        ));
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
