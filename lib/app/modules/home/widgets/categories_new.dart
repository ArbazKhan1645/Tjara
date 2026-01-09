// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tjara/app/core/dialogs/dialogs.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/core/widgets/filter_dialog.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/modules/home/controllers/home_controller.dart';

class CategorySectionNew extends StatefulWidget {
  const CategorySectionNew({super.key});

  @override
  State<CategorySectionNew> createState() => _CategorySectionNewState();
}

class _CategorySectionNewState extends State<CategorySectionNew> {
  final PageStorageBucket _bucket = PageStorageBucket();
  final double _categoryItemWidth = 84;
  final double _categoryImageSize = 70; // Thoda chota for circular look

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      builder: (controller) {
        if (controller.categories.value.productAttributeItems == null ||
            controller.categoryList.isEmpty) {
          return const SizedBox.shrink();
        }

        return PageStorage(
          bucket: _bucket,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFfea52d), // top
                  const Color(0xFFfea52d).withOpacity(0.05), // fade
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildCategoryList(controller),
                _buildFilterBar(controller),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryList(HomeController controller) {
    return SizedBox(
      height: 120, // Increased for circular design
      child: _OptimizedCategoryRow(
        categories: controller.allCategories,
        itemWidth: _categoryItemWidth,
        imageSize: _categoryImageSize,
      ),
    );
  }

  Widget _buildFilterBar(HomeController controller) {
    return SizedBox(
      child: Row(
        children: [
          const SizedBox(width: 10),
          _FilterButton(
            icon: Icons.filter_list_rounded,
            label: 'Filter',
            width: 150,
            onTap: () async => await _handleFilterTap(controller),
          ),
          const SizedBox(width: 10),
          _FilterButton(
            icon: Icons.arrow_forward_ios,
            label: controller.selectedFilter.value.toString(),
            width: 200,
            onTap: () async => await _handleSortTap(controller),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Future<void> _handleFilterTap(HomeController controller) async {
    final res = await showFilterBottomSheet(context);
    if (res != null && res is Map<String, double>) {
      controller.minFilter.value = res['min'] as double;
      controller.maxFilter.value = res['max'] as double;
      controller.filterCategoryProductss(
        controller.selectedFilter.value,
        res['min'] as double,
        res['max'] as double,
        context,
      );
    }
  }

  Future<void> _handleSortTap(HomeController controller) async {
    final res = await showdialogwidget(
      context,
      controller.selectedFilter.value,
    );
    if (res != null) {
      controller.filterCategoryProductss(
        res,
        controller.minFilter.value,
        controller.maxFilter.value,
        context,
      );
    }
  }
}

class _OptimizedCategoryRow extends StatelessWidget {
  const _OptimizedCategoryRow({
    required this.categories,
    required this.itemWidth,
    required this.imageSize,
  });

  final List<Map<String, dynamic>> categories;
  final double itemWidth;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,

      itemCount: categories.length,
      shrinkWrap: true,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        return _CategoryItem(
          category: categories[index],
          itemWidth: itemWidth,
          imageSize: imageSize,
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.itemWidth,
    required this.imageSize,
  });

  final Map<String, dynamic> category;
  final double itemWidth;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    // ✨ Dynamic color aur icon
    final categoryName = category["name"]?.toString() ?? 'Unknown';
    final bgColor = CategoryColorHelper.getColorFromName(categoryName);
    final fallbackIcon = CategoryColorHelper.getIconFromName(categoryName);

    return GestureDetector(
      onTap: () => _handleCategoryTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: itemWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✨ Circular container with gradient border
              _OptimizedCategoryImage(
                imageUrl: category['icon'] ?? '',
                size: imageSize,
                bgColor: bgColor,
                fallbackIcon: fallbackIcon,
              ),
              const SizedBox(height: 8),
              Expanded(child: _CategoryName(name: categoryName)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCategoryTap() async {
    final controller = Get.find<HomeController>();
    await controller.setSelectedCategory(
      category['model'] ?? ProductAttributeItems(),
    );
    controller.fetchCategoryProductsa(category["id"].toString());
  }
}

class _CategoryName extends StatelessWidget {
  const _CategoryName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// ========================================
// ✨ UPDATED: Circular Image with Fallback Icon
// ========================================
class _OptimizedCategoryImage extends StatelessWidget {
  const _OptimizedCategoryImage({
    required this.imageUrl,
    required this.size,
    required this.bgColor,
    required this.fallbackIcon,
  });

  final String imageUrl;
  final double size;
  final Color bgColor;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: bgColor.withOpacity(0.4), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child:
            imageUrl.isNotEmpty
                ? CachedNetworkImage(
                  cacheManager: PersistentCacheManager(),
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildIconPlaceholder(),
                  errorWidget: (context, url, error) => _buildIconPlaceholder(),
                )
                : _buildIconPlaceholder(),
      ),
    );
  }

  Widget _buildIconPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, bgColor.withOpacity(0.7)],
        ),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: size * 0.45, // Icon size = 45% of container
          color: Colors.white,
        ),
      ),
    );
  }
}

// ========================================
// 🎨 Helper: Dynamic Color & Icon Generator
// ========================================
class CategoryColorHelper {
  static Color getColorFromName(String name) {
    final colors = [
      const Color(0xFF2C6B7A), // Blue-green
      const Color(0xFF4A90E2), // Blue
      const Color(0xFFF5A623), // Orange
      const Color(0xFF50C9CE), // Cyan
      const Color(0xFF2D5E3F), // Green
      const Color(0xFFE8A23D), // Yellow
      const Color(0xFFE76F6F), // Red
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF3498DB), // Light blue
      const Color(0xFFE67E22), // Dark orange
      const Color(0xFF1ABC9C), // Turquoise
      const Color(0xFFE74C3C), // Alizarin
    ];

    // Name se hash code nikal ke color assign
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  static IconData getIconFromName(String name) {
    final lowerName = name.toLowerCase();

    // Common keywords se icon match
    if (lowerName.contains('shoe') || lowerName.contains('foot')) {
      return Icons.shopping_bag;
    } else if (lowerName.contains('cloth') ||
        lowerName.contains('fashion') ||
        lowerName.contains('wear') ||
        lowerName.contains('dress')) {
      return Icons.checkroom;
    } else if (lowerName.contains('food') || lowerName.contains('eat')) {
      return Icons.fastfood;
    } else if (lowerName.contains('game') || lowerName.contains('play')) {
      return Icons.videogame_asset;
    } else if (lowerName.contains('home') || lowerName.contains('furniture')) {
      return Icons.weekend;
    } else if (lowerName.contains('cook') || lowerName.contains('kitchen')) {
      return Icons.restaurant;
    } else if (lowerName.contains('green') ||
        lowerName.contains('eco') ||
        lowerName.contains('plant')) {
      return Icons.eco;
    } else if (lowerName.contains('car') ||
        lowerName.contains('auto') ||
        lowerName.contains('vehicle')) {
      return Icons.directions_car;
    } else if (lowerName.contains('beauty') ||
        lowerName.contains('makeup') ||
        lowerName.contains('cosmetic')) {
      return Icons.face;
    } else if (lowerName.contains('electronic') ||
        lowerName.contains('tech') ||
        lowerName.contains('gadget')) {
      return Icons.devices;
    } else if (lowerName.contains('book') || lowerName.contains('read')) {
      return Icons.menu_book;
    } else if (lowerName.contains('sport') ||
        lowerName.contains('fitness') ||
        lowerName.contains('gym')) {
      return Icons.fitness_center;
    } else if (lowerName.contains('baby') ||
        lowerName.contains('kid') ||
        lowerName.contains('child')) {
      return Icons.child_care;
    } else if (lowerName.contains('pet') || lowerName.contains('animal')) {
      return Icons.pets;
    } else if (lowerName.contains('toy')) {
      return Icons.toys;
    } else if (lowerName.contains('watch') || lowerName.contains('time')) {
      return Icons.watch;
    } else if (lowerName.contains('bag') || lowerName.contains('backpack')) {
      return Icons.backpack;
    } else if (lowerName.contains('jewel') ||
        lowerName.contains('accessory') ||
        lowerName.contains('ring')) {
      return Icons.diamond;
    } else if (lowerName.contains('health') || lowerName.contains('medical')) {
      return Icons.health_and_safety;
    } else if (lowerName.contains('music') || lowerName.contains('audio')) {
      return Icons.headphones;
    } else if (lowerName.contains('phone') || lowerName.contains('mobile')) {
      return Icons.phone_iphone;
    }

    // Default icon
    return Icons.category;
  }
}

// ========================================
// 🎨 Updated Filter Button (Matching theme)
// ========================================
class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.width,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: icon == Icons.arrow_forward_ios ? 14 : 18,
                color: const Color(0xFFF97316),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon == Icons.arrow_forward_ios) const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
