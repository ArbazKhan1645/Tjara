// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjara/app/models/admin_products_model.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/modules/admin/add_product_admin/widgets/attributes/attributes_manage.dart';
import 'package:tjara/app/repo/network_repository.dart';
import 'package:tjara/main.dart';

class AuctionAddProductAdminController extends GetxController {
  // Add these variables to your controller class
  Rx<DateTime?> selectedStartTime = Rx<DateTime?>(null);
  final salepriceController = TextEditingController();
  Rx<DateTime?> selectedEndTime = Rx<DateTime?>(null);
  TextEditingController selectedStartTimeController = TextEditingController();
  TextEditingController selectedEndTimeController = TextEditingController();
  RxString timeError = RxString('');

  // Add these methods to your controller class
  Future<void> selectStartTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)), // Default to tomorrow
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        // Validate that start time is in the future
        if (selectedDateTime.isBefore(now)) {
          timeError.value = 'Start time must be in the future';
        } else {
          selectedStartTime.value = selectedDateTime;
          selectedStartTimeController.text = selectedDateTime.toString();
          timeError.value = '';

          // If end time is already selected and is before new start time, clear it
          if (selectedEndTime.value != null &&
              selectedEndTime.value!.isBefore(selectedDateTime)) {
            selectedEndTime.value = null;
            timeError.value =
                'Please select a new end time after the start time';
          }
        }
      }
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    if (selectedStartTime.value == null) {
      timeError.value = 'Please select start time first';
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartTime.value!.add(const Duration(days: 1)),
      firstDate: selectedStartTime.value!,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedStartTime.value!),
      );

      if (time != null) {
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        // Validate that end time is after start time
        if (selectedDateTime.isBefore(selectedStartTime.value!)) {
          timeError.value = 'End time must be after start time';
        } else {
          selectedEndTime.value = selectedDateTime;
          selectedEndTimeController.text = selectedEndTime.value.toString();
          timeError.value = '';
        }
      }
    }
  }

  // Helper method to format date for display
  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not selected';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static const String _insertApiUrl =
      'https://api.libanbuy.com/api/products/insert';
  static const String _updateApiUrl = 'https://api.libanbuy.com/api/products';
  static const String _shopId = '0000c539-9857-3456-bc53-2bbdc1474f1a';
  static const String _requestFromHeader = 'Application';

  // Observable variables
  var isExpanded = true.obs;
  var selectedShippingCompany = 'ORIENT Shipping co'.obs;
  var shippingTimeFrom = '3'.obs;
  var shippingTimeTo = '4'.obs;
  var selectedTimeUnit = 'days'.obs;
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
  final List<String> timeUnits = ['days', 'weeks', 'months'];
  final List<String> productTypes = ['Simple', 'Variants'];

  // Controllers
  final productNameController = TextEditingController();
  final upcNameController = TextEditingController();
  final shiPPingNoticeController = TextEditingController();
  final productdescriptionController = TextEditingController();
  final skuController = TextEditingController();
  final priceController = TextEditingController();
  final bidsIncrementBy = TextEditingController()..text = '0';

  final inputProductStock = TextEditingController(text: '1');

  // Variants
  final RxList<VariantData> variants = <VariantData>[].obs;
  String mainattributeId = '';

  // Edit mode variables
  AdminProducts? editProduct;
  ProductAttributeItems? selectedItem;

  // Product category selection
  String? selectedCategoryId;
  String? selectedCategoryName;

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

  // Repository
  final NetworkRepository _repository = NetworkRepository();

  // Singleton access
  static AuctionAddProductAdminController get instance =>
      Get.find<AuctionAddProductAdminController>();

  @override
  void onInit() {
    super.onInit();
    // Ensure selectedTimeUnit has a valid default value
    if (!timeUnits.contains(selectedTimeUnit.value)) {
      selectedTimeUnit.value = 'days';
    }
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
      salepriceController.text = editProduct?.reservedPrice?.toString() ?? '';
      inputProductStock.text = editProduct?.stock?.toString() ?? '1';
      productdescriptionController.text = (editProduct?.description ?? '')
          .replaceAll(RegExp(r'<[^>]*>'), '');

      // Populate other fields
      selectedProductType.value = 'auction';
      isFeatured.value = editProduct?.isFeatured == 1;
      selectedStatus.value = editProduct?.status == 'active';
      isDeal.value = editProduct?.isDeal == 1;
      enablePurchaseLimit.value = false;

      shiPPingNoticeController.text = editProduct?.meta?.productNotice ?? '';
      upcNameController.text = editProduct?.meta?.upcCode ?? '';

      selectedStartTime.value =
          DateTime.tryParse(editProduct?.auctionStartTime ?? '--') ??
          DateTime.now();
      selectedEndTime.value =
          DateTime.tryParse(editProduct?.auctionEndTime ?? '--') ??
          DateTime.now();
      selectedEndTimeController.text = editProduct?.auctionEndTime ?? '-';
      selectedStartTimeController.text = editProduct?.auctionStartTime ?? '-';

      // Populate shipping info
      shippingTimeFrom.value = editProduct?.meta?.shippingTimeFrom ?? '3';
      shippingTimeTo.value = editProduct?.meta?.shippingTimeTo ?? '4';
      final String timeUnit =
          editProduct?.meta?.shippingTimeUnit?.toLowerCase() ?? 'days';
      selectedTimeUnit.value = timeUnits.contains(timeUnit) ? timeUnit : 'days';

      shippingFees.value = editProduct?.meta?.shippingFees?.toString() ?? '3';
      bidsIncrementBy.text =
          editProduct?.meta?.bid_increment_by?.toString() ?? '';
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

      update();
    } catch (e) {
      _showErrorSnackbar('Error loading product data', e.toString());
    }
  }

  // In your _showErrorSnackbar method, add a check for mounted context
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

    // Delay the snackbar until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen) {
        Get.back(); // Close any existing snackbar
      }
      Get.snackbar(
        title,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 4),
      );
    });
  }

  // Similarly for success snackbar
  void _showSuccessSnackbar(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen) {
        Get.back(); // Close any existing snackbar
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 3),
      );
    });
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
    // Validate that the unit exists in our timeUnits list
    if (timeUnits.contains(unit.toLowerCase())) {
      selectedTimeUnit.value = unit.toLowerCase();
    } else {
      // Default to 'days' if invalid unit is provided
      selectedTimeUnit.value = 'days';
    }
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
        update();

        final List<String> mediaIds = await _uploadMedia([file]);
        if (mediaIds.isNotEmpty) {
          videoId = mediaIds.first;
        }
      }
    } catch (e) {
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
          galleryFiles.add(finalFile);
          _uploadMedia([finalFile]).then((mediaIds) {
            if (mediaIds.isNotEmpty) {
              galleryIds.addAll(mediaIds);
            }
          });
        } else {
          thumbnailFile = finalFile;
          thumbnailUrl = null;
          thumbnailId = null;
          _uploadMedia([finalFile]).then((mediaIds) {
            if (mediaIds.isNotEmpty) {
              thumbnailId = mediaIds.first;
            }
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
          galleryFiles.add(finalFile);
          _uploadMedia([finalFile]).then((mediaIds) {
            if (mediaIds.isNotEmpty) {
              galleryIds.addAll(mediaIds);
            }
          });
        } else {
          thumbnailFile = finalFile;
          thumbnailUrl = null;
          thumbnailId = null;
          _uploadMedia([finalFile]).then((mediaIds) {
            if (mediaIds.isNotEmpty) {
              thumbnailId = mediaIds.first;
            }
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
    thumbnailFile = null;
    thumbnailUrl = null;
    thumbnailId = null;
    update();
  }

  void removeVideo() {
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
      request.fields['name'] = name;
      if (productGroup != null) request.fields['product_group'] = productGroup;
      request.fields['product_type'] = 'auction';
      request.fields['description'] = convertToHtml(description ?? '');
      request.fields['stock'] = stock.toString();
      request.fields['is_featured'] = isFeatured == true ? '1' : '0';
      request.fields['is_deal'] = isDeal == true ? '1' : '0';
      request.fields['thumbnail_id'] = thumbnailId;
      request.fields['price'] = (price ?? 0).toString();
      request.fields['status'] = status ?? 'active';
      request.fields['sale_price'] = '0';

      request.fields['reserved_price'] = (salePrice ?? 0).toString();

      request.fields['auction_start_time'] =
          auctionStartTime!.toIso8601String();

      request.fields['auction_end_time'] = auctionEndTime!.toIso8601String();

      if ((galleryIds ?? []).isNotEmpty) {
        request.fields['gallery_ids'] = jsonEncode(galleryIds);
      }

      if ((videoId ?? '').isNotEmpty) {
        request.fields['video_id'] = videoId.toString();
      }

      if (mainattributeId.isNotEmpty) {
        request.fields['main_attribute_id'] = mainattributeId;
      }

      categoryIds?.forEach((ele) {
        request.fields['categories[0]'] = ele;
      });

      // Add meta fields (nested array format)
      request.fields['meta[][is_sold]'] = '0';
      request.fields['meta[][shipping_company]'] =
          selectedShippingCompany.value;
      request.fields['meta[][shipping_time_from]'] = shippingTimeFrom.value;
      request.fields['meta[][shipping_time_to]'] = shippingTimeTo.value;
      request.fields['meta[][shipping_time_unit]'] = selectedTimeUnit.value;
      request.fields['meta[][shipping_fees]'] = shippingFees.value;
      request.fields['meta[][upc_code]'] = upcNameController.text;
      request.fields['meta[][product_notice]'] = shiPPingNoticeController.text;
      request.fields['meta[][bid_increment_by]'] =
          bidsIncrementBy.text.isEmpty ? '0' : bidsIncrementBy.text;

      // Add headers if needed
      request.headers['Authorization'] = 'Bearer your-token-here';
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['x-request-from'] = 'Application';
      request.headers['shop-id'] = '0000c539-9857-3456-bc53-2bbdc1474f1a';

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

      // Prepare JSON data matching the expected format
      final Map<String, dynamic> requestBody = {
        'name': name,
        'product_type': 'auction', // Fixed for auction products
        'description': convertToHtml(description ?? ''),
        'stock':
            (stock ?? 1).toString(), // Keep as string to match expected format
        'is_featured': isFeatured == true ? '1' : '0', // Keep as string
        'is_deal': isDeal == true ? '1' : '0', // Keep as string
        'price': (price ?? 0).toString(), // Keep as string
        'status': status ?? 'active',
        'sale_price': '0', // Always 0 for auction items
      };

      // Add optional fields
      if (productGroup != null && productGroup.isNotEmpty) {
        requestBody['product_group'] = productGroup;
      }

      if (thumbnailId != null && thumbnailId.isNotEmpty) {
        requestBody['thumbnail_id'] = thumbnailId;
      }

      if (videoId != null && videoId.isNotEmpty) {
        requestBody['video_id'] = videoId;
      }

      if (mainattributeId.isNotEmpty) {
        requestBody['main_attribute_id'] = mainattributeId;
      }

      // Add categories as array (matches expected format)
      if (categoryIds != null && categoryIds.isNotEmpty) {
        requestBody['categories'] = categoryIds;
      }

      // Add variations as array of objects (if applicable)
      if (variants.isNotEmpty) {
        requestBody['variations'] =
            variants.map((variant) => variant.toJson()).toList();
      }

      // Add gallery as array (note: "gallery" not "gallery_ids")
      if (galleryIds != null && galleryIds.isNotEmpty) {
        requestBody['gallery'] = galleryIds;
      }

      // Add tag IDs if provided
      if (tagIds != null && tagIds.isNotEmpty) {
        requestBody['tag_ids'] = tagIds;
      }

      // Add auction-specific fields
      if (reservedPrice != null) {
        requestBody['reserved_price'] = reservedPrice.toString();
      } else if (salePrice != null) {
        requestBody['reserved_price'] = salePrice.toString();
      }

      if (auctionStartTime != null) {
        requestBody['auction_start_time'] = auctionStartTime.toIso8601String();
      }

      if (auctionEndTime != null) {
        requestBody['auction_end_time'] = auctionEndTime.toIso8601String();
      }

      // Add meta data as array of objects (matches expected format)
      final List<Map<String, String>> metaArray = [];

      // Add shipping meta data
      metaArray.add({'is_sold': '0'});
      metaArray.add({'shipping_company': selectedShippingCompany.value});
      metaArray.add({'shipping_time_from': shippingTimeFrom.value});
      metaArray.add({'shipping_time_to': shippingTimeTo.value});
      metaArray.add({'shipping_time_unit': selectedTimeUnit.value});
      metaArray.add({'shipping_fees': shippingFees.value});
      metaArray.add({'upc_code': upcNameController.text});
      metaArray.add({'product_notice': shiPPingNoticeController.text});
      metaArray.add({
        'bid_increment_by':
            bidsIncrementBy.text.isEmpty ? '0' : bidsIncrementBy.text,
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
        'X-Request-From':
            'Application', // Changed from 'Dashboard' to match your original
        'Shop-Id': _shopId,
      };

      // Add User-Id if available
      // try {
      //   if (AuthService.instance.authCustomer?.user?.id != null) {
      //     headers['User-Id'] = AuthService.instance.authCustomer!.user!.id.toString();
      //   }
      // } catch (e) {
      //   print('Could not get User-Id: $e');
      // }

      // Add authorization header if available
      // TODO: Replace with your actual auth token getter
      // Example: if (AuthService.instance.authToken != null) {
      //   headers['Authorization'] = 'Bearer ${AuthService.instance.authToken}';
      // }

      // Make the HTTP PUT request
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optionally parse response to check for success message
        try {
          final responseData = jsonDecode(response.body);
          print('Parsed Response: $responseData');

          // Check if the response contains success indication
          if (responseData is Map && responseData.containsKey('success')) {
            return responseData['success'] == true;
          }

          // Also check for data field which might indicate success
          if (responseData is Map && responseData.containsKey('data')) {
            return true;
          }
        } catch (e) {
          print('Could not parse response: $e');
        }

        return true;
      } else {
        String errorMessage = response.body;
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            if (errorData.containsKey('message')) {
              errorMessage = errorData['message'];
            } else if (errorData.containsKey('error')) {
              errorMessage = errorData['error'];
            } else if (errorData.containsKey('errors')) {
              // Handle validation errors
              final errors = errorData['errors'];
              if (errors is Map) {
                final List<String> errorMessages = [];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.map((e) => e.toString()));
                  } else {
                    errorMessages.add(value.toString());
                  }
                });
                errorMessage = errorMessages.join(', ');
              }
            }
          }
        } catch (e) {
          // Use raw response body if JSON parsing fails
          print('Could not parse error response: $e');
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
