import 'package:flutter/material.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/admin_ui_components.dart';

/// Shimmer effect widget
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey.shade200;
    final highlightColor = widget.highlightColor ?? Colors.grey.shade50;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Flash Deal Settings Shimmer - for loading state
class FlashDealSettingsShimmer extends StatelessWidget {
  const FlashDealSettingsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flash Deals Status Card
          _buildCardShimmer(height: 100),
          const SizedBox(height: 16),
          // Duration Card
          _buildCardShimmer(height: 180),
          const SizedBox(height: 16),
          // Interval Card
          _buildCardShimmer(height: 180),
          const SizedBox(height: 16),
          // Start Time Card
          _buildCardShimmer(height: 220),
          const SizedBox(height: 24),
          // Products Tabs
          _buildProductsTabsShimmer(),
        ],
      ),
    );
  }

  Widget _buildCardShimmer({required double height}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              ShimmerWidget(width: 32, height: 32, borderRadius: 8),
              const SizedBox(width: 12),
              ShimmerWidget(width: 150, height: 20, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          ShimmerWidget(
            width: double.infinity,
            height: height - 80,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTabsShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ShimmerWidget(width: 32, height: 32, borderRadius: 8),
              const SizedBox(width: 12),
              ShimmerWidget(width: 120, height: 20, borderRadius: 4),
              const Spacer(),
              ShimmerWidget(width: 100, height: 36, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 16),
          // Tabs
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  child: ShimmerWidget(
                    width: double.infinity,
                    height: 40,
                    borderRadius: 8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Product items
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProductItemShimmer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItemShimmer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Drag handle
          ShimmerWidget(width: 24, height: 24, borderRadius: 4),
          const SizedBox(width: 12),
          // Image
          ShimmerWidget(width: 56, height: 56, borderRadius: 8),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                ShimmerWidget(width: 100, height: 14, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Actions
          ShimmerWidget(width: 32, height: 32, borderRadius: 8),
        ],
      ),
    );
  }
}

/// Product Card Shimmer
class FlashDealProductShimmer extends StatelessWidget {
  const FlashDealProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ShimmerWidget(width: 24, height: 24, borderRadius: 4),
          const SizedBox(width: 12),
          ShimmerWidget(width: 56, height: 56, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(
                  width: double.infinity,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                ShimmerWidget(width: 100, height: 14, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ShimmerWidget(width: 32, height: 32, borderRadius: 8),
        ],
      ),
    );
  }
}

/// Empty state widget
class FlashDealEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const FlashDealEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.flash_off_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminTheme.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AdminTheme.primaryColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AdminTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AdminTheme.textSecondary.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
