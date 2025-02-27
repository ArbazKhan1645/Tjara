// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/routes/app_pages.dart';
import '../../../models/products/products_model.dart';
import '../../product_detail_screen/views/product_detail_screen_view.dart';
import '../controllers/home_controller.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid>
    with AutomaticKeepAliveClientMixin {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PageStorage(
        bucket: _bucket,
        child: GetBuilder<HomeController>(
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
                key: PageStorageKey<String>('productGridKey'),
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
                      key: PageStorageKey('product_${product.id}'),
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

class ProductCard extends StatelessWidget {
  final ProductDatum product;
  final int index;

  const ProductCard({super.key, required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreenView(product: product)));
      },
      child: Stack(
        children: [
          Container(
            height: 300,
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
                  child: Stack(
                    children: [
                      FutureBuilder<ImageProvider>(
                        future: loadCachedImage(
                            product.thumbnail?.media?.url ?? 'moj'),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              height: 140,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: snapshot.data!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              height: 140,
                              decoration: BoxDecoration(),
                            );
                          }
                        },
                      ),
                      // CachedNetworkImage(
                      //   cacheManager: PersistentCacheManager(),
                      //   imageUrl: product.thumbnail?.media?.url ?? 'moj',
                      //   imageBuilder: (context, imageProvider) => Container(
                      //     height: 140,
                      //     decoration: BoxDecoration(
                      //       image: DecorationImage(
                      //         image: imageProvider,
                      //         fit: BoxFit.cover,
                      //       ),
                      //     ),
                      //   ),
                      //   placeholder: (context, url) => Container(),
                      //   errorWidget: (context, url, error) => Container(),
                      // ),
                      // SizedBox(
                      //   child: Image.asset(
                      //     'assets/images/beer2.png',
                      //     fit: BoxFit.fill,
                      //     width: double.infinity,
                      //     height: 140,
                      //     // errorBuilder: (context, error, stackTrace) {
                      //     //   return Image.asset(
                      //     //     index.isEven
                      //     //         ? 'assets/images/beer2.png'
                      //     //         : 'assets/images/beer.png',
                      //     //     fit: BoxFit.fill,
                      //     //     width: double.infinity,
                      //     //     height: 140,
                      //     //   );
                      //     // },
                      //   ),
                      // ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Builder(builder: (context) {
                          if (product.isDeal == 1) {
                            return Container(
                              height: 24,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.red,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/images/light.png',
                                      height: 14),
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
                                  Image.asset('assets/images/flower.png',
                                      height: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    "Limited Time Offer",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }
                          if ((product.stock ?? 0) < 10) {
                            return Container(
                              height: 24,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.green,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Almost Sold Out",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Container();
                        }),
                      ),
                    ],
                  ),
                ),
                LightningDealCard(product: product),
              ],
            ),
          ),
          if (product.isFeatured == 1)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                height: 24,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Featured",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LightningDealCard extends StatelessWidget {
  const LightningDealCard({super.key, required this.product});
  final ProductDatum product; // Assuming Product is your model class

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
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if ((product.shop?.shop?.isVerified ?? 0) == 1)
                        Icon(Icons.verified_outlined,
                            size: 10, color: Colors.red),
                      Expanded(
                          flex: 5,
                          child: TextButton(
                              onPressed: () {
                                Get.toNamed(Routes.STORE_PAGE, arguments: {
                                  'shopid': product.shop?.shop?.id ?? '',
                                  'ShopShop': product.shop?.shop,
                                });
                              },
                              child: Text(
                                product.shop?.shop?.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ))),
                      Expanded(
                        flex: 4,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ...List.generate(
                                5,
                                (index) => Image.asset(
                                  index < 4
                                      ? 'assets/images/star.png'
                                      : 'assets/images/star.png',
                                  height: 6,
                                ),
                              ),
                              SizedBox(width: 2),
                              Text(
                                  '(${(product.rating?.length ?? 0).toString()})',
                                  style: TextStyle(fontSize: 10)),
                            ]),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.remove_red_eye, size: 10),
                      Text((product.meta?.views ?? 0).toString(),
                          style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  Text(
                    product.name.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "\$${(product.price ?? product.maxPrice ?? 0).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Spacer(),
                      Image.asset('assets/images/cart.png'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Builder(builder: (controller) {
                    if ((product.stock ?? 0) < 10) {
                      if (product.productGroup == 'car') {
                        return Container();
                      }
                      return Text(
                        "Almost Sold Out",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    }
                    return Container();
                  })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
