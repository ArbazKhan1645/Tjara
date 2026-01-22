import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
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
  late AuctionProductsController controller;

  @override
  void initState() {
    super.initState();
    // Controller pehle se exist karta hai to use karo, nahi to banao
    controller =
        Get.isRegistered<AuctionProductsController>()
            ? Get.find<AuctionProductsController>()
            : Get.put(AuctionProductsController(), permanent: true);
    controller.refreshs();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.products.isEmpty && !controller.isLoading.value) {
        return const SizedBox.shrink();
      }

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
                  const Icon(
                    Icons.gavel_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
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
          SizedBox(
            height: 300,
            child:
                controller.isLoading.value && controller.products.isEmpty
                    ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildShimmerCard(),
                        );
                      },
                    )
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.products.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AuctionProductCard(
                            key: ValueKey(controller.products[i].id),
                            product: controller.products[i],
                          ),
                        );
                      },
                    ),
          ),
        ],
      );
    });
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 160,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 46,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
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

class AuctionProductsController extends GetxController {
  final products = <ProductDatum>[].obs;
  final isLoading = false.obs;
  Timer? _expiryCheckTimer;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
    _startExpiryCheckTimer();
  }

  @override
  void onClose() {
    _expiryCheckTimer?.cancel();
    super.onClose();
  }

  void _startExpiryCheckTimer() {
    _expiryCheckTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      products.refresh();
    });
  }

  Future<void> _loadProducts() async {
    if (products.isEmpty) {
      isLoading.value = true;
    }

    try {
      const baseUrl = 'https://api.libanbuy.com/api/products';
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;

      final params =
          '?with=thumbnail,shop'
          '&filterByColumns[filterJoin]=AND'
          '&per_page=12'
          '&page=1'
          '&cb=$cacheBuster';

      final url =
          '$baseUrl$params'
          '&filterByColumns[columns][0][column]=product_type'
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
        products.value = model.products?.data ?? [];
      }
    } catch (_) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  void refreshs() => _loadProducts();
}

class AuctionProductCard extends StatefulWidget {
  const AuctionProductCard({super.key, required this.product});
  final ProductDatum product;

  @override
  State<AuctionProductCard> createState() => _AuctionProductCardState();
}

class _AuctionProductCardState extends State<AuctionProductCard> {
  Timer? _countdownTimer;
  Duration? _remainingTime;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _initializeAuctionTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initializeAuctionTimer() {
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
    final now = DateTime.now();
    _remainingTime = endTimeLocal.difference(now);

    if (_remainingTime! <= Duration.zero) {
      _isExpired = true;
      return;
    }

    // Sirf agar auction active hai to timer start karo
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();

    // Har minute update karo (ya har 30 seconds agar chahiye)
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        _countdownTimer?.cancel();
        return;
      }

      final endTime = DateTime.tryParse(widget.product.auctionEndTime!);
      if (endTime == null) return;

      final endTimeLocal = endTime.toLocal();
      final now = DateTime.now();
      final remaining = endTimeLocal.difference(now);

      if (remaining <= Duration.zero) {
        setState(() {
          _isExpired = true;
          _remainingTime = Duration.zero;
        });
        _countdownTimer?.cancel();
      } else {
        setState(() {
          _remainingTime = remaining;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.product.salePrice ?? widget.product.price ?? 0;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProductDetailScreenView(product: widget.product),
          preventDuplicates: false,
        )?.then((val) {
          if (mounted) {
            _initializeAuctionTimer();
          }
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
          mainAxisSize: MainAxisSize.min,
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
                Positioned(top: 8, right: 8, child: _buildStatusBadge()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  _buildBiddingStatus(),
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

  Widget _buildStatusBadge() {
    if (_isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildBiddingStatus() {
    return Container(
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
          color: _isExpired ? Colors.grey.shade300 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Center(
        child:
            _isExpired
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, size: 14, color: Colors.grey.shade600),
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
    );
  }
}
