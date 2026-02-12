import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/admin_ui_components.dart';

class ShippingWidget extends StatelessWidget {
  final AddProductAdminController controller =
      Get.find<AddProductAdminController>();

  ShippingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'Shipping Information',
      icon: Icons.local_shipping_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShippingCompanySection(),
          const SizedBox(height: 24),
          _buildShippingTimeSection(),
          const SizedBox(height: 24),
          _buildShippingFeesSection(),
        ],
      ),
    );
  }

  Widget _buildShippingCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(
          title: 'Shipping Company',
          subtitle: 'Enter the preferred shipping company or method',
        ),
        AdminTextField(
          hint: 'Enter shipping company name',
          prefixIcon: Icons.business_outlined,
          onChanged: controller.updateShippingCompany,
        ),
        const SizedBox(height: 8),
        Obx(
          () => _buildInfoChip(
            'Current: ${controller.selectedShippingCompany.value}',
            Icons.info_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(
          title: 'Shipping Time',
          subtitle: 'Enter the estimated delivery time range',
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'From',
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AdminTextField(
                    hint: '3',
                    keyboardType: TextInputType.number,
                    onChanged: controller.updateShippingTimeFrom,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To',
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AdminTextField(
                    hint: '5',
                    keyboardType: TextInputType.number,
                    onChanged: controller.updateShippingTimeTo,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildTimeUnitDropdown(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => _buildInfoChip(
            controller.shippingTimeDisplay,
            Icons.schedule_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeUnitDropdown() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AdminTheme.bgColor,
          borderRadius: AdminTheme.borderRadiusSm,
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value:
                controller.selectedTimeUnit.value.isEmpty
                    ? null
                    : controller.selectedTimeUnit.value,
            isExpanded: true,
            hint: const Text(
              'Select',
              style: TextStyle(color: AdminTheme.textMuted, fontSize: 14),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AdminTheme.textSecondary,
            ),
            style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
            items:
                controller.timeUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              controller.updateTimeUnit(newValue ?? '');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShippingFeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(
          title: 'Shipping Fees',
          subtitle: 'Enter the shipping cost for this product',
        ),
        AdminTextField(
          hint: '10.00',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.attach_money,
          onChanged: controller.updateShippingFees,
        ),
        const SizedBox(height: 8),
        Obx(
          () => _buildInfoChip(
            controller.shippingFeesDisplay,
            Icons.payments_outlined,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Price will be in decimals e.g. 10.00',
          style: TextStyle(fontSize: 12, color: AdminTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AdminTheme.primarySurface,
        borderRadius: AdminTheme.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AdminTheme.primaryColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AdminTheme.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
