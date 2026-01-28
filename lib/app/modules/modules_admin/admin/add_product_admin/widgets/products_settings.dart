import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/views/add_product_admin_view.dart';

class ProductSettingsWidget extends StatelessWidget {
  final AddProductAdminController controller = Get.put(
    AddProductAdminController(),
  );

  ProductSettingsWidget({super.key});

  Widget _buildProductTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${controller.selectedProductgroup.value} Type:",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text("Select the ${controller.selectedProductgroup.value} type."),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildTypeButton("Simple"),
            const SizedBox(width: 10),
            _buildTypeButton("Variants"),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(String type) {
    return Obx(() {
      final bool isSelected = controller.selectedProductType.value == type;
      return GestureDetector(
        onTap: () => controller.setProductType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
            border: Border.all(color: const Color(0xFFF97316)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSwitchTile(String title, RxBool value) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Switch(
            value: value.value,
            onChanged: (val) => value.value = val,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFF97316),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSKUField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SKU:", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller.skuController,
          decoration: InputDecoration(
            hintText: "Add SKU",
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProductFieldsCardCustomWidget(
      column: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductTypeSelector(),
          const SizedBox(height: 24),
          _buildSwitchTile("Is Featured ?", controller.isFeatured),
          _buildSwitchTile("Is Deal?", controller.isDeal),
          _buildSwitchTile(
            "Enable purchase limit per customer ?",
            controller.enablePurchaseLimit,
          ),
          const SizedBox(height: 16),
          _buildSKUField(),
        ],
      ),
    );
  }
}
