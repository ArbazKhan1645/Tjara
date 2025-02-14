// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../models/products/products_model.dart';
import '../controllers/home_controller.dart';
import 'product_detail.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final HomeController _homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    _homeController
        .fetchProducts(); // Fetch products when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
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

class ProductCard extends StatelessWidget {
  final Datum product; // Assuming Product is your model class
  final int index;

  const ProductCard({super.key, required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.offAll(() => ProductDetailScreen(product: product));
      },
      child: Container(
        height: 330,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              offset: const Offset(0, 2.64),
              blurRadius: 33.05,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13.22)),
              child: Image.network(
                product.thumbnail?.media?.url ??
                    'moj', // Assuming your product model has an imageUrl field
                fit: BoxFit.fill,
                width: double.infinity,
                height: 140,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    index.isEven
                        ? 'assets/images/beer2.png'
                        : 'assets/images/beer.png',
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 140,
                  );
                },
              ),
            ),
            LightningDealCard(product: product),
          ],
        ),
      ),
    );
  }
}

class LightningDealCard extends StatelessWidget {
  const LightningDealCard({super.key, required this.product});
  final Datum product; // Assuming Product is your model class

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 33.05,
              offset: Offset(0, 2.64),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 24,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/light.png', height: 14),
                  SizedBox(width: 4),
                  Text(
                    "Lightning Deal",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Image.asset('assets/images/flower.png', height: 14),
                  SizedBox(width: 4),
                  Text(
                    "Limited Time Offer",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.shop?.shop?.name ?? '',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Padding(
                            padding: EdgeInsets.only(left: 2),
                            child: Image.asset(
                              index < 4
                                  ? 'assets/images/star.png'
                                  : 'assets/images/star.png',
                              height: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    product.name.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      if (product.isDiscountProduct == true)
                        Text(
                          "\$${(product.price ?? 0).toString()}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      SizedBox(width: 5),
                      Text(
                        "\$${(product.price ?? 0).toString()}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Spacer(),
                      Image.asset('assets/images/cart.png'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Text(
                          "T",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "rated 5 star 5 min ago",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
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
