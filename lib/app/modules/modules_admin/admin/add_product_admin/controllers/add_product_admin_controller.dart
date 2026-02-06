// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/attributes/attributes_manage.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/car_location_data_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/admin_ui_components.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/main.dart';

class AddProductAdminController extends GetxController {
  // Add these to your controller
  TextEditingController mileageController = TextEditingController();
  TextEditingController engineCCController = TextEditingController();
  RxString selectedCondition = 'New'.obs;
  RxString selectedTransmission = ''.obs;
  RxString selectedFuelType = ''.obs;
  // Car specific selections
  String? selectedCarMakeId;
  String? selectedCarMakeName;
  String? selectedCarYearId;
  String? selectedCarYearName;

  // Product category selection
  String? selectedCategoryId;
  String? selectedCategoryName;

  // Constants
  static const String _insertApiUrl =
      'https://api.libanbuy.com/api/products/insert';
  static const String _updateApiUrl = 'https://api.libanbuy.com/api/products';
  static final String _shopId =
      AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '';
  static const String _requestFromHeader = 'Dashboard';

  // Observable variables
  var isExpanded = true.obs;
  var selectedShippingCompany = 'ORIENT Shipping co'.obs;
  var shippingTimeFrom = '3'.obs;
  var shippingTimeTo = '4'.obs;
  var selectedTimeUnit = 'Days'.obs;
  var shippingFees = '3'.obs;
  final RxBool isLoading = false.obs;
  RxBool isEditMode = false.obs;
  RxBool selectedStatus = true.obs;
  RxString selectedProductgroup = 'product'.obs;
  RxString selectedProductType = 'Simple'.obs;
  RxBool isFeatured = false.obs;
  RxBool isDeal = false.obs;
  var enablePurchaseLimit = false.obs;

  // Available options
  final List<String> timeUnits = ['Days', 'Weeks', 'Months']; // Capital case
  final List<String> productTypes = ['Simple', 'Variants'];

  // Controllers
  final productNameController = TextEditingController();
  final upcNameController = TextEditingController();
  final shiPPingNoticeController = TextEditingController();
  final productdescriptionController = TextEditingController();
  final skuController = TextEditingController();
  final priceController = TextEditingController();
  final salepriceController = TextEditingController();
  final inputProductStock = TextEditingController(text: '1');

  // Variants
  final RxList<VariantData> variants = <VariantData>[].obs;
  String mainattributeId = '';

  // Edit mode variables
  AdminProducts? editProduct;
  ProductAttributeItems? selectedItem;

  // Media variables
  String? thumbnailId;
  String? videoId;
  List<String> galleryIds = [];
  File? thumbnailFile;
  File? videoFile;
  List<File> galleryFiles = [];
  String? thumbnailUrl;
  String? videoUrl;
  List<String> galleryUrls = [];

  // Media Upload State Tracking
  final RxBool isThumbnailUploading = false.obs;
  final RxBool isVideoUploading = false.obs;
  final RxList<bool> galleryUploadingStates = <bool>[].obs;

  // Cancel tokens for uploads (using index tracking)
  bool _thumbnailUploadCancelled = false;
  bool _videoUploadCancelled = false;
  final List<bool> _galleryUploadCancelled = [];

  /// Check if any media is currently uploading
  bool get isAnyMediaUploading =>
      isThumbnailUploading.value ||
      isVideoUploading.value ||
      galleryUploadingStates.any((uploading) => uploading);

  // Repository

  // Singleton access
  static AddProductAdminController get instance =>
      Get.find<AddProductAdminController>();

  @override
  void onInit() {
    super.onInit();
    _handleInitialArguments();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  // Private Methods
  void _handleInitialArguments() {
    try {
      final args = Get.arguments;

      if (args is Map && args['product'] != null) {
        isEditMode.value = true;
        editProduct = args['product'] as AdminProducts;
        selectedProductgroup.value = args['product_group'] ?? 'product';
        _populateFieldsFromProduct();
      } else {
        isEditMode.value = false;
        if (args is String) {
          selectedProductgroup.value = args;
        }
      }
    } catch (e) {
      _showErrorSnackbar('Error initializing product form', e.toString());
    }
  }

  void _disposeControllers() {
    productNameController.dispose();
    productdescriptionController.dispose();
    skuController.dispose();
    priceController.dispose();
    salepriceController.dispose();
    inputProductStock.dispose();
  }

  void _populateFieldsFromProduct() {
    if (editProduct == null) return;

    try {
      // Populate text controllers
      productNameController.text = editProduct?.name ?? '';
      skuController.text = editProduct?.slug ?? '';
      priceController.text = editProduct?.price?.toString() ?? '';
      salepriceController.text = editProduct?.salePrice?.toString() ?? '';
      inputProductStock.text = editProduct?.stock?.toString() ?? '1';
      productdescriptionController.text = (editProduct?.description ?? '')
          .replaceAll(RegExp(r'<[^>]*>'), '');

      // Populate other fields
      selectedProductType.value =
          editProduct?.productType == 'variable' ? 'Variants' : 'Simple';
      isFeatured.value = editProduct?.isFeatured == 1;
      selectedStatus.value = editProduct?.status == 'active';
      isDeal.value = editProduct?.isDeal == 1;
      enablePurchaseLimit.value = false;

      shiPPingNoticeController.text = editProduct?.meta?.productNotice ?? '';
      upcNameController.text = editProduct?.meta?.upcCode ?? '';

      // Populate car meta fields
      mileageController.text = editProduct?.meta?.mileage?.toString() ?? '';
      engineCCController.text = editProduct?.meta?.engine?.toString() ?? '';
      selectedTransmission.value = editProduct?.meta?.transmission ?? '';
      selectedFuelType.value = editProduct?.meta?.fuelType ?? '';

      // Populate shipping info
      shippingTimeFrom.value = editProduct?.meta?.shippingTimeFrom ?? '3';
      shippingTimeTo.value = editProduct?.meta?.shippingTimeTo ?? '4';

      // Handle shipping time unit dynamically
      final String apiTimeUnit =
          editProduct?.meta?.shippingTimeUnit?.toString() ?? '';

      // Convert API value to match dropdown options
      final String normalizedTimeUnit = _normalizeTimeUnit(apiTimeUnit);
      selectedTimeUnit.value = normalizedTimeUnit;

      shippingFees.value = editProduct?.meta?.shippingFees?.toString() ?? '3';
      selectedShippingCompany.value =
          editProduct?.meta?.shippingCompany ?? 'ORIENT Shipping co';

      // Handle media URLs
      if (editProduct?.thumbnail?.media?.url != null) {
        thumbnailUrl = editProduct?.thumbnail?.media?.url;
        thumbnailId = editProduct?.thumbnail?.media?.id?.toString();
      }

      if (editProduct?.video?.media?.url != null) {
        videoUrl = editProduct?.video?.media?.url;
        videoId = editProduct?.video?.media?.id?.toString();
      }

      // Preload location based on meta IDs (country/state/city)
      try {
        // Defer to ensure location lists initialize
        WidgetsBinding.instance.addPostFrameCallback((_) {
          preloadLocationFromMeta(
            editProduct?.meta?.countryId,
            editProduct?.meta?.stateId,
            editProduct?.meta?.cityId,
          );
        });
      } catch (_) {}

      update();
    } catch (e) {
      _showErrorSnackbar('Error loading product data', e.toString());
    }
  }

  // Helper method to normalize time unit values
  String _normalizeTimeUnit(String apiValue) {
    // Handle null, empty, or 'undefined' values
    if (apiValue.isEmpty ||
        apiValue == 'null' ||
        apiValue == 'undefined' ||
        apiValue.toLowerCase() == 'undefined') {
      return 'Days'; // default value
    }

    // Convert to lowercase for comparison
    final String lowerValue = apiValue.toLowerCase();

    // Map common variations to the correct dropdown values
    switch (lowerValue) {
      case 'day':
      case 'days':
        return 'Days';
      case 'week':
      case 'weeks':
        return 'Weeks';
      case 'month':
      case 'months':
        return 'Months';
      default:
        // If it's already in the correct format, return as is
        if (timeUnits.contains(apiValue)) {
          return apiValue;
        }
        // If no match found, return default
        return 'Days';
    }
  }

  void _showErrorSnackbar(String title, String message) {
    // Extract meaningful error message from API response
    String errorMessage = message;
    try {
      if (message.contains('{')) {
        final jsonError = jsonDecode(message);
        errorMessage = jsonError['message'] ?? jsonError['error'] ?? message;
      }
    } catch (e) {
      // If not JSON, use original message but limit length
      if (message.length > 100) {
        errorMessage = '${message.substring(0, 100)}...';
      }
    }
    AdminSnackbar.error(title, errorMessage);
  }

  void _showSuccessSnackbar(String title, String message) {
    AdminSnackbar.success(title, message);
  }

  void _showWarningSnackbar(String title, String message) {
    AdminSnackbar.warning(title, message);
  }

  void _showInfoSnackbar(String title, String message) {
    AdminSnackbar.info(title, message);
  }

  Map<String, String> _getCommonHeaders() {
    return {
      'X-Request-From': _requestFromHeader,
      'Content-Type': 'application/json',
      'shop-id': _shopId,
    };
  }

  // Image Cropping
  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xff196A30),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      _showErrorSnackbar('Image Crop Error', e.toString());
      return null;
    }
  }

  // Media Upload
  Future<List<String>> _uploadMedia(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    final List<String> mediaIds = [];
    try {
      final String id = await uploadMedia(
        files,
        directory: directory,
        width: width,
        height: height,
      );
      mediaIds.add(id);
    } catch (e) {
      _showErrorSnackbar('Media Upload Error', e.toString());
    }
    return mediaIds;
  }

  // Product Data Preparation

  // Public Methods
  void toggleExpansion() {
    isExpanded.value = !isExpanded.value;
  }

  void updateShippingCompany(String company) {
    selectedShippingCompany.value = company;
  }

  void updateShippingTimeFrom(String time) {
    shippingTimeFrom.value = time;
  }

  void updateShippingTimeTo(String time) {
    shippingTimeTo.value = time;
  }

  void updateTimeUnit(String unit) {
    selectedTimeUnit.value = unit;
  }

  void updateShippingFees(String fees) {
    shippingFees.value = fees;
  }

  String get shippingTimeDisplay {
    return 'Shipping Time : ${shippingTimeFrom.value} - ${shippingTimeTo.value} Business ${selectedTimeUnit.value}';
  }

  String get shippingFeesDisplay {
    return 'Shipping Fees : \$ ${shippingFees.value}';
  }

  // Variant Management
  void addVariant(VariantData variant) {
    variants.add(variant);
    // Set mainattributeId from the first variant's primary attribute
    if (mainattributeId.isEmpty) {
      mainattributeId = variant.primaryAttribute.id.toString();
    }
    update();
  }

  void removeVariant(VariantData variant) {
    variants.remove(variant);
  }

  void updateVariant(int index, VariantData variant) {
    if (index >= 0 && index < variants.length) {
      variants[index] = variant;
      if (mainattributeId.isEmpty) {
        mainattributeId = variant.primaryAttribute.id.toString();
      }
      update();
    }
  }

  List<Map<String, dynamic>> getVariantsJson() {
    return variants.map((variant) => variant.toJson()).toList();
  }

  void setProductType(String type) {
    selectedProductType.value = type;
  }

  // Media Management
  bool get hasThumbnail => thumbnailFile != null || thumbnailUrl != null;
  bool get hasVideo => videoFile != null || videoUrl != null;
  bool get hasGalleryImages =>
      galleryFiles.isNotEmpty || galleryUrls.isNotEmpty;

  Future<void> pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        videoFile = file;
        videoUrl = null;
        videoId = null;
        _videoUploadCancelled = false;
        isVideoUploading.value = true;
        update();

        final List<String> mediaIds = await _uploadMedia([file]);

        // Check if cancelled during upload
        if (_videoUploadCancelled) {
          isVideoUploading.value = false;
          return;
        }

        if (mediaIds.isNotEmpty) {
          videoId = mediaIds.first;
        }
        isVideoUploading.value = false;
        update();
      }
    } catch (e) {
      isVideoUploading.value = false;
      _showErrorSnackbar('Video Selection Error', e.toString());
    }
  }

  Future<void> pickImage(ImageSource source, {bool isGallery = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File originalFile = File(pickedFile.path);
        final File? croppedFile = await _cropImage(originalFile);
        final File finalFile = croppedFile ?? originalFile;

        if (isGallery) {
          final int galleryIndex = galleryFiles.length;
          galleryFiles.add(finalFile);
          galleryUploadingStates.add(true);
          _galleryUploadCancelled.add(false);
          update();

          _uploadMedia([finalFile])
              .then((mediaIds) {
                // Check if cancelled
                if (galleryIndex < _galleryUploadCancelled.length &&
                    _galleryUploadCancelled[galleryIndex]) {
                  if (galleryIndex < galleryUploadingStates.length) {
                    galleryUploadingStates[galleryIndex] = false;
                  }
                  return;
                }

                if (mediaIds.isNotEmpty) {
                  galleryIds.add(mediaIds.first);
                }
                if (galleryIndex < galleryUploadingStates.length) {
                  galleryUploadingStates[galleryIndex] = false;
                }
                update();
              })
              .catchError((e) {
                if (galleryIndex < galleryUploadingStates.length) {
                  galleryUploadingStates[galleryIndex] = false;
                }
                update();
              });
        } else {
          thumbnailFile = finalFile;
          thumbnailUrl = null;
          thumbnailId = null;
          _thumbnailUploadCancelled = false;
          isThumbnailUploading.value = true;
          update();

          _uploadMedia([finalFile])
              .then((mediaIds) {
                // Check if cancelled
                if (_thumbnailUploadCancelled) {
                  isThumbnailUploading.value = false;
                  return;
                }

                if (mediaIds.isNotEmpty) {
                  thumbnailId = mediaIds.first;
                }
                isThumbnailUploading.value = false;
                update();
              })
              .catchError((e) {
                isThumbnailUploading.value = false;
                update();
              });
        }
        update();
      }
    } catch (e) {
      _showErrorSnackbar('Image Selection Error', e.toString());
    }
  }

  Future<void> pickImageFromCamera({bool isGallery = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File originalFile = File(pickedFile.path);
        final File? croppedFile = await _cropImage(originalFile);
        final File finalFile = croppedFile ?? originalFile;

        if (isGallery) {
          final int galleryIndex = galleryFiles.length;
          galleryFiles.add(finalFile);
          galleryUploadingStates.add(true);
          _galleryUploadCancelled.add(false);
          update();

          _uploadMedia([finalFile])
              .then((mediaIds) {
                // Check if cancelled
                if (galleryIndex < _galleryUploadCancelled.length &&
                    _galleryUploadCancelled[galleryIndex]) {
                  if (galleryIndex < galleryUploadingStates.length) {
                    galleryUploadingStates[galleryIndex] = false;
                  }
                  return;
                }

                if (mediaIds.isNotEmpty) {
                  galleryIds.add(mediaIds.first);
                }
                if (galleryIndex < galleryUploadingStates.length) {
                  galleryUploadingStates[galleryIndex] = false;
                }
                update();
              })
              .catchError((e) {
                if (galleryIndex < galleryUploadingStates.length) {
                  galleryUploadingStates[galleryIndex] = false;
                }
                update();
              });
        } else {
          thumbnailFile = finalFile;
          thumbnailUrl = null;
          thumbnailId = null;
          _thumbnailUploadCancelled = false;
          isThumbnailUploading.value = true;
          update();

          _uploadMedia([finalFile])
              .then((mediaIds) {
                // Check if cancelled
                if (_thumbnailUploadCancelled) {
                  isThumbnailUploading.value = false;
                  return;
                }

                if (mediaIds.isNotEmpty) {
                  thumbnailId = mediaIds.first;
                }
                isThumbnailUploading.value = false;
                update();
              })
              .catchError((e) {
                isThumbnailUploading.value = false;
                update();
              });
        }
        update();
      }
    } catch (e) {
      _showErrorSnackbar('Camera Error', e.toString());
    }
  }

  Future<void> showImageSourceDialog({bool isGallery = false}) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery, isGallery: isGallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImageFromCamera(isGallery: isGallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void removeGalleryImage(int index, {bool isUrl = false}) {
    try {
      if (isUrl && index < galleryUrls.length) {
        galleryUrls.removeAt(index);
        if (index < galleryIds.length) {
          galleryIds.removeAt(index);
        }
      } else if (!isUrl && index < galleryFiles.length) {
        // Cancel upload if in progress
        if (index < _galleryUploadCancelled.length) {
          _galleryUploadCancelled[index] = true;
        }
        if (index < galleryUploadingStates.length) {
          galleryUploadingStates.removeAt(index);
        }
        if (index < _galleryUploadCancelled.length) {
          _galleryUploadCancelled.removeAt(index);
        }
        galleryFiles.removeAt(index);
        if (index < galleryIds.length) {
          galleryIds.removeAt(index);
        }
      }
      update();
    } catch (e) {
      _showErrorSnackbar('Remove Image Error', e.toString());
    }
  }

  void removeThumbnail() {
    // Cancel upload if in progress
    _thumbnailUploadCancelled = true;
    isThumbnailUploading.value = false;
    thumbnailFile = null;
    thumbnailUrl = null;
    thumbnailId = null;
    update();
  }

  void removeVideo() {
    // Cancel upload if in progress
    _videoUploadCancelled = true;
    isVideoUploading.value = false;
    videoFile = null;
    videoUrl = null;
    videoId = null;
    update();
  }

  String convertToHtml(String text) {
    return "<p>$text</p>";
  }

  // Product Operations
  Future<bool> saveProduct({
    required String name,
    required String productType,
    String? productGroup,
    String? description,
    int? stock,
    String? thumbnailId,
    String? videoId,
    bool? isFeatured,
    bool? isDeal,
    double? price,
    double? salePrice,
    double? reservedPrice,
    DateTime? auctionStartTime,
    DateTime? auctionEndTime,
    String? status,
    List<String>? galleryIds,
    List<String>? categoryIds,
    List<int>? tagIds,
    Map<String, dynamic>? meta,
  }) async {
    if (isLoading.value) return false;

    // Check if any media is still uploading
    if (isAnyMediaUploading) {
      _showWarningSnackbar(
        'Upload in Progress',
        'Please wait for media uploads to complete before saving.',
      );
      return false;
    }

    isLoading.value = true;

    try {
      bool result;
      if (isEditMode.value) {
        result = await updateProduct(
          id: editProduct?.id,
          name: name,
          productType: productType,
          productGroup: productGroup,
          description: description,
          stock: stock,
          thumbnailId: thumbnailId ?? this.thumbnailId,
          videoId: videoId,
          isFeatured: isFeatured,
          isDeal: isDeal,
          price: price,
          salePrice: salePrice,
          reservedPrice: reservedPrice,
          auctionStartTime: auctionStartTime,
          auctionEndTime: auctionEndTime,
          status: status,
          galleryIds: galleryIds,
          categoryIds: categoryIds,
          tagIds: tagIds,
          meta: meta,
        );
      } else {
        result = await insertProduct(
          name: name,
          productType: productType,
          productGroup: productGroup,
          description: description,
          stock: stock,
          thumbnailId: thumbnailId ?? this.thumbnailId!,
          videoId: videoId,
          isFeatured: isFeatured,
          isDeal: isDeal,
          price: price,
          salePrice: salePrice,
          reservedPrice: reservedPrice,
          auctionStartTime: auctionStartTime,
          auctionEndTime: auctionEndTime,
          status: status,
          galleryIds: galleryIds,
          categoryIds: categoryIds,
          tagIds: tagIds,
          meta: meta,
        );
      }

      if (result) {
        _showSuccessSnackbar(
          'Success',
          isEditMode.value
              ? 'Product updated successfully'
              : 'Product created successfully',
        );
      }

      return result;
    } catch (e) {
      _showErrorSnackbar('Operation Failed', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> insertProduct({
    required String name,
    required String productType,
    String? productGroup,
    String? description,
    int? stock,
    required String thumbnailId,
    String? videoId,
    bool? isFeatured,
    bool? isDeal,
    double? price,
    double? salePrice,
    double? reservedPrice,
    DateTime? auctionStartTime,
    DateTime? auctionEndTime,
    String? status,
    List<String>? galleryIds,
    List<String>? categoryIds,
    List<int>? tagIds,
    Map<String, dynamic>? meta,
  }) async {
    try {
      // final url = Uri.parse(_insertApiUrl);
      final request = http.MultipartRequest('POST', Uri.parse(_insertApiUrl));

      // Add basic product fields
      request.fields['name'] = name.isNotEmpty ? name : 'ab';
      request.fields['product_group'] =
          (productGroup?.isNotEmpty == true) ? productGroup! : 'car';
      // Convert product type: handles both 'Variants'/'variable' -> 'variable', otherwise 'simple'
      final String lowerProductType = productType.toLowerCase();
      final String apiProductType =
          (lowerProductType == 'variants' || lowerProductType == 'variable')
              ? 'variable'
              : 'simple';
      request.fields['product_type'] = apiProductType;
      // If description provided already contains HTML, use as is; otherwise wrap
      final String descValue =
          (description != null && description.trim().isNotEmpty)
              ? description
              : '<p></p>';
      request.fields['description'] = descValue;
      request.fields['stock'] = (stock ?? 1).toString();
      request.fields['is_featured'] = (isFeatured == true) ? '1' : '0';
      request.fields['is_deal'] = (isDeal == true) ? '1' : '0';
      request.fields['thumbnail_id'] = thumbnailId;
      request.fields['price'] = (price ?? 1010).toString();
      request.fields['status'] = 'active';
      if (salePrice != null) {
        request.fields['sale_price'] = salePrice.toString();
      }
      // Video ID
      if ((videoId ?? '').isNotEmpty) {
        request.fields['video_id'] = videoId.toString();
      }

      // Gallery IDs (array format)
      if (galleryIds != null && galleryIds.isNotEmpty) {
        for (var i = 0; i < galleryIds.length; i++) {
          request.fields['gallery[$i]'] = galleryIds[i];
        }
      } else if (this.galleryIds.isNotEmpty) {
        for (var i = 0; i < this.galleryIds.length; i++) {
          request.fields['gallery[$i]'] = this.galleryIds[i];
        }
      }

      if (mainattributeId.isNotEmpty) {
        request.fields['main_attribute_id'] = mainattributeId;
      }

      // Categories
      if (categoryIds != null && categoryIds.isNotEmpty) {
        request.fields['categories[0]'] = categoryIds.first;
      } else {
        // Default category for car
        request.fields['categories[0]'] =
            'd732ac28-fb4c-49cd-80d2-8ae590fa0dab';
      }

      // Year (attribute id or taxonomy id as per API contract)
      request.fields['year'] =
          selectedCarYearId ?? 'effd345e-64b5-477e-a697-aa685dfd0715';

      // Add categories (array format)

      // Add more categories if needed:
      // request.fields['categories[1]'] = 'another-category-id';

      // Add variations for variable products
      for (var i = 0; i < variants.length; i++) {
        request.fields['variations[$i]'] = jsonEncode(variants[i].toJson());
      }

      // Add meta fields (nested array format)
      request.fields['meta[][hide_price]'] = '0';
      request.fields['meta[][country_id]'] =
          '89b79d20-36e8-4619-8d39-681450cb1311';
      request.fields['meta[][state_id]'] =
          'e03f9639-b93d-49f5-a518-5b08bbd578b8';
      request.fields['meta[][city_id]'] =
          'd97de179-35cc-413c-9c36-88f7a6aa16b9';
      request.fields['meta[][is_sold]'] = '0';
      request.fields['meta[][shipping_company]'] = 'Standard Shipping';
      request.fields['meta[][shipping_time_from]'] =
          (shippingTimeFrom.value.isNotEmpty ? shippingTimeFrom.value : '3');
      request.fields['meta[][shipping_time_to]'] =
          (shippingTimeTo.value.isNotEmpty ? shippingTimeTo.value : '4');
      request.fields['meta[][shipping_time_unit]'] =
          (selectedTimeUnit.value.isNotEmpty ? selectedTimeUnit.value : 'Days');
      request.fields['meta[][shipping_fees]'] =
          (shippingFees.value.isNotEmpty ? shippingFees.value : '3');
      request.fields['meta[][mileage]'] =
          mileageController.text.isNotEmpty ? mileageController.text : '100000';
      request.fields['meta[][transmission]'] =
          selectedTransmission.value.isNotEmpty
              ? selectedTransmission.value
              : 'Automatic';
      request.fields['meta[][fuel_type]'] =
          selectedFuelType.value.isNotEmpty ? selectedFuelType.value : 'Diesel';
      request.fields['meta[][engine]'] =
          engineCCController.text.isNotEmpty ? engineCCController.text : '4996';
      request.fields['meta[][upc_code]'] = upcNameController.text;
      request.fields['meta[][product_notice]'] = shiPPingNoticeController.text;

      request.headers['Content-Type'] =
          'multipart/form-data; boundary=----WebKitFormBoundaryloiQQIBhpOS9GzyB';
      request.headers['x-request-from'] = 'Dashboard';
      request.headers['shop-id'] =
          AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '';

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _showErrorSnackbar('Insert Failed', responseBody);
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Insert Error', e.toString());
      return false;
    }
  }

  Future<bool> updateProduct({
    required dynamic id,
    required String name,
    required String productType,
    String? productGroup,
    String? description,
    int? stock,
    String? thumbnailId,
    String? videoId,
    bool? isFeatured,
    bool? isDeal,
    double? price,
    double? salePrice,
    double? reservedPrice,
    DateTime? auctionStartTime,
    DateTime? auctionEndTime,
    String? status,
    List<String>? galleryIds,
    List<String>? categoryIds,
    List<int>? tagIds,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final url = Uri.parse('$_updateApiUrl/$id/update');

      // Convert product type: handles both 'Variants'/'variable' -> 'variable', otherwise 'simple'
      final String lowerProductType = productType.toLowerCase();
      final String apiProductType =
          (lowerProductType == 'variants' || lowerProductType == 'variable')
              ? 'variable'
              : 'simple';

      // Prepare JSON data matching the expected format
      final Map<String, dynamic> requestBody = {
        'name': name.isNotEmpty ? name : 'ab',
        'product_type': apiProductType,
        'description':
            (description != null && description.trim().isNotEmpty)
                ? description
                : '<p>a test of new car</p>',
        'stock': (stock ?? 1).toString(),
        'is_featured': (isFeatured == true) ? '1' : '0',
        'is_deal': (isDeal == true) ? '1' : '0',
        'price': (price ?? 1010).toString(),
        'status': status ?? 'active',
        if (salePrice != null) 'sale_price': salePrice.toString(),
      };

      // Add optional fields
      requestBody['product_group'] =
          (productGroup != null && productGroup.isNotEmpty)
              ? productGroup
              : 'car';

      if (thumbnailId != null && thumbnailId.isNotEmpty) {
        requestBody['thumbnail_id'] = thumbnailId;
      }

      // Video ID
      if (videoId != null && videoId.isNotEmpty) {
        requestBody['video_id'] = videoId;
      } else if (this.videoId != null && this.videoId!.isNotEmpty) {
        requestBody['video_id'] = this.videoId;
      }

      if (mainattributeId.isNotEmpty) {
        requestBody['main_attribute_id'] = mainattributeId;
      }

      // Add categories as array (matches expected format)
      if (categoryIds != null && categoryIds.isNotEmpty) {
        requestBody['categories'] = categoryIds;
      } else {
        requestBody['categories'] = ['d732ac28-fb4c-49cd-80d2-8ae590fa0dab'];
      }

      // Year
      requestBody['year'] =
          selectedCarYearId ?? 'effd345e-64b5-477e-a697-aa685dfd0715';

      // Add variations as array of objects
      if (variants.isNotEmpty) {
        requestBody['variations'] =
            variants.map((variant) => variant.toJson()).toList();
      }

      // Add gallery as array (note: "gallery" not "gallery_ids")
      if (galleryIds != null && galleryIds.isNotEmpty) {
        requestBody['gallery'] = galleryIds;
      } else if (this.galleryIds.isNotEmpty) {
        requestBody['gallery'] = this.galleryIds;
      }

      // Add tag IDs if provided
      if (tagIds != null && tagIds.isNotEmpty) {
        requestBody['tag_ids'] = tagIds;
      }

      // Add auction fields if provided
      if (reservedPrice != null) {
        requestBody['reserved_price'] = reservedPrice.toString();
      }
      if (auctionStartTime != null) {
        requestBody['auction_start_time'] = auctionStartTime.toIso8601String();
      }
      if (auctionEndTime != null) {
        requestBody['auction_end_time'] = auctionEndTime.toIso8601String();
      }

      // Add meta data as array of objects (matches expected format)
      final List<Map<String, String>> metaArray = [];

      metaArray.add({'hide_price': '0'});
      metaArray.add({'country_id': '89b79d20-36e8-4619-8d39-681450cb1311'});
      metaArray.add({'state_id': 'e03f9639-b93d-49f5-a518-5b08bbd578b8'});
      metaArray.add({'city_id': 'd97de179-35cc-413c-9c36-88f7a6aa16b9'});
      metaArray.add({'is_sold': '0'});
      metaArray.add({'shipping_company': 'Standard Shipping'});
      metaArray.add({
        'shipping_time_from':
            (shippingTimeFrom.value.isNotEmpty ? shippingTimeFrom.value : '3'),
      });
      metaArray.add({
        'shipping_time_to':
            (shippingTimeTo.value.isNotEmpty ? shippingTimeTo.value : '4'),
      });
      metaArray.add({
        'shipping_time_unit':
            (selectedTimeUnit.value.isNotEmpty
                ? selectedTimeUnit.value
                : 'Days'),
      });
      metaArray.add({
        'shipping_fees':
            (shippingFees.value.isNotEmpty ? shippingFees.value : '3'),
      });
      metaArray.add({
        'mileage':
            mileageController.text.isNotEmpty
                ? mileageController.text
                : '100000',
      });
      metaArray.add({
        'transmission':
            (selectedTransmission.value.isNotEmpty
                ? selectedTransmission.value
                : 'Automatic'),
      });
      metaArray.add({
        'fuel_type':
            (selectedFuelType.value.isNotEmpty
                ? selectedFuelType.value
                : 'Diesel'),
      });
      metaArray.add({
        'engine':
            (engineCCController.text.isNotEmpty
                ? engineCCController.text
                : '4996'),
      });

      // Add any additional meta data passed as parameter
      if (meta != null) {
        meta.forEach((key, value) {
          metaArray.add({key: value.toString()});
        });
      }

      requestBody['meta'] = metaArray;

      // Prepare headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Request-From': 'Dashboard',
        'dashboard-view': 'admin',
        'Shop-Id': _shopId,
        'User-Id': AuthService.instance.authCustomer!.user!.id.toString(),
        'Origin': 'https://dashboard.tjara.com',
        'Referer': 'https://dashboard.tjara.com/',
      };

      // Add authorization header if available

      // Example: if (AuthService.instance.authToken != null) {
      //   headers['Authorization'] = 'Bearer ${AuthService.instance.authToken}';
      // }
      // OR if you have it stored elsewhere:
      // headers['Authorization'] = 'Bearer YOUR_TOKEN_HERE';

      // Make the HTTP PUT request
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optionally parse response to check for success message
        try {
          final responseData = jsonDecode(response.body);

          // Check if the response contains success indication
          if (responseData is Map && responseData.containsKey('success')) {
            return responseData['success'] == true;
          }
        } catch (e) {
          print('Could not parse response: $e');
        }

        return true;
      } else {
        String errorMessage = response.body;
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Use raw response body if JSON parsing fails
        }

        _showErrorSnackbar('Update Failed', errorMessage);
        return false;
      }
    } catch (e) {
      print('Update Error: $e');
      _showErrorSnackbar('Update Error', e.toString());
      return false;
    }
  }

  Future<bool> duplicateProduct(AdminProducts mainproduct) async {
    if (isLoading.value) return false;

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(
          'https://api.libanbuy.com/api/products/${mainproduct.id}/duplicate',
        ),
        headers: _getCommonHeaders(),
      );

      final bool success =
          response.statusCode == 200 || response.statusCode == 201;

      if (success) {
        _showSuccessSnackbar('Success', 'Product duplicated successfully');
        return true;
      } else {
        _showErrorSnackbar('Duplicate Failed', response.body);
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Duplicate Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
