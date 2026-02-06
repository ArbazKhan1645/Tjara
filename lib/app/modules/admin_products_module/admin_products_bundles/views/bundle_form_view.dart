import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_bundles/controller/admin_bundle_controller.dart';
import 'package:tjara/app/modules/admin_products_module/admin_products_templates/model/product_model.dart';

class BundleFormView extends StatelessWidget {
  final AdminBundleController controller;

  const BundleFormView({super.key, required this.controller});

  static const Color primaryTeal = Color(0xFF009688);
  static const Color darkTeal = Color(0xFF00796B);
  static const Color lightTeal = Color(0xFFE0F2F1);
  static const Color accentTeal = Color(0xFF4DB6AC);

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.editingBundle.value != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Bundle' : 'Create New Bundle',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Basic Information',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  _buildTextField(
                    controller: controller.nameController,
                    label: 'Bundle Name',
                    hint: 'e.g., Summer Sale Bundle',
                    icon: Icons.title_rounded,
                    isRequired: true,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: controller.descriptionController,
                    label: 'Description',
                    hint: 'Enter bundle description...',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField(
                    label: 'Status',
                    value: controller.selectedStatus,
                    icon: Icons.toggle_on_outlined,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Bundle Image',
              icon: Icons.image_outlined,
              child: _buildImagePicker(context),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Discount Settings',
              icon: Icons.local_offer_outlined,
              child: Column(
                children: [
                  _buildDropdownField(
                    label: 'Discount Type',
                    value: controller.selectedDiscountType,
                    icon: Icons.discount_outlined,
                    items: const [
                      DropdownMenuItem(value: 'none', child: Text('No Discount')),
                      DropdownMenuItem(value: 'percentage', child: Text('Percentage Off')),
                      DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount Off')),
                    ],
                  ),
                  Obx(() {
                    if (controller.selectedDiscountType.value != 'none') {
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: controller.discountValueController,
                            label: controller.selectedDiscountType.value == 'percentage'
                                ? 'Discount Value (%)'
                                : 'Discount Value (\$)',
                            hint: 'e.g., 10',
                            icon: Icons.percent_rounded,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Select Products',
              icon: Icons.inventory_2_outlined,
              child: _buildProductsSection(context),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, isEditing),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryTeal.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primaryTeal, size: 20),
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(icon, color: primaryTeal, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryTeal, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required Rx<String> value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() => Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: Icon(icon, color: primaryTeal, size: 22),
                  ),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value.value,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        borderRadius: BorderRadius.circular(12),
                        items: items,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            value.value = newValue;
                          }
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade600,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Obx(() {
      final hasImage = controller.selectedImageFile.value != null ||
          controller.thumbnailUrl.value != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: controller.selectedImageFile.value != null
                      ? Image.file(
                          controller.selectedImageFile.value!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          controller.thumbnailUrl.value!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                ),
                if (controller.isUploadingImage.value)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: controller.removeImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          InkWell(
            onTap: () => _pickImage(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryTeal.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    hasImage ? Icons.edit_rounded : Icons.add_photo_alternate_outlined,
                    color: primaryTeal,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasImage ? 'Change Image' : 'Add Bundle Image',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recommended size: 400x400px. Formats: JPG, PNG',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      controller.uploadImage(File(image.path));
    }
  }

  Widget _buildProductsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Select Products',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: lightTeal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.selectedProductIds.length} selected',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: darkTeal,
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 12),
        // Search field
        TextField(
          controller: controller.productSearchController,
          onChanged: (value) => controller.searchProducts(value),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search products by name...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Obx(() => controller.isSearchingProducts.value
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
                : const Icon(Icons.search_rounded, color: primaryTeal)),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        // Search results
        _buildSearchResults(),
        const SizedBox(height: 20),
        // Selected products
        _buildSelectedProducts(),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.isLoadingProducts.value) {
        return _buildShimmerList(3);
      }

      if (controller.searchedProducts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 36,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 200),
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
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final product = controller.searchedProducts[index];
              return Obx(() {
                final isAlreadyAdded = controller.isProductSelected(product.id);
                return _buildProductSearchItem(product, isAlreadyAdded);
              });
            },
          ),
        ),
      );
    });
  }

  Widget _buildProductSearchItem(Product product, bool isAlreadyAdded) {
    return Material(
      color: isAlreadyAdded ? Colors.grey.shade100 : Colors.white,
      child: InkWell(
        onTap: isAlreadyAdded ? null : () => controller.addProduct(product),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isAlreadyAdded ? Colors.grey.shade500 : Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (isAlreadyAdded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_rounded, color: primaryTeal, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Added',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: primaryTeal,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.reorder_rounded, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              'Selected Products (drag to reorder)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.selectedProductIds.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.amber.shade700, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No products selected\nPlease select at least one product.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemCount: controller.selectedProductIds.length,
                onReorder: controller.reorderProducts,
                itemBuilder: (context, index) {
                  final productId = controller.selectedProductIds[index];
                  return _buildSelectedProductItem(productId, index);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectedProductItem(String productId, int index) {
    return Material(
      key: ValueKey(productId),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade100,
              width: index < controller.selectedProductIds.length - 1 ? 1 : 0,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryTeal,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FutureBuilder<Product>(
                  future: controller.fetchProductById(productId),
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
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      );
                    }

                    if (snapshot.hasError) {
                      return Text(
                        'ID: ${productId.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }

                    final product = snapshot.data!;
                    return Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () => controller.removeProduct(productId),
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.red.shade400,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList(int count) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        children: List.generate(
          count,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
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

  Widget _buildBottomBar(BuildContext context, bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            final success = isEditing
                                ? await controller.updateBundle(context)
                                : await controller.createBundle(context);
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      disabledBackgroundColor: primaryTeal.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEditing ? Icons.check_rounded : Icons.add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isEditing
                                    ? 'Update Bundle'
                                    : 'Create Bundle (${controller.selectedProductIds.length})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
