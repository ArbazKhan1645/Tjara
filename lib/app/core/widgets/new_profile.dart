import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/modules_admin/profile/profile.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/service/wishlist_service.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/dashbopard_services/balance_service.dart';
import 'package:tjara/app/services/notifications/notification_service.dart';

// Main User Menu Dialog
class UserMenuDialog extends StatefulWidget {
  const UserMenuDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const UserMenuDialog());
  }

  @override
  State<UserMenuDialog> createState() => _UserMenuDialogState();
}

class _UserMenuDialogState extends State<UserMenuDialog> {
  String? shopBalance;
  bool isLoadingBalance = true;

  bool isShopFound = false;

  @override
  void initState() {
    super.initState();
    _fetchShopBalance();
  }

  Future<void> _fetchShopBalance() async {
    final shopId =
        AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '';
    if (shopId.isEmpty) {
      setState(() {
        isLoadingBalance = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/shops/$shopId'),
        headers: {
          'Content-Type': 'application/json',
          'x-request-from': 'Dashboard',
          'shop-id': shopId,
          'user-id':
              AuthService.instance.authCustomer?.user?.id?.toString() ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balance = data['shop']?['balance'];
        if (mounted) {
          setState(() {
            if (data['shop'] != null) {
              isShopFound = true;
            }
            shopBalance = balance?.toString() ?? '0.00';
            isLoadingBalance = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingBalance = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isShopFound = false;
          isLoadingBalance = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Profile Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo.png', // Your logo
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.store,
                              color: Color(0xFFF97316),
                              size: 30,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AuthService.instance.authCustomer?.user?.firstName !=
                                  null
                              ? '${AuthService.instance.authCustomer?.user?.firstName ?? ''} ${AuthService.instance.authCustomer?.user?.lastName ?? ''}'
                              : 'Tjara Group',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AuthService.instance.authCustomer?.user?.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  if (isShopFound)
                    // Shop Balance
                    _MenuItem(
                      icon: Icons.store_outlined,
                      title: 'Shop Balance:',
                      trailing:
                          isLoadingBalance
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFF97316),
                                ),
                              )
                              : Text(
                                '\$${shopBalance ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF97316),
                                ),
                              ),
                      onTap: null,
                    ),
                  if (isShopFound) const Divider(height: 1, thickness: 1),

                  // Reseller Balance
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Reseller Balance:',
                    trailing: Text(
                      '\$${BalanceService.to.resellerProgram.value?.balance ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF97316),
                      ),
                    ),
                    onTap: null,
                  ),

                  const Divider(height: 1, thickness: 1),

                  // Switch Account
                  if (AuthService.instance.authCustomer?.user?.role ==
                          'admin' ||
                      AuthService.instance.authCustomer?.user?.role == 'vendor')
                    _MenuItem(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Switch Account',
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade600,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        SwitchAccountDialog.show(
                          context,
                          AuthService.instance.authCustomer?.user?.email ?? '',
                        );
                      },
                    ),
                  if (AuthService.instance.authCustomer?.user?.role == 'admin')
                    const Divider(height: 1, thickness: 1),

                  // Profile Info
                  _MenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile Info',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade600,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const ProfileScreen());
                    },
                  ),

                  const Divider(height: 1, thickness: 1),

                  // Reset Password
                  _MenuItem(
                    icon: Icons.lock_outline,
                    title: 'Reset Password',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade600,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to reset password
                    },
                  ),

                  const Divider(height: 1, thickness: 1),

                  // Logout
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade600,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await _handleLogout(context);
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      Get.until((route) => route.isFirst);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      AuthService.instance.cleanStorage();
      WishlistServiceController.instance.initCall();
      Get.find<NotificationService>().initCall();
      final CartService cartService = Get.find<CartService>();
      cartService.initcall();
      DashboardController.instance.changeIndex(0);

      NotificationHelper.showSuccess(
        context,
        'Success',
        'User logged out successfully',
      );
    } catch (e) {
      Get.until((route) => route.isFirst);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      AuthService.instance.cleanStorage();
      DashboardController.instance.changeIndex(0);

      NotificationHelper.showSuccess(
        context,
        'Success',
        'User logged out successfully',
      );
    }
  }
}

// Menu Item Widget
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.green.shade500),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// Switch Account Dialog
class SwitchAccountDialog extends StatefulWidget {
  final String email;

  const SwitchAccountDialog({super.key, required this.email});

  static void show(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SwitchAccountDialog(email: email),
    );
  }

  @override
  State<SwitchAccountDialog> createState() => _SwitchAccountDialogState();
}

class _SwitchAccountDialogState extends State<SwitchAccountDialog> {
  String? selectedRole;
  bool _isSwitching = false;
  final AuthService authService = AuthService.instance;

  List<Map<String, String>> get roles {
    final userRole =
        AuthService.instance.authCustomer?.user?.role?.toLowerCase();
    if (userRole == 'admin') {
      return [
        {'role': 'admin', 'label': 'Admin'},
        {'role': 'vendor', 'label': 'Vendor'},
        {'role': 'customer', 'label': 'Customer'},
      ];
    } else {
      // Vendor can switch between vendor and customer
      return [
        {'role': 'vendor', 'label': 'Vendor'},
        {'role': 'customer', 'label': 'Customer'},
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    selectedRole =
        authService.authCustomer?.user?.meta?.dashboardView?.toLowerCase() ??
        authService.role;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Switch Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Role Options
            ...roles.map(
              (roleData) =>
                  _buildRoleOption(roleData['role']!, roleData['label']!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role, String label) {
    final isSelected = selectedRole?.toLowerCase() == role.toLowerCase();

    return GestureDetector(
      onTap:
          _isSwitching
              ? null
              : () {
                setState(() {
                  selectedRole = role;
                });
                _switchRole(role);
              },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFF97316) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Logo/Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.store,
                        color: Color(0xFFF97316),
                        size: 24,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Role Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'test Group - ($label)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.email,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Loading or Radio Button
            if (_isSwitching && isSelected)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFF97316),
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFFF97316)
                            : Colors.grey.shade400,
                    width: 2,
                  ),
                  color:
                      isSelected ? const Color(0xFFF97316) : Colors.transparent,
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
          ],
        ),
      ),
    );
  }

  void _switchRole(String role) async {
    if (_isSwitching) return;

    setState(() {
      _isSwitching = true;
    });

    try {
      final response = await http.put(
        Uri.parse('https://api.libanbuy.com/api/users/switch-user-role'),
        headers: {
          'Content-Type': 'application/json',
          'x-request-from': 'Dashboard',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id':
              AuthService.instance.authCustomer?.user?.id?.toString() ?? '',
        },
        body: jsonEncode({'role': role.toLowerCase()}),
      );

      if (response.statusCode == 200) {
        // Update dashboardView in auth state
        final currentAuth = authService.authCustomer;
        if (currentAuth != null && currentAuth.user != null) {
          final updatedMeta =
              currentAuth.user!.meta != null
                  ? currentAuth.user!.meta!.copyWith(
                    dashboardView: role.toLowerCase(),
                  )
                  : Meta(dashboardView: role.toLowerCase());
          final updatedUser = currentAuth.user!.copyWith(meta: updatedMeta);
          final updatedAuth = currentAuth.copyWith(user: updatedUser);
          authService.saveAuthState(updatedAuth);
        }

        // Update role
        authService.updateRole(role.toLowerCase());

        // Close dialog
        if (!mounted) return;
        Navigator.of(context).pop();

        // Navigate to dashboard
        Get.until((route) => route.isFirst);
        Get.toNamed(Routes.DASHBOARD_ADMIN);

        // Show success message
        Get.snackbar(
          'Account Switched',
          'Successfully switched to ${role.toUpperCase()} account',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF0D9488),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      } else {
        setState(() {
          _isSwitching = false;
        });
        Get.snackbar(
          'Error',
          'Failed to switch account. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
    } catch (e) {
      setState(() {
        _isSwitching = false;
      });
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }
}

// Helper to show user menu dialog
class UserMenuHelper {
  static void showUserMenu(BuildContext context) {
    UserMenuDialog.show(context);
  }
}

// Usage Example:
// In your app bar or profile icon:
/*
IconButton(
  icon: Icon(Icons.person),
  onPressed: () => UserMenuDialog.show(context),
)
*/
