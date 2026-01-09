import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:tjara/app/routes/app_pages.dart';

/// Temu-style horizontal scrollable category tabs
class CategoryTabsWidget extends StatelessWidget {
  const CategoryTabsWidget({super.key});

  static const List<_CategoryItem> _categories = [
    _CategoryItem('All', 0),
    _CategoryItem('On Sale', 1),
    _CategoryItem('Featured', 2),
    _CategoryItem('Cars', 3),
    _CategoryItem('Auctions', 4),
    _CategoryItem('Jobs', 5),
    _CategoryItem('Services', 6),
    _CategoryItem('Contests', 7),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF97316),
      child: SizedBox(
        height: 34,

        child: GetBuilder<HomeController>(
          builder: (controller) {
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(0),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _buildCategoryChip(_categories[index], controller);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(_CategoryItem category, HomeController controller) {
    return Obx(() {
      final isSelected =
          controller.selectedIndexProducts.value == category.index;

      return GestureDetector(
        onTap: () => _onCategoryTap(category.index, controller),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 08, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            category.name,

            style: TextStyle(
              decoration: isSelected ? TextDecoration.underline : null,
              decorationColor: Colors.white,
              fontSize: 14,

              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white70,
            ),
          ),
        ),
      );
    });
  }

  void _onCategoryTap(int index, HomeController controller) {
    // Handle special navigation items
    if (index == 5) {
      Get.toNamed(Routes.TJARA_JOBS);
      return;
    } else if (index == 6) {
      Get.toNamed(Routes.SERVICES);
      return;
    } else if (index == 7) {
      Get.toNamed(Routes.CONTESTS);
      return;
    }

    controller.setSelectedIndexProducts(index);
    if (index == 0) {
      controller.update(['product_grid']);
    } else {
      controller.startFilteredLoading();
      controller.loadFilteredFirstPage(index);
    }
  }
}

class _CategoryItem {
  final String name;
  final int index;

  const _CategoryItem(this.name, this.index);
}
