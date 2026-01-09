// shipping_settings_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin/myshop/controller.dart';

class ShippingSettingsTab extends StatelessWidget {
  const ShippingSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final MyShopController controller = Get.find<MyShopController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shipping Company Field
          _buildTextField(
            label: 'Shipping Company',
            controller: controller.shippingCompanyController,
            hint: 'ORIENT Shipping co',
            description:
                'Enter the preferred shipping company or method of your shop.',
          ),
          const SizedBox(height: 20),

          // Shipping Time Section
          const Text(
            'Shipping Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the approx. shipping time of your shop.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.shippingTimeFromController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '3',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE91E63)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.shippingTimeToController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '4',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE91E63)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Days',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final from = controller.shippingTimeFromController.text;
              final to = controller.shippingTimeToController.text;
              if (from.isNotEmpty && to.isNotEmpty) {
                return Text(
                  'Shipping Time: $from - $to Business Days',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                );
              }
              return const SizedBox();
            },
          ),
          const SizedBox(height: 20),

          // Shipping Fees Field
          _buildTextField(
            label: 'Shipping Fees',
            controller: controller.shippingFeesController,
            hint: '\$ 3',
            description: 'Enter the general shipping fees of your shop.',
            keyboardType: TextInputType.number,
            prefix: '\$ ',
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final fees = controller.shippingFeesController.text;
              if (fees.isNotEmpty) {
                return Text(
                  'Shipping Fees: \$ $fees',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                );
              }
              return Text(
                'Price will be in decimals e.g. 10.00',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              );
            },
          ),
          const SizedBox(height: 20),

          // Free Shipping Target
          _buildTextField(
            label: 'Allow free shipping?',
            controller: controller.freeShippingTargetController,
            hint: '\$ 100',
            description:
                'Add maximum cart amount upon which the shipping will be free for customer.',
            keyboardType: TextInputType.number,
            prefix: '\$ ',
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final target = controller.freeShippingTargetController.text;
              if (target.isNotEmpty) {
                return Text(
                  'Price will be in decimals e.g. 10.00',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                );
              }
              return Text(
                'Price will be in decimals e.g. 10.00',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              );
            },
          ),
          const SizedBox(height: 30),

          // Save Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    controller.isUpdating.value ? null : controller.updateShop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    controller.isUpdating.value
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? description,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE91E63)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
