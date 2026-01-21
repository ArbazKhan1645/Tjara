import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:tjara/app/modules/home/screens/flash_deal_detail_screen.dart';
import 'package:tjara/app/modules/home/views/trust_badge.dart';
import 'package:tjara/app/modules/product_detail_screen/views/product_detail_screen_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DealSectionsWidget extends StatelessWidget {
  const DealSectionsWidget({
    super.key,
    this.onViewAllTap,
    this.isEndedDeals = false,
  });
  final VoidCallback? onViewAllTap;
  final bool isEndedDeals;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final products = controller.dealsproducts.value.products?.data ?? [];

        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        // Take only first 3 products
        final dealProducts = products.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEndedDeals) const TrustBadgesWidget(),
            if (!isEndedDeals)
              // Title
              Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 0,
                  bottom: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // WhatsApp Icon (Start)
                    GestureDetector(
                      onTap: () {
                        _openWhatsAppGroup();
                      },
                      child: Container(
                        width: 40,
                        padding: const EdgeInsets.all(6),

                        child: Image.asset('assets/icons/whatsapp.png'),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Texts (Middle)
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flash Deals',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'انضم لمجموعتنا لتوصلك العروض اليومية',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // View All Button (End)
                    TextButton(
                      onPressed: onViewAllTap ?? () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.teal,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(left: 12, bottom: 12),
                child: Text(
                  'Ended Deals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

            // Products Row
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(dealProducts.length, (index) {
                    final bool isschedule =
                        controller.superdealAvailable.value.product?.id ==
                        dealProducts[index].id;
                    if (isschedule && isEndedDeals) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _DealProductCard(
                        isScheduledProduct: isschedule,

                        product: dealProducts[index],
                        index: index,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _openWhatsAppGroup() async {
  final Uri url = Uri.parse(
    'https://chat.whatsapp.com/H4zhsjX17z5LV60lwtagR7?mode=r_c',
  );

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch WhatsApp link';
  }
}

class _DealProductCard extends StatelessWidget {
  const _DealProductCard({
    required this.product,
    required this.index,
    this.isScheduledProduct = false,
  });

  final ProductDatum product;
  final bool isScheduledProduct;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isScheduledProduct) {
          Get.to(
            () => ProductDetailScreenView(product: product),
            preventDuplicates: false,
          );
          return;
        }

        Get.to(() => const FlashDealDetailScreen(), preventDuplicates: false);
      },
      child: isScheduledProduct ? _buildScheduledCard() : _buildNormalCard(),
    );
  }

  // ============================================================
  // 🟢 SCHEDULED PRODUCT CARD
  // ============================================================
  Widget _buildScheduledCard() {
    final salePrice = product.salePrice ?? 0;
    final originalPrice = product.price ?? product.maxPrice ?? 0;

    int discountPercent = 0;
    if (salePrice > 0 && originalPrice > 0) {
      discountPercent =
          (((originalPrice - salePrice) / originalPrice) * 100).round();
    }

    return Container(
      width: 120,
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          /// IMAGE AREA
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFffedd5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: _buildProductImage(),
                  ),
                ),

                /// SCHEDULED BADGE
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfda730),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Scheduled',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// BOTTOM DISCOUNT STRIP
          if (discountPercent > 0)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    discountPercent > 0 ? '$discountPercent% Off' : '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔵 NORMAL PRODUCT CARD (UNCHANGED DESIGN)
  // ============================================================
  Widget _buildNormalCard() {
    final salePrice = product.salePrice;
    final originalPrice = product.price ?? product.maxPrice ?? 0;
    final hasDiscount = salePrice != null && salePrice != 0;

    int discountPercent = 0;
    if (hasDiscount && originalPrice > 0) {
      discountPercent =
          (((originalPrice - salePrice) / originalPrice) * 100).round();
    }

    return Container(
      height: 170,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Container(
            width: 120,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFffedd5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: _buildProductImage(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PRODUCT NAME
                Text(
                  product.name ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                /// PRICE ROW
                Row(
                  children: [
                    Text(
                      '\$${hasDiscount ? salePrice.toStringAsFixed(0) : originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (hasDiscount)
                      Text(
                        '\$${originalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                /// DISCOUNT BADGE
                if (hasDiscount && discountPercent > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$discountPercent% OFF',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🖼 IMAGE BUILDER (UNCHANGED)
  // ============================================================
  Widget _buildProductImage() {
    final imageUrl =
        product.thumbnail?.media?.optimizedMediaUrl ??
        product.thumbnail?.media?.url ??
        product.thumbnail?.media?.localUrl ??
        '';

    if (imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFFffedd5),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Colors.grey.shade400,
            size: 32,
          ),
        ),
      );
    }

    return FutureBuilder<ImageProvider>(
      future: loadCachedImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image(
            image: snapshot.data!,
            fit: BoxFit.cover,
            width: 300,

            height: double.infinity,
          );
        }
        return Container(color: const Color(0xFFffedd5));
      },
    );
  }
}
