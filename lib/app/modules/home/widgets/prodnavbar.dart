// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/my_colors.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:tjara/app/routes/app_pages.dart';

class ProductNavBar extends StatefulWidget {
  const ProductNavBar({super.key});

  @override
  State<ProductNavBar> createState() => _ProductNavBarState();
}

class _ProductNavBarState extends State<ProductNavBar> {
  final List<String> categories = const [
    "All",
    "On Sale",
    "Featured Products",
    "Cars",
    'Hot Auctions',
    'Jobs',
    'Services',
    'Contests',
  ];

  // Cache the HomeController to avoid multiple lookups
  late final HomeController _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => _buildCategoryItem(index),
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    return Obx(() {
      final int selectedIndex = _homeController.selectedIndexProducts.value;
      final bool isSelected = selectedIndex == index;

      return Padding(
        padding: const EdgeInsets.only(right: 20, left: 12),
        child: GestureDetector(
          onTap: () => _onCategoryTapped(index),
          child: Center(
            child: Container(
              padding: isSelected ? const EdgeInsets.all(10) : null,
              child: Text(
                categories[index],
                style: defaultTextStyle.copyWith(
                  decoration: isSelected ? TextDecoration.underline : null,
                  decorationColor: isSelected ? AppColors.primaryColor : null,
                  decorationStyle:
                      isSelected ? TextDecorationStyle.double : null,
                  color:
                      isSelected ? const Color(0xFF0D9488) : const Color(0xff000000),
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _onCategoryTapped(int index) {
    if (index == 5) {
      Get.toNamed(Routes.TJARA_JOBS);
    } else if (index == 6) {
      Get.toNamed(Routes.SERVICES);
    } else if (index == 7) {
      Get.toNamed(Routes.CONTESTS);
    } else {
      _homeController.setSelectedIndexProducts(index);
      if (index == 0) {
        // All products already loaded; keep existing list
        _homeController.update(['product_grid']);
      } else {
        // Prepare UI and then load first page for filtered tabs
        _homeController.startFilteredLoading();
        _homeController.loadFilteredFirstPage(index);
      }
    }
  }
}
