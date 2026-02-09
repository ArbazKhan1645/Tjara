import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';

class AuctionActionButtons extends StatelessWidget {
  final String productId;
  final String productName;
  final String productSku;
  final bool isActive;
  final bool isFeatured;
  final bool isDeal;
  final bool hasInventory;
  final bool isPinnedSale;
  final bool isPrivate;
  final VoidCallback? onActiveChanged;
  final VoidCallback? onFeaturedChanged;
  final VoidCallback? onDealChanged;
  final VoidCallback? onInventoryChanged;
  final VoidCallback? onPinSaleChanged;
  final VoidCallback? onPrivateChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const AuctionActionButtons({
    super.key,
    required this.productId,
    required this.productName,
    required this.productSku,
    this.isActive = false,
    this.isFeatured = false,
    this.isDeal = false,
    this.hasInventory = false,
    this.isPinnedSale = false,
    this.isPrivate = false,
    this.onActiveChanged,
    this.onFeaturedChanged,
    this.onDealChanged,
    this.onInventoryChanged,
    this.onPinSaleChanged,
    this.onPrivateChanged,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.qr_code_2_rounded,
          tooltip: 'Show QR Code',
          onTap: () => _showQRCodeDialog(context),
          color: AuctionAdminTheme.textSecondary,
        ),
        _buildActionButton(
          icon: isActive
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
          tooltip: isActive ? 'Product Active' : 'Product Inactive',
          onTap: () => _showActiveDialog(context),
          color: isActive
              ? AuctionAdminTheme.success
              : AuctionAdminTheme.textTertiary,
          backgroundColor: isActive
              ? AuctionAdminTheme.success.withValues(alpha: 0.1)
              : null,
        ),
        _buildActionButton(
          icon: Icons.star_rounded,
          tooltip: isFeatured ? 'Featured Product' : 'Not Featured',
          onTap: () => _showFeaturedDialog(context),
          color: isFeatured
              ? AuctionAdminTheme.primary
              : AuctionAdminTheme.textTertiary,
          backgroundColor: isFeatured
              ? AuctionAdminTheme.primaryLight
              : null,
        ),
        _buildActionButton(
          icon: Icons.local_offer_rounded,
          tooltip: isDeal ? 'Deal Product' : 'Not on Deal',
          onTap: () => _showDealDialog(context),
          color: isDeal
              ? AuctionAdminTheme.error
              : AuctionAdminTheme.textTertiary,
          backgroundColor: isDeal
              ? AuctionAdminTheme.errorLight
              : null,
        ),
        _buildActionButton(
          icon: Icons.inventory_2_rounded,
          tooltip: hasInventory ? 'Inventory Assigned' : 'No Inventory',
          onTap: () => _showInventoryDialog(context),
          color: hasInventory
              ? const Color(0xFF8B5CF6)
              : AuctionAdminTheme.textTertiary,
          backgroundColor: hasInventory ? const Color(0xFFEDE9FE) : null,
        ),
        _buildActionButton(
          icon: Icons.push_pin_rounded,
          tooltip: isPinnedSale ? 'Pinned Sale' : 'Not Pinned',
          onTap: () => _showPinSaleDialog(context),
          color: isPinnedSale
              ? const Color(0xFFEC4899)
              : AuctionAdminTheme.textTertiary,
          backgroundColor: isPinnedSale ? const Color(0xFFFCE7F3) : null,
        ),
        _buildActionButton(
          icon: isPrivate ? Icons.lock_rounded : Icons.lock_open_rounded,
          tooltip: isPrivate ? 'Private Product' : 'Public Product',
          onTap: () => _showPrivateDialog(context),
          color: isPrivate
              ? const Color(0xFF6366F1)
              : AuctionAdminTheme.textTertiary,
          backgroundColor: isPrivate ? const Color(0xFFE0E7FF) : null,
        ),
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
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
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
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: AuctionAdminTheme.textSecondary,
        ),
      ),
      itemBuilder: (BuildContext context) => [
        _buildPopupMenuItem(
          value: 'duplicate',
          icon: Icons.copy_rounded,
          label: 'Duplicate',
          color: AuctionAdminTheme.info,
        ),
        _buildPopupMenuItem(
          value: 'edit',
          icon: Icons.edit_rounded,
          label: 'Edit',
          color: AuctionAdminTheme.accent,
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: AuctionAdminTheme.error,
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
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: value == 'delete' ? color : AuctionAdminTheme.textPrimary,
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
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusLg),
          ),
          child: Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AuctionAdminTheme.accentLight,
                            borderRadius: BorderRadius.circular(
                              AuctionAdminTheme.radiusSm,
                            ),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            size: 20,
                            color: AuctionAdminTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Inventory QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AuctionAdminTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(
                          AuctionAdminTheme.radiusSm,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: AuctionAdminTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AuctionAdminTheme.spacingXl),
                Container(
                  padding: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AuctionAdminTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusMd,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AuctionAdminTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: $productSku',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AuctionAdminTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AuctionAdminTheme.spacingXl),
                Container(
                  padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: AuctionAdminTheme.surface,
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusMd,
                    ),
                    border: Border.all(color: AuctionAdminTheme.border),
                  ),
                  child: QrImageView(
                    data: productId,
                    version: QrVersions.auto,
                    size: 180.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AuctionAdminTheme.textPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AuctionAdminTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AuctionAdminTheme.spacingXl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: AuctionAdminTheme.spacingMd),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _printQRCode,
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text('Print'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AuctionAdminTheme.accent,
                          foregroundColor: Colors.white,
                        ),
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
          ? 'Do you want to make this auction inactive?'
          : 'Do you want to make this auction active?',
      confirmLabel: isActive ? 'Make Inactive' : 'Make Active',
      confirmColor:
          isActive ? AuctionAdminTheme.warning : AuctionAdminTheme.success,
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
          ? 'Do you want to remove this auction from featured?'
          : 'Do you want to make this auction featured?',
      confirmLabel: isFeatured ? 'Remove Featured' : 'Make Featured',
      confirmColor: AuctionAdminTheme.primary,
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
          ? 'Do you want to remove this auction from deals?'
          : 'Do you want to add this auction to deals?',
      confirmLabel: isDeal ? 'Remove from Deal' : 'Add to Deal',
      confirmColor: AuctionAdminTheme.error,
      icon: Icons.local_offer_rounded,
      onConfirm: () {
        Navigator.of(context).pop();
        onDealChanged?.call();
      },
    );
  }

  void _showInventoryDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Inventory Status',
      message: hasInventory
          ? 'Do you want to unassign inventory from this auction?'
          : 'Do you want to mark this auction as inventory assigned?',
      confirmLabel: hasInventory ? 'Unassign Inventory' : 'Assign Inventory',
      confirmColor: const Color(0xFF8B5CF6),
      icon: Icons.inventory_2_rounded,
      onConfirm: () {
        Navigator.of(context).pop();
        onInventoryChanged?.call();
      },
    );
  }

  void _showPinSaleDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Pin Sale',
      message: isPinnedSale
          ? 'Do you want to unpin this auction from sale?'
          : 'Do you want to pin this auction to sale?',
      confirmLabel: isPinnedSale ? 'Unpin Sale' : 'Pin Sale',
      confirmColor: const Color(0xFFEC4899),
      icon: Icons.push_pin_rounded,
      onConfirm: () {
        Navigator.of(context).pop();
        onPinSaleChanged?.call();
      },
    );
  }

  void _showPrivateDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Product Visibility',
      message: isPrivate
          ? 'Do you want to make this auction public?'
          : 'Do you want to make this auction private?',
      confirmLabel: isPrivate ? 'Make Public' : 'Make Private',
      confirmColor: const Color(0xFF6366F1),
      icon: isPrivate ? Icons.lock_open_rounded : Icons.lock_rounded,
      onConfirm: () {
        Navigator.of(context).pop();
        onPrivateChanged?.call();
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
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusLg),
          ),
          child: Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: confirmColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: confirmColor),
                ),
                const SizedBox(height: AuctionAdminTheme.spacingLg),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AuctionAdminTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AuctionAdminTheme.spacingSm),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AuctionAdminTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AuctionAdminTheme.spacingXl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AuctionAdminTheme.spacingMd),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AuctionAdminTheme.spacingLg,
                            vertical: AuctionAdminTheme.spacingMd,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AuctionAdminTheme.radiusMd,
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
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusLg),
        ),
        child: Container(
          padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AuctionAdminTheme.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: AuctionAdminTheme.error,
                ),
              ),
              const SizedBox(height: AuctionAdminTheme.spacingLg),
              const Text(
                'Delete Auction',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AuctionAdminTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AuctionAdminTheme.spacingSm),
              Text(
                'Are you sure you want to delete "$productName"? This action cannot be undone.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AuctionAdminTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AuctionAdminTheme.spacingXl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AuctionAdminTheme.spacingMd),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        onDelete?.call();
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuctionAdminTheme.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AuctionAdminTheme.spacingLg,
                          vertical: AuctionAdminTheme.spacingMd,
                        ),
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

  void _printQRCode() {
    Get.snackbar(
      'Print QR Code',
      'QR Code sent to printer',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AuctionAdminTheme.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: AuctionAdminTheme.radiusMd,
      icon: const Icon(Icons.print_rounded, color: Colors.white),
    );
  }
}
