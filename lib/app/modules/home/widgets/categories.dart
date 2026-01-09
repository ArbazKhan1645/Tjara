// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_icons/simple_icons.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key, this.isCarSection = false});

  final bool isCarSection;

  // Static categories list for general items
  static const List<Map<String, dynamic>> staticCategories = [
    {'name': 'Shoes', 'icon': Icons.shopping_bag, 'color': Color(0xFF2C6B7A)},
    {
      'name': 'Games',
      'icon': Icons.videogame_asset,
      'color': Color(0xFF4A90E2),
    },
    {'name': 'Clothing', 'icon': Icons.checkroom, 'color': Color(0xFFF5A623)},
    {'name': 'Home', 'icon': Icons.weekend, 'color': Color(0xFF50C9CE)},
    {'name': 'Greeko', 'icon': Icons.eco, 'color': Color(0xFF2D5E3F)},
    {'name': 'E-cook', 'icon': Icons.restaurant, 'color': Color(0xFFE8A23D)},
    {'name': 'Food', 'icon': Icons.fastfood, 'color': Color(0xFFE76F6F)},
  ];

  // Car brands categories list with actual brand logos
  static const List<Map<String, dynamic>> carCategories = [
    {
      'name': 'Chevrolet',
      'icon': FontAwesomeIcons.car,
      'color': Color(0xFFC41E3A),
    },
    {'name': 'Honda', 'icon': SimpleIcons.honda, 'color': Color(0xFF1E88E5)},
    {'name': 'BMW', 'icon': SimpleIcons.bmw, 'color': Color(0xFF333333)},
    {'name': 'Toyota', 'icon': SimpleIcons.toyota, 'color': Color(0xFFEB0A1E)},
    {'name': 'Ford', 'icon': SimpleIcons.ford, 'color': Color(0xFF004B87)},
    {'name': 'Kia', 'icon': SimpleIcons.kia, 'color': Color(0xFF05141F)},
    {'name': 'Suzuki', 'icon': SimpleIcons.suzuki, 'color': Color(0xFFE30613)},
  ];

  @override
  Widget build(BuildContext context) {
    final categories = isCarSection ? carCategories : staticCategories;
    final sectionTitle = isCarSection ? 'Car Brands' : 'Categories';

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          // Categories Row
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              top: 0,
              bottom: 8,
              right: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  categories.map((category) {
                    return Expanded(child: _CategoryItem(category: category));
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category});

  final Map<String, dynamic> category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: GestureDetector(
        onTap: () {
          try {
            DashboardController.instance.reset();
            final controller = Get.put(HomeController());
            controller.searchProducts(category['name']);
            controller.setSelectedCategory(ProductAttributeItems());
          } catch (e) {
            debugPrint('Error selecting subcategory: $e');
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: category['color'],
                shape: BoxShape.circle,
              ),
              child: Center(child: _getIconWidget(category['icon'])),
            ),
            const SizedBox(height: 6),
            // Category name
            Text(
              category['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconWidget(dynamic icon) {
    // Handle SimpleIcons (from simple_icons package)
    if (icon is IconData && icon.fontFamily == 'SimpleIcons') {
      return Icon(icon, size: 28, color: Colors.white);
    }
    // Handle FontAwesomeIcons
    else if (icon is IconData) {
      return FaIcon(icon, size: 24, color: Colors.white);
    }
    // Default Material icon
    return Icon(icon, size: 28, color: Colors.white);
  }
}
