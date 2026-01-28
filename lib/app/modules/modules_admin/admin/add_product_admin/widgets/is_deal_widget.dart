import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/views/add_product_admin_view.dart';

class IsDealWidget extends StatelessWidget {
  final ValueChanged<bool?> onTapCallback;
  const IsDealWidget({super.key, required this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    final addProductController = Get.find<AddProductAdminController>();
    return ProductFieldsCardCustomWidget(
      column: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Is Deal",
              style: TextStyle(
                color: AppColors.adminGreyColorText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Select the is Deal",
              style: TextStyle(color: AppColors.adminGreyColorText),
            ),
            const SizedBox(height: 15),
            Obx(
              () => Transform.scale(
                scale: 0.8,
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: addProductController.isDeal.value,
                    onChanged: onTapCallback,
                    activeColor: AppColors.redmeronColor,
                    side: const BorderSide(
                      color: AppColors.lightGreyBorderColor,
                      width: 2,
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
