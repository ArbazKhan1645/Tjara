// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/coupens/coupens_model.dart';
import 'package:tjara/app/models/products/products_model.dart';
import 'package:tjara/app/modules/modules_admin/coupens/edit_model.dart';
import 'package:tjara/app/modules/modules_admin/coupens/edit_service.dart';

class EditCouponController extends GetxController {
  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountValueController = TextEditingController();
  final minimumAmountController = TextEditingController();
  final maximumDiscountController = TextEditingController();
  final usageLimitController = TextEditingController();
  final usageLimitPerUserController = TextEditingController();
  final customCodeController = TextEditingController();
  final codeCountController = TextEditingController(text: '1');
  final shopSearchController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable variables
  final RxString selectedCouponType = 'discount'.obs;
  final RxString selectedDiscountType = 'percentage'.obs;
  final RxBool isGlobal = true.obs;
  final RxString selectedStatus = 'active'.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);

  // New feature: allow on discounted items
  final RxBool allowOnDiscountedItems = false.obs;
  final RxString discountPriceMode = 'original'.obs;

  // Code generation
  final RxBool isAutoGenerate = true.obs;
  final RxList<String> generatedCodes = <String>[].obs;

  // Shop selection
  final RxList<ShopShop> availableShops = <ShopShop>[].obs;
  final RxList<ShopShop> selectedShops = <ShopShop>[].obs;
  final RxBool isLoadingShops = false.obs;
  final RxString shopSearchQuery = ''.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isCreatingCoupon = false.obs;

  // Edit mode
  final Rxn<Coupon> editingCoupon = Rxn<Coupon>();
  bool get isEditMode => editingCoupon.value != null;

  @override
  void onInit() {
    super.onInit();
    _initializeDates();
    _setupShopSearch();
    _handleArguments();
  }

  void _handleArguments() {
    final args = Get.arguments;
    if (args != null && args is Coupon) {
      _loadCouponForEdit(args);
    }
  }

  void _loadCouponForEdit(Coupon coupon) {
    editingCoupon.value = coupon;

    nameController.text = coupon.name;
    descriptionController.text = coupon.description ?? '';
    selectedCouponType.value = coupon.couponType;
    selectedDiscountType.value = coupon.discountType;
    discountValueController.text = coupon.discountValue;
    startDate.value = coupon.startDate;
    expiryDate.value = coupon.expiryDate;
    isGlobal.value = coupon.isGlobal;
    selectedStatus.value = coupon.status;

    // New fields
    allowOnDiscountedItems.value = coupon.allowOnDiscountedItems;
    if (coupon.discountPriceMode != null) {
      discountPriceMode.value = coupon.discountPriceMode!;
    }

    if (coupon.minimumAmount != null && coupon.minimumAmount!.isNotEmpty) {
      minimumAmountController.text = coupon.minimumAmount!;
    }
    if (coupon.maximumDiscount != null && coupon.maximumDiscount!.isNotEmpty) {
      maximumDiscountController.text = coupon.maximumDiscount!;
    }
    if (coupon.usageLimit != null) {
      usageLimitController.text = coupon.usageLimit.toString();
    }
    if (coupon.usageLimitPerUser != null) {
      usageLimitPerUserController.text = coupon.usageLimitPerUser.toString();
    }

    for (var code in coupon.codes) {
      generatedCodes.add(code.code);
    }

    if (!coupon.isGlobal && coupon.shops.isNotEmpty) {
      fetchShops();
    }
  }

  void _initializeDates() {
    final now = DateTime.now();
    startDate.value = now;
    expiryDate.value = now.add(const Duration(days: 30));
  }

  void _setupShopSearch() {
    shopSearchController.addListener(() {
      if (shopSearchQuery.value != shopSearchController.text) {
        shopSearchQuery.value = shopSearchController.text;
        _debounceShopSearch();
      }
    });
  }

  Timer? _searchTimer;
  void _debounceShopSearch() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchShops(shopSearchController.text);
    });
  }

  Future<void> fetchShops([String search = '']) async {
    try {
      isLoadingShops.value = true;
      final response = await CouponEditService.fetchShops(search: search);
      availableShops.value = response.data;
    } catch (e) {
      _showError('Failed to fetch shops: ${e.toString()}');
    } finally {
      isLoadingShops.value = false;
    }
  }

  void toggleShopSelection(ShopShop shop) {
    final index = selectedShops.indexWhere((s) => s.id == shop.id);
    if (index >= 0) {
      selectedShops.removeAt(index);
    } else {
      selectedShops.add(shop);
    }
  }

  bool isShopSelected(ShopShop shop) {
    return selectedShops.any((s) => s.id == shop.id);
  }

  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.teal),
            ),
            child: child!,
          ),
    );

    if (picked != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder:
            (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: Colors.teal),
              ),
              child: child!,
            ),
      );

      if (time != null) {
        startDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        if (expiryDate.value != null &&
            expiryDate.value!.isBefore(startDate.value!)) {
          expiryDate.value = startDate.value!.add(const Duration(days: 1));
        }
      }
    }
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    final minDate =
        startDate.value?.add(const Duration(days: 1)) ??
        DateTime.now().add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate.value ?? minDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.teal),
            ),
            child: child!,
          ),
    );

    if (picked != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder:
            (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: Colors.teal),
              ),
              child: child!,
            ),
      );

      if (time != null) {
        expiryDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
      }
    }
  }

  void generateCodes() {
    if (!isAutoGenerate.value) return;

    final count = int.tryParse(codeCountController.text) ?? 1;
    if (count <= 0 || count > 100) {
      _showError('Please enter a valid count between 1 and 100');
      return;
    }

    generatedCodes.clear();
    final random = Random();

    for (int i = 0; i < count; i++) {
      String code;
      do {
        code = 'CODE${random.nextInt(90000) + 10000}';
      } while (generatedCodes.contains(code));

      generatedCodes.add(code);
    }
  }

  void addCustomCode() {
    final code = customCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showError('Please enter a code');
      return;
    }

    if (!RegExp(r'^[A-Z0-9-]+$').hasMatch(code)) {
      _showError('Code can only contain letters, numbers, and hyphens');
      return;
    }

    if (code.length < 3 || code.length > 20) {
      _showError('Code must be between 3 and 20 characters');
      return;
    }

    if (generatedCodes.contains(code)) {
      _showError('Code already exists');
      return;
    }

    generatedCodes.add(code);
    customCodeController.clear();
  }

  void removeCode(String code) {
    generatedCodes.remove(code);
  }

  // Validation
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateDiscountValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Discount value is required';
    }

    final doubleValue = double.tryParse(value);
    if (doubleValue == null || doubleValue <= 0) {
      return 'Please enter a valid discount value';
    }

    if (selectedDiscountType.value == 'percentage' && doubleValue > 100) {
      return 'Percentage cannot be greater than 100';
    }

    return null;
  }

  String? validateNumeric(
    String? value,
    String fieldName, {
    bool required = false,
  }) {
    if (!required && (value == null || value.trim().isEmpty)) {
      return null;
    }

    if (required && (value == null || value.trim().isEmpty)) {
      return '$fieldName is required';
    }

    final numValue = double.tryParse(value!);
    if (numValue == null || numValue < 0) {
      return 'Please enter a valid $fieldName';
    }

    return null;
  }

  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (startDate.value == null) {
      _showError('Please select start date');
      return false;
    }

    if (expiryDate.value == null) {
      _showError('Please select expiry date');
      return false;
    }

    if (expiryDate.value!.isBefore(startDate.value!)) {
      _showError('Expiry date must be after start date');
      return false;
    }

    if (!isGlobal.value && selectedShops.isEmpty) {
      _showError('Please select at least one shop');
      return false;
    }

    if (!isEditMode && generatedCodes.isEmpty) {
      _showError('Please generate or add at least one coupon code');
      return false;
    }

    return true;
  }

  Future<void> createCoupon() async {
    if (!_validateForm()) return;

    try {
      isCreatingCoupon.value = true;

      if (isEditMode) {
        final existingCodes = editingCoupon.value!.codes.map((c) => c.code).toList();

        final request = CouponInsertRequest(
          name: nameController.text.trim(),
          description:
              descriptionController.text.trim().isNotEmpty
                  ? descriptionController.text.trim()
                  : null,
          couponType: selectedCouponType.value,
          discountType:
              selectedCouponType.value == 'discount'
                  ? selectedDiscountType.value
                  : null,
          discountValue: double.parse(discountValueController.text),
          startDate: startDate.value!,
          expiryDate: expiryDate.value!,
          isGlobal: isGlobal.value,
          shopIds:
              isGlobal.value
                  ? null
                  : selectedShops.map((s) => s.id ?? '').toList(),
          codes: existingCodes,
          usageLimit:
              usageLimitController.text.trim().isNotEmpty
                  ? int.parse(usageLimitController.text)
                  : null,
          usageLimitPerUser:
              usageLimitPerUserController.text.trim().isNotEmpty
                  ? int.parse(usageLimitPerUserController.text)
                  : null,
          minimumAmount:
              minimumAmountController.text.trim().isNotEmpty
                  ? double.parse(minimumAmountController.text)
                  : null,
          maximumDiscount:
              maximumDiscountController.text.trim().isNotEmpty
                  ? double.parse(maximumDiscountController.text)
                  : null,
          status: selectedStatus.value,
          allowOnDiscountedItems: allowOnDiscountedItems.value,
          discountPriceMode:
              allowOnDiscountedItems.value ? discountPriceMode.value : null,
        );

        await CouponEditService.updateCoupon(editingCoupon.value!.id, request.toJson());

        Get.back(result: true);
        _showSuccess('Coupon updated successfully');
      } else {
        final request = CouponInsertRequest(
          name: nameController.text.trim(),
          description:
              descriptionController.text.trim().isNotEmpty
                  ? descriptionController.text.trim()
                  : null,
          couponType: selectedCouponType.value,
          discountType:
              selectedCouponType.value == 'discount'
                  ? selectedDiscountType.value
                  : null,
          discountValue: double.parse(discountValueController.text),
          startDate: startDate.value!,
          expiryDate: expiryDate.value!,
          isGlobal: isGlobal.value,
          shopIds:
              isGlobal.value
                  ? null
                  : selectedShops.map((s) => s.id ?? '').toList(),
          codes: generatedCodes.toList(),
          usageLimit:
              usageLimitController.text.trim().isNotEmpty
                  ? int.parse(usageLimitController.text)
                  : null,
          usageLimitPerUser:
              usageLimitPerUserController.text.trim().isNotEmpty
                  ? int.parse(usageLimitPerUserController.text)
                  : null,
          minimumAmount:
              minimumAmountController.text.trim().isNotEmpty
                  ? double.parse(minimumAmountController.text)
                  : null,
          maximumDiscount:
              maximumDiscountController.text.trim().isNotEmpty
                  ? double.parse(maximumDiscountController.text)
                  : null,
          status: selectedStatus.value,

          allowOnDiscountedItems: allowOnDiscountedItems.value,
          discountPriceMode:
              allowOnDiscountedItems.value ? discountPriceMode.value : null,
        );

        await CouponEditService.insertCoupon(request);

        _resetForm();
        Get.back(result: true);

        _showSuccess('Coupon created successfully');
      }
    } catch (e) {
      if (e is ApiException) {
        _showError(e.message);
      } else if (e is FormatException) {
        _showError('Invalid data format. Please check your inputs.');
      } else if (e is SocketException) {
        _showError('No internet connection. Please check your network.');
      } else {
        _showError(
          'Failed to ${isEditMode ? "update" : "create"} coupon. Please try again.',
        );
      }
    } finally {
      isCreatingCoupon.value = false;
    }
  }

  void _resetForm() {
    nameController.clear();
    descriptionController.clear();
    discountValueController.clear();
    minimumAmountController.clear();
    maximumDiscountController.clear();
    usageLimitController.clear();
    usageLimitPerUserController.clear();
    customCodeController.clear();
    codeCountController.text = '1';
    shopSearchController.clear();

    selectedCouponType.value = 'discount';
    selectedDiscountType.value = 'percentage';
    isGlobal.value = true;
    selectedStatus.value = 'active';
    isAutoGenerate.value = true;
    allowOnDiscountedItems.value = false;
    discountPriceMode.value = 'original';

    generatedCodes.clear();
    selectedShops.clear();

    _initializeDates();
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    discountValueController.dispose();
    minimumAmountController.dispose();
    maximumDiscountController.dispose();
    usageLimitController.dispose();
    usageLimitPerUserController.dispose();
    customCodeController.dispose();
    codeCountController.dispose();
    shopSearchController.dispose();
    _searchTimer?.cancel();
    super.onClose();
  }
}
