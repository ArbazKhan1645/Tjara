import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/dashbopard_services/admin_auction_service.dart';

class AuctionOrderItemCard extends StatelessWidget {
  final AdminProducts product;

  const AuctionOrderItemCard({super.key, required this.product});

  // Safe getters for null safety
  String get _productId => product.meta?.productId?.toString() ?? '-';
  String get _productName => product.name ?? 'Unnamed Product';
  String get _shopName => product.shop?.shop?.name ?? 'N/A';
  String get _price => '\$${product.price ?? '0.00'}';
  String get _stock => '${product.stock ?? 0}';
  String get _auctionStart => product.auctionStartTime ?? '-';
  String get _auctionEnd => product.auctionEndTime ?? '-';
  String get _status => product.status?.toString() ?? 'unknown';
  bool get _isActive => _status.toLowerCase() == 'active';
  String get _thumbnailUrl => product.thumbnail?.media?.url ?? '';
  String get _productSlug => product.slug ?? '';
  String get _shopId => product.shop?.shop?.id ?? '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AuctionAdminTheme.surface,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        border: Border.all(color: AuctionAdminTheme.border),
        boxShadow: AuctionAdminTheme.shadowSm,
      ),
      child: IntrinsicWidth(
        child: Row(
          children: [
            // Product ID
            _AuctionDataCell(
              label: 'Product ID',
              width: 100,
              child: Text(
                _productId,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AuctionAdminTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Product Image
            _AuctionDataCell(
              label: 'Image',
              width: 150,
              child: _ProductImage(imageUrl: _thumbnailUrl),
            ),

            // Product Name
            _AuctionDataCell(
              label: 'Product Name',
              width: 120,
              child: Text(
                _productName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AuctionAdminTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),

            // Shop Name
            _AuctionDataCell(
              label: 'Shop Name',
              width: 150,
              child: Text(
                _shopName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AuctionAdminTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),

            // Price
            _AuctionDataCell(
              label: 'Price',
              width: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuctionAdminTheme.spacingSm,
                  vertical: AuctionAdminTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AuctionAdminTheme.primaryLight,
                  borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
                ),
                child: Text(
                  _price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AuctionAdminTheme.primary,
                  ),
                ),
              ),
            ),

            // Stock
            _AuctionDataCell(
              label: 'Stock',
              width: 100,
              child: _StockBadge(stock: _stock),
            ),

            // Auction Start
            _AuctionDataCell(
              label: 'Auction Start',
              width: 170,
              child: _TimeBadge(
                time: _auctionStart,
                icon: Icons.play_circle_outline_rounded,
                color: AuctionAdminTheme.success,
              ),
            ),

            // Auction End
            _AuctionDataCell(
              label: 'Auction End',
              width: 170,
              child: _TimeBadge(
                time: _auctionEnd,
                icon: Icons.stop_circle_outlined,
                color: AuctionAdminTheme.error,
              ),
            ),

            // Published At
            _AuctionDataCell(
              label: 'Published',
              width: 120,
              child: Text(
                _formatDate(product.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AuctionAdminTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Status
            _AuctionDataCell(
              label: 'Status',
              width: 100,
              child: _StatusBadge(status: _status, isActive: _isActive),
            ),

            // Actions
            _AuctionDataCell(
              label: 'Actions',
              width: 250,
              child: _AuctionActionButtons(
                product: product,
                shopId: _shopId,
                productSlug: _productSlug,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }
}

/// Auction Data Cell Widget
class _AuctionDataCell extends StatelessWidget {
  final String label;
  final double width;
  final Widget child;

  const _AuctionDataCell({
    required this.label,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AuctionAdminTheme.spacingMd,
        vertical: AuctionAdminTheme.spacingSm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AuctionAdminTheme.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AuctionAdminTheme.spacingXs),
          child,
        ],
      ),
    );
  }
}

/// Product Image Widget
class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AuctionAdminTheme.surfaceSecondary,
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          border: Border.all(color: AuctionAdminTheme.border),
        ),
        child: const Icon(
          Icons.image_rounded,
          color: AuctionAdminTheme.textTertiary,
          size: 24,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 50,
          height: 50,
          color: AuctionAdminTheme.surfaceSecondary,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AuctionAdminTheme.accent,
                ),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          ),
          child: Image.asset(
            'assets/icons/logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// Stock Badge Widget
class _StockBadge extends StatelessWidget {
  final String stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final stockValue = int.tryParse(stock) ?? 0;
    final isLowStock = stockValue < 10;
    final color = isLowStock ? AuctionAdminTheme.warning : AuctionAdminTheme.info;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuctionAdminTheme.spacingSm,
        vertical: AuctionAdminTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            stock,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Time Badge Widget
class _TimeBadge extends StatelessWidget {
  final String time;
  final IconData icon;
  final Color color;

  const _TimeBadge({
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuctionAdminTheme.spacingSm,
        vertical: AuctionAdminTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              time,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isActive;

  const _StatusBadge({
    required this.status,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AuctionAdminTheme.success : AuctionAdminTheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuctionAdminTheme.spacingMd,
        vertical: AuctionAdminTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.capitalize ?? status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Auction Action Buttons Widget
class _AuctionActionButtons extends StatelessWidget {
  final AdminProducts product;
  final String shopId;
  final String productSlug;

  const _AuctionActionButtons({
    required this.product,
    required this.shopId,
    required this.productSlug,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Edit Button
        _ActionButton(
          icon: Icons.edit_rounded,
          tooltip: 'Edit',
          color: AuctionAdminTheme.info,
          onTap: _onEdit,
        ),
        const SizedBox(width: AuctionAdminTheme.spacingXs),

        // Duplicate Button
        _ActionButton(
          icon: Icons.copy_rounded,
          tooltip: 'Duplicate',
          color: AuctionAdminTheme.accent,
          onTap: _onDuplicate,
        ),
        const SizedBox(width: AuctionAdminTheme.spacingXs),

        // Toggle Active Button
        _ActionButton(
          icon: product.status == 'active'
              ? Icons.pause_circle_outline_rounded
              : Icons.play_circle_outline_rounded,
          tooltip: product.status == 'active' ? 'Deactivate' : 'Activate',
          color: product.status == 'active'
              ? AuctionAdminTheme.warning
              : AuctionAdminTheme.success,
          onTap: _onToggleActive,
        ),
        const SizedBox(width: AuctionAdminTheme.spacingXs),

        // Toggle Featured Button
        _ActionButton(
          icon: product.isFeatured == 1
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          tooltip: product.isFeatured == 1 ? 'Remove Featured' : 'Make Featured',
          color: AuctionAdminTheme.primary,
          onTap: _onToggleFeatured,
        ),
        const SizedBox(width: AuctionAdminTheme.spacingXs),

        // Toggle Deal Button
        _ActionButton(
          icon: product.isDeal == 1
              ? Icons.local_offer_rounded
              : Icons.local_offer_outlined,
          tooltip: product.isDeal == 1 ? 'Remove Deal' : 'Mark as Deal',
          color: AuctionAdminTheme.error,
          onTap: _onToggleDeal,
        ),
        const SizedBox(width: AuctionAdminTheme.spacingXs),

        // Delete Button
        _ActionButton(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Delete',
          color: AuctionAdminTheme.error,
          onTap: _onDelete,
          isDanger: true,
        ),
      ],
    );
  }

  void _onEdit() {
    Get.delete<AuctionAddProductAdminController>();
    Get.toNamed(
      Routes.ADD_AUCTION_PRODUCT_ADMIN_VIEW,
      preventDuplicates: false,
      arguments: {'product': product},
    )?.then((val) {
      Get.find<AdminAuctionService>().refreshProducts();
    });
  }

  Future<void> _onDuplicate() async {
    final response = await Get.put<AuctionAddProductAdminController>(
      AuctionAddProductAdminController(),
    ).duplicateProduct(product);

    if (response == true) {
      Get.delete<AuctionAddProductAdminController>();
      await Get.find<AdminAuctionService>().refreshProducts();
      await Get.find<AdminAuctionService>().fetchProducts(refresh: true);
    }
  }

  Future<void> _onToggleActive() async {
    final response = await ProductService.updateActiveStatus(
      shopId: shopId,
      productId: product.id ?? '',
      isActive: product.status == 'active',
    );
    await Get.find<AdminAuctionService>().refreshProducts();

    if (response.success) {
      _showSuccessMessage(response.message);
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _onToggleFeatured() async {
    final response = await ProductService.updateFeaturedStatus(
      shopId: shopId,
      productId: product.id ?? '',
      isFeatured: product.isFeatured == 1,
    );
    await Get.find<AdminAuctionService>().refreshProducts();

    if (response.success) {
      _showSuccessMessage(response.message);
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _onToggleDeal() async {
    final response = await ProductService.updateDealStatus(
      shopId: shopId,
      productId: product.id ?? '',
      isDeal: product.isDeal == 1,
    );
    await Get.find<AdminAuctionService>().refreshProducts();

    if (response.success) {
      _showSuccessMessage(response.message);
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _onDelete() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Auction'),
        content: Text(
          'Are you sure you want to delete "${product.name ?? 'this auction'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AuctionAdminTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await ProductService.deleteProduct(
      shopId: shopId,
      productId: product.id ?? '',
    );

    Get.find<AdminAuctionService>().refreshProducts();

    if (response.success) {
      _showSuccessMessage(response.message);
    } else {
      _showErrorMessage(response);
    }
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AuctionAdminTheme.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
      borderRadius: AuctionAdminTheme.radiusMd,
    );
  }

  void _showErrorMessage(ApiResponse response) {
    String errorMessage = response.message;

    if (response.errors != null && response.errors!.isNotEmpty) {
      final List<String> errorList = [];
      response.errors!.forEach((key, value) {
        if (value is List) {
          errorList.addAll(value.map((e) => e.toString()));
        } else {
          errorList.add(value.toString());
        }
      });
      errorMessage = errorList.join('\n');
    }

    Get.snackbar(
      'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AuctionAdminTheme.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      maxWidth: Get.width * 0.9,
      margin: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
      borderRadius: AuctionAdminTheme.radiusMd,
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
