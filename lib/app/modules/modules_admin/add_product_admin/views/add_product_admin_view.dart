import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';

import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/car_location_data_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/car_meta_data_widget.dart';
import 'package:tjara/app/modules/modules_admin/cars/cars_view.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/controllers/add_product_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/attributes/attributes_manage.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/product_details_card_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/product_information_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/product_management_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/products_settings.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/scan.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/shipping.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/upload_product_images_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/admin_ui_components.dart';
import 'package:tjara/app/modules/modules_admin/categories_admin/controllers/categories_admin_controller.dart';

class AddProductAdminView extends StatelessWidget {
  const AddProductAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.adminBgLightGreyColor,
      body: AddAdminProductWidget(),
    );
  }
}

class AddAdminProductWidget extends StatelessWidget {
  const AddAdminProductWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddProductAdminController>(
      init: AddProductAdminController(),
      builder: (controller) {
        return CustomScrollView(
          slivers: [
            const AdminSliverAppBarWidget(
              title: 'Dashboard',
              isAppBarExpanded: true,
              actions: [AdminAppBarActions()],
            ),
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  const AdminHeaderAnimatedBackgroundWidget(
                    isAppBarExpanded: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(controller),
                        _buildProductForm(controller),
                        _buildActionButtons(controller),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(AddProductAdminController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GetBuilder<AddProductAdminController>(
        builder: (controller) {
          final groupName = _getGroupName();
          final label =
              controller.isEditMode.value
                  ? 'Update $groupName'
                  : 'Add $groupName';

          return Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductForm(AddProductAdminController controller) {
    return Column(
      children: [
        GetBuilder<CategoriesAdminController>(
          builder:
              (categoryController) => ProductInformationWidget(
                controller: controller,
                categoryAdminController: categoryController,
              ),
        ),
        const SizedBox(height: 20),
        const UploadProductImagesWidget(),

        const SizedBox(height: 20),
        GetBuilder<AddProductAdminController>(
          builder: (controller) => ProductSettingsWidget(),
        ),
        Obx(() {
          if (controller.selectedProductType.value != "Variants") {
            return const SizedBox.shrink();
          }
          return const Column(
            children: [SizedBox(height: 20), AttributesManage()],
          );
        }),
        const SizedBox(height: 20),
        const ProductDetailsCardWidget(),
        const SizedBox(height: 20),
        const UPCFormWidget(),
        const SizedBox(height: 20),
        Obx(() {
          final group = controller.selectedProductgroup.value.toLowerCase();
          if (group == 'car' || group == 'cars') {
            return Column(
              children: [
                CarMetaFieldsWidget(controller: controller),
                const SizedBox(height: 20),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          final group = controller.selectedProductgroup.value.toLowerCase();
          if (group == 'car' || group == 'cars') {
            return Column(
              children: [
                SellingAreaWidget(controller: controller),
                const SizedBox(height: 20),
              ],
            );
          }
          return const SizedBox.shrink();
        }),

        const ProductManagementWidget(),
        const SizedBox(height: 20),

        ShippingWidget(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButtons(AddProductAdminController controller) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      return Column(
        children: [
          const SizedBox(height: 25),
          AdminPrimaryButton(
            label: controller.isEditMode.value ? 'Update' : 'Save',
            icon: Icons.save_outlined,
            isLoading: isLoading,
            onPressed: isLoading ? null : () => _handleSave(controller),
          ),
          const SizedBox(height: 12),
          AdminSecondaryButton(
            label: 'Cancel',
            icon: Icons.close,
            onPressed: isLoading ? null : () => Get.back(),
          ),
        ],
      );
    });
  }

  String _getGroupName() {
    final args = Get.arguments;
    if (args is String) return args;

    if (args is Map) {
      final pg = args['product_group'];
      if (pg is String) return pg;
      if (pg is Map && pg['name'] is String) return pg['name'];
    }

    return 'Product';
  }

  Future<void> _handleSave(AddProductAdminController controller) async {
    // Validation
    final validationError = _validateForm(controller);
    if (validationError != null) {
      AdminSnackbar.warning('Validation Error', validationError);
      return;
    }

    // Show loading
    AdminFullScreenLoader.show(
      message:
          controller.isEditMode.value
              ? 'Updating product...'
              : 'Saving product...',
    );

    try {
      final success =
          controller.isEditMode.value
              ? await _updateProduct(controller)
              : await _insertProduct(controller);

      // Hide loading
      AdminFullScreenLoader.hide();

      _handleSaveResult(success, controller.isEditMode.value);
    } catch (e) {
      AdminFullScreenLoader.hide();
      AdminSnackbar.error('Error', 'An unexpected error occurred');
    }
  }

  String? _validateForm(AddProductAdminController controller) {
    if (controller.productNameController.text.trim().isEmpty) {
      return 'Product name is required';
    }
    if (controller.selectedProductType.value.isEmpty) {
      return 'Product type is required';
    }
    if (controller.thumbnailId?.isEmpty ?? true) {
      return 'Thumbnail is required';
    }

    if (controller.selectedProductType.value == 'Variants' &&
        controller.variants.isEmpty) {
      return 'Variants are required';
    }
    if (controller.selectedProductType.value == 'Variants') {
      for (int i = 0; i < controller.variants.length; i++) {
        if (controller.variants[i].price <= 0) {
          return 'Price is required for variant "${controller.variants[i].item.name ?? 'Variant ${i + 1}'}"';
        }
      }
    }
    if (controller.selectedProductType.value == 'Simple' &&
        controller.priceController.text.trim().isEmpty) {
      return 'Product price is required';
    }

    return null;
  }

  Future<bool> _updateProduct(AddProductAdminController controller) {
    return controller.updateProduct(
      productGroup:
          (controller.selectedProductgroup.value == 'product' ||
                  controller.selectedProductgroup.value == 'Product')
              ? 'global'
              : 'car',
      description: controller.productdescriptionController.text,
      id: controller.editProduct?.id ?? '',
      name: controller.productNameController.text.trim(),
      productType:
          controller.selectedProductType.value == 'Simple'
              ? 'simple'
              : 'variable',
      stock: int.tryParse(controller.inputProductStock.text.trim()),
      thumbnailId: controller.thumbnailId ?? '',
      videoId: controller.videoId,
      isFeatured: controller.isFeatured.value,
      isDeal: controller.isDeal.value,
      price: double.tryParse(controller.priceController.text.trim()),
      salePrice: double.tryParse(controller.salepriceController.text.trim()),
      reservedPrice: null,
      auctionStartTime: null,
      auctionEndTime: null,
      status: 'active',
      galleryIds: controller.galleryIds,
      categoryIds:
          controller.selectedCategoryId != null
              ? [controller.selectedCategoryId!]
              : (controller.selectedItem != null
                  ? [controller.selectedItem!.id ?? '']
                  : []),
      tagIds: [],
      meta: {
        'hide_price': '0',
        'is_sold': '0',
        'country_id': controller.selectedCountry?.id,
        'state_id': controller.selectedState?.id,
        'city_id': controller.selectedCity?.id,
        'mileage': controller.mileageController.text,
        'transmission': controller.selectedTransmission.value,
        'fuel_type': controller.selectedFuelType.value,
        'engine': controller.engineCCController.text,
      },
    );
  }

  Future<bool> _insertProduct(AddProductAdminController controller) {
    return controller.insertProduct(
      productGroup:
          (controller.selectedProductgroup.value == 'product' ||
                  controller.selectedProductgroup.value == 'Product')
              ? 'global'
              : 'car',
      description: controller.productdescriptionController.text,
      name: controller.productNameController.text.trim(),
      productType:
          controller.selectedProductType.value == 'Simple'
              ? 'simple'
              : 'variable',
      stock: int.tryParse(controller.inputProductStock.text.trim()),
      thumbnailId: controller.thumbnailId ?? '',
      videoId: controller.videoId,
      isFeatured: controller.isFeatured.value,
      isDeal: controller.isDeal.value,
      price: double.tryParse(controller.priceController.text.trim()) ?? 0,
      salePrice: double.tryParse(controller.salepriceController.text.trim()),
      // Custom meta values for cars/products
      status: 'active',
      meta: {
        'hide_price': '0',
        'country_id': controller.selectedCountry?.id,
        'state_id': controller.selectedState?.id,
        'city_id': controller.selectedCity?.id,
        'is_sold': '0',
        'mileage': controller.mileageController.text,
        'transmission': controller.selectedTransmission.value,
        'fuel_type': controller.selectedFuelType.value,
        'engine': controller.engineCCController.text,
      },
      reservedPrice: null,
      auctionStartTime: null,
      auctionEndTime: null,
      galleryIds: controller.galleryIds,
      categoryIds:
          controller.selectedCategoryId != null
              ? [controller.selectedCategoryId!]
              : (controller.selectedItem != null
                  ? [controller.selectedItem!.id ?? '']
                  : []),
      tagIds: [],
    );
  }

  void _handleSaveResult(bool success, bool isEditMode) async {
    if (success) {
      // Prefer explicit return route if provided by caller
      final args = Get.arguments;
      final String? returnToRoute =
          (args is Map && args['return_to'] is String)
              ? args['return_to']
              : null;

      // Delay navigation slightly to show snackbar
      await Future.delayed(const Duration(milliseconds: 500), () {
        if (returnToRoute != null && returnToRoute.isNotEmpty) {
          Get.offNamed(returnToRoute);
        } else {
          // Context-aware fallback: cars → CarsView, else back
          String groupName = 'Product';
          if (args is String) {
            groupName = args;
          } else if (args is Map) {
            final pg = args['product_group'];
            if (pg is String) groupName = pg;
            if (pg is Map && pg['name'] is String) groupName = pg['name'];
          }

          if (groupName.toLowerCase().contains('car')) {
            Get.off(() => const CarsView());
          } else {
            Get.back();
          }
        }
      });
      AdminSnackbar.success(
        'Success',
        isEditMode
            ? 'Product updated successfully'
            : 'Product added successfully',
      );
    }
  }
}

class ShippingDetails extends StatelessWidget {
  final AddProductAdminController controller;

  const ShippingDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddProductAdminController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Shipping'),
            const Divider(thickness: 1, color: Colors.grey),
            _buildShippingField(
              title: "Shipping Company",
              description:
                  "Enter the preferred shipping company or method for delivering this product to customers.",
              hint: 'ORIENT Shipping co',
              value: "Shipping Company : ORIENT Shipping co",
              controller: controller.inputProductStock,
            ),
            _buildShippingTimeSection(),
            _buildShippingField(
              title: "Shipping Fees",
              description:
                  "Enter the shipping fee for delivering this product to customers.",
              hint: '10.00',
              value:
                  "Shipping Fees :\$10\nPrice will be in decimals e.g. 10.00",
              controller: controller.inputProductStock,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.darkLightTextColor,
        ),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.darkLightTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingField({
    required String title,
    required String description,
    required String hint,
    required String value,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.darkLightTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: AppColors.adminGreyColorText),
          ),
          const SizedBox(height: 10),
          SimpleTextFormFieldWidget(textController: controller, hint: hint),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: AppColors.adminGreyColorText),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingTimeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shipping Time",
            style: TextStyle(
              color: AppColors.darkLightTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter the shipping time range.",
            style: TextStyle(color: AppColors.adminGreyColorText),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 8.0 : 0),
                  child: SimpleTextFormFieldWidget(
                    textController: controller.inputProductStock,
                    hint: '${index + 1}',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Shipping Time : 5 - 10 Business Days",
            style: TextStyle(color: AppColors.adminGreyColorText),
          ),
        ],
      ),
    );
  }
}

class ToggleSwitchButtonWidget extends StatelessWidget {
  final bool value;
  final Function(dynamic)? onChanged;

  const ToggleSwitchButtonWidget({
    super.key,
    this.value = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            border:
                value
                    ? null
                    : Border.all(color: AppColors.lightGreyBorderColor),
            borderRadius: BorderRadius.circular(24),
          ),
          child: AdvancedSwitch(
            onChanged: (value) {
              onChanged!(value);
            },
            initialValue: value,
            activeColor: const Color(0xFFF97316),
            inactiveColor: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(24),
            width: 60,
            height: 32,
            thumb: const DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(value ? "active" : "inactive"),
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
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: SizedBox(height: 15),
          ),
        ),
      ],
    );
  }
}
