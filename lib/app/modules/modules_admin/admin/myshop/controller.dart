// shop_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/myshop/service.dart';

import 'package:tjara/main.dart'; // For uploadMedia function

enum ShopLoadingState { initial, loading, loaded, error, updating }

class MyShopController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Tab Controller
  late TabController tabController;

  // Loading States
  final Rx<ShopLoadingState> loadingState = ShopLoadingState.initial.obs;
  final RxBool isUpdating = false.obs;
  final RxString errorMessage = ''.obs;

  // Shop Data
  final Rx<ShopShop?> shop = Rx<ShopShop?>(null);

  // Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController shippingCompanyController =
      TextEditingController();
  final TextEditingController shippingFeesController = TextEditingController();
  final TextEditingController freeShippingTargetController =
      TextEditingController();
  final TextEditingController shippingTimeFromController =
      TextEditingController();
  final TextEditingController shippingTimeToController =
      TextEditingController();

  // Status and Feature switches
  final RxBool isFeatured = false.obs;
  final RxBool isVerified = false.obs;
  final RxString selectedStatus = 'active'.obs;
  final RxBool isEligibleForDiscounts = true.obs;

  // Image handling
  final RxString thumbnailUrl = ''.obs;
  final RxString bannerUrl = ''.obs;
  final RxBool isUploadingThumbnail = false.obs;
  final RxBool isUploadingBanner = false.obs;

  final ShopService _shopService = ShopService();
  void checkshopId() {
    final args = Get.arguments;

    if (args != null && args is Map && args.containsKey('shopId')) {
      final id = args['shopId'];
      shopIdArguement.value = id;
    } else {
      // Handle null case if needed
      shopIdArguement.value = '';
    }
  }

  RxString shopIdArguement = RxString('');
  final String shopId = "0000c539-9857-3456-bc53-2bbdc1474f1a";

  @override
  void onInit() {
    super.onInit();
    checkshopId();
    tabController = TabController(length: 2, vsync: this);
    fetchShopData();
  }

  @override
  void onClose() {
    tabController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    shippingCompanyController.dispose();
    shippingFeesController.dispose();
    freeShippingTargetController.dispose();
    shippingTimeFromController.dispose();
    shippingTimeToController.dispose();
    super.onClose();
  }

  Future<void> fetchShopData() async {
    try {
      loadingState.value = ShopLoadingState.loading;
      errorMessage.value = '';

      final response = await _shopService.getShop(
        shopIdArguement.value.isNotEmpty ? shopIdArguement.value : shopId,
      );

      if (response != null) {
        shop.value = response;
        _populateFormFields();
        loadingState.value = ShopLoadingState.loaded;
      } else {
        throw Exception('Shop data not found');
      }
    } catch (e) {
      loadingState.value = ShopLoadingState.error;
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load shop data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _populateFormFields() {
    final currentShop = shop.value;
    if (currentShop == null) return;

    // Basic Info
    nameController.text = currentShop.name ?? '';
    descriptionController.text = currentShop.description ?? '';
    selectedStatus.value = currentShop.status ?? 'active';
    isFeatured.value = (currentShop.isFeatured ?? 0) == 1;
    isVerified.value = (currentShop.isVerified ?? 0) == 1;

    // Images
    thumbnailUrl.value = currentShop.thumbnail?.message?.url ?? '';
    bannerUrl.value = currentShop.banner?.media.url ?? '';

    // Meta data
    final meta = currentShop.meta;
    if (meta != null) {
      phoneController.text = meta.phone ?? '';
      whatsappController.text = meta.whatsapp ?? '';
      shippingCompanyController.text = meta.shippingCompany ?? '';
      shippingFeesController.text = meta.shippingFees ?? '';
      freeShippingTargetController.text = meta.freeShippingTargetAmount ?? '';
      shippingTimeFromController.text = meta.shippingTimeFrom ?? '';
      shippingTimeToController.text = meta.shippingTimeTo ?? '';
      isEligibleForDiscounts.value =
          (meta.isEligibleForDiscounts ?? '1') == '1';
    }
  }

  Future<void> pickThumbnailImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        isUploadingThumbnail.value = true;
        final File imageFile = File(image.path);

        // Call uploadMedia function from main.dart
        final String mediaId = await uploadMedia([imageFile]);

        // Update the shop data immediately for UI
        if (shop.value != null) {
          shop.value = shop.value!.copyWith(thumbnailId: mediaId);
        }

        Get.snackbar(
          'Success',
          'Thumbnail uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload thumbnail: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isUploadingThumbnail.value = false;
    }
  }

  Future<void> pickBannerImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        isUploadingBanner.value = true;
        final File imageFile = File(image.path);

        // Call uploadMedia function from main.dart
        final String mediaId = await uploadMedia([imageFile]);

        // Update the shop data immediately for UI
        if (shop.value != null) {
          shop.value = shop.value!.copyWith(bannerImageId: mediaId);
        }

        Get.snackbar(
          'Success',
          'Banner uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload banner: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isUploadingBanner.value = false;
    }
  }

  Future<void> updateShop() async {
    try {
      if (nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Shop name is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      isUpdating.value = true;

      final updateData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'status': selectedStatus.value,
        'is_featured': isFeatured.value,
        'is_verified': isVerified.value,
        if (shop.value?.thumbnailId != null)
          'thumbnail_id': shop.value!.thumbnailId,
        if (shop.value?.bannerImageId != null)
          'banner_image_id': shop.value!.bannerImageId,
        'meta': [
          {
            'phone': phoneController.text.trim(),
            'whatsapp': whatsappController.text.trim(),
            'shipping_company': shippingCompanyController.text.trim(),
            'shipping_fees': shippingFeesController.text.trim(),
            'free_shipping_target_amount':
                freeShippingTargetController.text.trim(),
            'shipping_time_from': shippingTimeFromController.text.trim(),
            'shipping_time_to': shippingTimeToController.text.trim(),
            'is_eligible_for_discounts':
                isEligibleForDiscounts.value ? '1' : '0',
          },
        ],
      };

      final success = await _shopService.updateShop(
        shopIdArguement.value.isNotEmpty ? shopIdArguement.value : shopId,
        updateData,
      );

      if (success) {
        await fetchShopData(); // Refresh data
        Get.snackbar(
          'Success',
          'Shop updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to update shop');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update shop: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void retryFetch() {
    fetchShopData();
  }

  bool get isLoading => loadingState.value == ShopLoadingState.loading;
  bool get isLoaded => loadingState.value == ShopLoadingState.loaded;
  bool get hasError => loadingState.value == ShopLoadingState.error;
}
