import 'package:flutter/material.dart';
import 'package:tjara/app/modules/modules_admin/admin/admin_jobs/widgets/jobs_admin_theme.dart';

/// Shimmer effect widget for loading states
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF1F5F9),
                Color(0xFFE2E8F0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Jobs Table Shimmer - Loading placeholder for the jobs table
class JobsTableShimmer extends StatelessWidget {
  final int rowCount;

  const JobsTableShimmer({super.key, this.rowCount = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: JobsAdminTheme.cardDecoration,
      child: Column(
        children: [
          // Header shimmer
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: JobsAdminTheme.surfaceSecondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(JobsAdminTheme.radiusMd),
                topRight: Radius.circular(JobsAdminTheme.radiusMd),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: JobsAdminTheme.spacingLg,
            ),
            child: Row(
              children: [
                const ShimmerWidget(width: 150, height: 16),
                const Spacer(),
                const ShimmerWidget(width: 80, height: 16),
                const SizedBox(width: JobsAdminTheme.spacingXl),
                const ShimmerWidget(width: 100, height: 16),
                const SizedBox(width: JobsAdminTheme.spacingXl),
                const ShimmerWidget(width: 80, height: 16),
                const SizedBox(width: JobsAdminTheme.spacingXl),
                const ShimmerWidget(width: 100, height: 16),
              ],
            ),
          ),

          // Rows shimmer
          ...List.generate(rowCount, (index) => _buildShimmerRow(index)),
        ],
      ),
    );
  }

  Widget _buildShimmerRow(int index) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: JobsAdminTheme.spacingLg,
        vertical: JobsAdminTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: index % 2 == 0
            ? JobsAdminTheme.surface
            : JobsAdminTheme.surfaceSecondary,
        border: Border(
          bottom: BorderSide(color: JobsAdminTheme.borderLight),
        ),
      ),
      child: Row(
        children: [
          // Avatar + Title
          Row(
            children: [
              const ShimmerWidget(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              const SizedBox(width: JobsAdminTheme.spacingMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerWidget(
                    width: 120 + (index % 3) * 20,
                    height: 14,
                  ),
                  const SizedBox(height: 6),
                  const ShimmerWidget(width: 80, height: 10),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Salary
          const ShimmerWidget(width: 70, height: 14),
          const SizedBox(width: JobsAdminTheme.spacingXl),
          // Work Type Badge
          const ShimmerWidget(
            width: 80,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(width: JobsAdminTheme.spacingXl),
          // Country
          const ShimmerWidget(width: 90, height: 14),
          const SizedBox(width: JobsAdminTheme.spacingXl),
          // Date
          const ShimmerWidget(width: 80, height: 14),
          const SizedBox(width: JobsAdminTheme.spacingXl),
          // Status Badge
          const ShimmerWidget(
            width: 60,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(width: JobsAdminTheme.spacingXl),
          // Actions
          const ShimmerWidget(width: 32, height: 32),
        ],
      ),
    );
  }
}

/// Single Job Card Shimmer
class JobCardShimmer extends StatelessWidget {
  const JobCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: JobsAdminTheme.spacingXs),
      padding: const EdgeInsets.all(JobsAdminTheme.spacingLg),
      decoration: BoxDecoration(
        color: JobsAdminTheme.surface,
        borderRadius: BorderRadius.circular(JobsAdminTheme.radiusSm),
        border: Border.all(color: JobsAdminTheme.borderLight),
      ),
      child: Row(
        children: [
          const ShimmerWidget(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          const SizedBox(width: JobsAdminTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShimmerWidget(width: 150, height: 14),
                const SizedBox(height: 6),
                const ShimmerWidget(width: 100, height: 10),
              ],
            ),
          ),
          const ShimmerWidget(
            width: 70,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ],
      ),
    );
  }
}

/// Stats Card Shimmer
class StatsCardShimmer extends StatelessWidget {
  const StatsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(JobsAdminTheme.spacingLg),
      decoration: JobsAdminTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerWidget(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              const Spacer(),
              const ShimmerWidget(width: 60, height: 24),
            ],
          ),
          const SizedBox(height: JobsAdminTheme.spacingMd),
          const ShimmerWidget(width: 80, height: 12),
          const SizedBox(height: JobsAdminTheme.spacingSm),
          const ShimmerWidget(width: 50, height: 20),
        ],
      ),
    );
  }
}
