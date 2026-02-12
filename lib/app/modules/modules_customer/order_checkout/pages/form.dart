// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/core/widgets/searchable_dropdown.dart';
import 'package:tjara/app/models/cart/cart_model.dart';
import 'package:tjara/app/models/others/country_model.dart';
import 'package:tjara/app/models/others/state_model.dart';
import 'package:tjara/app/modules/authentication_module/screens/contact_us.dart';
import 'package:tjara/app/modules/modules_customer/order_checkout/pages/success.dart';
import 'package:tjara/app/modules/modules_customer/product_detail_screen/screens/product_detail_by_id.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/orders/make_order_service.dart';
import 'package:tjara/app/services/country_state_city_service/country_state_city_service.dart';
import 'package:tjara/app/services/coupon/coupon_service.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/models/others/cities_model.dart';

// Theme Colors - matching cart screen
const Color _primaryColor = Color(0xFFfda730);
const Color _primaryColorDark = Color(0xFFf59e0b);

class FormController extends GetxController {
  // Observable variables for dropdowns
  var selectedCountry = Rxn<Countries>();
  var selectedState = Rxn<States>();
  var selectedCity = Rxn<City>();
  var selectedPaymentOption = "cash-on-delivery".obs;
  var isLoading = false.obs;
  var isLoadingCountries = true.obs;
  var isLoadingStates = false.obs;
  var isLoadingCities = false.obs;
  var couponCode = ''.obs;
  var isApplyingCoupon = false.obs;

  // Coupon state
  var isCouponApplied = false.obs;
  var appliedCouponCode = ''.obs;
  var couponDiscountAmount = 0.0.obs;
  var couponFinalAmount = 0.0.obs;
  var couponMessage = ''.obs;
  var couponUsageId = ''.obs;

  // Lists for dropdown data
  var countries = <Countries>[].obs;
  var states = <States>[].obs;
  var cities = <City>[].obs;

  // Wallet state
  var walletBalance = 0.0.obs;
  var isLoadingWallet = true.obs;
  var walletError = RxnString();
  var walletAmount = 0.0.obs;

  // Error messages
  var countryError = RxnString();
  var stateError = RxnString();
  var cityError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCountries();
    fetchWalletBalance();
  }

  Future<void> loadCountries() async {
    try {
      isLoadingCountries.value = true;
      countryError.value = null;

      if (CountryService.instance.countryList.isNotEmpty) {
        countries.value = CountryService.instance.countryList;
      } else {
        await CountryService.instance.fetchCountries();
        countries.value = CountryService.instance.countryList;
      }
    } catch (e) {
      countryError.value = 'Failed to load countries. Please try again.';
      _showErrorSnackbar('Error', 'Failed to load countries: ${e.toString()}');
    } finally {
      isLoadingCountries.value = false;
    }
  }

  Future<void> onCountryChanged(Countries? country) async {
    if (country == null) return;

    try {
      selectedCountry.value = country;
      selectedState.value = null;
      selectedCity.value = null;
      states.clear();
      cities.clear();
      stateError.value = null;
      cityError.value = null;

      isLoadingStates.value = true;

      await CountryService.instance.fetchStates(country.id.toString());
      states.value = CountryService.instance.stateList;
    } catch (e) {
      stateError.value = 'Failed to load states for ${country.name}';
      _showErrorSnackbar('Error', 'Failed to load states: ${e.toString()}');
    } finally {
      isLoadingStates.value = false;
    }
  }

  Future<void> onStateChanged(States? state) async {
    if (state == null) return;

    try {
      selectedState.value = state;
      selectedCity.value = null;
      cities.clear();
      cityError.value = null;

      isLoadingCities.value = true;

      await CountryService.instance.fetchCities(state.id.toString());
      cities.value = CountryService.instance.cityList;
    } catch (e) {
      cityError.value = 'Failed to load cities for ${state.name}';
      _showErrorSnackbar('Error', 'Failed to load cities: ${e.toString()}');
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onCityChanged(City? city) {
    selectedCity.value = city;
  }

  void onPaymentChanged(String? payment) {
    if (payment != null) {
      selectedPaymentOption.value = payment;
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(10),
    );
  }

  Future<void> retryLoadCountries() async {
    await loadCountries();
  }

  Future<void> retryLoadStates() async {
    if (selectedCountry.value != null) {
      await onCountryChanged(selectedCountry.value);
    }
  }

  Future<void> retryLoadCities() async {
    if (selectedState.value != null) {
      await onStateChanged(selectedState.value);
    }
  }

  Future<void> applyCoupon(double orderAmount, {String? shopId}) async {
    if (couponCode.value.trim().isEmpty) {
      _showErrorSnackbar('Error', 'Please enter a coupon code');
      return;
    }

    isApplyingCoupon.value = true;

    try {
      // Step 1: Validate the coupon first
      final validationResult = await CouponService.validateCoupon(
        code: couponCode.value.trim(),
        orderAmount: orderAmount,
        shopId: shopId,
      );

      if (!validationResult.success || !validationResult.valid) {
        _showErrorSnackbar(
          'Invalid Coupon',
          validationResult.error ??
              validationResult.message ??
              'Coupon is not valid',
        );
        isApplyingCoupon.value = false;
        return;
      }

      // Step 2: Apply the coupon
      final applyResult = await CouponService.applyCoupon(
        code: couponCode.value.trim(),
        orderAmount: orderAmount,
        shopId: shopId,
      );

      if (applyResult.success) {
        // Update coupon state
        isCouponApplied.value = true;
        appliedCouponCode.value = couponCode.value.trim().toUpperCase();
        couponDiscountAmount.value = applyResult.discountAmount;
        couponFinalAmount.value = applyResult.finalAmount;
        couponMessage.value =
            applyResult.message ?? 'Coupon applied successfully';
        couponUsageId.value = applyResult.usageId ?? '';

        _showSuccessSnackbar(
          'Coupon Applied',
          applyResult.message ??
              'You\'ll save \$${applyResult.discountAmount.toStringAsFixed(2)}!',
        );
      } else {
        _showErrorSnackbar(
          'Error',
          applyResult.error ?? applyResult.message ?? 'Failed to apply coupon',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to apply coupon: ${e.toString()}');
    } finally {
      isApplyingCoupon.value = false;
    }
  }

  void removeCoupon() {
    isCouponApplied.value = false;
    appliedCouponCode.value = '';
    couponDiscountAmount.value = 0.0;
    couponFinalAmount.value = 0.0;
    couponMessage.value = '';
    couponUsageId.value = '';
    couponCode.value = '';
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  Future<void> fetchWalletBalance() async {
    final userId = AuthService.instance.authCustomer?.user?.id ?? '';
    if (userId.isEmpty) {
      isLoadingWallet.value = false;
      return;
    }

    try {
      isLoadingWallet.value = true;
      walletError.value = null;

      final response = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/reseller-programs/$userId/user-id',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final balance = data['reseller_program']?['balance'];
        walletBalance.value =
            (balance is num)
                ? balance.toDouble()
                : double.tryParse(balance?.toString() ?? '0') ?? 0.0;
      } else {
        walletBalance.value = 0.0;
      }
    } catch (e) {
      walletBalance.value = 0.0;
      walletError.value = 'Failed to load wallet balance';
    } finally {
      isLoadingWallet.value = false;
    }
  }

  /// Re-verify wallet balance before placing order to prevent bypass
  Future<bool> verifyWalletBalance(double requestedAmount) async {
    if (requestedAmount <= 0) return true;

    final userId = AuthService.instance.authCustomer?.user?.id ?? '';
    if (userId.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/reseller-programs/$userId/user-id',
        ),
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final balance = data['reseller_program']?['balance'];
        final currentBalance =
            (balance is num)
                ? balance.toDouble()
                : double.tryParse(balance?.toString() ?? '0') ?? 0.0;
        walletBalance.value = currentBalance;
        return currentBalance >= requestedAmount;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final FormController controller = Get.put(FormController());
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _walletAmountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  late final CartService cartService;

  @override
  void initState() {
    super.initState();
    cartService = Get.find<CartService>();
    cartService.initcall();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _couponController.dispose();
    _walletAmountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 8) {
      return 'Phone number must be at least 8 digits';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  void _onPlaceOrderPressed() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToTop();
      return;
    }

    if (controller.selectedCountry.value == null) {
      _scrollToTop();
      Get.snackbar(
        'Validation Error',
        'Please select a country',
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (controller.isLoading.value) return;

    final walletAmount = controller.walletAmount.value;

    try {
      controller.isLoading.value = true;

      // Re-verify wallet balance before placing order
      if (walletAmount > 0) {
        final isBalanceValid = await controller.verifyWalletBalance(
          walletAmount,
        );
        if (!isBalanceValid) {
          controller.isLoading.value = false;
          if (!mounted) return;
          NotificationHelper.showError(
            context,
            'Wallet Error',
            'Insufficient wallet balance. Your current balance is \$${controller.walletBalance.value.toStringAsFixed(2)}',
          );
          return;
        }
      }

      final String firstName = _firstNameController.text.trim();
      final String lastName = _lastNameController.text.trim();
      final String email = _emailController.text.trim();
      final String phone = _phoneController.text.trim();
      final String address = _addressController.text.trim();
      // Zip Code commented out for now
      // final String zipCode = _zipCodeController.text.trim();

      final String countryId =
          controller.selectedCountry.value?.id.toString() ?? '';
      // State and City commented out for now
      // final String stateId =
      //     controller.selectedState.value?.id.toString() ?? '';
      // final String cityId = controller.selectedCity.value?.id.toString() ?? '';

      final response = await MakeOrderService.placeOrder(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        streetAddress: address,
        postalCode: "", // commented out - was zipCode
        countryId: countryId,
        stateId: '', // commented out - was stateId
        cityId: '', // commented out - was cityId
        paymentMethod: controller.selectedPaymentOption.value,
        successUrl: "https://tjara.com/checkout",
        cancelUrl: "https://tjara.com/checkout",
        walletCheckoutAmount: walletAmount,
        couponCode:
            controller.isCouponApplied.value
                ? controller.appliedCouponCode.value
                : null,
        couponUsageId:
            controller.isCouponApplied.value
                ? controller.couponUsageId.value
                : null,
      );

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      if (response['message'] == 'Orders placed successfully!') {
        _clearForm();
        await _refreshCartData();
        Get.until((route) => route.isFirst);
        showContactDialog(context, const OrderSuccessDialog());
      } else if (response['message'] ==
          'Orders placed successfully using wallet payment!') {
        _clearForm();
        await _refreshCartData();
        Get.until((route) => route.isFirst);
        showContactDialog(context, const OrderSuccessDialog());
      } else {
        NotificationHelper.showError(
          context,
          'Order Failed',
          response['message']?.toString() ?? 'Unknown error occurred',
        );
      }
    } on Exception catch (e) {
      NotificationHelper.showError(
        context,
        'Order Failed',
        e.toString().replaceAll('Exception: ', ''),
      );
    } catch (e) {
      NotificationHelper.showError(
        context,
        'Order Failed',
        'An unexpected error occurred. Please try again.',
      );
    } finally {
      controller.isLoading.value = false;
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _zipCodeController.clear();
    _couponController.clear();
    _walletAmountController.clear();
    controller.walletAmount.value = 0.0;
    controller.selectedCountry.value = null;
    // controller.selectedState.value = null;
    // controller.selectedCity.value = null;
    controller.countries.clear();
    // controller.states.clear();
    // controller.cities.clear();
    // Clear coupon state
    controller.removeCoupon();
  }

  void _initializeUserData() {
    if (AuthService.instance.islogin &&
        AuthService.instance.authCustomer?.user != null) {
      final user = AuthService.instance.authCustomer!.user!;
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? '';
    }
  }

  Future<void> _refreshCartData() async {
    try {
      if (Get.isRegistered<CartService>()) {
        final cartService = Get.find<CartService>();
        await cartService.initcall();
      }

      if (Get.isRegistered<DashboardController>()) {
        final dashboardController = Get.find<DashboardController>();
        dashboardController.refreshCartCount();
      }
    } catch (e) {
      debugPrint('Error refreshing cart data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<CartModel>(
        stream: cartService.cartStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            );
          }

          final cart = snapshot.data!;

          return Stack(
            children: [
              // Gradient background at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 150,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _primaryColor.withValues(alpha: 0.12),
                        Colors.grey.shade100,
                      ],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Billing Information Section
                      _BillingInfoSection(
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        addressController: _addressController,
                        zipCodeController: _zipCodeController,
                        controller: controller,
                        validateEmail: _validateEmail,
                        validatePhone: _validatePhone,
                        validateRequired: _validateRequired,
                      ),

                      // Payment Method Section
                      _PaymentMethodSection(controller: controller),

                      // Shop grouped items (matching cart screen)
                      ...cart.cartItems.map(
                        (cartItem) => _ShopSection(cartItem: cartItem),
                      ),

                      // Reseller Levels Section (matching cart screen)
                      // _ResellerLevelsSection(cart: cart),

                      // Order Summaries per Shop (matching cart screen)
                      _OrderSummariesSection(
                        cart: cart,
                        controller: controller,
                      ),

                      // Notices Section
                      // _NoticesSection(cart: cart),

                      // Safe Payment Section (matching cart screen)
                      // const _SafePaymentSection(),

                      // Coupon Section
                      _CouponSection(
                        couponController: _couponController,
                        controller: controller,
                        cart: cart,
                      ),

                      // Wallet Section
                      _WalletSection(
                        walletAmountController: _walletAmountController,
                        controller: controller,
                        cart: cart,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Place Order Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomPlaceOrderBar(
                  cart: cart,
                  onPlaceOrder: _onPlaceOrderPressed,
                  controller: controller,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ========================================
// Billing Information Section
// ========================================
class _BillingInfoSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController zipCodeController;
  final FormController controller;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePhone;
  final String? Function(String?, String) validateRequired;

  const _BillingInfoSection({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.zipCodeController,
    required this.controller,
    required this.validateEmail,
    required this.validatePhone,
    required this.validateRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient accent bar
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _primaryColorDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: _primaryColor,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Billing Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'First Name',
                          firstNameController,
                          validator: (v) => validateRequired(v, 'first name'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField('Last Name', lastNameController),
                      ),
                    ],
                  ),

                  _buildTextField(
                    'Email',
                    emailController,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  _buildTextField(
                    'Phone Number',
                    phoneController,
                    validator: validatePhone,
                    keyboardType: TextInputType.phone,
                  ),

                  _buildTextField(
                    'Full Address',
                    addressController,
                    validator: (v) => validateRequired(v, 'address'),
                    maxLines: 2,
                  ),

                  // Zip Code - commented out for now
                  // _buildTextField('Zip Code', zipCodeController),

                  // Country Dropdown
                  Obx(
                    () => SearchableDropdown<Countries>(
                      label: 'Country',
                      hint: 'Select Country',
                      searchHint: 'Search country...',
                      items: controller.countries,
                      value: controller.selectedCountry.value,
                      onChanged: controller.onCountryChanged,
                      getDisplayText: (country) => country.name ?? 'Unknown',
                      isLoading: controller.isLoadingCountries.value,
                      errorMessage: controller.countryError.value,
                      onRetry: controller.retryLoadCountries,
                    ),
                  ),

                  // State Dropdown - commented out for now, uncomment when needed
                  // Obx(
                  //   () => SearchableDropdown<States>(
                  //     label: 'Region/State',
                  //     hint: 'Select State',
                  //     searchHint: 'Search state...',
                  //     items: controller.states,
                  //     value: controller.selectedState.value,
                  //     onChanged: controller.onStateChanged,
                  //     getDisplayText: (state) => state.name ?? 'Unknown',
                  //     isLoading: controller.isLoadingStates.value,
                  //     errorMessage: controller.stateError.value,
                  //     onRetry: controller.retryLoadStates,
                  //     enabled: controller.selectedCountry.value != null,
                  //   ),
                  // ),

                  // City Dropdown - commented out for now, uncomment when needed
                  // Obx(
                  //   () => SearchableDropdown<City>(
                  //     label: 'City',
                  //     hint: 'Select City',
                  //     searchHint: 'Search city...',
                  //     items: controller.cities,
                  //     value: controller.selectedCity.value,
                  //     onChanged: controller.onCityChanged,
                  //     getDisplayText: (city) => city.name,
                  //     isLoading: controller.isLoadingCities.value,
                  //     errorMessage: controller.cityError.value,
                  //     onRetry: controller.retryLoadCities,
                  //     enabled: controller.selectedState.value != null,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController textController, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: textController,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primaryColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}

// ========================================
// Payment Method Section
// ========================================
class _PaymentMethodSection extends StatelessWidget {
  final FormController controller;

  const _PaymentMethodSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, color: _primaryColor, size: 22),
                SizedBox(width: 8),
                Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Row(
                children: [
                  // Cash on Delivery
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => controller.onPaymentChanged("cash-on-delivery"),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedPaymentOption.value ==
                                      "cash-on-delivery"
                                  ? _primaryColor.withValues(alpha: 0.08)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                controller.selectedPaymentOption.value ==
                                        "cash-on-delivery"
                                    ? _primaryColor
                                    : Colors.grey.shade300,
                            width:
                                controller.selectedPaymentOption.value ==
                                        "cash-on-delivery"
                                    ? 2
                                    : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 28,
                              color:
                                  controller.selectedPaymentOption.value ==
                                          "cash-on-delivery"
                                      ? _primaryColor
                                      : Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cash on\nDelivery',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    controller.selectedPaymentOption.value ==
                                            "cash-on-delivery"
                                        ? _primaryColor
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Whish Payment
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.onPaymentChanged("whish"),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              controller.selectedPaymentOption.value == "whish"
                                  ? _primaryColor.withValues(alpha: 0.08)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                controller.selectedPaymentOption.value ==
                                        "whish"
                                    ? _primaryColor
                                    : Colors.grey.shade300,
                            width:
                                controller.selectedPaymentOption.value ==
                                        "whish"
                                    ? 2
                                    : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 28,
                              color:
                                  controller.selectedPaymentOption.value ==
                                          "whish"
                                      ? _primaryColor
                                      : Colors.grey.shade600,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Whish\nPayment',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    controller.selectedPaymentOption.value ==
                                            "whish"
                                        ? _primaryColor
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Card Payment (Disabled)
                  Expanded(
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 28,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Card\nPayment',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Shop Section - Groups items by shop (matching cart screen)
// ========================================
class _ShopSection extends StatelessWidget {
  final CartItem cartItem;

  const _ShopSection({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final shop = cartItem.shop.shop;
    final hasDiscount = cartItem.shopDiscount > 0;
    final hasBonus = cartItem.shopBonus > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient accent bar at top
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _primaryColorDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // Shop Header
            _ShopHeader(
              shop: shop,
              freeShippingNotice: cartItem.freeShippingNotice,
              estimatedDelivery: cartItem.getEstimatedDelivery(),
              freeShipping: cartItem.freeShipping,
            ),

            const Divider(height: 1),

            // Products List
            ...cartItem.items.map((item) => _ProductCard(item: item)),

            const Divider(height: 1),

            // Shop Summary
            _ShopSummary(
              shopTotal: cartItem.shopTotal,
              shopDiscount: cartItem.shopDiscount,
              shopBonus: cartItem.shopBonus,
              hasDiscount: hasDiscount,
              hasBonus: hasBonus,
              discountBreakdown: cartItem.discountBreakdown,
              shopFinalTotal: cartItem.shopFinalTotal,
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Shop Header
// ========================================
class _ShopHeader extends StatelessWidget {
  final ShopDetails shop;
  final String freeShippingNotice;
  final String estimatedDelivery;
  final bool freeShipping;

  const _ShopHeader({
    required this.shop,
    required this.freeShippingNotice,
    required this.estimatedDelivery,
    required this.freeShipping,
  });

  @override
  Widget build(BuildContext context) {
    final hasShopImage = shop.thumbnail.media?.optimizedMediaUrl != null;
    final firstLetter = shop.name.isNotEmpty ? shop.name[0].toUpperCase() : 'S';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Shop Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasShopImage ? null : _primaryColor,
              shape: BoxShape.circle,
            ),
            child:
                hasShopImage
                    ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: shop.thumbnail.media!.optimizedMediaUrl!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                _buildAvatarPlaceholder(firstLetter),
                        errorWidget:
                            (context, url, error) =>
                                _buildAvatarPlaceholder(firstLetter),
                      ),
                    )
                    : Center(
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          ),
          const SizedBox(width: 12),

          // Shop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (freeShippingNotice.isNotEmpty)
                  Text(
                    freeShippingNotice,
                    style: TextStyle(
                      fontSize: 12,
                      color: freeShipping ? Colors.green : Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // Estimated Delivery
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Est. Delivery :',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                estimatedDelivery,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String letter) {
    return Container(
      color: _primaryColor,
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ========================================
// Product Card (matching cart screen)
// ========================================
class _ProductCard extends StatelessWidget {
  final Item item;

  const _ProductCard({required this.item});

  void _navigateToProduct() {
    Get.to(
      () => ProductDetailByIdScreen(productId: item.productId),
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.getDisplayThumbnailUrl() ?? '';
    final hasDiscount = item.hasDiscount;
    final effectivePrice = item.getEffectivePrice();
    final originalPrice = item.price;
    final attributes = item.getAttributeDisplayStrings();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          GestureDetector(
            onTap: _navigateToProduct,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                GestureDetector(
                  onTap: _navigateToProduct,
                  child: Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Attributes (Colors, Sizes, etc.)
                if (attributes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...attributes.map(
                    (attr) => Text(
                      attr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Price Row
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        '\$${originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '\$${effectivePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasDiscount ? _primaryColor : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quantity Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Qty: ${item.quantity}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Shop Summary (matching cart screen)
// ========================================
class _ShopSummary extends StatelessWidget {
  final double shopTotal;
  final double shopDiscount;
  final double shopBonus;
  final bool hasDiscount;
  final bool hasBonus;
  final List<DiscountBreakdown> discountBreakdown;
  final double shopFinalTotal;

  const _ShopSummary({
    required this.shopTotal,
    required this.shopDiscount,
    required this.shopBonus,
    required this.hasDiscount,
    required this.hasBonus,
    required this.discountBreakdown,
    required this.shopFinalTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Shop Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop Subtotal',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                '\$${shopTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // Discount Breakdown
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            ...discountBreakdown.map(
              (discount) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_box,
                          size: 16,
                          color: _primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${discount.name} (${discount.percentage.toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '-\$${discount.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Bonus Amount
          if (hasBonus) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.card_giftcard, size: 16, color: Colors.teal),
                    SizedBox(width: 4),
                    Text(
                      'Bonus Amount',
                      style: TextStyle(fontSize: 13, color: Colors.teal),
                    ),
                  ],
                ),
                Text(
                  '+\$${shopBonus.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Shop Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '\$${shopFinalTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ========================================
// Overall Order Summary Section (matching screenshot)
// ========================================
class _OrderSummariesSection extends StatelessWidget {
  final CartModel cart;
  final FormController controller;

  const _OrderSummariesSection({required this.cart, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Check if there are any discounts
    final hasDiscounts = (cart.totalDiscounts ?? 0) > 0;

    // Calculate if delivery is free
    final isFreeDelivery = (cart.totalShippingFees ?? 0) == 0;

    return Obx(() {
      // Calculate final total considering coupon and wallet
      final hasCoupon = controller.isCouponApplied.value;
      final couponDiscount = controller.couponDiscountAmount.value;
      final walletUsed = controller.walletAmount.value;
      final totalBeforeWallet =
          hasCoupon
              ? controller.couponFinalAmount.value
              : (cart.grandTotal ?? 0).toDouble();
      final finalTotal = (totalBeforeWallet - walletUsed).clamp(
        0.0,
        double.infinity,
      );

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Items Total
            _SummaryRow(
              label: 'Items Total',
              value: '\$${(cart.cartTotal ?? 0).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),

            // Delivery Fee
            _SummaryRow(
              label: 'Delivery Fee',
              value:
                  isFreeDelivery
                      ? 'Free'
                      : '\$${(cart.totalShippingFees ?? 0).toStringAsFixed(2)}',
              valueColor: isFreeDelivery ? Colors.green : null,
            ),

            // Applied Discounts Section
            if (hasDiscounts) ...[
              const SizedBox(height: 16),
              const Text(
                'Applied Discounts:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              // Show discounts grouped by shop
              ...cart.cartItems
                  .where((cartItem) => cartItem.shopDiscount > 0)
                  .map(
                    (cartItem) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shop name
                        Text(
                          '${cartItem.shop.shop.name}:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Discount breakdown for this shop
                        ...cartItem.discountBreakdown.map(
                          (discount) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${discount.name} (${discount.percentage.toStringAsFixed(0)}%)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _primaryColor,
                                  ),
                                ),
                                Text(
                                  '- \$${discount.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
            ],

            // Coupon Discount (when applied)
            if (hasCoupon) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Coupon Discount (${controller.appliedCouponCode.value})',
                    style: const TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  Text(
                    '- \$${couponDiscount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],

            // Wallet Deduction (when used)
            if (walletUsed > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 16,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Wallet Payment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '- \$${walletUsed.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Total Payment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Payment',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '\$${finalTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ========================================
// Notices Section
// ========================================
class _NoticesSection extends StatelessWidget {
  final CartModel cart;

  const _NoticesSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    final notices = <String>[];
    double totalBonus = 0;

    // Calculate total bonus
    for (var cartItem in cart.cartItems) {
      totalBonus += cartItem.shopBonus;
    }

    // Add bonus notice
    if (totalBonus > 0) {
      notices.add(
        'Bonus: \$${totalBonus.toStringAsFixed(0)} (Gets Added to your wallet!)',
      );
    }

    // Collect discount messages
    if (cart.discountMessages != null) {
      for (var msg in cart.discountMessages!) {
        if (msg != null && msg.isNotEmpty) {
          notices.add(msg);
        }
      }
    }

    // Add tier messages from cart items
    for (var cartItem in cart.cartItems) {
      if (cartItem.nextTierMessageCheckout != null &&
          cartItem.nextTierMessageCheckout!.isNotEmpty) {
        notices.add(cartItem.nextTierMessageCheckout!);
      }
    }

    if (notices.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Notices',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
            ),
          ),
          ...notices.asMap().entries.map((entry) {
            final index = entry.key;
            final notice = entry.value;
            final isBonus = index == 0 && totalBonus > 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBonus ? Colors.amber.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isBonus ? Colors.amber.shade200 : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isBonus ? Icons.card_giftcard : Icons.check_circle_outline,
                    size: 18,
                    color:
                        isBonus ? Colors.amber.shade700 : Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notice,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isBonus
                                ? Colors.amber.shade800
                                : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ========================================
// Reseller Levels Section (matching cart screen)
// ========================================
class _ResellerLevelsSection extends StatelessWidget {
  final CartModel cart;

  const _ResellerLevelsSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    // Get global reseller tiers from cart API
    final resellerTiers = cart.resellerTiers;
    if (resellerTiers.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get current tier and next tier from API
    final currentTier = cart.currentTier;
    final nextTierInfo = cart.nextTier;

    // Get current tier data
    final currentTierData = resellerTiers.firstWhere(
      (t) => t.tier == currentTier,
      orElse: () => resellerTiers.first,
    );

    // Use progress value directly from API (e.g., 27.7 means 27.7%)
    final double progress = nextTierInfo?.progress ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Level Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Level : $currentTier',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currentTierData.discountRate.toStringAsFixed(0)}% discount + \$${currentTierData.bonusAmount.toStringAsFixed(0)} bonus',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (nextTierInfo != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Next Level Benefits:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${nextTierInfo.discountRate.toStringAsFixed(0)}% discount + \$${nextTierInfo.bonusAmount.toStringAsFixed(0)} bonus',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
                minHeight: 8,
              ),
            ),
          ),

          // Next Level Message
          if (nextTierInfo != null && nextTierInfo.message.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nextTierInfo.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Reseller Levels Grid
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Reseller Levels & Benefits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Available discounts and bonuses for each level',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(height: 12),

          // Levels Grid - 2 columns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: resellerTiers.length,
              itemBuilder: (context, index) {
                final tier = resellerTiers[index];
                final isCurrentTier = currentTier == tier.tier;
                return _ResellerLevelCard(
                  tier: tier,
                  isCurrentTier: isCurrentTier,
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ResellerLevelCard extends StatelessWidget {
  final ResellerTier tier;
  final bool isCurrentTier;

  const _ResellerLevelCard({required this.tier, required this.isCurrentTier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
            isCurrentTier
                ? _primaryColor.withValues(alpha: 0.05)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrentTier ? _primaryColor : Colors.grey.shade200,
          width: isCurrentTier ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Level ${tier.tier}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isCurrentTier ? _primaryColor : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Minimum Purchase',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            '\$${tier.minPurchase.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Discount Rate',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            '${tier.discountRate.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bonus Amount',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          Text(
            '\$${tier.bonusAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// Safe Payment Section (matching cart screen)
// ========================================
class _SafePaymentSection extends StatelessWidget {
  const _SafePaymentSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: _primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Safe Payment Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tjara is committed to protecting your payment information. We follow PCI DSS standards, use strong encryption, and perform regular reviews of its system to protect your privacy.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '1. Payment methods',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PaymentIcon(icon: Icons.credit_card, label: 'Card'),
              _PaymentIcon(icon: Icons.account_balance_wallet, label: 'Wallet'),
              _PaymentIcon(icon: Icons.payment, label: 'PayPal'),
              _PaymentIcon(icon: Icons.credit_card, label: 'Visa'),
              _PaymentIcon(icon: Icons.credit_card, label: 'MasterCard'),
              _PaymentIcon(icon: Icons.apple, label: 'Apple Pay'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PaymentIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 24, color: _primaryColor),
    );
  }
}

// ========================================
// Coupon Section
// ========================================
class _CouponSection extends StatelessWidget {
  final TextEditingController couponController;
  final FormController controller;
  final CartModel cart;

  const _CouponSection({
    required this.couponController,
    required this.controller,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  color: _primaryColor,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Apply Coupon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Show applied coupon or input field
            Obx(() {
              if (controller.isCouponApplied.value) {
                // Applied coupon display
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Text('🎉 ', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coupon Applied: ${controller.appliedCouponCode.value}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${controller.couponDiscountAmount.value.toStringAsFixed(2)} discount applied',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.removeCoupon();
                          couponController.clear();
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }

              // Coupon input field
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: couponController,
                      onChanged: (value) => controller.couponCode.value = value,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: _primaryColor,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed:
                        controller.isApplyingCoupon.value
                            ? null
                            : () => controller.applyCoupon(cart.cartTotal ?? 0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        controller.isApplyingCoupon.value
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Apply',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Wallet Section
// ========================================
class _WalletSection extends StatelessWidget {
  final TextEditingController walletAmountController;
  final FormController controller;
  final CartModel cart;

  const _WalletSection({
    required this.walletAmountController,
    required this.controller,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Don't show wallet section if loading or user not logged in
      if (controller.isLoadingWallet.value) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: _primaryColor,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: _primaryColor,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        );
      }

      final balance = controller.walletBalance.value;
      final hasBalance = balance > 0;

      // Calculate order total (considering coupon)
      final orderTotal =
          controller.isCouponApplied.value
              ? controller.couponFinalAmount.value
              : (cart.grandTotal ?? 0).toDouble();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with balance
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: _primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          hasBalance
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            hasBalance
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      'Balance: \$${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            hasBalance
                                ? Colors.green.shade700
                                : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Wallet amount input
              if (!hasBalance)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No wallet balance available',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use wallet balance for this order',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: walletAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value) ?? 0.0;
                              final maxAllowed =
                                  balance < orderTotal ? balance : orderTotal;
                              if (parsed > maxAllowed) {
                                walletAmountController.text = maxAllowed
                                    .toStringAsFixed(2);
                                walletAmountController
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(
                                    offset: walletAmountController.text.length,
                                  ),
                                );
                                controller.walletAmount.value = maxAllowed;
                              } else {
                                controller.walletAmount.value = parsed;
                              }
                            },
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixText: '\$ ',
                              prefixStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: _primaryColor,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Use max button
                        GestureDetector(
                          onTap: () {
                            final maxUsable =
                                balance < orderTotal ? balance : orderTotal;
                            walletAmountController.text = maxUsable
                                .toStringAsFixed(2);
                            controller.walletAmount.value = maxUsable;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              'Use Max',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Max limit hint
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Max: \$${(balance < orderTotal ? balance : orderTotal).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ========================================
// Bottom Place Order Bar
// ========================================
class _BottomPlaceOrderBar extends StatelessWidget {
  final CartModel cart;
  final VoidCallback onPlaceOrder;
  final FormController controller;

  const _BottomPlaceOrderBar({
    required this.cart,
    required this.onPlaceOrder,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primaryColor, _primaryColorDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(() {
            final hasCoupon = controller.isCouponApplied.value;
            final walletUsed = controller.walletAmount.value;
            final totalBeforeWallet =
                hasCoupon
                    ? controller.couponFinalAmount.value
                    : (cart.grandTotal ?? 0).toDouble();
            final finalTotal = (totalBeforeWallet - walletUsed).clamp(
              0.0,
              double.infinity,
            );

            return ElevatedButton(
              onPressed: controller.isLoading.value ? null : onPlaceOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:
                  controller.isLoading.value
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${finalTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
            );
          }),
        ),
      ),
    );
  }
}
