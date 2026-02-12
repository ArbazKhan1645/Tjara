import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/authentication_module/controllers/auth_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_shops_module/const/appColors.dart';
import 'package:tjara/app/services/auth/apis.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';

class InsertNewUser extends StatefulWidget {
  final User? existingUser; // Pass existing user for edit mode

  const InsertNewUser({super.key, this.existingUser});

  @override
  State<InsertNewUser> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<InsertNewUser> {
  final _formKey = GlobalKey<FormState>();
  late final AuthController authController;
  String selectedRole = 'customer';

  bool get isEditMode => widget.existingUser != null;

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());

    // Pre-populate fields if editing
    if (isEditMode) {
      _populateFields();
    }
  }

  void _populateFields() {
    final user = widget.existingUser!;
    authController.firstNameController.text = user.firstName ?? '';
    authController.lastNameController.text = user.lastName ?? '';
    authController.emailController.text = user.email ?? '';
    authController.phoneController.text = user.phone ?? '';
    selectedRole = user.role ?? 'customer';
  }

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF97316), Color(0xFFFACC15)],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: appcolors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Name Field
                          _buildInputField(
                            label: 'First Name',
                            controller: authController.firstNameController,
                            hintText:
                                'Enter your full legal name as it appears on your official identification',
                            validator: (s) {
                              if (s!.isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                            isRequired: true,
                          ),

                          // Last Name Field
                          _buildInputField(
                            label: 'Last Name',
                            controller: authController.lastNameController,
                            hintText:
                                'Enter your full legal name as it appears on your official identification',
                            validator: (s) {
                              if (s!.isEmpty) {
                                return 'Last name is required';
                              }
                              return null;
                            },
                            isRequired: true,
                          ),

                          // Email Field
                          _buildInputField(
                            label: 'Email',
                            controller: authController.emailController,
                            hintText:
                                'Please provide a valid email address that you have access to',
                            validator: (s) {
                              if (s!.isEmpty) {
                                return 'email is required';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            isRequired: true,
                          ),

                          if (isEditMode) ...[
                            _buildInputField(
                              label: 'Phone Number',
                              controller: authController.phoneController,
                              hintText: 'Please provide a valid Phone Number',
                              validator: (s) {
                                if (s!.isEmpty) {
                                  return 'Phone number is required';
                                }
                                if (!RegExp(r'^\d{7,15}$').hasMatch(s.trim())) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              isRequired: true,
                            ),
                          ],

                          // Password Field (only for create mode)
                          if (!isEditMode) ...[_buildPasswordField()],

                          // Role Field
                          _buildRoleField(),

                          const SizedBox(height: 32),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed:
                                    authController.isLoading.value
                                        ? null
                                        : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF14B8A6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 0,
                                ),
                                child:
                                    authController.isLoading.value
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Text(
                                          isEditMode ? 'Update' : 'Save',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
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
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red, fontSize: 15),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hintText,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Alex Johnson',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF14B8A6),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: 'Password',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please provide a valid password that you have access to',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Obx(
            () => TextFormField(
              controller: authController.passwordController,
              obscureText: !authController.isPasswordVisible.value,
              style: const TextStyle(fontSize: 14),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a password';
                } else if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: '••••••••••',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF14B8A6),
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: IconButton(
                  icon: Icon(
                    authController.isPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: authController.togglePasswordVisibility,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              text: 'Role',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please provide a valid role that you have access to',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                items:
                    ['customer', 'admin', 'vendor'].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          role[0].toUpperCase() + role.substring(1),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (isEditMode) {
      await _updateUser();
    } else {
      await _createUser();
    }
  }

  Future<void> _createUser() async {
    await AuthenticationApiService.registerUser(
      firstName: authController.firstNameController.text,
      lastName: authController.lastNameController.text,
      email: authController.emailController.text,
      phone: authController.phoneController.text,
      password: authController.passwordController.text,
      role: selectedRole.toLowerCase(),
      context: context,
    );
  }

  Future<void> _updateUser() async {
    await AuthenticationApiService.updateUser(
      userId: widget.existingUser!.id!,
      firstName: authController.firstNameController.text,
      lastName: authController.lastNameController.text,
      email: authController.emailController.text,
      phone: authController.phoneController.text,
      role: selectedRole.toLowerCase(),
      context: context,
    );
  }

  @override
  void dispose() {
    // Only dispose controllers if they were created in this widget
    if (!Get.isRegistered<AuthController>()) {
      authController.dispose();
    }
    super.dispose();
  }
}
