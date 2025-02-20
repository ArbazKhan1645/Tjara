// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import '../controllers/home_controller.dart';

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  static const double _kInitialScrollProgress = 0.2;
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(-1);
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollProgress =
      ValueNotifier<double>(_kInitialScrollProgress);

  late final HomeController _controller;
  List<Map<String, String>> _categoryList = [];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
    _scrollController.addListener(_updateScrollProgress);
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

  void _updateScrollProgress() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent == 0) {
      return;
    }

    final progress =
        _scrollController.offset / _scrollController.position.maxScrollExtent;
    _scrollProgress.value =
        (progress.isNaN ? _kInitialScrollProgress : progress).clamp(0.2, 1.0);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    _selectedIndex.dispose();
    _scrollProgress.dispose();
    super.dispose();
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

      final int midIndex = (_categoryList.length / 2).ceil();
      final topCategories = _categoryList.sublist(0, midIndex);
      final bottomCategories = _categoryList.sublist(midIndex);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryRow(
                    categories: topCategories,
                    startIndex: 0,
                    selectedIndexNotifier: _selectedIndex,
                  ),
                  const SizedBox(height: 15),
                  _CategoryRow(
                    categories: bottomCategories,
                    startIndex: midIndex,
                    selectedIndexNotifier: _selectedIndex,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<double>(
            valueListenable: _scrollProgress,
            builder: (context, progress, _) {
              return _ScrollProgressIndicator(progress: progress);
            },
          ),
        ],
      );
    });
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.startIndex,
    required this.selectedIndexNotifier,
  });

  final List<Map<String, String>> categories;
  final int startIndex;
  final ValueNotifier<int> selectedIndexNotifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.asMap().entries.map((entry) {
        final int index = entry.key + startIndex;
        final category = entry.value;
        return _CategoryItem(
          category: category,
          index: index,
          selectedIndexNotifier: selectedIndexNotifier,
        );
      }).toList(),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.index,
    required this.selectedIndexNotifier,
  });

  final Map<String, String> category;
  final int index;
  final ValueNotifier<int> selectedIndexNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndexNotifier,
      builder: (context, selectedIndex, _) {
        final bool isSelected = index == selectedIndex;
        return GestureDetector(
          onTap: () {
            selectedIndexNotifier.value = index;
            var controller = Get.find<HomeController>();
            controller.fetchCategoryProducts(controller
                .categories.value.productAttributeItems!.first.id
                .toString());

            controller.setSelectedCategory(
                controller.categories.value.productAttributeItems?.first ??
                    ProductAttributeItems());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: 84,
              child: Column(
                children: [
                  _CategoryImage(
                      key: ValueKey('image_${category["icon"]}'),
                      imageUrl: category['icon']!),
                  const SizedBox(height: 5),
                  Text(
                    category["name"]!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isSelected ? Colors.red : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Color(0xffD21642), width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
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
