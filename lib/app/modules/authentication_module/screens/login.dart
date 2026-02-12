import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/authentication_module/controllers/login_auth_controller.dart';
import 'package:tjara/app/modules/authentication_module/screens/forget_password.dart';
import 'package:tjara/app/modules/authentication_module/controllers/signup_controller.dart';
import 'package:tjara/app/modules/authentication_module/screens/signup.dart';
import 'package:flutter/gestures.dart';

class LoginUi extends StatefulWidget {
  const LoginUi({super.key, this.avoidNavigate = false, this.onSwitchToSignup});

  final bool avoidNavigate;
  final VoidCallback? onSwitchToSignup;

  @override
  State<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final ScrollController _scrollController = ScrollController();
  bool _rememberPassword = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade50,
      body: GetBuilder<DeviceActivationController>(
        init: DeviceActivationController(),
        builder: (controller) {
          return Form(
            key: controller.formKey,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).padding.top,
                  color: const Color(0xFFfda730),
                ),

                // ✨ Gradient Background (Top portion)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.4,
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
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Header Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                          child: Column(
                            children: [
                              // Logo/Icon
                              Container(
                                width: 80,
                                height: 80,
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
                                  Icons.shopping_bag,
                                  size: 40,
                                  color: Color(0xFFfea52d),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sign in to continue shopping\nand enjoy exclusive deals',
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Field
                                const Text(
                                  "Email Address",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _buildInputDecoration(
                                    hintText: 'Enter your email',
                                    prefixIcon: Icons.email_outlined,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Password Field
                                const Text(
                                  "Password",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: controller.passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: _buildInputDecoration(
                                    hintText: 'Enter your password',
                                    prefixIcon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey.shade600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Remember & Forgot Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: 0.9,
                                          child: Checkbox(
                                            value: _rememberPassword,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberPassword =
                                                    value ?? false;
                                              });
                                            },
                                            activeColor: const Color(
                                              0xFFfea52d,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Remember me',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.dialog(const ForgetPassword());
                                      },
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Color(0xFFfea52d),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: Obx(
                                    () => ElevatedButton(
                                      onPressed:
                                          controller.isLoggingIn.value
                                              ? null
                                              : () async {
                                                await controller.onLogin(context);
                                              },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFfea52d),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: const Color(0xFFfea52d).withValues(alpha: 0.6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                      ),
                                      child:
                                          controller.isLoggingIn.value
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
                                                    'Sign In',
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

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'Or continue with',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Social Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SocialButton(
                                        icon:
                                            'https://www.google.com/images/branding/product/ico/googleg_lodp.ico',
                                        label: 'Google',
                                        onTap: () async {
                                          await controller.signInWithGoogle(
                                            context,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Sign Up Link
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Sign Up',
                                          style: const TextStyle(
                                            color: Color(0xFFfea52d),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  Get.put(AuthController());
                                                  if (widget.avoidNavigate &&
                                                      widget.onSwitchToSignup !=
                                                          null) {
                                                    widget.onSwitchToSignup!();
                                                  } else {
                                                    Get.to(
                                                      () =>
                                                          const SignupScreen(),
                                                    );
                                                  }
                                                },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
        },
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
// ✨ Social Button Component
// ========================================
class _SocialButton extends StatelessWidget {
  final String? icon;

  final String label;

  final VoidCallback onTap;

  const _SocialButton({this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Image.network(icon!, height: 22, width: 22),

            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
