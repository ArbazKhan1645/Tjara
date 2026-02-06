import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/controller/flash_deal_controller.dart';
import 'package:tjara/app/modules/admin_products_module/admin_flash_deals/model/flash_deal_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class FlashDealProductSearch extends StatefulWidget {
  const FlashDealProductSearch({super.key});

  @override
  State<FlashDealProductSearch> createState() => _FlashDealProductSearchState();
}

class _FlashDealProductSearchState extends State<FlashDealProductSearch> {
  final controller = Get.find<FlashDealController>();
  final searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.loadInitialProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildSearchField(),
            Expanded(child: _buildProductsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AdminTheme.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Product to Flash Deals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Search and select products to add',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search products by name...',
          hintStyle: TextStyle(color: AdminTheme.textMuted),
          prefixIcon: const Icon(Icons.search, color: AdminTheme.textSecondary),
          suffixIcon: Obx(() {
            if (controller.isSearchingProducts.value) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AdminTheme.primaryColor,
                  ),
                ),
              );
            }
            if (searchController.text.isNotEmpty) {
              return IconButton(
                onPressed: () {
                  searchController.clear();
                  controller.loadInitialProducts();
                },
                icon: const Icon(Icons.clear, color: AdminTheme.textMuted),
              );
            }
            return const SizedBox.shrink();
          }),
          filled: true,
          fillColor: AdminTheme.bgColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminTheme.primaryColor, width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.length >= 2) {
            controller.searchProducts(value);
          } else if (value.isEmpty) {
            controller.loadInitialProducts();
          }
        },
      ),
    );
  }

  Widget _buildProductsList() {
    return Obx(() {
      // Get all product IDs that are already in any tab
      final Set<String> existingProductIds = {
        ...controller.activeProductIds,
        ...controller.skippedProductIds,
        ...controller.expiredProductIds,
        ...controller.soldProductIds,
      };

      // Filter out products that are already in any tab
      final products = controller.searchedProducts
          .where((p) => !existingProductIds.contains(p.id))
          .toList();

      if (controller.isSearchingProducts.value && products.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AdminTheme.primaryColor),
        );
      }

      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 48,
                color: AdminTheme.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                controller.searchedProducts.isNotEmpty
                    ? 'All matching products are already in flash deals'
                    : 'No products found',
                style: TextStyle(
                  color: AdminTheme.textMuted,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductItem(product);
        },
      );
    });
  }

  Widget _buildProductItem(FlashDealProduct product) {
    return GestureDetector(
      onTap: () {
        controller.addProductToActiveDeals(product);
        Get.back();
        AdminSnackbar.success(
          'Product Added',
          '${product.name} added to flash deals',
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 56,
                height: 56,
                color: AdminTheme.bgColor,
                child: product.image != null && product.image!.isNotEmpty
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.price != null)
                    Row(
                      children: [
                        Text(
                          '\$${product.price}',
                          style: TextStyle(
                            color: product.salePrice != null
                                ? AdminTheme.textMuted
                                : AdminTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            decoration: product.salePrice != null
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
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Add button
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminTheme.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.add,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
}
