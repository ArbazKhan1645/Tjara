import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/modules/home/widgets/products_grid.dart';
import 'package:tjara/app/modules/product_detail_screen/views/product_detail_screen_view.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';

class SuperDealsWidget extends StatefulWidget {
  const SuperDealsWidget({super.key});

  @override
  State<SuperDealsWidget> createState() => _SuperDealsWidgetState();
}

class _SuperDealsWidgetState extends State<SuperDealsWidget> {
  static const _horizontalPadding = 12.0;
  static const _itemSpacing = 15.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        // Don't show flash deals section if sequence is completed
        if (!controller.shouldShowFlashDeals) {
          return const SizedBox.shrink();
        }

        final products = controller.dealsproducts.value.products?.data;
        final isLoading = controller.isLoadingDeals.value;
        final hasError = controller.hasDealsError.value;
        final errorMessage = controller.dealsError.value;

        return Column(
          children: [
            _buildHeader(),
            if (isLoading)
              _buildLoadingState()
            else if (hasError)
              _buildErrorState(controller, errorMessage)
            else if (products == null || products.isEmpty)
              const SizedBox()
            else
              _buildDealsList(products),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Row(
        children: [
          const Icon(Icons.electric_bolt_outlined, size: 25, color: Colors.black),
          const SizedBox(width: 4),
          const Text(
            "Flash Deals",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              final controller = Get.put(HomeController());
              controller.searchSuperDealsProducts();
              controller.setSelectedCategory(ProductAttributeItems());
            },
            child: const Text(
              "View All",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealsList(List<ProductDatum> products) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        itemCount: products.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: _itemSpacing, top: 10),
        cacheExtent: double.maxFinite,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == products.length - 1 ? _itemSpacing : 12,
            ),
            child: GestureDetector(
              onTap: () {
                Get.to(
                  () => ProductDetailScreenView(product: products[index]),
                  preventDuplicates: false,
                );
              },
              child: SuperDealItem(
                key: ValueKey('deal_product_${products[index].id}'),
                product: products[index],
                width: 200,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.orange, strokeWidth: 2),
          const SizedBox(height: 12),
          Text(
            'Loading Super Deals...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(HomeController controller, String errorMessage) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 32),
          const SizedBox(height: 12),
          Text(
            'Failed to load Super Deals',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your connection and try again',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => controller.retryDealsProducts(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, color: Colors.grey[400], size: 32),
          const SizedBox(height: 12),
          Text(
            'No Super Deals Available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for amazing deals!',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SuperDealItem extends StatefulWidget {
  const SuperDealItem({super.key, required this.product, required this.width});

  final ProductDatum product;
  final double width;

  @override
  State<SuperDealItem> createState() => _SuperDealItemState();
}

class _SuperDealItemState extends State<SuperDealItem>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  Widget? _cachedImageWidget;
  String? _cachedImageUrl;
  bool _isImageBuilt = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildImageContent();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RepaintBoundary(
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFF5F5F5), Color(0xFFFFD4B8)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange.shade300, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(height: 12),
            _buildProductInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
      ),
      child: Container(
        height: 120,
        width: widget.width,
        color: Colors.grey[100],
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    final currentImageUrl = widget.product.thumbnail?.media?.url ?? '';

    if (_cachedImageWidget == null ||
        _cachedImageUrl != currentImageUrl ||
        !_isImageBuilt) {
      print('Building image for product ${widget.product.id}');
      _cachedImageUrl = currentImageUrl;
      _isImageBuilt = true;

      _cachedImageWidget = Container(
        key: ValueKey('image_container_${widget.product.id}'),
        child: CachedImage(
          key: ValueKey(
            'cached_image_${widget.product.id}_${currentImageUrl.hashCode}',
          ),
          fit: BoxFit.cover,
          imageUrl: currentImageUrl,
        ),
      );
    } else {
      print('Reusing cached image for product ${widget.product.id}');
    }

    return _cachedImageWidget!;
  }

  Widget _buildProductInfo() {
    final num originalPrice = widget.product.price ?? 0;
    final num salePrice = widget.product.salePrice ?? 0;
    final String productName = widget.product.name ?? 'Product';

    final double discountPercentage =
        originalPrice > 0
            ? ((originalPrice - salePrice) / originalPrice * 100)
                .round()
                .toDouble()
            : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 11,
                ),
                const SizedBox(width: 3),
                Text(
                  '${discountPercentage.round()}% Off',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${salePrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '\$${originalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

enum ImageLoadingState { loading, loaded, error }
