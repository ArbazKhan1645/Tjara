// ignore_for_file: deprecated_member_use, strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart'; // Add this package
import 'package:tjara/app/core/widgets/appbar.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/modules/authentication/dialogs/auth_wrapper.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/modules/authentication/dialogs/login.dart';
import 'package:tjara/app/modules/modules_customer/tjara_blogs/blogs.dart';
import 'package:tjara/app/modules/modules_customer/tjara_faqs/faqs.dart';
import 'package:tjara/app/modules/modules_customer/app_home/controllers/home_controller.dart';
import 'package:tjara/app/modules/modules_customer/app_home/views/home_view.dart';
import 'package:tjara/app/modules/modules_customer/dashboard_more/views/more_view.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/views/my_cart_view.dart';
import 'package:tjara/app/modules/modules_customer/tjara_privacy_policy/policy_view.dart';
import 'package:tjara/app/modules/modules_customer/tjara_terms/terms.dart';
import 'package:tjara/app/modules/modules_customer/user_wishlist/views/wishlist_view.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/modules/modules_customer/app_home/screens/drawer_categories.dart';
import 'package:tjara/app/modules/modules_customer/customer_cart/controllers/my_cart_controller.dart';
import 'package:tjara/app/modules/modules_customer/customer_dashboard/controllers/dashboard_controller.dart';

/// Wrapper to handle back navigation
class NoPopNavWrapper extends StatelessWidget {
  final Widget child;

  const NoPopNavWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _handleBackPress(),
      child: child,
    );
  }

  _handleBackPress() {
    final DashboardController controller =
        Get.isRegistered<DashboardController>()
            ? Get.find<DashboardController>()
            : Get.put(DashboardController());
    final HomeController homeController =
        Get.isRegistered<HomeController>()
            ? Get.find<HomeController>()
            : Get.put(HomeController());

    try {
      if (homeController.selectedCategory != null) {
        homeController.selectedCategory = null;
        homeController.update();
        controller.changeIndex(0);
        return;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    if (controller.selectedIndex.value != 0) {
      controller.changeIndex(0);
      return;
    }

    final now = DateTime.now();
    if (controller.lastPressed == null ||
        now.difference(controller.lastPressed!) > const Duration(seconds: 2)) {
      controller.lastPressed = now;
      Get.snackbar(
        "Exit",
        "Press again to exit",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    SystemNavigator.pop();
  }
}

/// Main Dashboard View with optimized memory management
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBackPress();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: controller.scaffoldKey,
        // drawer: _buildCustomDrawer(context),
        backgroundColor: Colors.white,
        body: _buildOptimizedBody(),
        bottomNavigationBar: _buildModernBottomNav(),
      ),
    );
  }

  void _handleBackPress() {
    AppBarController.instance.clearSearch();
    try {
      final homeController = Get.find<HomeController>();
      if (homeController.selectedCategory != null) {
        homeController.selectedCategory = null;
        homeController.update();
        controller.changeIndex(0);

        return;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    if (controller.selectedIndex.value != 0) {
      controller.changeIndex(0);
      return;
    }

    final now = DateTime.now();
    if (controller.lastPressed == null ||
        now.difference(controller.lastPressed!) > const Duration(seconds: 2)) {
      controller.lastPressed = now;
      Get.snackbar(
        "Exit",
        "Press again to exit",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    SystemNavigator.pop();
  }

  Widget _buildCustomDrawer(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: const Drawer(
        backgroundColor: Colors.white,
        child: CategoriesScreen(),
      ),
    );
  }

  /// Sign-in banner shown when user is not logged in
  Widget _buildSignInBanner() {
    return Obx(() {
      final isLoggedIn =
          AuthService.instance.authCustomerRx.value?.user != null;

      if (isLoggedIn) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(Iconsax.user, color: Color(0xFFF97316), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Sign in for best experience',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showContactDialog(Get.context!, const LoginUi());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Optimized body - Home stays in memory, others rebuild
  Widget _buildOptimizedBody() {
    return Obx(() {
      return IndexedStack(
        index: controller.selectedIndex.value,
        children: [
          const NoPopNavWrapper(child: HomeView()), // Home stays in memory
          const NoPopNavWrapper(child: CategoriesScreen()),

          controller.selectedIndex.value == 2
              ? AuthService.instance.authCustomerRx.value?.user != null
                  ? const NoPopNavWrapper(child: MoreView())
                  : const NoPopNavWrapper(child: AuthWrapper())
              : const NoPopNavWrapper(child: SizedBox.shrink()),

          controller.selectedIndex.value == 3
              ? const NoPopNavWrapper(child: MyCartView())
              : const NoPopNavWrapper(child: SizedBox.shrink()),
          controller.selectedIndex.value == 4
              ? const NoPopNavWrapper(child: WishlistView())
              : const NoPopNavWrapper(child: SizedBox.shrink()),

          controller.selectedIndex.value == 5
              ? const NoPopNavWrapper(child: PrivacyPolicyScreen())
              : const NoPopNavWrapper(child: SizedBox.shrink()),
          controller.selectedIndex.value == 6
              ? const NoPopNavWrapper(child: TermsOfServiceScreen())
              : const NoPopNavWrapper(child: SizedBox.shrink()),
          controller.selectedIndex.value == 7
              ? const NoPopNavWrapper(child: HelpCenterScreen())
              : const NoPopNavWrapper(child: SizedBox.shrink()),
          controller.selectedIndex.value == 8
              ? const NoPopNavWrapper(child: BlogListScreen())
              : const NoPopNavWrapper(child: SizedBox.shrink()),
        ],
      );
    });
  }

  /// Modern bottom navigation with Iconsax icons
  Widget _buildModernBottomNav() {
    return Obx(() {
      final isLoggedIn =
          AuthService.instance.authCustomerRx.value?.user != null;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 63,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Iconsax.home,
                  activeIcon: Iconsax.home_25,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Iconsax.search_status,
                  activeIcon: Iconsax.category5,
                  label: 'Categories',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Iconsax.user,
                  activeIcon: Iconsax.user,
                  label: 'You',
                ),

                _buildNavItem(
                  index: 3,
                  icon: Iconsax.shopping_cart,
                  activeIcon: Iconsax.shopping_cart5,
                  label: 'Cart',
                  badgeCount: controller.cartCount.value,
                ),
                if (isLoggedIn)
                  _buildNavItem(
                    index: 4,
                    icon: Iconsax.heart,
                    activeIcon: Iconsax.heart,
                    label: 'Wishlist',
                    badgeCount: controller.wishlistCount.value,
                  )
                else
                  _buildPromoItem(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final color = isSelected ? const Color(0xFFF97316) : Colors.grey.shade600;

      return Expanded(
        child: InkWell(
          onTap: () => _handleNavItemTap(index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? activeIcon : icon,
                      color: color,
                      size: 24,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -10,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 16,
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : badgeCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Promo item shown when user is not logged in (replaces wishlist)
  Widget _buildPromoItem() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _handlePromoTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.truck_fast, color: Colors.white, size: 14),
                    SizedBox(width: 2),
                    Text(
                      'FREE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Limited-time',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal,
                ),
                maxLines: 1,
              ),
              const Text(
                'Free Shipping',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavItemTap(int index) {
    AppBarController.instance.clearSearch();
    switch (index) {
      case 0:
        _handleHomeTap();
        break;
      case 1:
        controller.changeIndex(index);
        break;
      case 4:
        controller.changeIndex(index);
        break;
      case 3:
        AppBarController.instance.clearSearch();
        final cartService = Get.find<CartService>();
        cartService.initcall();

        controller.changeIndex(3);
        break;
      case 2:
        controller.changeIndex(index);
        break;
    }
  }

  void _handleHomeTap() {
    AppBarController.instance.clearSearch();
    final homeController = Get.find<HomeController>();
    homeController.selectedCategory = null;
    homeController.update();
    controller.changeIndex(0);
  }

  void _handlePromoTap() {
    AppBarController.instance.clearSearch();
    final homeController = Get.find<HomeController>();
    homeController.selectedCategory = null;
    homeController.update();
    controller.changeIndex(0);
    homeController.searchProducts('sale');
    homeController.setSelectedCategory(ProductAttributeItems());
  }

  void _handleCartTap() {
    AppBarController.instance.clearSearch();
    final cartService = Get.find<CartService>();
    cartService.initcall();
    Get.to(() => const MyCartView());
    // controller.changeIndex(3);
  }

  void _handleMoreTap() {
    AppBarController.instance.clearSearch();
    if (AuthService.instance.authCustomerRx.value?.user == null) {
      showContactDialog(Get.context!, const LoginUi());
    } else {
      controller.changeIndex(2);
    }
  }
}
