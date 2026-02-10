import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/auction_admin/widgets/actions_buttons.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/dashbopard_services/admin_auction_service.dart';

class AuctionOrderItemCard extends StatefulWidget {
  final AdminProducts product;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const AuctionOrderItemCard({
    super.key,
    required this.product,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  State<AuctionOrderItemCard> createState() => _AuctionOrderItemCardState();
}

class _AuctionOrderItemCardState extends State<AuctionOrderItemCard> {
  bool _isHovered = false;

  String get productId => widget.product.meta?.productId?.toString() ?? '';
  String get productName => widget.product.name ?? 'Unnamed Product';
  String get shopName => widget.product.shop?.shop?.name ?? 'Unknown Shop';
  String get shopId => widget.product.shop?.shop?.id ?? '';
  double get price => widget.product.price ?? 0.0;
  int get stock => widget.product.stock ?? 0;
  String get status => widget.product.status ?? 'inactive';
  String get slug => widget.product.slug ?? '';
  String get id => widget.product.id ?? '';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isFeatured => widget.product.isFeatured == 1;
  bool get isDeal => widget.product.isDeal == 1;
  bool get hasInventory => widget.product.meta?.inventoryUpdatedAt != null;
  bool get isPinnedSale => widget.product.meta?.isPinnedSale == '1';
  bool get isPrivate => status.toLowerCase() == 'private';
  String get auctionStart => widget.product.auctionStartTime ?? '-';
  String get auctionEnd => widget.product.auctionEndTime ?? '-';

  String get imageUrl {
    final media = widget.product.thumbnail?.media;
    if (media == null) return '';
    return media.url ?? '';
  }

  DateTime get createdAt => widget.product.createdAt ?? DateTime.now();
  ProductAnalytics get analytics =>
      widget.product.analytics ?? ProductAnalytics();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color:
              widget.isSelected
                  ? AuctionAdminTheme.accent.withValues(alpha: 0.04)
                  : _isHovered
                  ? AuctionAdminTheme.surface
                  : AuctionAdminTheme.surface,
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
          border: Border.all(
            color:
                widget.isSelected
                    ? AuctionAdminTheme.accent
                    : _isHovered
                    ? AuctionAdminTheme.accent.withValues(alpha: 0.3)
                    : AuctionAdminTheme.border,
            width: widget.isSelected ? 1.5 : 1,
          ),
          boxShadow:
              _isHovered
                  ? [
                    BoxShadow(
                      color: AuctionAdminTheme.accent.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : AuctionAdminTheme.shadowSm,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AuctionAdminTheme.spacingLg,
            vertical: AuctionAdminTheme.spacingMd,
          ),
          child: Row(
            children: [
              // Checkbox
              if (widget.onSelectionChanged != null)
                SizedBox(
                  width: 40,
                  child: Checkbox(
                    value: widget.isSelected,
                    onChanged:
                        (val) => widget.onSelectionChanged?.call(val ?? false),
                    activeColor: AuctionAdminTheme.accent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),

              // Product ID
              _buildColumn(
                width: 100,
                label: 'Product ID',
                child: _buildProductIdBadge(),
              ),

              // Image
              _buildColumn(
                width: 80,
                label: 'Image',
                child: _buildProductImage(),
              ),

              // Product Name (with quick edit)
              _buildColumn(
                width: 180,
                label: 'Product Name',
                child: Row(
                  children: [
                    _buildSmallEditIcon(onTap: () => _showUpdateNameDialog()),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AuctionAdminTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Shop Name
              _buildColumn(
                width: 150,
                label: 'Shop',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AuctionAdminTheme.accentLight,
                        borderRadius: BorderRadius.circular(
                          AuctionAdminTheme.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 14,
                        color: AuctionAdminTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shopName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AuctionAdminTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              _buildColumn(
                width: 100,
                label: 'Price',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AuctionAdminTheme.primaryLight,
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusSm,
                    ),
                  ),
                  child: Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AuctionAdminTheme.primary,
                    ),
                  ),
                ),
              ),

              // Stock
              _buildColumn(
                width: 80,
                label: 'Stock',
                child: _buildStockBadge(),
              ),

              // Auction Start
              _buildColumn(
                width: 140,
                label: 'Auction Start',
                child: _TimeBadge(
                  time: auctionStart,
                  icon: Icons.play_circle_outline_rounded,
                  color: AuctionAdminTheme.success,
                ),
              ),

              // Auction End
              _buildColumn(
                width: 140,
                label: 'Auction End',
                child: _TimeBadge(
                  time: auctionEnd,
                  icon: Icons.stop_circle_outlined,
                  color: AuctionAdminTheme.error,
                ),
              ),

              // Published
              _buildColumn(
                width: 120,
                label: 'Published',
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AuctionAdminTheme.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AuctionAdminTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status
              _buildColumn(
                width: 100,
                label: 'Status',
                child: _buildStatusBadge(),
              ),

              // Analytics
              _buildColumn(
                width: 200,
                label: 'Analytics',
                child: _buildAnalyticsSection(),
              ),

              // Actions
              const SizedBox(width: AuctionAdminTheme.spacingMd),
              AuctionActionButtons(
                productId: id,
                productName: productName,
                productSku: slug,
                isActive: isActive,
                isFeatured: isFeatured,
                isDeal: isDeal,
                hasInventory: hasInventory,
                isPinnedSale: isPinnedSale,
                isPrivate: isPrivate,
                onDuplicate: _handleDuplicate,
                onActiveChanged: _handleActiveChange,
                onFeaturedChanged: _handleFeaturedChange,
                onDealChanged: _handleDealChange,
                onInventoryChanged: _handleInventoryChange,
                onPinSaleChanged: _handlePinSaleChange,
                onPrivateChanged: _handlePrivateChange,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumn({
    required double width,
    required String label,
    required Widget child,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AuctionAdminTheme.spacingSm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AuctionAdminTheme.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildProductIdBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AuctionAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
        border: Border.all(color: AuctionAdminTheme.border),
      ),
      child: Text(
        '#$productId',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
          color: AuctionAdminTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
        border: Border.all(color: AuctionAdminTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm - 1),
        child:
            imageUrl.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildImagePlaceholder(),
                  errorWidget:
                      (context, url, error) => _buildImagePlaceholder(),
                )
                : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AuctionAdminTheme.surfaceSecondary,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 24,
          color: AuctionAdminTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    final bool lowStock = stock < 10;
    final bool outOfStock = stock == 0;

    Color bgColor = AuctionAdminTheme.info.withValues(alpha: 0.1);
    Color textColor = AuctionAdminTheme.info;

    if (outOfStock) {
      bgColor = AuctionAdminTheme.errorLight;
      textColor = AuctionAdminTheme.error;
    } else if (lowStock) {
      bgColor = AuctionAdminTheme.warning.withValues(alpha: 0.1);
      textColor = AuctionAdminTheme.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (outOfStock)
            Icon(Icons.warning_amber_rounded, size: 12, color: textColor),
          if (outOfStock) const SizedBox(width: 4),
          Text(
            stock.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            isActive
                ? AuctionAdminTheme.success.withValues(alpha: 0.1)
                : AuctionAdminTheme.errorLight,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isActive
                      ? AuctionAdminTheme.success
                      : AuctionAdminTheme.error,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  isActive
                      ? AuctionAdminTheme.success
                      : AuctionAdminTheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _buildAnalyticItem('Views', analytics.views),
        _buildAnalyticItem('Clicks', analytics.clicks),
        _buildAnalyticItem('Likes', analytics.likes),
        _buildAnalyticItem('Shares', analytics.shares),
        _buildAnalyticItem('Cart', analytics.addToCart),
        _buildAnalyticItem('Purchases', analytics.purchase),
        _buildAnalyticItem('Wishlist', analytics.wishlist),
        _buildAnalyticItem('Comments', analytics.comments),
      ],
    );
  }

  Widget _buildAnalyticItem(String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            color: AuctionAdminTheme.textTertiary,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AuctionAdminTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallEditIcon({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AuctionAdminTheme.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.edit_outlined,
          size: 13,
          color: AuctionAdminTheme.accent,
        ),
      ),
    );
  }

  // Quick edit: only name for auctions (no price/stock)
  void _showUpdateNameDialog() {
    final controller = TextEditingController(text: productName);
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusLg),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Update Auction Title',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Current Title',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AuctionAdminTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AuctionAdminTheme.surfaceSecondary,
                      borderRadius: BorderRadius.circular(
                        AuctionAdminTheme.radiusSm,
                      ),
                      border: Border.all(color: AuctionAdminTheme.border),
                    ),
                    child: Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AuctionAdminTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'New Title *',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AuctionAdminTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AuctionAdminTheme.radiusSm,
                        ),
                        borderSide: const BorderSide(
                          color: AuctionAdminTheme.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AuctionAdminTheme.radiusSm,
                        ),
                        borderSide: const BorderSide(
                          color: AuctionAdminTheme.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AuctionAdminTheme.radiusSm,
                        ),
                        borderSide: const BorderSide(
                          color: AuctionAdminTheme.accent,
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This will update the auction display name',
                    style: TextStyle(
                      fontSize: 12,
                      color: AuctionAdminTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AuctionAdminTheme.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AuctionAdminTheme.radiusSm,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AuctionAdminTheme.info,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoText(
                                'The product slug will remain unchanged',
                              ),
                              _infoText(
                                'Only the display name will be updated',
                              ),
                              _infoText(
                                'This change will be reflected immediately',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final newName = controller.text.trim();
                            if (newName.isEmpty || newName == productName) {
                              Navigator.of(ctx).pop();
                              return;
                            }
                            Navigator.of(ctx).pop();
                            final response =
                                await ProductService.updateProductName(
                                  productId: id,
                                  shopId: shopId,
                                  name: newName,
                                );
                            if (response.success) {
                              _showSuccessMessage(response.message);
                              await _refreshProducts();
                            } else {
                              _showErrorMessage(response);
                            }
                          },
                          icon: const Icon(Icons.save_outlined, size: 16),
                          label: const Text('Update'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AuctionAdminTheme.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AuctionAdminTheme.radiusMd,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\u2022 ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AuctionAdminTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Action Handlers
  Future<void> _handleDuplicate() async {
    final response = await Get.put<AuctionAddProductAdminController>(
      AuctionAddProductAdminController(),
    ).duplicateProduct(widget.product);

    if (response == true) {
      Get.delete<AuctionAddProductAdminController>();
      await _refreshProducts();
    }
  }

  Future<void> _handleActiveChange() async {
    final response = await ProductService.updateActiveStatus(
      shopId: shopId,
      productId: id,
      isActive: !isActive,
    );

    if (response.success) {
      _showSuccessMessage(response.message);
      await _refreshProducts();
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _handleFeaturedChange() async {
    final response = await ProductService.updateFeaturedStatus(
      shopId: shopId,
      productId: id,
      isFeatured: !isFeatured,
    );

    if (response.success) {
      _showSuccessMessage(response.message);
      await _refreshProducts();
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _handleDealChange() async {
    final response = await ProductService.updateDealStatus(
      shopId: shopId,
      productId: id,
      isDeal: !isDeal,
    );

    if (response.success) {
      _showSuccessMessage(response.message);
      await _refreshProducts();
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _handleInventoryChange() async {
    final response = await ProductService.updateInventoryStatus(
      shopId: shopId,
      productId: id,
      hasInventory: hasInventory,
    );

    if (response.success) {
      _showSuccessMessage(response.message);
      await _refreshProducts();
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _handlePinSaleChange() async {
    final response = await ProductService.updatePinSaleStatus(
      shopId: shopId,
      productId: id,
      isPinned: isPinnedSale,
    );

    if (response.success) {
      _showSuccessMessage(response.message);
      await _refreshProducts();
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _handlePrivateChange() async {
    final response = await ProductService.updatePrivateStatus(
      shopId: shopId,
      productId: id,
      isPrivate: isPrivate,
    );

    if (response.success) {
      _showSuccessMessage(response.message);
      await _refreshProducts();
    } else {
      _showErrorMessage(response);
    }
  }

  void _handleEdit() {
    Get.delete<AuctionAddProductAdminController>();
    Get.toNamed(
      Routes.ADD_AUCTION_PRODUCT_ADMIN_VIEW,
      preventDuplicates: false,
      arguments: {'product': widget.product},
    )?.then((val) {
      Get.find<AdminAuctionService>().refreshProducts();
    });
  }

  Future<void> _handleDelete() async {
    final response = await ProductService.deleteProduct(
      shopId: shopId,
      productId: id,
    );

    if (response.success) {
      await _refreshProducts();
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _refreshProducts() async {
    final service = Get.find<AdminAuctionService>();
    await service.fetchProducts(refresh: true);
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AuctionAdminTheme.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: AuctionAdminTheme.radiusMd,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorMessage(ApiResponse response) {
    String errorMessage = response.message;

    final errors = response.errors;
    if (errors != null && errors.isNotEmpty) {
      final List<String> errorList = [];
      errors.forEach((key, value) {
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
      margin: const EdgeInsets.all(16),
      borderRadius: AuctionAdminTheme.radiusMd,
      icon: const Icon(Icons.error_outline, color: Colors.white),
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
