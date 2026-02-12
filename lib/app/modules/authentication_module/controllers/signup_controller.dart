// Authentication implementation with GetX state management
// File structure:
// - main.dart
// - controllers/auth_controller.dart
// - screens/auth/login_screen.dart
// - screens/auth/signup_screen.dart
// - utils/themes.dart
// - utils/validators.dart

// main.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/authentication_module/controllers/login_auth_controller.dart';
import 'dart:convert';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var userType = 'Customer'.obs; // Seller or Customer
  var selectedCountryCode = '+961'.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final referralCodeController = TextEditingController();
  final storeNameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  var receivePromos = false.obs;

  // Referral validation state: '' | 'validating' | 'valid' | 'invalid'
  var referralStatus = ''.obs;
  var referralErrorMessage = ''.obs;
  Timer? _referralDebounce;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void onReferralCodeChanged(String value) {
    _referralDebounce?.cancel();
    if (value.trim().isEmpty) {
      referralStatus.value = '';
      referralErrorMessage.value = '';
      return;
    }
    referralStatus.value = '';
    referralErrorMessage.value = '';
    _referralDebounce = Timer(const Duration(milliseconds: 800), () {
      validateReferralCode(value.trim());
    });
  }

  Future<void> validateReferralCode(String code) async {
    referralStatus.value = 'validating';
    referralErrorMessage.value = '';
    try {
      final url = Uri.parse(
        'https://api.libanbuy.com/api/reseller-programs/validate-referral',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'referral_code': code,
          'user_email': emailController.text.trim().toLowerCase(),
        }),
      );
      final data = jsonDecode(response.body);
      if (data['valid'] == true) {
        referralStatus.value = 'valid';
      } else {
        referralStatus.value = 'invalid';
        referralErrorMessage.value = 'Invalid referral code: please check...';
      }
    } catch (e) {
      referralStatus.value = 'invalid';
      referralErrorMessage.value = 'Failed to validate referral code';
    }
  }

  Future<void> signIn() async {
    isLoading.value = true;

    try {} catch (e) {
      Get.snackbar(
        'Error',
        'Failed to login: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Password Mismatch',
        'Password and Confirm Password do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Prepare phone number (combine country code with phone)
      final fullPhone = '${selectedCountryCode.value}${phoneController.text}'
          .replaceAll(' ', '');

      // Prepare API request data
      final data = {
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'email': emailController.text.trim().toLowerCase(),
        'password': passwordController.text,
        'phone': fullPhone,
        'registration_type': 'quick',
        'role': userType.value == 'Seller' ? 'vendor' : 'customer',
      };

      // Add store_name if seller
      if (userType.value == 'Seller' &&
          storeNameController.text.trim().isNotEmpty) {
        data['store_name'] = storeNameController.text.trim();
      }

      // Add referral code if provided and valid
      if (referralCodeController.text.trim().isNotEmpty &&
          referralStatus.value == 'valid') {
        data['referral_code'] = referralCodeController.text.trim();
      }

      // Make API call using http package (sending as raw JSON)
      final url = Uri.parse('https://api.libanbuy.com/api/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain, */*',
          'X-Request-From': 'Website',
        },
        body: jsonEncode(data), // Send as raw JSON
      );

      print('📥 Sign Up Response Status: ${response.statusCode}');
      print('📥 Sign Up Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        final registeredEmail = emailController.text.trim();
        final registeredPassword = passwordController.text;

        final con = Get.put(DeviceActivationController());
        await con.autoSignInOrSignUp(
          context: Get.context!,
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          role: userType.value.toLowerCase(),
          phone: fullPhone,
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
        );

        // Clear only non-login fields
        firstNameController.clear();
        lastNameController.clear();
        phoneController.clear();
        confirmPasswordController.clear();
        referralCodeController.clear();
        storeNameController.clear();
        referralStatus.value = '';
        referralErrorMessage.value = '';

        // Pre-fill login credentials
        emailController.text = registeredEmail;
        passwordController.text = registeredPassword;
      } else {
        // Handle error response
        String errorMessage = 'Failed to create account';

        try {
          final responseData = jsonDecode(response.body);

          if (responseData is Map) {
            if (responseData.containsKey('message')) {
              errorMessage = responseData['message'];
            } else if (responseData.containsKey('error')) {
              errorMessage = responseData['error'];
            } else if (responseData.containsKey('errors')) {
              // Handle validation errors
              final errors = responseData['errors'];
              if (errors is Map) {
                errorMessage = errors.values
                    .map((e) => e is List ? e.join(', ') : e.toString())
                    .join('\n');
              }
            }
          }
        } catch (e) {
          errorMessage = response.body;
        }

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('❌ Unexpected Error: $e');

      String errorMessage = 'An unexpected error occurred';

      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please try again.';
      } else {
        errorMessage = 'Failed to create account: ${e.toString()}';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String generateRandomPhone() {
    final random = Random();

    // Pakistan mobile prefixes
    const prefixes = ['030', '031', '032', '033', '034'];

    final prefix = prefixes[random.nextInt(prefixes.length)];

    final number = List.generate(7, (_) => random.nextInt(10)).join();

    return '$prefix$number';
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;

    try {
      // Simulate Google auth delay
      await Future.delayed(const Duration(seconds: 2));

      // Integration with Google Auth would go here
      Get.snackbar(
        'Success',
        'Google login successful',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to login with Google: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    isLoading.value = true;

    try {
      // Simulate Facebook auth delay
      await Future.delayed(const Duration(seconds: 2));

      // Integration with Facebook Auth would go here
      Get.snackbar(
        'Success',
        'Facebook login successful',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to login with Facebook: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void togglePromos() {
    receivePromos.value = !receivePromos.value;
  }

  @override
  void onClose() {
    _referralDebounce?.cancel();
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    referralCodeController.dispose();
    storeNameController.dispose();
    super.onClose();
  }
}
