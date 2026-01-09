import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';
import 'package:tjara/app/modules/admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/admin/add_product_admin/views/add_product_admin_view.dart';

class SkuWidget extends StatelessWidget {
  const SkuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final addProductController = Get.find<AddProductAdminController>();
    return ProductFieldsCardCustomWidget(
      column: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SKU", style: TextStyle(color: AppColors.adminGreyColorText, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            SimpleTextFormFieldWidget(textController: addProductController.skuController, hint: 'Add SKU')
          ],
        ),
      ),
    );
  }
}
