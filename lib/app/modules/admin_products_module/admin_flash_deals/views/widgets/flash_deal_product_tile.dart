import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/controller/flash_deal_controller.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/model/flash_deal_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class FlashDealProductTile extends StatelessWidget {
  final FlashDealProduct product;
  final int tabIndex;
  final int index;

  const FlashDealProductTile({
    super.key,
    required this.product,
    required this.tabIndex,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FlashDealController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AdminTheme.borderRadiusSm,
        border: Border.all(color: AdminTheme.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drag handle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
            child: const Icon(
              Icons.drag_indicator,
              color: AdminTheme.textMuted,
              size: 20,
            ),
          ),

          const SizedBox(width: 2),
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 48,
              height: 48,
              color: AdminTheme.bgColor,
              child:
                  product.image != null && product.image!.isNotEmpty
                      ? Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                      : _buildPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (product.price != null) ...[
                      Text(
                        '\$${product.price}',
                        style: TextStyle(
                          color:
                              product.salePrice != null
                                  ? AdminTheme.textMuted
                                  : AdminTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          decoration:
                              product.salePrice != null
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      if (product.salePrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${product.salePrice}',
                          style: const TextStyle(
                            color: AdminTheme.errorColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                _buildActions(controller),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AdminTheme.bgColor,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AdminTheme.textMuted,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildActions(FlashDealController controller) {
    return Obx(() {
      final isSkipping = controller.isSkipping(product.id);
      final isRestoring = controller.isRestoring(product.id);
      final isRemoving = controller.isRemoving(product.id);

      switch (tabIndex) {
        case 0: // Active - Show Skip button
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skip button
              _buildActionButton(
                icon: Icons.skip_next_outlined,
                label: 'Skip',
                color: AdminTheme.warningColor,
                isLoading: isSkipping,
                onTap: () => controller.skipDeal(product.id),
              ),
              const SizedBox(width: 4),
              // Remove button
              _buildIconButton(
                icon: Icons.close,
                color: AdminTheme.errorColor,
                isLoading: isRemoving,
                onTap: () => controller.removeProduct(product.id, tabIndex),
              ),
            ],
          );

        case 1: // Skipped - Show Restore button
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.restore,
                label: 'Restore',
                color: AdminTheme.successColor,
                isLoading: isRestoring,
                onTap: () => controller.restoreDeal(product.id),
              ),
            ],
          );

        case 2: // Expired - Show Remove button
        case 3: // Sold - Show Remove button
          return _buildIconButton(
            icon: Icons.close,
            color: AdminTheme.errorColor,
            isLoading: isRemoving,
            onTap: () => controller.removeProduct(product.id, tabIndex),
          );

        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
                : Icon(icon, size: 18, color: color),
      ),
    );
  }
}
