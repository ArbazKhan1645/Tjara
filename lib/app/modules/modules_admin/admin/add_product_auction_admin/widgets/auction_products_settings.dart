import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/views/add_product_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';

class AuctionProductSettingsWidget extends StatelessWidget {
  final AuctionAddProductAdminController controller = Get.put(
    AuctionAddProductAdminController(),
  );

  AuctionProductSettingsWidget({super.key});

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
          // _buildProductTypeSelector(),
          const SizedBox(height: 24),
          _buildSwitchTile("Is Featured ?", controller.isFeatured),
          _buildSwitchTile("Is Deal?", controller.isDeal),

          const SizedBox(height: 16),
          _buildSKUField(),
        ],
      ),
    );
  }
}
