import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/views/add_product_admin_view.dart';

import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/product_details/product_details_editor_widget.dart';

class ProductDetailsCardWidget extends StatelessWidget {
  const ProductDetailsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddProductAdminController>();

    return Obx(() {
      final productGroup = controller.selectedProductgroup.value;
      final productType = controller.selectedProductType.value;

      return ProductFieldsCardCustomWidget(
        column: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      "$productGroup Details",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "$productGroup Description",
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.transparent,
                ),
                child: const Text(
                  "Enter the unique name of your product. Make it descriptive and easy to remember for customers.",
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
              ),
              const SizedBox(height: 15),
              ProductDetailsEditorWidget(
                controller: controller.productdescriptionController,
              ),
              const SizedBox(height: 25),
              if (productType != "Variants") ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          "Price",
                          style: TextStyle(
                            fontSize: 17,
                            color: AppColors.black,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          "*",
                          style: TextStyle(color: AppColors.red, fontSize: 20),
                        ),
                      ],
                    ),
                    Text(
                      "Enter the unique name of your $productGroup. Make it descriptive and easy to remember for customers.",
                      style: const TextStyle(
                        color: AppColors.adminGreyColorText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SimpleTextFormFieldWidget(
                      textController: controller.priceController,
                      hint: '\$0',
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Price will be in decimals e-g: 10.00",
                      style: TextStyle(color: AppColors.adminGreyColorText),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sale Price",
                      style: TextStyle(
                        fontSize: 17,
                        color: AppColors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      "Add sale price of your $productGroup here",
                      style: const TextStyle(
                        color: AppColors.adminGreyColorText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SimpleTextFormFieldWidget(
                      textController: controller.salepriceController,
                      hint: '\$0',
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
