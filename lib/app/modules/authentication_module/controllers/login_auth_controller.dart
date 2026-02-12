// ignore_for_file: unused_catch_clause, avoid_print, use_build_context_synchronously, depend_on_referenced_packages
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';
import 'package:tjara/app/services/auth/apis.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DeviceActivationController extends GetxController {
  // Captcha related
  RxString captchaVerified = ''.obs;
  RxBool isCaptchaSuccess = false.obs;

  // Registration type
  RxString selectedRegistrationType = 'customer'.obs;

  // Referral field visibility
  RxBool showReferralField = false.obs;

  // Referral validation state
  RxBool isReferralValidating = false.obs;
  RxBool isReferralValid = false.obs;
  RxString referralValidationMessage = ''.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final emailController = TextEditingController();
  final forgetEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final shopNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final signupemailController = TextEditingController();
  final phoneController = TextEditingController();
  final sinuppasswordController = TextEditingController();
  final referralCodeController = TextEditingController();

  // State variables
  bool isPasswordVisible = false;
  bool hasError = false;
  String countryCode = '+44'; // Default to GB
  RxString loginError = ''.obs;
  var isLoading = false.obs;
  var isLoggingIn = false.obs;
  var isSignInVisible = true.obs;
  var isSignInVisible2 = false.obs;
  RxString selectedPage = ''.obs;

  final _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    // Initialize default values
    selectedRegistrationType.value = 'customer';
    showReferralField.value = false;
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    // emailController.dispose();
    // forgetEmailController.dispose();
    // passwordController.dispose();
    // firstNameController.dispose();
    // lastNameController.dispose();
    // signupemailController.dispose();
    // phoneController.dispose();
    // sinuppasswordController.dispose();
    // referralCodeController.dispose();
    super.onClose();
  }

  // Captcha methods
  void setCaptchaSuccess(String token) {
    try {
      captchaVerified.value = token;
      isCaptchaSuccess.value = true;
      update();
    } catch (e) {
      print('Error setting captcha success: $e');
    }
  }

  void resetCaptcha() {
    try {
      captchaVerified.value = '';
      isCaptchaSuccess.value = false;
      update();
    } catch (e) {
      print('Error resetting captcha: $e');
    }
  }

  // Visibility toggle methods
  void onTogglePasswordVisibility() {
    try {
      isPasswordVisible = !isPasswordVisible;
      update();
    } catch (e) {
      print('Error toggling password visibility: $e');
    }
  }

  void toggleSignInVisibility() {
    try {
      isSignInVisible.value = !isSignInVisible.value;
      update();
    } catch (e) {
      print('Error toggling sign in visibility: $e');
    }
  }

  // Loading state methods
  void setIsloading(bool val) {
    try {
      isLoading.value = val;
      update();
    } catch (e) {
      print('Error setting loading state: $e');
    }
  }

  void setIsLogin(bool val) {
    try {
      isLoggingIn.value = val;
      update();
    } catch (e) {
      print('Error setting login state: $e');
    }
  }

  // Error handling methods
  void setLoginError(String val) {
    try {
      loginError.value = val;
      update();
    } catch (e) {
      print('Error setting login error: $e');
    }
  }

  // Validation methods
  bool _validateForm() {
    try {
      if (firstNameController.text.trim().isEmpty) {
        _showError('First name is required');
        return false;
      }

      if (lastNameController.text.trim().isEmpty) {
        _showError('Last name is required');
        return false;
      }

      if (signupemailController.text.trim().isEmpty) {
        _showError('Email is required');
        return false;
      }

      if (!_isValidEmail(signupemailController.text.trim())) {
        _showError('Please enter a valid email address');
        return false;
      }

      if (phoneController.text.trim().isEmpty) {
        _showError('Phone number is required');
        return false;
      }

      if (!_isValidPhoneNumber(phoneController.text.trim())) {
        _showError('Please enter a valid phone number');
        return false;
      }

      if (sinuppasswordController.text.isEmpty) {
        _showError('Password is required');
        return false;
      }

      if (!_isValidPassword(sinuppasswordController.text)) {
        _showError(
          'Password must be at least 8 characters with uppercase, lowercase and number',
        );
        return false;
      }

      if (!isCaptchaSuccess.value) {
        _showError('Please complete the captcha verification');
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating form: $e');
      _showError('Form validation failed');
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^\d{7,15}$').hasMatch(phone);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password);
  }

  void _showError(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  String formatPhoneNumber(String countryCode, String phone) {
    // Convert pk/PK to 92
    if (countryCode.toLowerCase() == "pk") {
      countryCode = "92";
    }

    // Remove leading 0 from phone if exists
    if (phone.startsWith("0")) {
      phone = phone.substring(1);
    }

    return countryCode + phone;
  }

  // Registration method with comprehensive error handling
  Future<void> onregister(BuildContext context) async {
    try {
      // Validate form first
      if (!_validateForm()) {
        return;
      }

      // Check internet connectivity
      if (!await _hasInternetConnection()) {
        _showError('No internet connection. Please check your network.');
        return;
      }

      setIsloading(true);

      // First, validate referral code if provided
      if (referralCodeController.text.trim().isNotEmpty) {
        print(
          'Validating referral code: ${referralCodeController.text.trim()}',
        );

        final bool isReferralValid = await _validateReferralCode(
          referralCodeController.text.trim(),
          signupemailController.text.trim().toLowerCase(),
        );

        if (!isReferralValid) {
          _showError('Invalid referral code. Please check and try again.');
          return;
        }

        print('Referral code validated successfully');
      }

      // Determine role based on registration type
      final String role = selectedRegistrationType.value;

      // Prepare registration data
      final registrationData = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': signupemailController.text.trim().toLowerCase(),
        'phone': formatPhoneNumber(countryCode, phoneController.text.trim()),
        'password': sinuppasswordController.text,
        'shop_name': shopNameController.text.trim(),
        'role': role,
        'referralCode':
            referralCodeController.text.trim().isNotEmpty
                ? referralCodeController.text.trim()
                : null,
        'captchaToken': captchaVerified.value,
      };

      print('Registration data prepared: ${registrationData.toString()}');

      final result = await AuthenticationApiService.registerUser(
        firstName: registrationData['firstName']!,
        lastName: registrationData['lastName']!,
        context: context,
        email: registrationData['email']!,
        phone: registrationData['phone']!,
        password: registrationData['password']!,
        role: registrationData['role']!,
        invitedBy: registrationData['referralCode'],
      );

      if (registrationData['shop_name'].toString() != 'null' &&
          registrationData['shop_name'].toString() != '') {
        await http.post(
          Uri.parse('https://api.libanbuy.com/api/shops/insert'),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "X-Request-From": "Application",
          },
          body: {'first_name': registrationData['shop_name']},
        );
      }

      _clearForm();

      if (referralCodeController.text.trim().isNotEmpty) {
        _showSuccess(
          'Registration successful with referral! Please check your email for verification.',
        );
      } else {
        _showSuccess(
          'Registration successful! Please check your email for verification.',
        );
      }

      // Navigate back or to login
      Get.back();
    } on SocketException catch (e) {
      print('Network error during registration: $e');
      _showError(
        'Network error. Please check your internet connection and try again.',
      );
    } on TimeoutException catch (e) {
      print('Timeout error during registration: $e');
      _showError('Request timeout. Please try again.');
    } on FormatException catch (e) {
      print('Format error during registration: $e');
      _showError('Invalid data format. Please check your inputs.');
    } catch (e) {
      print('Unexpected error during registration: $e');

      // Handle specific API errors
      final String errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('email already exists') ||
          errorMessage.contains('email is already registered')) {
        _showError(
          'This email is already registered. Please use a different email or try logging in.',
        );
      } else if (errorMessage.contains('phone already exists') ||
          errorMessage.contains('phone number is already registered')) {
        _showError(
          'This phone number is already registered. Please use a different number.',
        );
      } else if (errorMessage.contains('invalid referral code') ||
          errorMessage.contains('referral code not found')) {
        _showError('Invalid referral code. Please check and try again.');
      } else if (errorMessage.contains('network error') ||
          errorMessage.contains('no internet')) {
        _showError(
          'Network error. Please check your internet connection and try again.',
        );
      } else if (errorMessage.contains('timeout')) {
        _showError('Request timeout. Please try again.');
      } else if (errorMessage.contains('server error') ||
          errorMessage.contains('internal server error')) {
        _showError('Server error. Please try again later.');
      } else {
        _showError('Registration failed. Please try again later.');
      }
    } finally {
      setIsloading(false);
    }
  }

  // Login method with enhanced error handling
  Future<void> onLogin(BuildContext context) async {
    if (isLoggingIn.value) return;

    try {
      if (!formKey.currentState!.validate()) {
        _showError('Please fill all required fields correctly');
        return;
      }

      if (!await _hasInternetConnection()) {
        _showError('No internet connection. Please check your network.');
        return;
      }

      final String email = emailController.text.trim().toLowerCase();
      final String password = passwordController.text;

      setLoginError('');
      setIsLogin(true);

      final res = await AuthenticationApiService.loginUser(email, password);

      if (res is LoginResponse) {
        _authService.saveAuthState(res);

        // Initialize services
        try {
          final CartService cartService = Get.find<CartService>();
          cartService.initcall();
        } catch (e) {
          print('Error initializing cart service: $e');
        }

        try {
          DashboardController.instance.reset();
        } catch (e) {
          print('Error resetting dashboard: $e');
        }

        try {
          WishlistServiceController.instance.initCall();
        } catch (e) {
          print('Error initializing wishlist: $e');
        }

        Get.back();
        NotificationHelper.showSuccess(context, 'Success', 'Login successful!');
      } else {
        hasError = true;
        final Map<String, dynamic> jsonRes = jsonDecode(res);
        final String message = jsonRes["message"] ?? "Login failed";

        print(message);

        NotificationHelper.showError(context, 'Login Failed', message);
        setLoginError(message);
      }
    } on SocketException catch (e) {
      print('Network error during login: $e');
      _showError('Network error. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('Timeout error during login: $e');
      _showError('Request timeout. Please try again.');
    } catch (e) {
      print('Unexpected error during login: $e');

      if (e.toString().contains('invalid credentials')) {
        _showError('Invalid email or password. Please try again.');
      } else if (e.toString().contains('account not verified')) {
        _showError('Please verify your email before logging in.');
      } else if (e.toString().contains('account suspended')) {
        _showError('Your account has been suspended. Please contact support.');
      } else {
        _showError('Login failed. Please try again later.');
      }

      hasError = true;
      setLoginError(e.toString());
    } finally {
      setIsLogin(false);
    }
  }

  // Forget password method with error handling
  Future<void> forgetPassword(BuildContext context) async {
    try {
      if (forgetEmailController.text.trim().isEmpty) {
        _showError('Please enter your email address');
        return;
      }

      if (!_isValidEmail(forgetEmailController.text.trim())) {
        _showError('Please enter a valid email address');
        return;
      }

      if (!await _hasInternetConnection()) {
        _showError('No internet connection. Please check your network.');
        return;
      }

      final String email = forgetEmailController.text.trim().toLowerCase();

      final res = await AuthenticationApiService.forgetPassword(email);

      if (res is bool && res) {
        Get.back();
        NotificationHelper.showSuccess(
          context,
          'Reset Link Sent',
          'Please check your email for password reset instructions.',
        );
        forgetEmailController.clear();
      } else {
        hasError = true;
        final Map<String, dynamic> jsonRes = jsonDecode(res.toString());
        final String message = jsonRes["message"] ?? "Password reset failed";

        NotificationHelper.showError(context, 'Reset Failed', message);
      }
    } on SocketException catch (e) {
      print('Network error during password reset: $e');
      _showError('Network error. Please check your internet connection.');
    } on TimeoutException catch (e) {
      print('Timeout error during password reset: $e');
      _showError('Request timeout. Please try again.');
    } catch (e) {
      print('Unexpected error during password reset: $e');

      if (e.toString().contains('email not found')) {
        _showError('Email not found. Please check your email address.');
      } else {
        _showError('Password reset failed. Please try again later.');
      }
    }
  }

  // Referral validation method
  Future<bool> _validateReferralCode(
    String referralCode,
    String userEmail,
  ) async {
    try {
      print(
        'Starting referral validation for code: $referralCode, email: $userEmail',
      );

      const String apiUrl =
          'https://api.libanbuy.com/api/reseller-programs/validate-referral';

      final Map<String, dynamic> requestBody = {
        'referral_code': referralCode,
        'user_email': userEmail,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Referral validation timeout',
                const Duration(seconds: 30),
              );
            },
          );

      print('Referral validation response status: ${response.statusCode}');
      print('Referral validation response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse response to check for additional data if needed
        try {
          final responseData = jsonDecode(response.body);
          print('Referral validation successful: $responseData');
          return true;
        } catch (e) {
          print('Error parsing referral response, but status 200: $e');
          return true; // Still consider it valid since status is 200
        }
      } else if (response.statusCode == 400) {
        // Bad request - likely invalid referral code
        try {
          final responseData = jsonDecode(response.body);
          final String errorMessage =
              responseData['message'] ?? 'Invalid referral code';
          print('Referral validation failed: $errorMessage');
          return false;
        } catch (e) {
          print('Error parsing 400 response: $e');
          return false;
        }
      } else if (response.statusCode == 404) {
        print('Referral code not found');
        return false;
      } else if (response.statusCode >= 500) {
        print(
          'Server error during referral validation: ${response.statusCode}',
        );
        throw Exception('Server error during referral validation');
      } else {
        print(
          'Unexpected status code during referral validation: ${response.statusCode}',
        );
        return false;
      }
    } on SocketException catch (e) {
      print('Network error during referral validation: $e');
      throw Exception('Network error during referral validation');
    } on TimeoutException catch (e) {
      print('Timeout during referral validation: $e');
      throw Exception('Referral validation timeout');
    } on FormatException catch (e) {
      print('Format error during referral validation: $e');
      throw Exception('Invalid response format during referral validation');
    } catch (e) {
      print('Unexpected error during referral validation: $e');
      throw Exception('Failed to validate referral code');
    }
  }

  // Enhanced referral field validation with real-time checking
  Future<void> validateReferralCodeRealTime() async {
    try {
      final String referralCode = referralCodeController.text.trim();
      final String email = signupemailController.text.trim().toLowerCase();

      if (referralCode.isEmpty) {
        _showError('Please enter a referral code to validate');
        return;
      }

      if (email.isEmpty || !_isValidEmail(email)) {
        _showError('Please enter a valid email address first');
        return;
      }

      // Set validation state
      isReferralValidating.value = true;
      isReferralValid.value = false;
      update();

      final bool isValid = await _validateReferralCode(referralCode, email);

      isReferralValidating.value = false;
      isReferralValid.value = isValid;
      update();

      if (isValid) {
        referralValidationMessage.value = 'Referral code is valid!';
        Get.snackbar(
          'Referral Code Valid',
          'Great! Your referral code is valid and you\'ll receive exclusive benefits.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        referralValidationMessage.value = 'Invalid referral code';
        _showError(
          'Invalid referral code. Please check with your friend and try again.',
        );
        // Don't clear the field, let user correct it
      }
    } catch (e) {
      isReferralValidating.value = false;
      isReferralValid.value = false;
      referralValidationMessage.value = 'Validation failed';
      update();

      if (e.toString().contains('Network error') ||
          e.toString().contains('SocketException')) {
        _showError(
          'Network error. Please check your connection and try again.',
        );
      } else if (e.toString().contains('timeout')) {
        _showError('Validation timeout. Please try again.');
      } else {
        _showError('Unable to validate referral code. Please try again later.');
      }

      print('Error in real-time referral validation: $e');
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      print('Error checking internet connection: $e');
      return false;
    }
  }

  void _clearForm() {
    try {
      firstNameController.clear();
      lastNameController.clear();
      signupemailController.clear();
      phoneController.clear();
      sinuppasswordController.clear();
      referralCodeController.clear();
      resetCaptcha();
      selectedRegistrationType.value = 'customer';
      showReferralField.value = false;
      update();
    } catch (e) {
      print('Error clearing form: $e');
    }
  }

  // Country code validation and formatting
  void updateCountryCode(String code) {
    try {
      if (code.isNotEmpty && !code.startsWith('+')) {
        countryCode = '+$code';
      } else {
        countryCode = code;
      }
      update();
    } catch (e) {
      print('Error updating country code: $e');
    }
  }

  // Registration type methods
  void setRegistrationType(String type) {
    try {
      if (['customer', 'vender'].contains(type)) {
        selectedRegistrationType.value = type;
        update();
      }
    } catch (e) {
      print('Error setting registration type: $e');
    }
  }

  void toggleReferralField() {
    try {
      showReferralField.value = !showReferralField.value;
      update();
    } catch (e) {
      print('Error toggling referral field: $e');
    }
  }

  // Form state validation
  bool get isFormValid {
    try {
      final bool basicFormValid =
          firstNameController.text.trim().isNotEmpty &&
          lastNameController.text.trim().isNotEmpty &&
          signupemailController.text.trim().isNotEmpty &&
          _isValidEmail(signupemailController.text.trim()) &&
          phoneController.text.trim().isNotEmpty &&
          _isValidPhoneNumber(phoneController.text.trim()) &&
          sinuppasswordController.text.isNotEmpty &&
          _isValidPassword(sinuppasswordController.text) &&
          isCaptchaSuccess.value;

      // If no referral code is provided, basic form validation is enough
      if (referralCodeController.text.trim().isEmpty) {
        return basicFormValid;
      }

      // If referral code is provided but not validated, form is not valid
      // Note: We'll validate it during registration process
      return basicFormValid;
    } catch (e) {
      print('Error checking form validity: $e');
      return false;
    }
  }

  // Get formatted phone number
  // String get formattedPhoneNumber {
  //   try {
  //     return countryCode + phoneController.text.trim();
  //   } catch (e) {
  //     print('Error formatting phone number: $e');
  //     return phoneController.text.trim();
  //   }
  // }

  // Debug methods for development
  void printFormData() {
    try {
      print('=== Registration Form Data ===');
      print('Registration Type: ${selectedRegistrationType.value}');
      print('First Name: ${firstNameController.text}');
      print('Last Name: ${lastNameController.text}');
      print('Email: ${signupemailController.text}');
      print(
        'Phone: ${formatPhoneNumber(countryCode, phoneController.text.trim())}',
      );
      print('Referral Code: ${referralCodeController.text}');
      print('Captcha Success: ${isCaptchaSuccess.value}');
      print('Form Valid: $isFormValid');
      print('============================');
    } catch (e) {
      print('Error printing form data: $e');
    }
  }

  Future<AuthResult> autoSignInOrSignUp({
    required BuildContext context,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? role,
    String? referralCode,
  }) async {
    if (!await _hasInternetConnection()) {
      throw 'No internet connection';
    }

    final normalizedEmail = email.trim().toLowerCase();

    if (!_isValidEmail(normalizedEmail)) {
      throw 'Invalid email address';
    }

    if (password.isEmpty) {
      throw 'Password is required';
    }

    /// 🔹 STEP 1: TRY LOGIN
    final loginRes = await AuthenticationApiService.loginUser(
      normalizedEmail,
      password,
    );

    if (loginRes is LoginResponse) {
      _authService.saveAuthState(loginRes);
      _initPostLoginServices();
      return AuthResult.loginSuccess;
    }

    /// 🔹 STEP 2: CHECK ERROR
    final jsonRes = jsonDecode(loginRes);
    final message = (jsonRes['message'] ?? '').toString().toLowerCase();

    if (!message.contains('user not found')) {
      throw jsonRes['message'] ?? 'Login failed';
    }

    /// 🔹 STEP 3: SIGN UP
    if (firstName == null || lastName == null) {
      throw 'Complete registration details required';
    }

    if (!_isValidPassword(password)) {
      throw 'Password must be 8 chars with upper, lower & number';
    }

    final registerRes = await AuthenticationApiService.registerUser(
      context: context,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: normalizedEmail,
      phone: phone ?? '',
      password: password,
      role: role ?? 'customer',
      invitedBy: referralCode?.trim(),
    );

    /// 🔹 STEP 4: AUTO LOGIN AFTER SIGNUP
    final finalLogin = await AuthenticationApiService.loginUser(
      normalizedEmail,
      password,
    );

    if (finalLogin is LoginResponse) {
      _authService.saveAuthState(finalLogin);
      _initPostLoginServices();
      return AuthResult.signupSuccess;
    }

    throw 'Account created but login failed';
  }

  void _initPostLoginServices() {
    try {
      Get.find<CartService>().initcall();
    } catch (_) {}

    try {
      DashboardController.instance.reset();
    } catch (_) {}

    try {
      WishlistServiceController.instance.initCall();
    } catch (_) {}
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await GoogleSignIn.instance.initialize(
        serverClientId:
            '78764961634-v2bu6jfei8aqg0jpj64a50teu5u0sinq.apps.googleusercontent.com',
      );

      final googleUser = await GoogleSignIn.instance.authenticate();

      final result = await autoSignInOrSignUp(
        context: context,
        email: googleUser.email,
        password: 'google_user4tssS@',
        firstName: googleUser.displayName ?? '',
        lastName: googleUser.displayName ?? '',
        phone: generateRandomPhone(),
        role: 'customer',
      );

      if (Get.isDialogOpen == true) Get.back();

      _showSuccess(
        result == AuthResult.signupSuccess
            ? 'Account created successfully!'
            : 'Login successful!',
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      _showError(e.toString());
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
}

enum AuthResult { loginSuccess, signupSuccess }
