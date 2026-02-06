import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class ProductSettingsWidget extends StatelessWidget {
  final AddProductAdminController controller = Get.find<AddProductAdminController>();

  ProductSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'Product Settings',
      icon: Icons.settings_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductTypeSelector(),
          const SizedBox(height: 20),
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
