import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';

class AuctionShippingWidget extends StatelessWidget {
  final AuctionAddProductAdminController controller = Get.put(
    AuctionAddProductAdminController(),
  );

  AuctionShippingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: controller.toggleExpansion,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Obx(
                    () => Icon(
                      controller.isExpanded.value
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Shipping',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.isExpanded.value ? null : 0,
              child:
                  controller.isExpanded.value
                      ? Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 20),

                            // Shipping Company Section
                            _buildShippingCompanySection(),
                            const SizedBox(height: 20),

                            // Shipping Time Section
                            _buildShippingTimeSection(),
                            const SizedBox(height: 20),

                            // Shipping Fees Section
                            _buildShippingFeesSection(),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Company',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the preferred shipping company or method for delivering this product to customers.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Obx(
          () => TextFormField(
            initialValue: controller.selectedShippingCompany.value,
            decoration: InputDecoration(
              hintText: 'Enter shipping company name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              fillColor: Colors.grey[50],
              filled: true,
            ),
            onChanged: controller.updateShippingCompany,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            'Shipping Company : ${controller.selectedShippingCompany.value}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the approx. shipping time for delivering this product to customers.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Obx(
                () => TextFormField(
                  initialValue: controller.shippingTimeFrom.value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    fillColor: Colors.grey[50],
                    filled: true,
                  ),
                  onChanged: controller.updateShippingTimeFrom,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Obx(
                () => TextFormField(
                  initialValue: controller.shippingTimeTo.value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    fillColor: Colors.grey[50],
                    filled: true,
                  ),
                  onChanged: controller.updateShippingTimeTo,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink[300]!),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[50],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedTimeUnit.value,
                      isExpanded: true,
                      items:
                          controller.timeUnits.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.updateTimeUnit(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            controller.shippingTimeDisplay,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingFeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Fees',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the shipping fees for delivering this product to customers.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Obx(
          () => TextFormField(
            initialValue: controller.shippingFees.value,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              fillColor: Colors.grey[50],
              filled: true,
            ),
            onChanged: controller.updateShippingFees,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            controller.shippingFeesDisplay,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Price will be in decimals e.g. 10.00',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
