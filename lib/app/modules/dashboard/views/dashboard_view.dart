// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/categories/views/categories_view.dart';
import 'package:tjara/app/modules/dialogs/contact_us.dart';
import 'package:tjara/app/modules/dialogs/login.dart';
import 'package:tjara/app/modules/dialogs/signUpaccount.dart';
import 'package:tjara/app/modules/home/views/home_view.dart';
import 'package:tjara/app/modules/home/widgets/auth.dart';
import 'package:tjara/app/modules/more/views/more_view.dart';
import 'package:tjara/app/modules/my_account/views/my_account_view.dart';
import 'package:tjara/app/modules/my_cart/views/my_cart_view.dart';
import '../../home/widgets/drawer_categories.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      builder: (controller) {
        return Scaffold(
          key: controller.scaffoldKey,
          drawer: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width / 1.5,
              child: Drawer(
                child: DrawerCategories(),
              )),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.29),
                  offset: Offset(0, 2.64),
                  blurRadius: 33.05,
                  spreadRadius: 0,
                ),
              ],
            ),
            height: 75,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(0, 'assets/icons/home.png', "Home", context),
                  _buildNavItem(
                      1, 'assets/icons/apps.png', "Categories", context),
                  _buildNavItem(2, 'assets/icons/user.png', "Account", context),
                  _buildNavItem(3, 'assets/icons/bag.png', "My Cart", context),
                  _buildNavItem(4, 'assets/icons/menu.png', "More", context),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.grey.shade100,
          body: Obx(() {
            switch (controller.selectedIndex.value) {
              case 0:
                return HomeView();
              case 1:
                return CategoriesView();
              case 2:
                return MyAccountView();
              case 3:
                return MyCartView();
              case 4:
                return MoreView();
              default:
                return HomeView();
            }
          }),
        );
      },
    );
  }

  Widget _buildNavItem(
      int index, String iconPath, String label, BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
        bool isSelected = controller.selectedIndex.value == index;

        return InkWell(
          onTap: () {
            if (index == 1) {
              controller.scaffoldKey.currentState?.openDrawer();
            } else if (index == 2) {
              showContactDialog(context, LoginUi());
            } else if (index == 3) {
              controller.changeIndex(index);
            } else {
              controller.changeIndex(index);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconPath,
                height: 24,
                width: 24,
                color: isSelected ? Colors.green : Colors.black,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.green : Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
