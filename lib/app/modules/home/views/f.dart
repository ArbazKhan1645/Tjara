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
  String _timeText = '';
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _calculateTime();
  }

  void _calculateTime() {
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

    if (difference <= Duration.zero) {
      _isExpired = true;
    } else {
      _isExpired = false;
      _timeText = _formatDuration(difference);
    }
  }

  String _formatDuration(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;

    if (days > 0) {
      return hours > 0 ? '${days}d ${hours}h' : '${days}day';
    }

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }

    return '${minutes}m';
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
            _calculateTime();
          });
        });
      },
      child: Container(
        width: 160,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 160,
              child: ProductImage(product: widget.product),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 56, // Fixed height
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          _isExpired
                              ? Colors.grey.shade200
                              : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child:
                          _isExpired
                              ? const Text(
                                'Auction Ended',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                              : Column(
                                children: [
                                  const Text(
                                    'Ends in',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  Text(
                                    _timeText,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.teal,
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
