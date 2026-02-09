import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/widgets/car_actions_buttons.dart';
import 'package:tjara/app/modules/modules_admin/admin/cars/widgets/cars_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/dashbopard_services/admin_cars_service.dart';

class CarOrderItemCard extends StatefulWidget {
  final AdminProducts product;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const CarOrderItemCard({
    super.key,
    required this.product,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  State<CarOrderItemCard> createState() => _CarOrderItemCardState();
}

class _CarOrderItemCardState extends State<CarOrderItemCard> {
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
  bool get isSold => widget.product.meta?.isSold == '1';

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
          color: widget.isSelected
              ? CarsAdminTheme.accent.withValues(alpha: 0.04)
              : _isHovered
                  ? CarsAdminTheme.surface
                  : CarsAdminTheme.surface,
          borderRadius: BorderRadius.circular(CarsAdminTheme.radiusMd),
          border: Border.all(
            color: widget.isSelected
                ? CarsAdminTheme.accent
                : _isHovered
                    ? CarsAdminTheme.accent.withValues(alpha: 0.3)
                    : CarsAdminTheme.border,
            width: widget.isSelected ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: CarsAdminTheme.accent.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : CarsAdminTheme.shadowSm,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CarsAdminTheme.spacingLg,
            vertical: CarsAdminTheme.spacingMd,
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
                    activeColor: CarsAdminTheme.accent,
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
                    _buildSmallEditIcon(onTap: () => _showQuickEditDialog()),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CarsAdminTheme.textPrimary,
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
                        color: CarsAdminTheme.accentLight,
                        borderRadius: BorderRadius.circular(
                          CarsAdminTheme.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        size: 14,
                        color: CarsAdminTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shopName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: CarsAdminTheme.textSecondary,
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
                    color: CarsAdminTheme.primaryLight,
                    borderRadius: BorderRadius.circular(
                      CarsAdminTheme.radiusSm,
                    ),
                  ),
                  child: Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CarsAdminTheme.primary,
                    ),
                  ),
                ),
              ),

              // Sold Badge
              _buildColumn(
                width: 135,
                label: 'Sold',
                child: Row(
                  children: [
                    _buildSmallEditIcon(onTap: _handleSoldChange),
                    const SizedBox(width: 4),
                    Expanded(child: _buildSoldBadge()),
                  ],
                ),
              ),

              // Stock
              _buildColumn(
                width: 80,
                label: 'Stock',
                child: _buildStockBadge(),
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
                      color: CarsAdminTheme.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: CarsAdminTheme.textSecondary,
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
              const SizedBox(width: CarsAdminTheme.spacingMd),
              CarActionButtons(
                productId: id,
                productName: productName,
                productSku: slug,
                isActive: isActive,
                isFeatured: isFeatured,
                isDeal: isDeal,
                hasInventory: hasInventory,
                isPinnedSale: isPinnedSale,
                isPrivate: isPrivate,
                isSold: isSold,
                onDuplicate: _handleDuplicate,
                onActiveChanged: _handleActiveChange,
                onFeaturedChanged: _handleFeaturedChange,
                onDealChanged: _handleDealChange,
                onInventoryChanged: _handleInventoryChange,
                onPinSaleChanged: _handlePinSaleChange,
                onPrivateChanged: _handlePrivateChange,
                onSoldChanged: _handleSoldChange,
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
        horizontal: CarsAdminTheme.spacingSm,
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
              color: CarsAdminTheme.textTertiary,
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
        color: CarsAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
        border: Border.all(color: CarsAdminTheme.border),
      ),
      child: Text(
        '#$productId',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
          color: CarsAdminTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
        border: Border.all(color: CarsAdminTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm - 1),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: CarsAdminTheme.surfaceSecondary,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 24,
          color: CarsAdminTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSoldBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSold ? const Color(0xFFFEF3C7) : CarsAdminTheme.successLight,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSold ? Icons.sell_rounded : Icons.sell_outlined,
            size: 12,
            color: isSold ? const Color(0xFFD97706) : CarsAdminTheme.success,
          ),
          const SizedBox(width: 4),
          Text(
            isSold ? 'Sold' : 'Available',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSold ? const Color(0xFFD97706) : CarsAdminTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge() {
    final bool lowStock = stock < 10;
    final bool outOfStock = stock == 0;

    Color bgColor = CarsAdminTheme.info.withValues(alpha: 0.1);
    Color textColor = CarsAdminTheme.info;

    if (outOfStock) {
      bgColor = CarsAdminTheme.errorLight;
      textColor = CarsAdminTheme.error;
    } else if (lowStock) {
      bgColor = CarsAdminTheme.warning.withValues(alpha: 0.1);
      textColor = CarsAdminTheme.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
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
        color: isActive
            ? CarsAdminTheme.success.withValues(alpha: 0.1)
            : CarsAdminTheme.errorLight,
        borderRadius: BorderRadius.circular(CarsAdminTheme.radiusSm),
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
                  isActive ? CarsAdminTheme.success : CarsAdminTheme.error,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? CarsAdminTheme.success
                  : CarsAdminTheme.error,
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
            color: CarsAdminTheme.textTertiary,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: CarsAdminTheme.textPrimary,
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
          color: CarsAdminTheme.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.edit_outlined,
          size: 13,
          color: CarsAdminTheme.accent,
        ),
      ),
    );
  }

  // Quick edit: name + price + sold toggle for cars
  void _showQuickEditDialog() {
    final nameController = TextEditingController(text: productName);
    final priceController = TextEditingController(text: price.toStringAsFixed(2));
    bool soldValue = isSold;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CarsAdminTheme.radiusLg),
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
                      'Quick Edit Car',
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

                // Name field
                const Text(
                  'Current Title',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CarsAdminTheme.textSecondary,
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
                    color: CarsAdminTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(
                      CarsAdminTheme.radiusSm,
                    ),
                    border: Border.all(color: CarsAdminTheme.border),
                  ),
                  child: Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CarsAdminTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'New Title *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CarsAdminTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        CarsAdminTheme.radiusSm,
                      ),
                      borderSide: const BorderSide(
                        color: CarsAdminTheme.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        CarsAdminTheme.radiusSm,
                      ),
                      borderSide: const BorderSide(
                        color: CarsAdminTheme.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        CarsAdminTheme.radiusSm,
                      ),
                      borderSide: const BorderSide(
                        color: CarsAdminTheme.accent,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Price field
                const Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CarsAdminTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        CarsAdminTheme.radiusSm,
                      ),
                      borderSide: const BorderSide(
                        color: CarsAdminTheme.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        CarsAdminTheme.radiusSm,
                      ),
                      borderSide: const BorderSide(
                        color: CarsAdminTheme.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        CarsAdminTheme.radiusSm,
                      ),
                      borderSide: const BorderSide(
                        color: CarsAdminTheme.accent,
                      ),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Sold toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mark as Sold',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CarsAdminTheme.textSecondary,
                      ),
                    ),
                    Switch(
                      value: soldValue,
                      onChanged: (val) {
                        setDialogState(() {
                          soldValue = val;
                        });
                      },
                      activeColor: CarsAdminTheme.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CarsAdminTheme.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      CarsAdminTheme.radiusSm,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: CarsAdminTheme.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoText('The product slug will remain unchanged'),
                            _infoText('Only the display name will be updated'),
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
                          final newName = nameController.text.trim();
                          final newPrice = double.tryParse(priceController.text.trim());
                          Navigator.of(ctx).pop();

                          // Update name if changed
                          if (newName.isNotEmpty && newName != productName) {
                            final response =
                                await ProductService.updateProductName(
                              productId: id,
                              shopId: shopId,
                              name: newName,
                            );
                            if (response.success) {
                              _showSuccessMessage(response.message);
                            } else {
                              _showErrorMessage(response);
                            }
                          }

                          // Update price if changed
                          if (newPrice != null && newPrice != price) {
                            final response =
                                await ProductService.updateProductPrice(
                              productId: id,
                              shopId: shopId,
                              price: newPrice,
                            );
                            if (response.success) {
                              _showSuccessMessage(response.message);
                            } else {
                              _showErrorMessage(response);
                            }
                          }

                          // Update sold status if changed
                          if (soldValue != isSold) {
                            final response =
                                await ProductService.updateSoldStatus(
                              productId: id,
                              isSold: soldValue,
                            );
                            if (response.success) {
                              _showSuccessMessage(response.message);
                            } else {
                              _showErrorMessage(response);
                            }
                          }

                          await _refreshProducts();
                        },
                        icon: const Icon(Icons.save_outlined, size: 16),
                        label: const Text('Update'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CarsAdminTheme.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              CarsAdminTheme.radiusMd,
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
      ),
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\u2022 ',
            style: TextStyle(fontSize: 12),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: CarsAdminTheme.textSecondary,
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
    Get.snackbar(
      'Info',
      'Duplicate not supported for cars',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CarsAdminTheme.info,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: CarsAdminTheme.radiusMd,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  Future<void> _handleSoldChange() async {
    final response = await ProductService.updateSoldStatus(
      productId: id,
      isSold: !isSold,
    );

    if (response.success) {
      _showSuccessMessage(response.message);
      await _refreshProducts();
    } else {
      _showErrorMessage(response);
    }
  }

  Future<void> _handleActiveChange() async {
    final response = await ProductService.updateActiveStatus(
      shopId: shopId,
      productId: id,
      isActive: isActive,
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
      isFeatured: isFeatured,
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
      isDeal: isDeal,
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
    Get.toNamed(
      Routes.ADD_PRODUCT_ADMIN_VIEW,
      preventDuplicates: false,
      arguments: {'product': widget.product, 'product_group': 'car'},
    )?.then((val) {
      Get.find<AdminCarsService>().fetchProducts(refresh: true);
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
    final service = Get.find<AdminCarsService>();
    await service.fetchProducts(refresh: true);
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: CarsAdminTheme.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: CarsAdminTheme.radiusMd,
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
      backgroundColor: CarsAdminTheme.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      maxWidth: Get.width * 0.9,
      margin: const EdgeInsets.all(16),
      borderRadius: CarsAdminTheme.radiusMd,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
