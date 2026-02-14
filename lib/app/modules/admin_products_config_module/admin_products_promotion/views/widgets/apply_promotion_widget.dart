import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_promotion/controller/admin_promotion_controller.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_promotion/model/promotion_model.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_products_promotion/model/store_product_model.dart';

class ApplyPromotionWidget extends StatelessWidget {
  final AdminPromotionController controller;

  const ApplyPromotionWidget({super.key, required this.controller});

  static const Color primaryTeal = Color(0xFF009688);
  static const Color darkTeal = Color(0xFF00796B);
  static const Color lightTeal = Color(0xFFE0F2F1);
  static const Color accentTeal = Color(0xFF4DB6AC);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(1, 'Select Shop'),
          const SizedBox(height: 12),
          _buildSectionCard(child: _buildShopSelector()),
          const SizedBox(height: 24),
          _buildStepIndicator(2, 'Apply To'),
          const SizedBox(height: 12),
          _buildSectionCard(child: _buildApplyToSelector()),
          Obx(() {
            if (controller.applyToOption.value == 'selected_category') {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  _buildStepIndicator(3, 'Select Category'),
                  const SizedBox(height: 12),
                  _buildSectionCard(child: _buildCategorySelector()),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),
          Obx(
            () => _buildStepIndicator(
              controller.applyToOption.value == 'selected_category' ? 4 : 3,
              'Select Promotions',
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(child: _buildPromotionsList()),
          const SizedBox(height: 28),
          _buildApplyButton(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryTeal, accentTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _buildShopSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.shopSearchController,
          onChanged: (value) => controller.searchShops(value),
          decoration: InputDecoration(
            hintText: 'Search shops by name...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Obx(
              () =>
                  controller.isSearchingShops.value
                      ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryTeal,
                          ),
                        ),
                      )
                      : const Icon(Icons.search_rounded, color: primaryTeal),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryTeal, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingShops.value) {
            return _buildShimmerList(4);
          }

          if (controller.shops.isEmpty) {
            return _buildEmptyState(
              icon: Icons.store_outlined,
              message: 'No shops found',
            );
          }

          return Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: controller.shops.length,
                separatorBuilder:
                    (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final shop = controller.shops[index];
                  final isSelected =
                      controller.selectedShop.value?.id == shop.id;
                  return _buildSelectableItem(
                    title: shop.name,
                    isSelected: isSelected,
                    onTap: () => controller.selectShop(shop),
                    icon: Icons.store_rounded,
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildApplyToSelector() {
    return Obx(
      () => Column(
        children: [
          _buildRadioOption(
            title: 'All Products in Shop',
            subtitle: 'Apply to every product in the selected shop',
            icon: Icons.inventory_2_outlined,
            value: 'shop',
            groupValue: controller.applyToOption.value,
            onChanged: (value) => controller.onApplyToOptionChanged(value!),
          ),
          const SizedBox(height: 12),
          _buildRadioOption(
            title: 'Specific Category',
            subtitle: 'Apply to products in a specific category only',
            icon: Icons.category_outlined,
            value: 'selected_category',
            groupValue: controller.applyToOption.value,
            onChanged: (value) => controller.onApplyToOptionChanged(value!),
          ),
          const SizedBox(height: 12),
          _buildSelectedProductsOption(),
          // Product search section when selected_products is active
          if (controller.applyToOption.value == 'selected_products' &&
              controller.selectedShop.value != null) ...[
            const SizedBox(height: 16),
            _buildProductSearchSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedProductsOption() {
    return Obx(() {
      final isSelected = controller.applyToOption.value == 'selected_products';
      final productCount = controller.selectedStoreProductIds.length;
      final hasProducts = productCount > 0;

      return InkWell(
        onTap: () => controller.onApplyToOptionChanged('selected_products'),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? lightTeal : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryTeal : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryTeal : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Selected Products of Store',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? darkTeal : Colors.grey.shade800,
                          ),
                        ),
                        if (isSelected && hasProducts) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$productCount selected',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Search and select products from the store',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? primaryTeal : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primaryTeal : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                        : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProductSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.productSearchController,
            onChanged: (value) => controller.searchStoreProducts(value),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Obx(
                () =>
                    controller.isSearchingProducts.value
                        ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryTeal,
                            ),
                          ),
                        )
                        : const Icon(Icons.search_rounded, color: primaryTeal),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryTeal, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isSearchingProducts.value &&
                controller.searchedProducts.isEmpty) {
              return _buildShimmerList(3);
            }

            if (controller.searchedProducts.isEmpty) {
              if (controller.productSearchController.text.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_rounded,
                  message: 'Search for products to select',
                );
              }
              return _buildEmptyState(
                icon: Icons.inventory_2_outlined,
                message: 'No products found',
              );
            }

            return Container(
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: controller.searchedProducts.length,
                  separatorBuilder:
                      (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final product = controller.searchedProducts[index];
                    return _buildProductItem(product);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem(StoreProduct product) {
    return Obx(() {
      final isSelected = controller.selectedStoreProductIds.contains(
        product.id,
      );
      return Material(
        color: isSelected ? lightTeal : Colors.white,
        child: InkWell(
          onTap: () => controller.toggleProductSelection(product.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Product thumbnail
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      product.thumbnailUrl != null &&
                              product.thumbnailUrl!.isNotEmpty
                          ? Image.network(
                            product.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                          )
                          : Icon(
                            Icons.image_outlined,
                            color: Colors.grey.shade400,
                            size: 24,
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? darkTeal : Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.price != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '\$${product.price}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? primaryTeal : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryTeal : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? primaryTeal : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                          : null,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? lightTeal : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryTeal : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? primaryTeal : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? darkTeal : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? primaryTeal : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryTeal : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.categorySearchController,
          onChanged: (value) => controller.searchCategories(value),
          decoration: InputDecoration(
            hintText: 'Search categories...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Obx(
              () =>
                  controller.isSearchingCategories.value
                      ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryTeal,
                          ),
                        ),
                      )
                      : const Icon(Icons.search_rounded, color: primaryTeal),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryTeal, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingCategories.value) {
            return _buildShimmerList(4);
          }

          if (controller.categories.isEmpty) {
            return _buildEmptyState(
              icon: Icons.category_outlined,
              message: 'No categories found',
            );
          }

          return Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: controller.categories.length,
                separatorBuilder:
                    (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  final isSelected =
                      controller.selectedCategory.value?.id == category.id;
                  return _buildSelectableItem(
                    title: category.name,
                    isSelected: isSelected,
                    onTap: () => controller.selectCategory(category),
                    icon: Icons.folder_outlined,
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectableItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Material(
      color: isSelected ? lightTeal : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? primaryTeal : Colors.grey.shade500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? darkTeal : Colors.grey.shade800,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: primaryTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionsList() {
    return Obx(() {
      var data =
          controller.promotions
              .where((e) => e.isCurrentlyActive == true)
              .toList();
      if (controller.isLoading.value && data.isEmpty) {
        return _buildShimmerList(5);
      }

      if (data.isEmpty) {
        return _buildEmptyState(
          icon: Icons.local_offer_outlined,
          message: 'No promotions available',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                'Select one or more promotions',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(
                  () => Text(
                    '${controller.selectedPromotionIds.length} selected',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: darkTeal,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 350),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final promotion = data[index];
                return _buildPromotionItem(promotion);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPromotionItem(Promotion promotion) {
    return Obx(() {
      final isSelected = controller.selectedPromotionIds.contains(promotion.id);
      final isActive = promotion.status == 'active';

      return GestureDetector(
        onTap: () => controller.togglePromotionSelection(promotion.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? lightTeal : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryTeal : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? primaryTeal : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? primaryTeal : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                        : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? darkTeal : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            controller.formatDiscount(promotion),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryTeal,
                            ),
                          ),
                        ),
                        if (promotion.shop != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              promotion.shop!.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive ? const Color(0xFFE8F5E9) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF4CAF50) : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            isActive
                                ? const Color(0xFF2E7D32)
                                : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildShimmerList(int count) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        children: List.generate(
          count,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Obx(() {
      // Base validation
      bool canApply =
          controller.selectedShop.value != null &&
          controller.selectedPromotionIds.isNotEmpty;

      // Category validation
      if (controller.applyToOption.value == 'selected_category') {
        canApply = canApply && controller.selectedCategory.value != null;
      }

      // Selected products validation
      if (controller.applyToOption.value == 'selected_products') {
        canApply = canApply && controller.selectedStoreProductIds.isNotEmpty;
      }

      return Container(
        decoration: BoxDecoration(
          boxShadow:
              canApply
                  ? [
                    BoxShadow(
                      color: primaryTeal.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : null,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                controller.isApplying.value || !canApply
                    ? null
                    : () => controller.applyPromotions(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child:
                controller.isApplying.value
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: canApply ? Colors.white : Colors.grey.shade500,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Apply Promotions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                canApply ? Colors.white : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      );
    });
  }
}
