import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';
import 'package:tjara/app/modules/modules_admin/admin/products_attributes_group/model.dart';

class ProductSettingsWidget extends StatelessWidget {
  final AddProductAdminController controller =
      Get.find<AddProductAdminController>();

  ProductSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'Product Settings',
      icon: Icons.settings_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hide product type selector for car products
          Obx(() {
            if (controller.isCarProduct) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _buildProductTypeSelector(),
                const SizedBox(height: 20),
              ],
            );
          }),
          // Show group attributes option when Variants is selected
          Obx(() {
            if (controller.selectedProductType.value == 'Variants') {
              return Column(
                children: [
                  _buildGroupAttributesToggle(),
                  const SizedBox(height: 12),
                  if (controller.useGroupAttributes.value)
                    _buildAttributeGroupSelector(),
                  const SizedBox(height: 20),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          _buildToggleSwitches(),
          const SizedBox(height: 20),
          _buildSKUField(),
        ],
      ),
    );
  }

  Widget _buildProductTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: '${controller.selectedProductgroup.value} Type',
          subtitle: 'Select the product type for your listing',
        ),
        Row(
          children: [
            Expanded(child: _buildTypeChip('Simple')),
            const SizedBox(width: 12),
            Expanded(child: _buildTypeChip('Variants')),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type) {
    return Obx(() {
      final bool isSelected = controller.selectedProductType.value == type;
      return AdminSelectionChip(
        label: type,
        isSelected: isSelected,
        onTap: () => controller.setProductType(type),
      );
    });
  }

  Widget _buildGroupAttributesToggle() {
    return Obx(() => AdminToggleSwitch(
          title: 'Group Attributes',
          subtitle: 'Use a predefined attribute group for variations',
          value: controller.useGroupAttributes.value,
          onChanged: (val) => controller.toggleGroupAttributes(val),
        ));
  }

  Widget _buildAttributeGroupSelector() {
    return Obx(() {
      if (controller.isLoadingGroups.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }

      if (controller.attributeGroups.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Text(
            'No attribute groups available',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Select Attribute Group',
            subtitle: 'All variations from the selected group will be added',
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<AttributeGroupModel>(
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Choose an attribute group',
              ),
              initialValue: controller.selectedAttributeGroup.value,
              items: controller.attributeGroups.map((group) {
                final itemCount = group.attributes.fold<int>(
                  0,
                  (sum, attr) => sum + attr.items.length,
                );
                return DropdownMenuItem<AttributeGroupModel>(
                  value: group,
                  child: Text(
                    '${group.name} ($itemCount items)',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (group) => controller.selectAttributeGroup(group),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildToggleSwitches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(
          title: 'Product Options',
          subtitle: 'Configure additional product settings',
        ),
        Obx(() => AdminToggleSwitch(
              title: 'Featured Product',
              subtitle: 'Highlight this product on the homepage',
              value: controller.isFeatured.value,
              onChanged: (val) => controller.isFeatured.value = val,
            )),
        const SizedBox(height: 12),
        Obx(() => AdminToggleSwitch(
              title: 'Deal of the Day',
              subtitle: 'Show in deals section',
              value: controller.isDeal.value,
              onChanged: (val) => controller.isDeal.value = val,
            )),
        const SizedBox(height: 12),
        Obx(() => AdminToggleSwitch(
              title: 'Purchase Limit',
              subtitle: 'Limit purchase quantity per customer',
              value: controller.enablePurchaseLimit.value,
              onChanged: (val) => controller.enablePurchaseLimit.value = val,
            )),
      ],
    );
  }

  Widget _buildSKUField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(
          title: 'SKU (Stock Keeping Unit)',
          subtitle: 'Unique identifier for inventory management',
        ),
        AdminTextField(
          controller: controller.skuController,
          hint: 'Enter SKU code',
          prefixIcon: Icons.qr_code_outlined,
        ),
      ],
    );
  }
}
