import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/core/widgets/admin_header_animated_background_widget.dart';
import 'package:tjara/app/core/widgets/admin_sliver_app_bar_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/widgets/auction_admin_theme.dart';
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/widgets/auction_products_settings.dart';
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/widgets/product_details_card_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/widgets/product_information_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/widgets/product_management_widget.dart';
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/widgets/shipping.dart';
import 'package:tjara/app/modules/modules_admin/add_product_auction_admin/widgets/upload_product_images_widget.dart';
import 'package:tjara/app/modules/modules_admin/categories_admin/controllers/categories_admin_controller.dart';

class AuctionAddProductAdminView extends StatelessWidget {
  const AuctionAddProductAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AuctionAdminTheme.background,
      body: AuctionAddAdminProductWidget(),
    );
  }
}

class AuctionAddAdminProductWidget extends StatelessWidget {
  const AuctionAddAdminProductWidget({super.key});

  // Safe getter for group name
  String get _groupName {
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
    return 'Auction';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      init: AuctionAddProductAdminController(),
      builder: (controller) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuctionAdminTheme.spacingLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AuctionHeader(
                          groupName: _groupName,
                          isEditMode: controller.isEditMode.value,
                        ),
                        const SizedBox(height: AuctionAdminTheme.spacingLg),
                        _AuctionFormContent(controller: controller),
                        const SizedBox(height: AuctionAdminTheme.spacingXl),
                        _AuctionActionButtons(controller: controller),
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
}

/// Auction Header Widget
class _AuctionHeader extends StatelessWidget {
  final String groupName;
  final bool isEditMode;

  const _AuctionHeader({required this.groupName, required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      builder: (controller) {
        final label =
            controller.isEditMode.value
                ? 'Update $groupName'
                : 'Add $groupName';

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              ),
              child: const Icon(
                Icons.gavel_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AuctionAdminTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Fill in the auction details below',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
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
}

/// Auction Form Content
class _AuctionFormContent extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _AuctionFormContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GetBuilder<CategoriesAdminController>(
          builder:
              (categoryController) => AuctionProductInformationWidget(
                controller: controller,
                categoryAdminController: categoryController,
              ),
        ),
        const SizedBox(height: AuctionAdminTheme.spacingLg),
        const AuctionUploadProductImagesWidget(),
        const SizedBox(height: AuctionAdminTheme.spacingLg),
        GetBuilder<AuctionAddProductAdminController>(
          builder: (_) => const AuctionProductSettingsWidget(),
        ),
        const SizedBox(height: AuctionAdminTheme.spacingLg),
        const AuctionProductDetailsCardWidget(),
        const SizedBox(height: AuctionAdminTheme.spacingLg),
        const AuctionProductManagementWidget(),
        const SizedBox(height: AuctionAdminTheme.spacingLg),
        const AuctionShippingWidget(),
      ],
    );
  }
}

/// Action Buttons Widget
class _AuctionActionButtons extends StatefulWidget {
  final AuctionAddProductAdminController controller;

  const _AuctionActionButtons({required this.controller});

  @override
  State<_AuctionActionButtons> createState() => _AuctionActionButtonsState();
}

class _AuctionActionButtonsState extends State<_AuctionActionButtons> {
  bool _isSubmitting = false;

  Future<void> _handleSave() async {
    if (_isSubmitting) return;

    final validationError = _validateForm();
    if (validationError != null) {
      _showSnackBar(validationError, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success =
          widget.controller.isEditMode.value
              ? await _updateProduct()
              : await _insertProduct();

      if (!mounted) return;
      _handleSaveResult(success);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _validateForm() {
    final ctrl = widget.controller;

    if (ctrl.productNameController.text.trim().isEmpty) {
      return 'Auction name is required';
    }
    if (ctrl.selectedProductType.value.isEmpty) {
      return 'Product type is required';
    }
    if (ctrl.thumbnailId?.isEmpty ?? true) {
      return 'Thumbnail is required';
    }
    if (ctrl.priceController.text.trim().isEmpty) {
      return 'Auction price is required';
    }
    // Only validate times when schedule type is 'now'
    if (ctrl.auctionScheduleType.value == 'now') {
      if (ctrl.selectedEndTime.value == null) {
        return 'Auction end time is required';
      }
      if (ctrl.selectedStartTime.value == null) {
        return 'Auction start time is required';
      }
      if (ctrl.selectedEndTime.value!.isBefore(ctrl.selectedStartTime.value!)) {
        return 'Auction end time must be after start time';
      }
      if (ctrl.selectedEndTime.value!.isBefore(DateTime.now())) {
        return 'Auction end time must be in the future';
      }
    }
    if (ctrl.bidsIncrementBy.text.isEmpty) {
      return 'Bids increment by is required';
    }
    if (int.tryParse(ctrl.bidsIncrementBy.text) == null) {
      return 'Bids increment by must be a number';
    }
    return null;
  }

  Future<bool> _updateProduct() {
    final ctrl = widget.controller;
    return ctrl.updateProduct(
      productGroup:
          (ctrl.selectedProductgroup.value == 'product' ||
                  ctrl.selectedProductgroup.value == 'Product')
              ? 'global'
              : 'car',
      description: ctrl.productdescriptionController.text,
      id: ctrl.editProduct?.id ?? '',
      name: ctrl.productNameController.text.trim(),
      productType: 'auction',
      stock: int.tryParse(ctrl.inputProductStock.text.trim()),
      thumbnailId: ctrl.thumbnailId ?? '',
      videoId: ctrl.videoId,
      isFeatured: ctrl.isFeatured.value,
      isDeal: ctrl.isDeal.value,
      price: double.tryParse(ctrl.priceController.text.trim()),
      salePrice: double.tryParse(ctrl.salepriceController.text.trim()),
      reservedPrice: null,
      auctionStartTime: ctrl.selectedStartTime.value,
      auctionEndTime: ctrl.selectedEndTime.value,
      galleryIds: ctrl.galleryIds,
      categoryIds:
          ctrl.selectedCategoryId != null
              ? [ctrl.selectedCategoryId!]
              : (ctrl.selectedItem != null
                  ? [ctrl.selectedItem!.id ?? '']
                  : []),
      tagIds: [],
      meta: {},
    );
  }

  Future<bool> _insertProduct() {
    final ctrl = widget.controller;
    return ctrl.insertProduct(
      productGroup:
          (ctrl.selectedProductgroup.value == 'product' ||
                  ctrl.selectedProductgroup.value == 'Product')
              ? 'global'
              : 'car',
      description: ctrl.productdescriptionController.text,
      name: ctrl.productNameController.text.trim(),
      productType: 'auction',
      stock: int.tryParse(ctrl.inputProductStock.text.trim()),
      thumbnailId: ctrl.thumbnailId ?? '',
      videoId: ctrl.videoId,
      isFeatured: ctrl.isFeatured.value,
      isDeal: ctrl.isDeal.value,
      price: double.tryParse(ctrl.priceController.text.trim()) ?? 0,
      salePrice: double.tryParse(ctrl.salepriceController.text.trim()),
      reservedPrice: null,
      auctionStartTime: ctrl.selectedStartTime.value,
      auctionEndTime: ctrl.selectedEndTime.value,
      galleryIds: ctrl.galleryIds,
      categoryIds:
          ctrl.selectedCategoryId != null
              ? [ctrl.selectedCategoryId!]
              : (ctrl.selectedItem != null
                  ? [ctrl.selectedItem!.id ?? '']
                  : []),
      tagIds: [],
      meta: {},
    );
  }

  void _handleSaveResult(bool success) {
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

      _showSnackBar(
        'Auction ${widget.controller.isEditMode.value ? 'updated' : 'added'} successfully',
        isError: false,
      );
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          isError
              ? AuctionAdminTheme.errorLight
              : AuctionAdminTheme.successLight,
      colorText: isError ? AuctionAdminTheme.error : AuctionAdminTheme.success,
      margin: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
      borderRadius: AuctionAdminTheme.radiusMd,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? AuctionAdminTheme.error : AuctionAdminTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      builder: (controller) {
        return Column(
          children: [
            // Save/Update Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSubmitting ? null : _handleSave,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color:
                        _isSubmitting
                            ? AuctionAdminTheme.surfaceSecondary
                            : AuctionAdminTheme.accent,
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusMd,
                    ),
                    boxShadow:
                        _isSubmitting
                            ? null
                            : AuctionAdminTheme.shadowColored(
                              AuctionAdminTheme.accent,
                            ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AuctionAdminTheme.textSecondary,
                            ),
                          ),
                        )
                      else
                        Icon(
                          controller.isEditMode.value
                              ? Icons.update_rounded
                              : Icons.save_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      const SizedBox(width: AuctionAdminTheme.spacingSm),
                      Text(
                        _isSubmitting
                            ? 'Saving...'
                            : (controller.isEditMode.value ? 'Update' : 'Save'),
                        style: TextStyle(
                          color:
                              _isSubmitting
                                  ? AuctionAdminTheme.textSecondary
                                  : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AuctionAdminTheme.spacingMd),

            // Cancel Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AuctionAdminTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(
                      AuctionAdminTheme.radiusMd,
                    ),
                    border: Border.all(color: AuctionAdminTheme.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        color: AuctionAdminTheme.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: AuctionAdminTheme.spacingSm),
                      Text(
                        'Cancel',
                        style: TextStyle(
                          color: AuctionAdminTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
