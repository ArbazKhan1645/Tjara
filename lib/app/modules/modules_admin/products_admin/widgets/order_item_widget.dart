import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/widgets/actions_buttons.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/widgets/admin_products_theme.dart';
import 'package:tjara/app/modules/modules_admin/products_admin/widgets/service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';

class ProductItemCard extends StatefulWidget {
  final AdminProducts product;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const ProductItemCard({
    super.key,
    required this.product,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  State<ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<ProductItemCard> {
  bool _isHovered = false;

  // Safe getters with default values - no null operators needed
  String get productId => widget.product.meta?.productId ?? '';
  String get productName => widget.product.name ?? 'Unnamed Product';
  String get shopName => widget.product.shop?.shop?.name ?? 'Unknown Shop';
  String get shopId => widget.product.shop?.shop?.id ?? '';
  double get price => widget.product.price ?? 0.0;
  double get salePrice => widget.product.salePrice ?? 0.0;
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
  String? get productType => widget.product.productType;

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
        decoration:
            widget.isSelected
                ? AdminProductsTheme.cardDecoration.copyWith(
                  border: Border.all(
                    color: AdminProductsTheme.primary,
                    width: 1.5,
                  ),
                  color: AdminProductsTheme.primary.withValues(alpha: 0.04),
                )
                : _isHovered
                ? AdminProductsTheme.cardHoverDecoration
                : AdminProductsTheme.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminProductsTheme.spacingLg,
            vertical: AdminProductsTheme.spacingMd,
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
                    activeColor: AdminProductsTheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),

              // Product ID Column
              _buildColumn(
                width: 100,
                label: 'Product ID',
                child: _buildProductIdBadge(),
              ),

              // Image Column
              _buildColumn(
                width: 80,
                label: 'Image',
                child: _buildProductImage(),
              ),

              // Product Name Column
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
                        style: AdminProductsTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Shop Name Column
              _buildColumn(
                width: 150,
                label: 'Shop',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AdminProductsTheme.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AdminProductsTheme.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 14,
                        color: AdminProductsTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shopName,
                        style: AdminProductsTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Price Column
              _buildColumn(
                width: 120,
                label: 'Price',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AdminProductsTheme.successLight,
                        borderRadius: BorderRadius.circular(
                          AdminProductsTheme.radiusSm,
                        ),
                      ),
                      child: Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: AdminProductsTheme.bodyMedium.copyWith(
                          color: AdminProductsTheme.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildSmallEditIcon(onTap: () => _showUpdatePriceDialog()),
                  ],
                ),
              ),

              // Stock Column
              _buildColumn(
                width: 100,
                label: 'Stock',
                child: Row(
                  children: [
                    _buildStockBadge(),
                    const SizedBox(width: 4),
                    _buildSmallEditIcon(onTap: () => _showUpdateStockDialog()),
                  ],
                ),
              ),

              // Published Date Column
              _buildColumn(
                width: 120,
                label: 'Published',
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AdminProductsTheme.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(createdAt),
                      style: AdminProductsTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Status Column
              _buildColumn(
                width: 100,
                label: 'Status',
                child: _buildStatusBadge(),
              ),

              // Analytics Column
              _buildColumn(
                width: 200,
                label: 'Analytics',
                child: _buildAnalyticsSection(),
              ),

              // Actions Column
              const SizedBox(width: AdminProductsTheme.spacingMd),
              ProductActionButtons(
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
        horizontal: AdminProductsTheme.spacingSm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AdminProductsTheme.labelMedium.copyWith(
              fontSize: 10,
              letterSpacing: 0.5,
              color: AdminProductsTheme.textTertiary,
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
        color: AdminProductsTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
        border: Border.all(color: AdminProductsTheme.border),
      ),
      child: Text(
        '#$productId',
        style: AdminProductsTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
        border: Border.all(color: AdminProductsTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm - 1),
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
      color: AdminProductsTheme.surfaceSecondary,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 24,
          color: AdminProductsTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    final bool lowStock = stock < 10;
    final bool outOfStock = stock == 0;

    Color bgColor = AdminProductsTheme.infoLight;
    Color textColor = AdminProductsTheme.info;

    if (outOfStock) {
      bgColor = AdminProductsTheme.errorLight;
      textColor = AdminProductsTheme.error;
    } else if (lowStock) {
      bgColor = AdminProductsTheme.warningLight;
      textColor = AdminProductsTheme.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (outOfStock)
            Icon(Icons.warning_amber_rounded, size: 12, color: textColor),
          if (outOfStock) const SizedBox(width: 4),
          Text(
            stock.toString(),
            style: AdminProductsTheme.bodyMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
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
                ? AdminProductsTheme.successLight
                : AdminProductsTheme.errorLight,
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
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
                      ? AdminProductsTheme.success
                      : AdminProductsTheme.error,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: AdminProductsTheme.bodySmall.copyWith(
              color:
                  isActive
                      ? AdminProductsTheme.success
                      : AdminProductsTheme.error,
              fontWeight: FontWeight.w600,
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
          style: AdminProductsTheme.bodySmall.copyWith(
            color: AdminProductsTheme.textTertiary,
            fontSize: 10,
          ),
        ),
        Text(
          value.toString(),
          style: AdminProductsTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 10,
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
          color: AdminProductsTheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.edit_outlined,
          size: 13,
          color: AdminProductsTheme.primary,
        ),
      ),
    );
  }

  void _showUpdateNameDialog() {
    final controller = TextEditingController(text: productName);
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
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
                        'Update Product Title',
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
                  Text(
                    'Current Title',
                    style: AdminProductsTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
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
                      color: AdminProductsTheme.surfaceSecondary,
                      borderRadius: BorderRadius.circular(
                        AdminProductsTheme.radiusSm,
                      ),
                      border: Border.all(color: AdminProductsTheme.border),
                    ),
                    child: Text(
                      productName,
                      style: AdminProductsTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'New Title *',
                    style: AdminProductsTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
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
                          AdminProductsTheme.radiusSm,
                        ),
                        borderSide: const BorderSide(
                          color: AdminProductsTheme.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AdminProductsTheme.radiusSm,
                        ),
                        borderSide: const BorderSide(
                          color: AdminProductsTheme.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AdminProductsTheme.radiusSm,
                        ),
                        borderSide: const BorderSide(
                          color: AdminProductsTheme.primary,
                        ),
                      ),
                    ),
                    style: AdminProductsTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This will update the product display name',
                    style: AdminProductsTheme.bodySmall.copyWith(
                      color: AdminProductsTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminProductsTheme.infoLight,
                      borderRadius: BorderRadius.circular(
                        AdminProductsTheme.radiusSm,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AdminProductsTheme.info,
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
                          style: AdminProductsTheme.outlineButtonStyle,
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
                                  productType: productType,
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
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AdminProductsTheme.radiusMd,
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

  void _showUpdatePriceDialog() {
    final regularController = TextEditingController(
      text: price > 0 ? price.toStringAsFixed(0) : '',
    );
    final saleController = TextEditingController(
      text: salePrice > 0 ? salePrice.toStringAsFixed(0) : '',
    );
    final selectedTab = ValueNotifier<int>(0);

    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 420),
              child: ValueListenableBuilder<int>(
                valueListenable: selectedTab,
                builder: (context, tabIndex, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Update Price for: $productName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildTabButton(
                            label: 'Regular Price',
                            isSelected: tabIndex == 0,
                            onTap: () => selectedTab.value = 0,
                          ),
                          const SizedBox(width: 8),
                          _buildTabButton(
                            label: 'Sale Price',
                            isSelected: tabIndex == 1,
                            onTap: () => selectedTab.value = 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller:
                            tabIndex == 0 ? regularController : saleController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminProductsTheme.radiusSm,
                            ),
                            borderSide: const BorderSide(
                              color: AdminProductsTheme.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminProductsTheme.radiusSm,
                            ),
                            borderSide: const BorderSide(
                              color: AdminProductsTheme.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminProductsTheme.radiusSm,
                            ),
                            borderSide: const BorderSide(
                              color: AdminProductsTheme.primary,
                            ),
                          ),
                        ),
                        style: AdminProductsTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tabIndex == 0
                            ? 'This will update the regular price of the product'
                            : 'This will update the sale price of the product',
                        style: AdminProductsTheme.bodySmall.copyWith(
                          color: AdminProductsTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: AdminProductsTheme.outlineButtonStyle,
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final text =
                                    tabIndex == 0
                                        ? regularController.text.trim()
                                        : saleController.text.trim();
                                final newPrice = double.tryParse(text);
                                if (newPrice == null) return;
                                Navigator.of(ctx).pop();
                                final response =
                                    await ProductService.updateProductPrice(
                                      productId: id,
                                      shopId: shopId,
                                      price: newPrice,
                                      isSalePrice: tabIndex == 1,
                                      productType: productType,
                                    );
                                if (response.success) {
                                  _showSuccessMessage(response.message);
                                  await _refreshProducts();
                                } else {
                                  _showErrorMessage(response);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AdminProductsTheme.radiusMd,
                                  ),
                                ),
                              ),
                              child: const Text('Update'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
    );
  }

  void _showUpdateStockDialog() {
    final controller = TextEditingController(text: stock.toString());
    final selectedMode = ValueNotifier<int>(0); // 0=Set, 1=Add, 2=Subtract

    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 420),
              child: ValueListenableBuilder<int>(
                valueListenable: selectedMode,
                builder: (context, modeIndex, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Update Stock for: $productName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildTabButton(
                            label: 'Set',
                            isSelected: modeIndex == 0,
                            onTap: () {
                              selectedMode.value = 0;
                              controller.text = stock.toString();
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildTabButton(
                            label: 'Add',
                            isSelected: modeIndex == 1,
                            onTap: () {
                              selectedMode.value = 1;
                              controller.clear();
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildTabButton(
                            label: 'Subtract',
                            isSelected: modeIndex == 2,
                            onTap: () {
                              selectedMode.value = 2;
                              controller.clear();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminProductsTheme.radiusSm,
                            ),
                            borderSide: const BorderSide(
                              color: AdminProductsTheme.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminProductsTheme.radiusSm,
                            ),
                            borderSide: const BorderSide(
                              color: AdminProductsTheme.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AdminProductsTheme.radiusSm,
                            ),
                            borderSide: const BorderSide(
                              color: AdminProductsTheme.primary,
                            ),
                          ),
                        ),
                        style: AdminProductsTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        modeIndex == 0
                            ? 'This will replace the current stock value'
                            : modeIndex == 1
                            ? 'This will add to the current stock'
                            : 'This will subtract from the current stock',
                        style: AdminProductsTheme.bodySmall.copyWith(
                          color: AdminProductsTheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: AdminProductsTheme.outlineButtonStyle,
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final value = int.tryParse(
                                  controller.text.trim(),
                                );
                                if (value == null) return;
                                int finalStock;
                                if (modeIndex == 0) {
                                  finalStock = value;
                                } else if (modeIndex == 1) {
                                  finalStock = stock + value;
                                } else {
                                  finalStock = (stock - value).clamp(0, 999999);
                                }
                                Navigator.of(ctx).pop();
                                final response =
                                    await ProductService.updateProductStock(
                                      productId: id,
                                      shopId: shopId,
                                      stock: finalStock,
                                      productType: productType,
                                    );
                                if (response.success) {
                                  _showSuccessMessage(response.message);
                                  await _refreshProducts();
                                } else {
                                  _showErrorMessage(response);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminProductsTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AdminProductsTheme.radiusMd,
                                  ),
                                ),
                              ),
                              child: const Text('Update Stock'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AdminProductsTheme.primary
                    : AdminProductsTheme.surface,
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            border: Border.all(
              color:
                  isSelected
                      ? AdminProductsTheme.primary
                      : AdminProductsTheme.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AdminProductsTheme.textPrimary,
            ),
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
          const Text('• ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: AdminProductsTheme.bodySmall.copyWith(
                color: AdminProductsTheme.textSecondary,
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
    final response = await Get.put<AddProductAdminController>(
      AddProductAdminController(),
    ).duplicateProduct(widget.product);

    if (response == true) {
      Get.delete<AddProductAdminController>();
      await _refreshProducts();
    }
  }

  Future<void> _handleActiveChange() async {
    final response = await ProductService.updateActiveStatus(
      shopId: shopId,
      productId: id,
      isActive: !isActive,
      productType: productType,
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
      productType: productType,
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
      productType: productType,
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
      productType: productType,
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
      productType: productType,
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
      productType: productType,
    );

    if (response.success) {
      _showSuccessMessage(response.message);
      await _refreshProducts();
    } else {
      _showErrorMessage(response);
    }
  }

  void _handleEdit() {
    Get.delete<AddProductAdminController>();
    Get.toNamed(
      Routes.ADD_PRODUCT_ADMIN_VIEW,
      preventDuplicates: false,
      arguments: {'product': widget.product},
    );
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
    final service = Get.find<AdminProductsService>();
    await service.fetchProducts(refresh: true);
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AdminProductsTheme.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: AdminProductsTheme.radiusMd,
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
      backgroundColor: AdminProductsTheme.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      maxWidth: Get.width * 0.9,
      margin: const EdgeInsets.all(16),
      borderRadius: AdminProductsTheme.radiusMd,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
