import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:tjara/app/modules/authentication/new/sign_in.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({
    super.key,
    this.avoidNavigate = false,
    this.onSwitchToSignup,
  });

  final bool avoidNavigate;
  final VoidCallback? onSwitchToSignup;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // ✨ Gradient Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFfea52d), Color(0xFFf97316)],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  // Header Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add,
                            size: 35,
                            color: Color(0xFFfea52d),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Join us today and enjoy\nexclusive deals & discounts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // White Card Form
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: authController.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Register as section
                            const Text(
                              'Register as:',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(
                              () => Row(
                                children: [
                                  Expanded(
                                    child: _RadioOption(
                                      label: 'Seller',
                                      isSelected:
                                          authController.userType.value ==
                                          'Seller',
                                      color: const Color(0xFF00897B),
                                      onTap:
                                          () =>
                                              authController.userType.value =
                                                  'Seller',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _RadioOption(
                                      label: 'Customer',
                                      isSelected:
                                          authController.userType.value ==
                                          'Customer',
                                      color: const Color(0xFFfea52d),
                                      onTap:
                                          () =>
                                              authController.userType.value =
                                                  'Customer',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // First Name
                            _buildLabel('First Name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: authController.firstNameController,
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                              decoration: _buildInputDecoration(
                                hintText: 'Alex',
                                prefixIcon: Icons.person_outline,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Last Name
                            _buildLabel('Last Name'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: authController.lastNameController,
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                              decoration: _buildInputDecoration(
                                hintText: 'Johnson',
                                prefixIcon: Icons.person_outline,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Email
                            _buildLabel('Email Address'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: authController.emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Invalid email';
                                }
                                return null;
                              },
                              decoration: _buildInputDecoration(
                                hintText: 'your@email.com',
                                prefixIcon: Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Phone
                            _buildLabel('Phone Number'),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  CountryCodePicker(
                                    onChanged: (country) {
                                      authController.selectedCountryCode.value =
                                          country.dialCode ?? '+961';
                                    },
                                    initialSelection: 'LB',
                                    favorite: const [
                                      '+961',
                                      '+1',
                                      '+44',
                                      '+971',
                                    ],
                                    showCountryOnly: false,
                                    showOnlyCountryWhenClosed: false,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    flagWidth: 24,
                                  ),
                                  Container(
                                    height: 30,
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          authController.phoneController,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        if (value.length < 6) {
                                          return 'Too short';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Phone number',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Password
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            Obx(
                              () => TextFormField(
                                controller: authController.passwordController,
                                obscureText:
                                    !authController.isPasswordVisible.value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (value.length < 6) {
                                    return 'Min 6 characters';
                                  }
                                  return null;
                                },
                                decoration: _buildInputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authController.isPasswordVisible.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed:
                                        authController.togglePasswordVisibility,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Confirm Password
                            _buildLabel('Confirm Password'),
                            const SizedBox(height: 8),
                            Obx(
                              () => TextFormField(
                                controller:
                                    authController.confirmPasswordController,
                                obscureText:
                                    !authController
                                        .isConfirmPasswordVisible
                                        .value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (value !=
                                      authController.passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                decoration: _buildInputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authController
                                              .isConfirmPasswordVisible
                                              .value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed:
                                        authController
                                            .toggleConfirmPasswordVisibility,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Promotions Checkbox
                            Obx(
                              () => InkWell(
                                onTap: authController.togglePromos,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color:
                                              authController.receivePromos.value
                                                  ? const Color(0xFFfea52d)
                                                  : Colors.transparent,
                                          border: Border.all(
                                            color:
                                                authController
                                                        .receivePromos
                                                        .value
                                                    ? const Color(0xFFfea52d)
                                                    : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child:
                                            authController.receivePromos.value
                                                ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                                : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Get exclusive deals & promotions via email',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Obx(
                                () => ElevatedButton(
                                  onPressed:
                                      authController.isLoading.value
                                          ? null
                                          : authController.signUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFfea52d),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child:
                                      authController.isLoading.value
                                          ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                          : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Create Account',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Login Link
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (avoidNavigate &&
                                          onSwitchToSignup != null) {
                                        onSwitchToSignup!();
                                      } else {
                                        Get.back();
                                      }
                                    },
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: Color(0xFFfea52d),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFfea52d), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// ========================================
// ✨ Custom Radio Option Component
// ========================================
class _RadioOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
