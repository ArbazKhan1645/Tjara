// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/modules/admin/profile/profile.dart';
import 'package:tjara/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/my_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/wishlist/controllers/wishlist_service.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/dashbopard_services/balance_service.dart';
import 'package:tjara/app/services/notifications/notification_service.dart';

class OverlayMenu extends StatefulWidget {
  final Widget child;
  final List<Widget>? Function(VoidCallback closeOverlay)? children;
  final double? menuWidth;
  const OverlayMenu({
    super.key,
    required this.child,
    this.children,
    this.menuWidth,
  });

  @override
  State<OverlayMenu> createState() => _OverlayMenuState();
}

class _OverlayMenuState extends State<OverlayMenu> {
  OverlayEntry? _overlayEntry;

  void _showOverlay(BuildContext context, TapDownDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final double menuWidth = widget.menuWidth ?? 250;
    const double menuHeight = 180; // Adjust as needed
    double left = details.globalPosition.dx;
    double top = details.globalPosition.dy;

    // Adjust position if it overflows
    if (left + menuWidth > screenSize.width) {
      left = screenSize.width - menuWidth - 10;
    }
    if (top + menuHeight > screenSize.height) {
      top = screenSize.height - menuHeight - 10;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Full screen gesture detector to close overlay
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: GestureDetector(
                // Prevent taps on the menu from closing it
                onTap: () {},
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: menuWidth,
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height * 0.6, // Limit height
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children:
                            widget.children?.call(_removeOverlay) ??
                            [
                              _menuItem(
                                "Hello! ${AuthService.instance.authCustomer?.user?.firstName ?? 'User'} ${AuthService.instance.authCustomer?.user?.lastName ?? 'User'}",
                                Icons.person,
                                null,
                                false,
                              ),
                              const Divider(),
                              if (AuthService
                                      .instance
                                      .authCustomer
                                      ?.user
                                      ?.role ==
                                  'admin')
                                _menuItem(
                                  "Shop Balance: \$${BalanceService.to.shop.value?.balance ?? '0.00'}",
                                  Icons.shop,
                                  null,
                                  false,
                                ),
                              _menuItem(
                                "Reseller Balance: \$${BalanceService.to.resellerProgram.value?.balance ?? '0.00'}",
                                Icons.reset_tv_outlined,
                                null,
                                false,
                              ),
                              const SizedBox(height: 10),

                              _menuItem("Profile Info", Icons.info, () {
                                Get.to(() => const ProfileScreen());
                              }),
                              const SizedBox(height: 10),

                              if (AuthService
                                      .instance
                                      .authCustomer
                                      ?.user
                                      ?.role ==
                                  'admin')
                                _menuItem(
                                  "Switch Account",
                                  Icons.swap_horizontal_circle_sharp,
                                  () {
                                    RoleSelectionHelper.showRoleSelectionDialog(
                                      context,
                                      AuthService
                                              .instance
                                              .authCustomer
                                              ?.user
                                              ?.email ??
                                          '',
                                    );
                                  },
                                ),
                              const Divider(),
                              _menuItem("Log Out", Icons.logout, () async {
                                try {
                                  Get.until((route) => route.isFirst);
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.clear();
                                  AuthService.instance.cleanStorage();
                                  WishlistServiceController.instance.initCall();
                                  Get.find<NotificationService>().initCall();
                                  final CartService cartService =
                                      Get.find<CartService>();
                                  cartService.initcall();

                                  DashboardController.instance.changeIndex(0);
                                  NotificationHelper.showSuccess(
                                    context,
                                    'Success',
                                    'User log out Sucessfully',
                                  );
                                } on Exception {
                                  Get.until((route) => route.isFirst);
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.clear();
                                  AuthService.instance.cleanStorage();
                                  DashboardController.instance.changeIndex(0);
                                  NotificationHelper.showSuccess(
                                    context,
                                    'Success',
                                    'User log out Sucessfully',
                                  );
                                }
                              }),
                            ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _menuItem(
    String text,
    IconData icon,
    VoidCallback? onTap, [
    bool closeOnTap = true,
    Widget? trailing,
  ]) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: trailing,
      onTap: () {
        if (closeOnTap) _removeOverlay();
        onTap?.call();
      },
    );
  }

  void _removeOverlay() {
    debugPrint("Overlay remove requested");
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _showOverlay(context, details),
      child: widget.child,
    );
  }
}
