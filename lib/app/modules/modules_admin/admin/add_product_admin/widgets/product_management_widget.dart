import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';

class ProductManagementWidget extends StatelessWidget {
  const ProductManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddProductAdminController>();

    return AdminCard(
      title: '${controller.selectedProductgroup.value} Management',
      icon: Icons.inventory_2_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusSection(controller),
          const SizedBox(height: 24),
          _buildStockSection(controller),
        ],
      ),
    );
  }

  Widget _buildStatusSection(AddProductAdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: '${controller.selectedProductgroup.value} Status',
          subtitle: 'Choose the status that best reflects the availability',
        ),
        Obx(() => AdminToggleSwitch(
          title: controller.selectedStatus.value ? 'Active' : 'Inactive',
          subtitle: controller.selectedStatus.value
              ? 'Product is visible to customers'
              : 'Product is hidden from customers',
          value: controller.selectedStatus.value,
          onChanged: (value) => controller.selectedStatus.value = value,
        )),
      ],
    );
  }

  Widget _buildStockSection(AddProductAdminController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: '${controller.selectedProductgroup.value} Stock',
          subtitle: 'Enter the total quantity currently in stock',
        ),
        AdminTextField(
          controller: controller.inputProductStock,
          hint: 'Enter stock quantity',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.inventory_outlined,
        ),
      ],
    );
  }
}
