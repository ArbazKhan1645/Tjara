import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';
import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';

class CarMetaFieldsWidget extends StatelessWidget {
  final AddProductAdminController controller;

  const CarMetaFieldsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProductFieldsCardCustomWidget(
      column: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Car Meta Fields', Icons.keyboard_arrow_down),
          const SizedBox(height: 20),

          // New/Used Radio Buttons
          _buildConditionRadioSection(),
          const SizedBox(height: 20),

          // Average Mileage
          _buildAverageMileageField(),
          const SizedBox(height: 20),

          // Transmission Dropdown
          _buildTransmissionDropdown(),
          const SizedBox(height: 20),

          // Fuel Type Dropdown
          _buildFuelTypeDropdown(),
          const SizedBox(height: 20),

          // Engine CC Field
          _buildEngineCCField(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF97316),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),

          Icon(icon, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildConditionRadioSection() {
    return GetBuilder<AddProductAdminController>(
      builder: (controller) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Condition',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Radio<String>(
                  value: 'New',
                  groupValue: controller.selectedCondition.value,
                  onChanged: (value) {
                    controller.selectedCondition.value = value ?? 'New';
                    controller.update();
                  },
                  activeColor: Colors.grey,
                ),
                const Text('New'),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'Used',
                  groupValue: controller.selectedCondition.value,
                  onChanged: (value) {
                    controller.selectedCondition.value = value ?? 'Used';
                    controller.update();
                  },
                  activeColor: Colors.grey,
                ),
                const Text('Used'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAverageMileageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AVERAGE MILEAGE (KM/LITER)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SimpleTextFormFieldWidget(
          textController: controller.mileageController,
          hint: '0',
        ),
      ],
    );
  }

  Widget _buildTransmissionDropdown() {
    final List<String> transmissionOptions = ['Automatic', 'Manual'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transmission',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GetBuilder<AddProductAdminController>(
          builder: (controller) {
            return Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:
                      controller.selectedTransmission.value.isEmpty
                          ? null
                          : controller.selectedTransmission.value,
                  hint: const Text(
                    'Select Transmission',
                    style: TextStyle(color: Colors.grey),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  dropdownColor: Colors.white,
                  items:
                      transmissionOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedTransmission.value = newValue ?? '';
                    controller.update();
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFuelTypeDropdown() {
    final List<String> fuelTypeOptions = [
      'Petrol',
      'Diesel',
      'Hybrid',
      'Electric',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fuel Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GetBuilder<AddProductAdminController>(
          builder: (controller) {
            return Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:
                      controller.selectedFuelType.value.isEmpty
                          ? null
                          : controller.selectedFuelType.value,
                  hint: const Text(
                    'Select Fuel Type',
                    style: TextStyle(color: Colors.grey),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  dropdownColor: Colors.white,
                  items:
                      fuelTypeOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedFuelType.value = newValue ?? '';
                    controller.update();
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEngineCCField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Engine (CC)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SimpleTextFormFieldWidget(
          textController: controller.engineCCController,
          hint: '0',
        ),
      ],
    );
  }
}

class ProductFieldsCardCustomWidget extends StatelessWidget {
  final Widget column;
  const ProductFieldsCardCustomWidget({super.key, required this.column});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: column,
            ),
            const SizedBox(height: 15),
          ],
        ),
        const Positioned(
          bottom: 0,
          left: 20,
          right: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: SizedBox(height: 15),
          ),
        ),
      ],
    );
  }
}
