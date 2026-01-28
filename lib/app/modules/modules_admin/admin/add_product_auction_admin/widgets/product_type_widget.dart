import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/views/add_product_admin_view.dart';

class ProductTypeWidget extends StatefulWidget {
  final Function(String) onTapCallback;
  final List<String> productTypes;
  const ProductTypeWidget({
    super.key,
    required this.onTapCallback,
    required this.productTypes,
  });

  @override
  State<ProductTypeWidget> createState() => _ProductTypeWidgetState();
}

class _ProductTypeWidgetState extends State<ProductTypeWidget> {
  @override
  Widget build(BuildContext context) {
    final addProductController = Get.find<AddProductAdminController>();
    return ProductFieldsCardCustomWidget(
      column: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Product Type",
                  style: TextStyle(
                    color: AppColors.adminGreyColorText,
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
            const SizedBox(height: 5),
            const Text(
              "Select the product type",
              style: TextStyle(color: AppColors.adminGreyColorText),
            ),
            const SizedBox(height: 15),
            Column(
              children: List.generate(
                widget.productTypes.length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: InkWell(
                    onTap:
                        () => widget.onTapCallback(
                          widget.productTypes[i],
                        ), // ✅ FIXED
                    child: Obx(
                      () => RadioButtonWidget(
                        borderWidth:
                            addProductController.selectedProductType.value ==
                                    widget.productTypes[i]
                                ? 5
                                : 1,
                        borderColor:
                            addProductController.selectedProductType.value ==
                                    widget.productTypes[i]
                                ? AppColors.redmeronColor
                                : AppColors.greyBottom,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadioButtonWidget extends StatelessWidget {
  final double borderWidth;
  final Color borderColor;
  const RadioButtonWidget({
    super.key,
    required this.borderWidth,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        border: Border.all(width: borderWidth, color: borderColor),
        borderRadius: BorderRadius.circular(50),
        color: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.transparent,
        ),
      ),
    );
  }
}
