import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/content_management/content_management_controller.dart';
import 'package:tjara/app/modules/web_settings/content_management/content_management_service.dart';

class ContentManagementScreen extends StatelessWidget {
  ContentManagementScreen({super.key});

  final controller = Get.put(ContentManagementController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebSettingsTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer();
        }

        if (controller.errorMessage.value != null) {
          return _buildErrorState();
        }

        return _buildContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: WebSettingsTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        'Content Management',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Obx(
          () =>
              controller.isSaving.value
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                  : IconButton(
                    icon: const Icon(Icons.save_outlined, color: Colors.white),
                    onPressed: () => controller.saveSettings(),
                    tooltip: 'Save All Settings',
                  ),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value ?? 'An error occurred',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.fetchAllData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebSettingsTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // All Categories Image Section
          _buildAllCategoriesImageSection(),
          const SizedBox(height: 20),

          // Website Features Promos Section
          _buildWebsiteFeaturesPromosSection(),
          const SizedBox(height: 20),

          // All Products Notice Section
          _buildAllProductsNoticeSection(),
          const SizedBox(height: 20),

          // Header Categories Section
          _buildHeaderCategoriesSection(),
          const SizedBox(height: 20),

          // Shop Discounts Section
          _buildShopDiscountsSection(),
          const SizedBox(height: 24),

          // Save Button
          _buildSaveButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ============================================
  // All Categories Image Section
  // ============================================

  Widget _buildAllCategoriesImageSection() {
    return _buildSectionCard(
      title: 'All Categories Image',
      icon: Icons.image_outlined,
      iconColor: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload an image to display in the "All Categories" section',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final imageUrl = controller.allCategoriesImageUrl.value;
            final isUploading = controller.isUploadingImage.value;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  if (imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildImageActionButton(
                          icon: Icons.edit_outlined,
                          label: 'Change',
                          color: WebSettingsTheme.primaryColor,
                          onTap:
                              isUploading
                                  ? null
                                  : () =>
                                      controller.pickAndUploadCategoriesImage(),
                        ),
                        const SizedBox(width: 12),
                        _buildImageActionButton(
                          icon: Icons.delete_outline,
                          label: 'Remove',
                          color: Colors.red,
                          onTap:
                              isUploading
                                  ? null
                                  : () => controller.removeCategoriesImage(),
                        ),
                      ],
                    ),
                  ] else ...[
                    if (isUploading)
                      Column(
                        children: [
                          const CircularProgressIndicator(
                            color: WebSettingsTheme.primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Uploading image...',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: () => controller.pickAndUploadCategoriesImage(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: WebSettingsTheme.primaryColor
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: WebSettingsTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Click to upload image',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: WebSettingsTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recommended: 200x200 pixels',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // Website Features Promos Section
  // ============================================

  Widget _buildWebsiteFeaturesPromosSection() {
    return _buildSectionCard(
      title: 'Website Features Promos',
      icon: Icons.campaign_outlined,
      iconColor: Colors.orange,
      child: Obx(() {
        final direction =
            controller.promoDirection.value == 'rtl'
                ? TextDirection.rtl
                : TextDirection.ltr;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure promotional messages displayed on the website header',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Direction Toggle
            _buildDirectionToggle(
              value: controller.promoDirection,
              label: 'Text Direction',
            ),
            const SizedBox(height: 16),

            // Promo Text Fields
            _buildTextField(
              controller: controller.promo1Controller,
              label: 'Promo 1',
              hint: 'Enter first promotional message',
              icon: Icons.looks_one_outlined,
              textDirection: direction,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controller.promo2Controller,
              label: 'Promo 2',
              hint: 'Enter second promotional message',
              icon: Icons.looks_two_outlined,
              textDirection: direction,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controller.promo3Controller,
              label: 'Promo 3',
              hint: 'Enter third promotional message',
              icon: Icons.looks_3_outlined,
              textDirection: direction,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controller.promo4Controller,
              label: 'Promo 4',
              hint: 'Enter fourth promotional message',
              icon: Icons.looks_4_outlined,
              textDirection: direction,
            ),
          ],
        );
      }),
    );
  }

  // ============================================
  // All Products Notice Section
  // ============================================

  Widget _buildAllProductsNoticeSection() {
    return _buildSectionCard(
      title: 'All Products Notice',
      icon: Icons.notifications_outlined,
      iconColor: Colors.purple,
      child: Obx(() {
        final direction =
            controller.allProductsNoticeDir.value == 'rtl'
                ? TextDirection.rtl
                : TextDirection.ltr;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display a notice message on the products listing page',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Direction Toggle
            _buildDirectionToggle(
              value: controller.allProductsNoticeDir,
              label: 'Text Direction',
            ),
            const SizedBox(height: 16),

            // Notice Text Field
            _buildTextField(
              controller: controller.allProductsNoticeController,
              label: 'Notice Text',
              hint: 'Enter the notice message',
              icon: Icons.info_outline,
              maxLines: 3,
              textDirection: direction,
            ),
          ],
        );
      }),
    );
  }

  // ============================================
  // Header Categories Section
  // ============================================

  Widget _buildHeaderCategoriesSection() {
    return _buildSectionCard(
      title: 'Header Categories',
      icon: Icons.category_outlined,
      iconColor: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select and reorder categories to display in the website header',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Add Category Button
          _buildAddCategorySection(),
          const SizedBox(height: 16),

          // Selected Categories List
          Obx(() {
            if (controller.headerCategoryIds.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No categories selected',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add categories from the dropdown above',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.drag_indicator,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Drag to reorder categories',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: controller.headerCategoryIds.length,
                  onReorder: (oldIndex, newIndex) {
                    controller.reorderCategories(oldIndex, newIndex);
                  },
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final categoryId = controller.headerCategoryIds[index];
                    final categoryName = controller.getCategoryName(categoryId);

                    return Container(
                      key: ValueKey(categoryId),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: ReorderableDragStartListener(
                          index: index,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.drag_handle,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: WebSettingsTheme.primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: WebSettingsTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                categoryName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.red.shade400,
                          ),
                          onPressed:
                              () => controller.removeCategory(categoryId),
                          tooltip: 'Remove category',
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddCategorySection() {
    return Obx(() {
      final filteredCategories = controller.filteredCategories;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: WebSettingsTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: WebSettingsTheme.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextField(
              onChanged:
                  (value) => controller.categorySearchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: WebSettingsTheme.primaryColor,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Categories Chips
            if (filteredCategories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  controller.categorySearchQuery.value.isEmpty
                      ? 'All categories have been added'
                      : 'No categories found',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    filteredCategories.take(15).map((category) {
                      return InkWell(
                        onTap: () => controller.addCategory(category.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                size: 16,
                                color: WebSettingsTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),

            if (filteredCategories.length > 15) ...[
              const SizedBox(height: 8),
              Text(
                '+${filteredCategories.length - 15} more categories',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ============================================
  // Shop Discounts Section
  // ============================================

  Widget _buildShopDiscountsSection() {
    return _buildSectionCard(
      title: 'Shop Discounts',
      icon: Icons.local_offer_outlined,
      iconColor: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure discount badges for specific shops and categories',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Add Discount Button
          InkWell(
            onTap: () => controller.addShopDiscount(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: WebSettingsTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: WebSettingsTheme.primaryColor.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: WebSettingsTheme.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add Shop Discount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WebSettingsTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Discounts List
          Obx(() {
            if (controller.shopDiscounts.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No shop discounts configured',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add discounts to display badges on shop products',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: List.generate(controller.shopDiscounts.length, (index) {
                return _buildShopDiscountCard(index);
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShopDiscountCard(int index) {
    return Obx(() {
      final discount = controller.shopDiscounts[index];

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.store_outlined,
                      size: 18,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Discount #${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => controller.removeShopDiscount(index),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Shop & Category Row
                  Row(
                    children: [
                      Expanded(child: _buildSearchableShopField(index: index)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSearchableCategoryField(
                          label: 'Category (Optional)',
                          value:
                              discount.categoryId.isEmpty
                                  ? null
                                  : discount.categoryId,
                          onChanged: (value) {
                            controller.updateShopDiscount(
                              index,
                              categoryId: value ?? '',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Discount Range
                  _buildDropdownField(
                    label: 'Discount Range',
                    value: discount.discountRange,
                    items:
                        controller.discountRangeOptions
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(r.contains('-') ? '$r%' : r),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateShopDiscount(
                          index,
                          discountRange: value,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Tooltip & Shipping Text
                  _buildTextFieldSimple(
                    value: discount.tooltipText,
                    label: 'Tooltip Text',
                    hint: 'Text shown on hover',
                    onChanged: (value) {
                      controller.updateShopDiscount(index, tooltipText: value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextFieldSimple(
                    value: discount.shippingText,
                    label: 'Shipping Text',
                    hint: 'e.g., Free Shipping',
                    onChanged: (value) {
                      controller.updateShopDiscount(index, shippingText: value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Searchable shop field with real-time API search
  Widget _buildSearchableShopField({required int index}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        // Show selected shop or search field - use Obx for reactivity
        Obx(() {
          final shopId = controller.shopDiscounts[index].shopId;
          if (shopId.isNotEmpty) {
            return _SelectedShopDisplay(
              key: ValueKey('shop_$shopId'),
              shopId: shopId,
              controller: controller,
              onRemove: () => controller.updateShopDiscount(index, shopId: ''),
            );
          } else {
            return _ShopSearchWidget(
              key: ValueKey('search_$index'),
              controller: controller,
              onShopSelected: (selectedShopId) {
                print('object');
                controller.updateShopDiscount(index, shopId: selectedShopId);
              },
            );
          }
        }),
      ],
    );
  }

  /// Searchable category dropdown using bottom sheet
  Widget _buildSearchableCategoryField({
    required String label,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showCategoryPicker(value, onChanged),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null || value.isEmpty
                        ? 'All Categories'
                        : controller.getCategoryName(value),
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          value == null || value.isEmpty
                              ? Colors.grey.shade500
                              : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Show category picker bottom sheet with search
  void _showCategoryPicker(String? currentValue, Function(String?) onChanged) {
    final searchController = TextEditingController();
    final searchQuery = ''.obs;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: (value) => searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // "All Categories" option
            ListTile(
              leading: Icon(
                currentValue == null || currentValue.isEmpty
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color:
                    currentValue == null || currentValue.isEmpty
                        ? WebSettingsTheme.primaryColor
                        : Colors.grey.shade400,
              ),
              title: const Text('All Categories'),
              onTap: () {
                onChanged('');
                Get.back();
              },
            ),
            const Divider(height: 1),
            // Categories list
            Expanded(
              child: Obx(() {
                final query = searchQuery.value.toLowerCase();
                final categories =
                    query.isEmpty
                        ? controller.allCategories
                        : controller.allCategories
                            .where((c) => c.name.toLowerCase().contains(query))
                            .toList();

                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      'No categories found',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: categories.length,
                  itemExtent: 56, // Fixed height for better performance
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == currentValue;

                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color:
                            isSelected
                                ? WebSettingsTheme.primaryColor
                                : Colors.grey.shade400,
                      ),
                      title: Text(
                        category.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        onChanged(category.id);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              items: items,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldSimple({
    required String value,
    required String label,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebSettingsTheme.primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // Common Widgets
  // ============================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildDirectionToggle({
    required RxString value,
    required String label,
  }) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              value.value == 'rtl'
                  ? Icons.format_textdirection_r_to_l
                  : Icons.format_textdirection_l_to_r,
              size: 20,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDirectionOption(
                    label: 'English',
                    isSelected: value.value == 'ltr',
                    onTap: () => value.value = 'ltr',
                    isFirst: true,
                  ),
                  _buildDirectionOption(
                    label: 'Arabic',
                    isSelected: value.value == 'rtl',
                    onTap: () => value.value = 'rtl',
                    isFirst: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isFirst,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? WebSettingsTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(7) : Radius.zero,
            right: !isFirst ? const Radius.circular(7) : Radius.zero,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextDirection? textDirection,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          textDirection: textDirection,
          textAlign:
              textDirection == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebSettingsTheme.primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed:
              controller.isSaving.value
                  ? null
                  : () => controller.saveSettings(),
          style: ElevatedButton.styleFrom(
            backgroundColor: WebSettingsTheme.primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              controller.isSaving.value
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                  : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Save All Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

/// Stateful widget for shop search with debounce
class _ShopSearchWidget extends StatefulWidget {
  final ContentManagementController controller;
  final Function(String shopId) onShopSelected;

  const _ShopSearchWidget({
    super.key,
    required this.controller,
    required this.onShopSelected,
  });

  @override
  State<_ShopSearchWidget> createState() => _ShopSearchWidgetState();
}

class _ShopSearchWidgetState extends State<_ShopSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  // Reactive variable for search text to work properly with Obx
  final _searchText = ''.obs;
  final _showResults = true.obs;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // Only hide results when losing focus AND search text is empty
    // Don't hide immediately to allow tap to register
    if (!_focusNode.hasFocus && _searchText.value.isEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _showResults.value = false;
        }
      });
    } else if (_focusNode.hasFocus) {
      _showResults.value = true;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _searchText.close();
    _showResults.close();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchText.value = query; // Update reactive variable
    _showResults.value = true; // Show results when typing
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().isNotEmpty) {
        widget.controller.searchShops(query);
      } else {
        widget.controller.clearShopSearch();
      }
    });
  }

  void _selectShop(String shopId) {
    // Call the callback first
    widget.onShopSelected(shopId);
    // Then clear everything
    _searchController.clear();
    _searchText.value = '';
    _showResults.value = false;
    widget.controller.clearShopSearch();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search shops...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade400,
              size: 20,
            ),
            suffixIcon: Obx(
              () =>
                  widget.controller.isSearchingShops.value
                      ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebSettingsTheme.primaryColor,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        // Search results dropdown
        Obx(() {
          if (!_showResults.value) return const SizedBox.shrink();

          final results = widget.controller.shopSearchResults;
          final searchText = _searchText.value;

          if (searchText.isEmpty) {
            return const SizedBox.shrink();
          }

          if (widget.controller.isSearchingShops.value && results.isEmpty) {
            return Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Searching...',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            );
          }

          if (results.isEmpty) {
            return Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'No shops found',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final shop = results[index];
                return InkWell(
                  onTap: () => _selectShop(shop.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border:
                          index < results.length - 1
                              ? Border(
                                bottom: BorderSide(color: Colors.grey.shade100),
                              )
                              : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            shop.name,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

/// Stateful widget to display selected shop with proper future caching
class _SelectedShopDisplay extends StatefulWidget {
  final String shopId;
  final ContentManagementController controller;
  final VoidCallback onRemove;

  const _SelectedShopDisplay({
    super.key,
    required this.shopId,
    required this.controller,
    required this.onRemove,
  });

  @override
  State<_SelectedShopDisplay> createState() => _SelectedShopDisplayState();
}

class _SelectedShopDisplayState extends State<_SelectedShopDisplay> {
  late Future<ShopItem?> _shopFuture;

  @override
  void initState() {
    super.initState();
    _shopFuture = widget.controller.getShopDetails(widget.shopId);
  }

  @override
  void didUpdateWidget(covariant _SelectedShopDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only create new future if shopId changed
    if (oldWidget.shopId != widget.shopId) {
      _shopFuture = widget.controller.getShopDetails(widget.shopId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<ShopItem?>(
              future: _shopFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  );
                }

                final shop = snapshot.data;
                return Text(
                  shop?.name ?? 'Unknown Shop',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          InkWell(
            onTap: widget.onRemove,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
