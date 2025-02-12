// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/categories/views/categories_view.dart';
import 'package:tjara/app/modules/home/views/home_view.dart';
import 'package:tjara/app/modules/my_account/views/my_account_view.dart';
import 'package:tjara/app/modules/my_cart/views/my_cart_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      builder: (controller) {
        return Scaffold(
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
                  _buildNavItem(0, 'assets/icons/home.png', "Home"),
                  _buildNavItem(1, 'assets/icons/apps.png', "Categories"),
                  _buildNavItem(2, 'assets/icons/user.png', "Account"),
                  _buildNavItem(3, 'assets/icons/bag.png', "My Cart"),
                  _buildNavItem(4, 'assets/icons/menu.png', "More"),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.grey.shade100,
          // bottomNavigationBar: ClipRRect(
          //   borderRadius: const BorderRadius.only(
          //       topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       boxShadow: [
          //         BoxShadow(
          //           color: const Color(0xFF000000)
          //               .withOpacity(0.25), // Black with 25% opacity
          //           offset: const Offset(0, 4), // X: 0, Y: 4
          //           blurRadius: 84.7, // Blur: 34.7
          //           spreadRadius: 0, // Spread: 0
          //         ),
          //       ],
          //     ),
          //     child: BottomAppBar(
          //       shadowColor: Colors.grey,
          //       shape: const CircularNotchedRectangle(),
          //       notchMargin: 4,
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 10),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             _buildNavItem(0, 'assets/icons/home.png', "Home"),
          //             _buildNavItem(1, 'assets/icons/apps.png', "Categories"),
          //             _buildNavItem(2, 'assets/icons/user.png', "Account"),
          //             _buildNavItem(3, 'assets/icons/bag.png', "My Cart"),
          //             _buildNavItem(4, 'assets/icons/menu.png', "More"),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
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
                return Container();
              default:
                return HomeView();
            }
          }),
        );
      },
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    return GetBuilder<DashboardController>(
      builder: (controller) {
        bool isSelected = controller.selectedIndex.value == index;

        return InkWell(
          onTap: () => controller.changeIndex(index),
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
