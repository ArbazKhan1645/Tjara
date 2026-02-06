import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/actions_buttons.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/admin_products_theme.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';

class ProductItemCard extends StatefulWidget {
  final AdminProducts product;

  const ProductItemCard({super.key, required this.product});

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
  int get stock => widget.product.stock ?? 0;
  String get status => widget.product.status ?? 'inactive';
  String get slug => widget.product.slug ?? '';
  String get id => widget.product.id ?? '';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isFeatured => widget.product.isFeatured == 1;
  bool get isDeal => widget.product.isDeal == 1;

  String get imageUrl {
    final media = widget.product.thumbnail?.media;
    if (media == null) return '';
    return media.url ?? '';
  }

  DateTime get createdAt => widget.product.createdAt ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration:
            _isHovered
                ? AdminProductsTheme.cardHoverDecoration
                : AdminProductsTheme.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminProductsTheme.spacingLg,
            vertical: AdminProductsTheme.spacingMd,
          ),
          child: Row(
            children: [
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
                child: Text(
                  productName,
                  style: AdminProductsTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                width: 100,
                label: 'Price',
                child: Container(
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
              ),

              // Stock Column
              _buildColumn(
                width: 80,
                label: 'Stock',
                child: _buildStockBadge(),
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

              // Actions Column
              const SizedBox(width: AdminProductsTheme.spacingMd),
              ProductActionButtons(
                productId: id,
                productName: productName,
                productSku: slug,
                isActive: isActive,
                isFeatured: isFeatured,
                isDeal: isDeal,
                onDuplicate: _handleDuplicate,
                onActiveChanged: _handleActiveChange,
                onFeaturedChanged: _handleFeaturedChange,
                onDealChanged: _handleDealChange,
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
    await service.refreshProducts();
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
