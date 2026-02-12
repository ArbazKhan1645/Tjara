import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals/controller/flash_deal_controller.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals/model/flash_deal_model.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals/views/widgets/flash_deal_product_tile.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals/views/widgets/flash_deal_product_search.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/admin_ui_components.dart';

class FlashDealProductsTabs extends GetView<FlashDealController> {
  const FlashDealProductsTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'Flash Deal Products',
      icon: Icons.inventory_2_outlined,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Tab bar
          _buildTabBar(),
          // Tab content
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AdminTheme.borderColor, width: 1),
        ),
      ),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTab(
                0,
                'Active',
                controller.activeProducts.length,
                Icons.flash_on,
              ),
              _buildTab(
                1,
                'Skipped',
                controller.skippedProducts.length,
                Icons.skip_next,
              ),
              _buildTab(
                2,
                'Expired',
                controller.expiredProducts.length,
                Icons.timer_off,
              ),
              _buildTab(3, 'Sold', controller.soldProducts.length, Icons.sell),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, int count, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedTabIndex.value == index;
      return GestureDetector(
        onTap: () => controller.selectedTabIndex.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? AdminTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    isSelected ? AdminTheme.primaryColor : AdminTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? AdminTheme.primaryColor
                          : AdminTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AdminTheme.primaryColor
                          : AdminTheme.borderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AdminTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabContent() {
    return Obx(() {
      final tabIndex = controller.selectedTabIndex.value;

      // Add product button only for Active tab
      final showAddButton = tabIndex == 0;

      List<FlashDealProduct> products;
      switch (tabIndex) {
        case 0:
          products = controller.activeProducts;
          break;
        case 1:
          products = controller.skippedProducts;
          break;
        case 2:
          products = controller.expiredProducts;
          break;
        case 3:
          products = controller.soldProducts;
          break;
        default:
          products = [];
      }

      return Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add product button for active tab
            if (showAddButton) ...[
              _buildAddProductButton(),
              const SizedBox(height: 16),
            ],

            // Products list
            if (products.isEmpty)
              _buildEmptyState(tabIndex)
            else
              _buildProductsList(tabIndex, products),
          ],
        ),
      );
    });
  }

  Widget _buildAddProductButton() {
    return GestureDetector(
      onTap: () => _showProductSearchDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AdminTheme.primarySurface,
          borderRadius: AdminTheme.borderRadiusSm,
          border: Border.all(
            color: AdminTheme.primaryBorderLight,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AdminTheme.primaryColor,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Add Product to Flash Deals',
              style: TextStyle(
                color: AdminTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSearchDialog() {
    Get.to(() => const FlashDealProductSearch());
  }

  Widget _buildEmptyState(int tabIndex) {
    String title;
    String subtitle;
    IconData icon;

    switch (tabIndex) {
      case 0:
        title = 'No Active Deals';
        subtitle = 'Add products to start flash deals';
        icon = Icons.flash_on_outlined;
        break;
      case 1:
        title = 'No Skipped Deals';
        subtitle = 'Skipped deals will appear here';
        icon = Icons.skip_next_outlined;
        break;
      case 2:
        title = 'No Expired Deals';
        subtitle = 'Expired deals will appear here';
        icon = Icons.timer_off_outlined;
        break;
      case 3:
        title = 'No Sold Deals';
        subtitle = 'Sold deals will appear here';
        icon = Icons.sell_outlined;
        break;
      default:
        title = 'No Products';
        subtitle = 'No products in this category';
        icon = Icons.inventory_2_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AdminTheme.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AdminTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AdminTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: AdminTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(int tabIndex, List<FlashDealProduct> products) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      buildDefaultDragHandles: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      onReorder: (oldIndex, newIndex) {
        controller.reorderProducts(tabIndex, oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 4,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final product = products[index];
        return FlashDealProductTile(
          key: ValueKey(product.id),
          product: product,
          tabIndex: tabIndex,
          index: index,
        );
      },
    );
  }
}
