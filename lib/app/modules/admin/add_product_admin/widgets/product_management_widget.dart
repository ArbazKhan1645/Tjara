import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';
import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/admin/add_product_admin/views/add_product_admin_view.dart';

class ProductManagementWidget extends StatelessWidget {
  const ProductManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddProductAdminController>();
    return ProductFieldsCardCustomWidget(
      column: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Container(
              height: 45.88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF97316),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${controller.selectedProductgroup.value} Managment",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${controller.selectedProductgroup.value} Status",
                  style: const TextStyle(
                    color: AppColors.darkLightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Choose the status that best reflects the availability of this product for customers.",
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
                const SizedBox(height: 20),
                ToggleSwitchButtonWidget(
                  value: controller.selectedStatus.value,
                  onChanged: (value) => controller.selectedStatus.value = value,
                ),
                // SimpleTextFormFieldWidget(textController: controller.productNameController, hint: 'Product name')
              ],
            ),
            const SizedBox(height: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${controller.selectedProductgroup.value} Stock",
                  style: const TextStyle(
                    color: AppColors.darkLightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Enter the total quantity of this product currently in stock",
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
                const SizedBox(height: 10),
                SimpleTextFormFieldWidget(
                  textController: controller.inputProductStock,
                  hint: 'Input Product Stock',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
