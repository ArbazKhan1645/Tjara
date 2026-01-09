// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.put(AuthService());

  // Initialize immediately to avoid late initialization errors
  final BehaviorSubject<LoginResponse?> _authCustomerBehaviorSubject =
      BehaviorSubject.seeded(null);

  BehaviorSubject<LoginResponse?> get authCustomerBehaviorSubject =>
      _authCustomerBehaviorSubject;

  // Role variables
  final Rxn<String> _roleRx = Rxn<String>();
  String? _role;

  // Getter for role
  String? get role => _role;

  // Reactive role getter
  Rxn<String> get roleRx => _roleRx;

  Future<AuthService> init() async {
    await _init();
    return this;
  }

  Future<void> _init() async {
    final SharedPreferences s = await SharedPreferences.getInstance();

    final authCustomerId = s.getString('current_user');
    if (authCustomerId != null) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(authCustomerId));
      _authCustomerBehaviorSubject.add(loginResponse);
      authCustomerRx.value = loginResponse;
    }

    // Initialize role from SharedPreferences
    final savedRole = s.getString('user_role');
    if (savedRole != null) {
      _role = savedRole;
      _roleRx.value = savedRole;
    }
  }

  void saveAuthState(LoginResponse customer) async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setString('current_user', jsonEncode(customer.toJson()));
    _authCustomerBehaviorSubject.add(customer);
    authCustomerRx.value = customer;

    if (customer.role != null) {
      updateRole(customer.role!);
    }
  }

  // Method to update role
  void updateRole(String newRole) async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _role = newRole;
    _roleRx.value = newRole;
    await s.setString('user_role', newRole);
  }

  // Method to clear role
  void clearRole() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _role = null;
    _roleRx.value = null;
    await s.remove('user_role');
  }

  LoginResponse? get authCustomer {
    return _authCustomerBehaviorSubject.value;
  }

  final Rxn<LoginResponse> authCustomerRx = Rxn<LoginResponse>();

  bool get islogin {
    return authCustomer != null;
  }

  Future<void> cleanStorage() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.remove('current_user');
    await s.remove('user_role'); // Also clear role when cleaning storage
    _authCustomerBehaviorSubject.add(null);
    authCustomerRx.value = null;
    _role = null;
    _roleRx.value = null;
  }
}

class RoleSelectionDialog extends StatefulWidget {
  final String email;

  const RoleSelectionDialog({super.key, required this.email});

  @override
  State<RoleSelectionDialog> createState() => _RoleSelectionDialogState();
}

class _RoleSelectionDialogState extends State<RoleSelectionDialog> {
  String? selectedRole;
  final AuthService authService = AuthService.instance;

  final List<String> roles = ['Vendor', 'Customer', 'Admin'];

  @override
  void initState() {
    super.initState();
    // Fetch saved role from SharedPreferences
    selectedRole = authService.role;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Switch Account',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Role options
            ...roles.map((role) => _buildRoleOption(role)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              selectedRole != null
                  ? () {
                    // Update role and close dialog
                    authService.updateRole(selectedRole!.toLowerCase());
                    Get.until((route) => route.isFirst);
                    Get.toNamed(Routes.DASHBOARD_ADMIN);

                    // Show confirmation snackbar
                    Get.snackbar(
                      'Switch Updated',
                      ' has been changed to $selectedRole',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                  : null,
          child: const Text('Switch'),
        ),
      ],
    );
  }

  Widget _buildRoleOption(String role) {
    final isSelected = selectedRole == role.toLowerCase();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.blue.shade50 : Colors.transparent,
      ),
      child: ListTile(
        leading: Radio<String>(
          value: role,
          groupValue: selectedRole,
          onChanged: (String? value) {
            setState(() {
              selectedRole = value;
            });
          },
        ),
        title: Text(
          role,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
        subtitle: Text(
          widget.email,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        onTap: () {
          setState(() {
            selectedRole = role;
          });
        },
      ),
    );
  }
}

// Helper class to show the dialog
class RoleSelectionHelper {
  static void showRoleSelectionDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RoleSelectionDialog(email: email);
      },
    );
  }
}

// Extension method for easier usage
extension RoleDialogExtension on BuildContext {
  void showRoleDialog(String email) {
    RoleSelectionHelper.showRoleSelectionDialog(this, email);
  }
}
