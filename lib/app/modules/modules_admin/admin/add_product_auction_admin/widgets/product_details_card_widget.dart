import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';

import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/views/add_product_admin_view.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/product_details/product_details_editor_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';

class AuctionProductDetailsCardWidget extends StatelessWidget {
  const AuctionProductDetailsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuctionAddProductAdminController>();
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Auction Detail",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Auction Description",
              style: TextStyle(
                color: AppColors.darkLightTextColor,
                fontWeight: FontWeight.w500,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Price",
                      style: TextStyle(
                        color: AppColors.darkLightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.buttonLightGreyColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5,
                        ),
                        child: Text(
                          "Required",
                          style: TextStyle(color: AppColors.darkLightTextColor),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Enter the unique name of your product. Make it descriptive and easy to remember for customers.",
                  style: TextStyle(color: AppColors.adminGreyColorText),
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
                  "Reserved Price",
                  style: TextStyle(
                    color: AppColors.darkLightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Add reserved_price of your product here",
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
                const SizedBox(height: 10),
                SimpleTextFormFieldWidget(
                  textController: controller.salepriceController,
                  hint: '\$0',
                ),
                const SizedBox(height: 2),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "bids Incrments By",
                  style: TextStyle(
                    color: AppColors.darkLightTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Add the number to increment the bid by it. if the number is 10 then the each new bid has to be incremented by 10, e.g. 10, 20, 30.",
                  style: TextStyle(color: AppColors.adminGreyColorText),
                ),
                const SizedBox(height: 10),
                SimpleTextFormFieldWidget(
                  textController: controller.bidsIncrementBy,
                  hint: '\$0',
                ),
                const SizedBox(height: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
