import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/modules/home/views/product.dart';
import 'package:tjara/app/modules/product_detail_screen/views/product_detail_screen_view.dart';

class AuctionProductsWidget extends StatefulWidget {
  const AuctionProductsWidget({super.key, this.onViewAllTap});
  final VoidCallback? onViewAllTap;

  @override
  State<AuctionProductsWidget> createState() => _AuctionProductsWidgetState();
}

class _AuctionProductsWidgetState extends State<AuctionProductsWidget> {
  List<ProductDatum> featuredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      const baseUrl = 'https://api.libanbuy.com/api/products';
      const params =
          '?with=thumbnail,shop&filterByColumns[filterJoin]=AND&per_page=12&page=1';
      const url =
          '$baseUrl$params&filterByColumns[columns][0][column]=product_type'
          '&filterByColumns[columns][0][value]=auction'
          '&filterByColumns[columns][0][operator]=%3D';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "X-Request-From": "Application",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = ProductModel.fromJson(data);

        setState(() {
          featuredProducts = model.products?.data ?? [];
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (_) {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (featuredProducts.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF015c5d),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.gavel_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Auction Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onViewAllTap,
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              featuredProducts.length,
              (i) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: AuctionProductCard(product: featuredProducts[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuctionProductCard extends StatefulWidget {
  const AuctionProductCard({super.key, required this.product});
  final ProductDatum product;

  @override
  State<AuctionProductCard> createState() => _AuctionProductCardState();
}

class _AuctionProductCardState extends State<AuctionProductCard> {
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _checkAuctionStatus();
  }

  void _checkAuctionStatus() {
    if (widget.product.auctionEndTime == null) {
      _isExpired = true;
      return;
    }

    final endTime = DateTime.tryParse(widget.product.auctionEndTime!);

    if (endTime == null) {
      _isExpired = true;
      return;
    }

    final endTimeLocal = endTime.toLocal();
    final nowUtc = DateTime.now().toUtc();
    final offset = DateTime.now().timeZoneOffset;

    final difference = endTimeLocal.difference(nowUtc) + offset;

    _isExpired = difference <= Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.product.salePrice ?? widget.product.price ?? 0;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProductDetailScreenView(product: widget.product),
          preventDuplicates: false,
        )?.then((val) async {
          setState(() {
            _checkAuctionStatus();
          });
        });
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _isExpired ? Colors.grey.shade300 : Colors.transparent,
            width: 1,
          ),
          boxShadow:
              _isExpired
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 160,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    child: ColorFiltered(
                      colorFilter:
                          _isExpired
                              ? ColorFilter.mode(
                                Colors.grey.withOpacity(0.5),
                                BlendMode.saturation,
                              )
                              : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              ),
                      child: ProductImage(product: widget.product),
                    ),
                  ),
                ),
                if (!_isExpired)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_isExpired)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ENDED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _isExpired ? Colors.grey.shade600 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 46,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient:
                          _isExpired
                              ? null
                              : const LinearGradient(
                                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                      color: _isExpired ? Colors.grey.shade200 : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            _isExpired
                                ? Colors.grey.shade300
                                : Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child:
                          _isExpired
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.block,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Auction Ended',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 16,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Bidding Active',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color:
                              _isExpired ? Colors.grey.shade500 : Colors.teal,
                        ),
                      ),
                      if (!_isExpired) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BID',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
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
