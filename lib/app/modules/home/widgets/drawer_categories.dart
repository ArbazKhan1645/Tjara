import 'package:flutter/material.dart';
// ignore_for_file: deprecated_member_use

import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import '../controllers/home_controller.dart';

class DrawerCategories extends StatefulWidget {
  const DrawerCategories({super.key});

  @override
  State<DrawerCategories> createState() => _DrawerCategoriesState();
}

class _DrawerCategoriesState extends State<DrawerCategories> {
  late final HomeController _controller;
  List<Map<String, String>> _categoryList = [];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();

    _initializeCategoryList();
  }

  void _initializeCategoryList() {
    _categoryList = _controller.categories.value.productAttributeItems
            ?.where((e) => e.thumbnail?.media?.url != null && e.name != null)
            .map((e) => {
                  "icon": e.thumbnail!.media!.url!,
                  "name": e.name!,
                })
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.categories.value.productAttributeItems == null) {
        return const SizedBox.shrink();
      }
      _initializeCategoryList();

      if (_categoryList.isEmpty) {
        return const SizedBox.shrink();
      }

      final topCategories = _categoryList;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categories', style: TextStyle(fontSize: 20)),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.cancel))
              ],
            ),
          ),
          Expanded(
            child: _CategoryRow(
              categories: topCategories,
              startIndex: 0,
            ),
          ),
        ],
      );
    });
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories, required this.startIndex});

  final List<Map<String, String>> categories;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          childAspectRatio: 0.8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final int realIndex = index + startIndex;
        final category = categories[index];
        return _CategoryItem(
          category: category,
          index: realIndex,
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.index,
  });

  final Map<String, String> category;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          child: Column(
            children: [
              _CategoryImage(
                  key: ValueKey('image_${category["icon"]}'),
                  imageUrl: category['icon']!),
              const SizedBox(height: 5),
              Text(
                category["name"].toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryImage extends StatefulWidget {
  const _CategoryImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  State<_CategoryImage> createState() => _CategoryImageState();
}

class _CategoryImageState extends State<_CategoryImage> {
  bool isHovered = false;
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isHovered || isTapped
            ? [
                BoxShadow(
                    color: Colors.red.withOpacity(0.50),
                    // offset: const Offset(0, 0),
                    blurRadius: 0.10,
                    spreadRadius: 0.5)
              ]
            : null,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => isTapped = true),
          onTapUp: (_) => setState(() => isTapped = false),
          onTapCancel: () => setState(() => isTapped = false),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            tween: Tween<double>(
              begin: 1.0,
              end: isTapped ? 0.85 : (isHovered ? 0.85 : 1.0),
            ),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Color(0xffD21642), width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    cacheManager: PersistentCacheManager(),
                    imageUrl: widget.imageUrl,
                    imageBuilder: (context, imageProvider) =>
                        _buildCircularImage(imageProvider),
                    errorWidget: (context, url, error) => _buildErrorWidget(),
                    placeholder: (context, url) => _buildShimmer(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCircularImage(ImageProvider imageProvider) {
    return ClipOval(
      child: Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return ClipOval(
      child: Container(
        width: 74,
        height: 74,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/icons/logo.png'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ClipOval(
      child: Container(
        width: 74,
        height: 74,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
      ).animate().fade(duration: 500.ms),
    );
  }
}

class _ScrollProgressIndicator extends StatelessWidget {
  const _ScrollProgressIndicator({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 250,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            color: Colors.red,
            minHeight: 4,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}

Widget _buildShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: ClipOval(
      child: Container(
        width: 74,
        height: 74,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}
