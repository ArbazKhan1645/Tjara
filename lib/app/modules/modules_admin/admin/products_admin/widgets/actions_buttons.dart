import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_admin/widgets/admin_products_theme.dart';

class ProductActionButtons extends StatelessWidget {
  final String productId;
  final String productName;
  final String productSku;
  final bool isActive;
  final bool isFeatured;
  final bool isDeal;
  final VoidCallback? onActiveChanged;
  final VoidCallback? onFeaturedChanged;
  final VoidCallback? onDealChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const ProductActionButtons({
    super.key,
    required this.productId,
    required this.productName,
    required this.productSku,
    this.isActive = false,
    this.isFeatured = false,
    this.isDeal = false,
    this.onActiveChanged,
    this.onFeaturedChanged,
    this.onDealChanged,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Code Button
        _buildActionButton(
          icon: Icons.qr_code_2_rounded,
          tooltip: 'Show QR Code',
          onTap: () => _showQRCodeDialog(context),
          color: AdminProductsTheme.textSecondary,
        ),

        // Active Status Button
        _buildActionButton(
          icon: isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          tooltip: isActive ? 'Product Active' : 'Product Inactive',
          onTap: () => _showActiveDialog(context),
          color: isActive ? AdminProductsTheme.success : AdminProductsTheme.textTertiary,
          backgroundColor: isActive ? AdminProductsTheme.successLight : null,
        ),

        // Featured Button
        _buildActionButton(
          icon: Icons.star_rounded,
          tooltip: isFeatured ? 'Featured Product' : 'Not Featured',
          onTap: () => _showFeaturedDialog(context),
          color: isFeatured ? AdminProductsTheme.featured : AdminProductsTheme.textTertiary,
          backgroundColor: isFeatured ? AdminProductsTheme.featuredLight : null,
        ),

        // Deal Button
        _buildActionButton(
          icon: Icons.local_offer_rounded,
          tooltip: isDeal ? 'Deal Product' : 'Not on Deal',
          onTap: () => _showDealDialog(context),
          color: isDeal ? AdminProductsTheme.deal : AdminProductsTheme.textTertiary,
          backgroundColor: isDeal ? AdminProductsTheme.dealLight : null,
        ),

        // More Options Button
        _buildPopupMenu(),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
    Color? backgroundColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminProductsTheme.radiusMd),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: AdminProductsTheme.textSecondary,
        ),
      ),
      itemBuilder: (BuildContext context) => [
        _buildPopupMenuItem(
          value: 'duplicate',
          icon: Icons.copy_rounded,
          label: 'Duplicate',
          color: AdminProductsTheme.info,
        ),
        _buildPopupMenuItem(
          value: 'edit',
          icon: Icons.edit_rounded,
          label: 'Edit',
          color: AdminProductsTheme.primary,
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: AdminProductsTheme.error,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AdminProductsTheme.radiusSm),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: value == 'delete' ? color : AdminProductsTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
          ),
          child: Container(
            padding: const EdgeInsets.all(AdminProductsTheme.spacingXl),
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AdminProductsTheme.primaryLight,
                            borderRadius: BorderRadius.circular(
                              AdminProductsTheme.radiusSm,
                            ),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            size: 20,
                            color: AdminProductsTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Inventory QR Code',
                          style: AdminProductsTheme.headingMedium,
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(
                          AdminProductsTheme.radiusSm,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: AdminProductsTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AdminProductsTheme.spacingXl),

                // Product info
                Container(
                  padding: const EdgeInsets.all(AdminProductsTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusMd,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        productName,
                        style: AdminProductsTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: $productSku',
                        style: AdminProductsTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AdminProductsTheme.spacingXl),

                // QR Code
                Container(
                  padding: const EdgeInsets.all(AdminProductsTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: AdminProductsTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AdminProductsTheme.radiusMd,
                    ),
                    border: Border.all(color: AdminProductsTheme.border),
                  ),
                  child: QrImageView(
                    data: productId,
                    version: QrVersions.auto,
                    size: 180.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AdminProductsTheme.textPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AdminProductsTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AdminProductsTheme.spacingXl),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: AdminProductsTheme.outlineButtonStyle,
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: AdminProductsTheme.spacingMd),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _printQRCode,
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text('Print'),
                        style: AdminProductsTheme.primaryButtonStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showActiveDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Product Status',
      message: isActive
          ? 'Do you want to make this product inactive?'
          : 'Do you want to make this product active?',
      confirmLabel: isActive ? 'Make Inactive' : 'Make Active',
      confirmColor: isActive ? AdminProductsTheme.warning : AdminProductsTheme.success,
      icon: isActive ? Icons.visibility_off_rounded : Icons.visibility_rounded,
      onConfirm: () {
        Navigator.of(context).pop();
        onActiveChanged?.call();
      },
    );
  }

  void _showFeaturedDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Featured Product',
      message: isFeatured
          ? 'Do you want to remove this product from featured?'
          : 'Do you want to make this product featured?',
      confirmLabel: isFeatured ? 'Remove Featured' : 'Make Featured',
      confirmColor: AdminProductsTheme.featured,
      icon: Icons.star_rounded,
      onConfirm: () {
        Navigator.of(context).pop();
        onFeaturedChanged?.call();
      },
    );
  }

  void _showDealDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Deal Product',
      message: isDeal
          ? 'Do you want to remove this product from deals?'
          : 'Do you want to add this product to deals?',
      confirmLabel: isDeal ? 'Remove from Deal' : 'Add to Deal',
      confirmColor: AdminProductsTheme.deal,
      icon: Icons.local_offer_rounded,
      onConfirm: () {
        Navigator.of(context).pop();
        onDealChanged?.call();
      },
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required IconData icon,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
          ),
          child: Container(
            padding: const EdgeInsets.all(AdminProductsTheme.spacingXl),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: confirmColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: confirmColor),
                ),
                const SizedBox(height: AdminProductsTheme.spacingLg),

                // Title
                Text(
                  title,
                  style: AdminProductsTheme.headingMedium,
                ),
                const SizedBox(height: AdminProductsTheme.spacingSm),

                // Message
                Text(
                  message,
                  style: AdminProductsTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AdminProductsTheme.spacingXl),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: AdminProductsTheme.outlineButtonStyle,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AdminProductsTheme.spacingMd),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AdminProductsTheme.spacingLg,
                            vertical: AdminProductsTheme.spacingMd,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AdminProductsTheme.radiusMd,
                            ),
                          ),
                        ),
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'duplicate':
        onDuplicate?.call();
        break;
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminProductsTheme.radiusLg),
        ),
        child: Container(
          padding: const EdgeInsets.all(AdminProductsTheme.spacingXl),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminProductsTheme.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: AdminProductsTheme.error,
                ),
              ),
              const SizedBox(height: AdminProductsTheme.spacingLg),

              // Title
              const Text(
                'Delete Product',
                style: AdminProductsTheme.headingMedium,
              ),
              const SizedBox(height: AdminProductsTheme.spacingSm),

              // Message
              Text(
                'Are you sure you want to delete "$productName"? This action cannot be undone.',
                style: AdminProductsTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AdminProductsTheme.spacingXl),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: AdminProductsTheme.outlineButtonStyle,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AdminProductsTheme.spacingMd),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        onDelete?.call();
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminProductsTheme.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AdminProductsTheme.spacingLg,
                          vertical: AdminProductsTheme.spacingMd,
                        ),
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

  void _printQRCode() {
    Get.snackbar(
      'Print QR Code',
      'QR Code sent to printer',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AdminProductsTheme.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: AdminProductsTheme.radiusMd,
      icon: const Icon(Icons.print_rounded, color: Colors.white),
    );
  }
}
