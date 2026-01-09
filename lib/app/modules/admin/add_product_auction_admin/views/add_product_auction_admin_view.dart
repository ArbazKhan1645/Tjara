import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/core/widgets/buttons/simple_button_with_left_icon_and_icon_widget.dart';
import 'package:tjara/app/core/widgets/simple_text_form_field_Widget.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/widgets/auction_products_settings.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/widgets/product_details_card_widget.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/widgets/product_information_widget.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/widgets/product_management_widget.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/widgets/shipping.dart';
import 'package:tjara/app/modules/admin/add_product_auction_admin/widgets/upload_product_images_widget.dart';
import 'package:tjara/app/modules/admin/categories_admin/controllers/categories_admin_controller.dart';

class AuctionAddProductAdminView extends StatelessWidget {
  const AuctionAddProductAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.adminBgLightGreyColor,
      body: AuctionAddAdminProductWidget(),
    );
  }
}

class AuctionAddAdminProductWidget extends StatelessWidget {
  const AuctionAddAdminProductWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      init: AuctionAddProductAdminController(),
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

  Widget _buildHeader(AuctionAddProductAdminController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GetBuilder<AuctionAddProductAdminController>(
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

  Widget _buildProductForm(AuctionAddProductAdminController controller) {
    return Column(
      children: [
        GetBuilder<CategoriesAdminController>(
          builder:
              (categoryController) => AuctionProductInformationWidget(
                controller: controller,
                categoryAdminController: categoryController,
              ),
        ),
        const SizedBox(height: 20),
        const AuctionUploadProductImagesWidget(),
        const SizedBox(height: 20),
        GetBuilder<AuctionAddProductAdminController>(
          builder: (controller) => AuctionProductSettingsWidget(),
        ),

        const SizedBox(height: 20),
        const AuctionProductDetailsCardWidget(),
        const SizedBox(height: 20),
        // UPCFormWidget(),
        const SizedBox(height: 20),
        const AuctionProductManagementWidget(),
        const SizedBox(height: 20),

        AuctionShippingWidget(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButtons(AuctionAddProductAdminController controller) {
    return GetBuilder<AuctionAddProductAdminController>(
      builder: (controller) {
        return Column(
          children: [
            const SizedBox(height: 25),
            RoundedTextButton(
              label: controller.isEditMode.value ? 'Update' : 'Save',
              onPressed: () => _handleSave(controller),
              backgroundColor: const Color(0xFF0D9488),
              textColor: Colors.white,
            ),
            const SizedBox(height: 12),
            RoundedTextButton(
              label: 'Cancel',
              onPressed: Get.back,
              backgroundColor: const Color(0xFFE5E5E5),
              textColor: Colors.black,
            ),
          ],
        );
      },
    );
  }

  String _getGroupName() {
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) return args;

    if (args is Map) {
      final pg = args['product_group'];
      if (pg is String && pg.isNotEmpty) return pg;
      if (pg is Map &&
          pg['name'] is String &&
          (pg['name'] as String).isNotEmpty) {
        return pg['name'];
      }
    }

    // This is the Auction add/update screen, default to "Auction"
    return 'Auction';
  }

  Future<void> _handleSave(AuctionAddProductAdminController controller) async {
    // Validation
    final validationError = _validateForm(controller);
    if (validationError != null) {
      Get.snackbar('Error', validationError);
      return;
    }

    final success =
        controller.isEditMode.value
            ? await _updateProduct(controller)
            : await _insertProduct(controller);

    _handleSaveResult(success);
  }

  String? _validateForm(AuctionAddProductAdminController controller) {
    if (controller.productNameController.text.trim().isEmpty) {
      return 'Auction name is required';
    }
    if (controller.selectedProductType.value.isEmpty) {
      return 'Product type is required';
    }
    if (controller.thumbnailId?.isEmpty ?? true) {
      return 'Thumbnail is required';
    }

    if (controller.priceController.text.trim().isEmpty) {
      return 'Auction price is required';
    }

    if (controller.selectedEndTime.value == null) {
      return 'Auction end time is required';
    }

    if (controller.selectedStartTime.value == null) {
      return 'Auction start time is required';
    }

    if (controller.selectedEndTime.value!.isBefore(
      controller.selectedStartTime.value!,
    )) {
      return 'Auction end time must be after start time';
    }

    if (controller.selectedEndTime.value!.isBefore(DateTime.now())) {
      return 'Auction end time must be in the future';
    }

    if (controller.bidsIncrementBy.text.isEmpty) {
      return 'Bids increment by is required';
    }

    if (int.tryParse(controller.bidsIncrementBy.text) == null) {
      return 'Bids increment by must be a number';
    }

    return null;
  }

  Future<bool> _updateProduct(AuctionAddProductAdminController controller) {
    return controller.updateProduct(
      productGroup:
          (controller.selectedProductgroup.value == 'product' ||
                  controller.selectedProductgroup.value == 'Product')
              ? 'global'
              : 'car',
      description: controller.productdescriptionController.text,

      id: controller.editProduct?.id ?? '',
      name: controller.productNameController.text.trim(),
      productType: 'auction',
      stock: int.tryParse(controller.inputProductStock.text.trim()),
      thumbnailId: controller.thumbnailId ?? '',
      videoId: controller.videoId,
      isFeatured: controller.isFeatured.value,
      isDeal: controller.isDeal.value,
      price: double.tryParse(controller.priceController.text.trim()),
      salePrice: double.tryParse(controller.salepriceController.text.trim()),
      reservedPrice: null,
      auctionStartTime: controller.selectedStartTime.value,
      auctionEndTime: controller.selectedEndTime.value,
      galleryIds: controller.galleryIds,
      categoryIds:
          controller.selectedCategoryId != null
              ? [controller.selectedCategoryId!]
              : (controller.selectedItem != null
                  ? [controller.selectedItem!.id ?? '']
                  : []),
      tagIds: [],
      meta: {},
    );
  }

  Future<bool> _insertProduct(AuctionAddProductAdminController controller) {
    return controller.insertProduct(
      productGroup:
          (controller.selectedProductgroup.value == 'product' ||
                  controller.selectedProductgroup.value == 'Product')
              ? 'global'
              : 'car',

      description: controller.productdescriptionController.text,
      name: controller.productNameController.text.trim(),
      productType: 'auction',
      stock: int.tryParse(controller.inputProductStock.text.trim()),
      thumbnailId: controller.thumbnailId ?? '',
      videoId: controller.videoId,
      isFeatured: controller.isFeatured.value,
      isDeal: controller.isDeal.value,
      price: double.tryParse(controller.priceController.text.trim()) ?? 0,
      salePrice: double.tryParse(controller.salepriceController.text.trim()),
      reservedPrice: null,
      auctionStartTime: controller.selectedStartTime.value,
      auctionEndTime: controller.selectedEndTime.value,
      galleryIds: controller.galleryIds,
      categoryIds:
          controller.selectedCategoryId != null
              ? [controller.selectedCategoryId!]
              : (controller.selectedItem != null
                  ? [controller.selectedItem!.id ?? '']
                  : []),
      tagIds: [],
      meta: {},
    );
  }

  void _handleSaveResult(bool success) {
    final controller = Get.find<AuctionAddProductAdminController>();
    if (success) {
      final args = Get.arguments;
      final String? returnToRoute =
          (args is Map && args['return_to'] is String)
              ? args['return_to']
              : null;
      if (returnToRoute != null && returnToRoute.isNotEmpty) {
        Get.offNamed(returnToRoute);
      } else {
        Get.back();
      }
      Get.snackbar(
        'Success',
        'Product ${controller.isEditMode.value ? 'updated' : 'added'} successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class ShippingDetails extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const ShippingDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
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
            activeColor: Colors.red,
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
