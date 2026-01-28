import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';

import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/views/add_product_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';

class AuctionProductManagementWidget extends StatelessWidget {
  const AuctionProductManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuctionAddProductAdminController>();
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Auction Managment",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Auction Status",
                  style: TextStyle(
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
                const Text(
                  "Auction Stock",
                  style: TextStyle(
                    color: AppColors.darkLightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Enter the total quantity of this Auction currently in stock",
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
                const SizedBox(height: 10),
                SimpleTextFormFieldWidget(
                  textController: controller.inputProductStock,
                  hint: 'Input Auction Stock',
                ),
                const SizedBox(height: 10),
                const Text(
                  "Auction Start From",
                  style: TextStyle(
                    color: AppColors.darkLightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Enter the start time of auction",
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
                const SizedBox(height: 10),
                SimpleTextFormFieldWidget(
                  readOnly: true,
                  onTap: () => controller.selectStartTime(context),
                  textController: controller.selectedStartTimeController,
                  hint: 'Input Auction Start Time',
                ),
                const SizedBox(height: 10),
                const Text(
                  "Auction End Time",
                  style: TextStyle(
                    color: AppColors.darkLightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Enter the end time of auction",
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
                const SizedBox(height: 10),
                SimpleTextFormFieldWidget(
                  readOnly: true,
                  onTap: () => controller.selectEndTime(context),
                  textController: controller.selectedEndTimeController,
                  hint: 'Input Auction End time',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
