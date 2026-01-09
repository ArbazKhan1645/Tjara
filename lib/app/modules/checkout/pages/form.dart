import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/cart/cart_model.dart';
import 'package:tjara/app/models/others/country_model.dart';
import 'package:tjara/app/models/others/state_model.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/checkout/pages/success.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/orders/order_service.dart';
import 'package:tjara/app/services/others/others_service.dart';
import 'package:tjara/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/models/others/cities_model.dart';

class FormController extends GetxController {
  // Observable variables for dropdowns
  var selectedCountry = Rxn<Countries>();
  var selectedState = Rxn<States>();
  var selectedCity = Rxn<City>();
  var selectedPaymentOption = "cash-on-delivery".obs; // Default payment method
  var isLoading = false.obs;
  var isLoadingCountries = true.obs;
  var isLoadingStates = false.obs;
  var isLoadingCities = false.obs;

  // Lists for dropdown data
  var countries = <Countries>[].obs;
  var states = <States>[].obs;
  var cities = <City>[].obs;

  // Error messages
  var countryError = RxnString();
  var stateError = RxnString();
  var cityError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCountries();
  }

  Future<void> loadCountries() async {
    try {
      isLoadingCountries.value = true;
      countryError.value = null;

      // Check cache first for better performance
      if (CountryService.instance.countryList.isNotEmpty) {
        countries.value = CountryService.instance.countryList;
        debugPrint('Countries loaded from cache: ${countries.length}');
      } else {
        debugPrint('Fetching countries from API...');
        await CountryService.instance.fetchCountries();
        countries.value = CountryService.instance.countryList;
        debugPrint('Countries fetched from API: ${countries.length}');
      }
    } catch (e) {
      debugPrint('Error loading countries: $e');
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

      debugPrint('Fetching states for country: ${country.name}');
      await CountryService.instance.fetchStates(country.id.toString());
      states.value = CountryService.instance.stateList;
      debugPrint('States loaded: ${states.length}');
    } catch (e) {
      debugPrint('Error loading states: $e');
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

      debugPrint('Fetching cities for state: ${state.name}');
      await CountryService.instance.fetchCities(state.id.toString());
      cities.value = CountryService.instance.cityList;
      debugPrint('Cities loaded: ${cities.length}');
    } catch (e) {
      debugPrint('Error loading cities: $e');
      cityError.value = 'Failed to load cities for ${state.name}';
      _showErrorSnackbar('Error', 'Failed to load cities: ${e.toString()}');
    } finally {
      isLoadingCities.value = false;
    }
  }

  void onCityChanged(City? city) {
    selectedCity.value = city;
    debugPrint('City selected: ${city?.name}');
  }

  void onPaymentChanged(String? payment) {
    if (payment != null) {
      selectedPaymentOption.value = payment;
      debugPrint('Payment method selected: $payment');
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

  // Method to retry loading data
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    super.dispose();
  }

  Widget buildSimpleTextField(
    String label,
    TextEditingController textController, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: textController,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: '',
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildSimpleDropdown<T>({
    required String label,
    required String hint,
    required List<T> items,
    required T? value,
    required Function(T?) onChanged,
    required String Function(T) getDisplayText,
    String? Function(T?)? validator,
    bool isLoading = false,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child:
              isLoading
                  ? const SizedBox(
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                  : errorMessage != null
                  ? Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                        if (onRetry != null)
                          TextButton(onPressed: onRetry, child: const Text('Retry')),
                      ],
                    ),
                  )
                  : DropdownButtonFormField<T>(
                    initialValue: value,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items:
                        items.map((T item) {
                          return DropdownMenuItem<T>(
                            value: item,
                            child: Text(getDisplayText(item)),
                          );
                        }).toList(),
                    onChanged: items.isEmpty ? null : onChanged,
                    validator: validator,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    ),
                  ),
        ),
        const SizedBox(height: 16),
      ],
    );
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

  void _onPlaceOrderPressed() async {
    debugPrint('=== Form Validation Started ===');

    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validation failed');
      return;
    }

    if (controller.selectedCountry.value == null) {
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

    try {
      controller.isLoading.value = true;

      final String firstName = _firstNameController.text.trim();
      final String lastName = _lastNameController.text.trim();
      final String email = _emailController.text.trim();
      final String phone = _phoneController.text.trim();
      final String address = _addressController.text.trim();
      final String zipCode = _zipCodeController.text.trim();

      final String countryId = controller.selectedCountry.value?.id.toString() ?? '';
      final String stateId = controller.selectedState.value?.id.toString() ?? '';
      final String cityId = controller.selectedCity.value?.id.toString() ?? '';

      debugPrint('=== Order Details ===');
      debugPrint('Name: $firstName $lastName');
      debugPrint('Email: $email');
      debugPrint('Phone: $phone');
      debugPrint('Address: $address');
      debugPrint('Country ID: $countryId');
      debugPrint('State ID: $stateId');
      debugPrint('City ID: $cityId');
      debugPrint('Payment: ${controller.selectedPaymentOption.value}');

      final response = await OrderService.placeOrder(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        streetAddress: address,
        postalCode: zipCode.isEmpty ? "12345" : zipCode,
        countryId: countryId,
        stateId: stateId,
        cityId: cityId,
        paymentMethod: controller.selectedPaymentOption.value,
        successUrl: "https://tjara.com/checkout",
        cancelUrl: "https://tjara.com/checkout",
        walletCheckoutAmount: 0,
      );

      debugPrint('Order response: $response');

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      if (response['message'] == 'Orders placed successfully!') {
        _clearForm();
        await _refreshCartData();
        showContactDialog(context, const OrderSuccessDialog());
      } else {
        NotificationHelper.showError(
          context,
          'Order Failed',
          response['message']?.toString() ?? 'Unknown error occurred',
        );
      }
    } on Exception catch (e) {
      debugPrint('Order error: $e');
      NotificationHelper.showError(
        context,
        'Order Failed',
        e.toString().replaceAll('Exception: ', ''),
      );
    } catch (e) {
      debugPrint('Unexpected error: $e');
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
    controller.selectedCountry.value = null;
    controller.selectedState.value = null;
    controller.selectedCity.value = null;
    controller.countries.clear();
    controller.states.clear();
    controller.cities.clear();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<CartModel>(
        stream: cartService.cartStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cart = snapshot.data!;

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Information Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Full Name
                        buildSimpleTextField(
                          "Full Name",
                          _firstNameController,
                          validator:
                              (value) => _validateRequired(value, 'full name'),
                        ),

                        // Email
                        buildSimpleTextField(
                          "Email",
                          _emailController,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        // Phone Number
                        buildSimpleTextField(
                          "Phone Number",
                          _phoneController,
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                        ),

                        // Address
                        buildSimpleTextField(
                          "Address",
                          _addressController,
                          validator:
                              (value) => _validateRequired(value, 'address'),
                          maxLines: 2,
                        ),

                        // Zip Code
                        buildSimpleTextField("Zip Code", _zipCodeController),

                        // Country Dropdown
                        Obx(
                          () => buildSimpleDropdown<Countries>(
                            label: 'Country',
                            hint: 'Select Country',
                            items: controller.countries,
                            value: controller.selectedCountry.value,
                            onChanged: controller.onCountryChanged,
                            getDisplayText:
                                (country) => country.name ?? 'Unknown',
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a country'
                                        : null,
                            isLoading: controller.isLoadingCountries.value,
                            errorMessage: controller.countryError.value,
                            onRetry: controller.retryLoadCountries,
                          ),
                        ),

                        // Region/State Dropdown
                        Obx(
                          () => buildSimpleDropdown<States>(
                            label: 'Region/State',
                            hint: 'Select State',
                            items: controller.states,
                            value: controller.selectedState.value,
                            onChanged: controller.onStateChanged,
                            getDisplayText: (state) => state.name ?? 'Unknown',
                            isLoading: controller.isLoadingStates.value,
                            errorMessage: controller.stateError.value,
                            onRetry: controller.retryLoadStates,
                          ),
                        ),

                        // City Dropdown
                        Obx(
                          () => buildSimpleDropdown<City>(
                            label: 'City',
                            hint: 'Select City',
                            items: controller.cities,
                            value: controller.selectedCity.value,
                            onChanged: controller.onCityChanged,
                            getDisplayText: (city) => city.name ?? 'Unknown',
                            isLoading: controller.isLoadingCities.value,
                            errorMessage: controller.cityError.value,
                            onRetry: controller.retryLoadCities,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Payment Method Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => Row(
                            children: [
                              // Cash on Delivery
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => controller.onPaymentChanged(
                                        "cash-on-delivery",
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color:
                                            controller
                                                        .selectedPaymentOption
                                                        .value ==
                                                    "cash-on-delivery"
                                                ? const Color(0xFF0D9488)
                                                : Colors.grey.shade300,
                                        width:
                                            controller
                                                        .selectedPaymentOption
                                                        .value ==
                                                    "cash-on-delivery"
                                                ? 2
                                                : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: "cash-on-delivery",
                                          groupValue:
                                              controller
                                                  .selectedPaymentOption
                                                  .value,
                                          onChanged:
                                              (value) => controller
                                                  .onPaymentChanged(value),
                                          activeColor: const Color(0xFF0D9488),
                                        ),
                                        const SizedBox(width: 8),
                                        Image.asset(
                                          'assets/images/cod_icon.png', // Add your COD icon
                                          height: 30,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.local_shipping,
                                                    size: 30,
                                                  ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Card Payment (Disabled for now)
                              Expanded(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Radio<String>(
                                          value: "card",
                                          groupValue: null,
                                          onChanged: null,
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.credit_card,
                                          size: 30,
                                          color: Colors.grey,
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

                  const SizedBox(height: 8),

                  // Order Items Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Cart Items List
                        if (cart.cartItems.isNotEmpty)
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: cart.cartItems.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final cartItem = cart.cartItems[index];
                              return _OrderItemCard(cartItem: cartItem);
                            },
                          )
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No items in cart',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Order Summary Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Tjara Store',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _SummaryRow(
                          label: 'Items total:',
                          value:
                              '\$${(cart.cartTotal ?? 0).toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 12),
                        _SummaryRow(
                          label: 'Delivery Fees:',
                          value:
                              cart.totalShippingFees == 0
                                  ? 'Free'
                                  : '\$${(cart.totalShippingFees ?? 0).toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        _SummaryRow(
                          label: 'Total Payment',
                          value:
                              '\$${(cart.grandTotal ?? 0).toStringAsFixed(2)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Place Order Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: const Color(0xFF0D9488),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _onPlaceOrderPressed,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Obx(
                                () =>
                                    controller.isLoading.value
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Place Order',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Order Item Card Widget
class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.cartItem});
  final CartItem cartItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Store Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF97316),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 59,
                  height: 59,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl:
                          cartItem
                              .shop
                              .shop
                              .thumbnail
                              .media
                              ?.optimizedMediaUrl ??
                          '',
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              Container(color: Colors.grey.shade200),
                      errorWidget:
                          (context, url, error) => Center(
                            child: Text(
                              cartItem.shop.shop.name.toString().substring(
                                0,
                                1,
                              ),
                              style: const TextStyle(
                                color: Color(0xFFFF6B35),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.shop.shop.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        cartItem.freeShippingNotice,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Products List
          ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cartItem.items.length,
            itemBuilder: (context, index) {
              final item = cartItem.items[index];
              return _ProductItemRow(item: item);
            },
          ),
        ],
      ),
    );
  }
}

// Product Item Row Widget
class _ProductItemRow extends StatelessWidget {
  const _ProductItemRow({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: item.thumbnail.media?.optimizedMediaUrl ?? '',
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey.shade200),
                errorWidget:
                    (context, url, error) =>
                        const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.getSizeName(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.displayDiscountedPrice != null) ...[
                      Text(
                        '\$${(item.price ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '\$${((item.displayDiscountedPrice ?? item.price) ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Delete Icon
          Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
}

// Summary Row Widget
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
