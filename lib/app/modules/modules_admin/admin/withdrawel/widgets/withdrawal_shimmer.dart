import 'package:flutter/material.dart';
import 'package:tjara/app/modules/modules_admin/admin/withdrawel/widgets/withdrawal_theme.dart';

/// Premium Shimmer effect widget for Withdrawal module
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
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
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle
                ? null
                : widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                WithdrawalTheme.primaryLight.withValues(alpha: 0.3),
                WithdrawalTheme.surfaceSecondary,
                WithdrawalTheme.primaryLight.withValues(alpha: 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Premium Withdrawal Card Shimmer
class WithdrawalCardShimmer extends StatelessWidget {
  const WithdrawalCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: WithdrawalTheme.spacingMd),
      decoration: WithdrawalTheme.premiumCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(WithdrawalTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Avatar shimmer
                const ShimmerWidget(
                  width: 48,
                  height: 48,
                  isCircle: true,
                ),
                const SizedBox(width: WithdrawalTheme.spacingMd),
                // Shop name and ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget(
                        width: 140,
                        height: 16,
                        borderRadius: BorderRadius.circular(
                          WithdrawalTheme.radiusSm,
                        ),
                      ),
                      const SizedBox(height: WithdrawalTheme.spacingXs),
                      ShimmerWidget(
                        width: 100,
                        height: 12,
                        borderRadius: BorderRadius.circular(
                          WithdrawalTheme.radiusXs,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge shimmer
                ShimmerWidget(
                  width: 80,
                  height: 28,
                  borderRadius: BorderRadius.circular(
                    WithdrawalTheme.radiusXl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: WithdrawalTheme.spacingLg),
            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WithdrawalTheme.border.withValues(alpha: 0),
                    WithdrawalTheme.border.withValues(alpha: 0.5),
                    WithdrawalTheme.border.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: WithdrawalTheme.spacingLg),
            // Amount and Date Row
            Row(
              children: [
                // Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget(
                        width: 60,
                        height: 10,
                        borderRadius: BorderRadius.circular(
                          WithdrawalTheme.radiusXs,
                        ),
                      ),
                      const SizedBox(height: WithdrawalTheme.spacingXs),
                      ShimmerWidget(
                        width: 90,
                        height: 24,
                        borderRadius: BorderRadius.circular(
                          WithdrawalTheme.radiusSm,
                        ),
                      ),
                    ],
                  ),
                ),
                // Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget(
                        width: 40,
                        height: 10,
                        borderRadius: BorderRadius.circular(
                          WithdrawalTheme.radiusXs,
                        ),
                      ),
                      const SizedBox(height: WithdrawalTheme.spacingXs),
                      ShimmerWidget(
                        width: 80,
                        height: 14,
                        borderRadius: BorderRadius.circular(
                          WithdrawalTheme.radiusSm,
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  children: [
                    ShimmerWidget(
                      width: 36,
                      height: 36,
                      borderRadius: BorderRadius.circular(
                        WithdrawalTheme.radiusSm,
                      ),
                    ),
                    const SizedBox(width: WithdrawalTheme.spacingSm),
                    ShimmerWidget(
                      width: 36,
                      height: 36,
                      borderRadius: BorderRadius.circular(
                        WithdrawalTheme.radiusSm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stats Card Shimmer for Dashboard
class StatsCardShimmer extends StatelessWidget {
  const StatsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WithdrawalTheme.spacingLg),
      decoration: WithdrawalTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerWidget(
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(WithdrawalTheme.radiusMd),
              ),
              const Spacer(),
              ShimmerWidget(
                width: 60,
                height: 24,
                borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXl),
              ),
            ],
          ),
          const SizedBox(height: WithdrawalTheme.spacingLg),
          ShimmerWidget(
            width: 80,
            height: 12,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXs),
          ),
          const SizedBox(height: WithdrawalTheme.spacingSm),
          ShimmerWidget(
            width: 100,
            height: 28,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
          ),
        ],
      ),
    );
  }
}

/// Form Card Shimmer
class WithdrawalFormShimmer extends StatelessWidget {
  const WithdrawalFormShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WithdrawalTheme.spacingXl),
      decoration: WithdrawalTheme.premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title shimmer
          ShimmerWidget(
            width: 180,
            height: 18,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
          ),
          const SizedBox(height: WithdrawalTheme.spacingSm),
          ShimmerWidget(
            width: 240,
            height: 12,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXs),
          ),
          const SizedBox(height: WithdrawalTheme.spacingXl),
          // Input field shimmer
          ShimmerWidget(
            width: double.infinity,
            height: 56,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusMd),
          ),
          const SizedBox(height: WithdrawalTheme.spacingLg),
          // Button shimmer
          ShimmerWidget(
            width: double.infinity,
            height: 52,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusMd),
          ),
        ],
      ),
    );
  }
}

/// Table Header Shimmer
class WithdrawalTableShimmer extends StatelessWidget {
  final int rowCount;

  const WithdrawalTableShimmer({super.key, this.rowCount = 5});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: WithdrawalTheme.premiumCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header shimmer
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(
              horizontal: WithdrawalTheme.spacingLg,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WithdrawalTheme.primary.withValues(alpha: 0.08),
                  WithdrawalTheme.primary.withValues(alpha: 0.04),
                ],
              ),
            ),
            child: Row(
              children: [
                ShimmerWidget(
                  width: 100,
                  height: 14,
                  borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXs),
                ),
                const Spacer(),
                ShimmerWidget(
                  width: 70,
                  height: 14,
                  borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXs),
                ),
                const SizedBox(width: WithdrawalTheme.spacing2Xl),
                ShimmerWidget(
                  width: 60,
                  height: 14,
                  borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXs),
                ),
                const SizedBox(width: WithdrawalTheme.spacing2Xl),
                ShimmerWidget(
                  width: 80,
                  height: 14,
                  borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXs),
                ),
              ],
            ),
          ),
          // Row shimmers
          ...List.generate(rowCount, (index) => _buildRowShimmer(index)),
        ],
      ),
    );
  }

  Widget _buildRowShimmer(int index) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: WithdrawalTheme.spacingLg,
        vertical: WithdrawalTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: index % 2 == 0
            ? WithdrawalTheme.surface
            : WithdrawalTheme.surfaceSecondary.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: WithdrawalTheme.border.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar + name
          Row(
            children: [
              const ShimmerWidget(
                width: 40,
                height: 40,
                isCircle: true,
              ),
              const SizedBox(width: WithdrawalTheme.spacingMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerWidget(
                    width: 100 + (index % 3) * 20,
                    height: 14,
                    borderRadius: BorderRadius.circular(
                      WithdrawalTheme.radiusXs,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ShimmerWidget(
                    width: 70,
                    height: 10,
                    borderRadius: BorderRadius.circular(
                      WithdrawalTheme.radiusXs,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Amount
          ShimmerWidget(
            width: 80,
            height: 20,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
          ),
          const SizedBox(width: WithdrawalTheme.spacing2Xl),
          // Status badge
          ShimmerWidget(
            width: 70,
            height: 26,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXl),
          ),
          const SizedBox(width: WithdrawalTheme.spacing2Xl),
          // Date
          ShimmerWidget(
            width: 80,
            height: 14,
            borderRadius: BorderRadius.circular(WithdrawalTheme.radiusXs),
          ),
          const SizedBox(width: WithdrawalTheme.spacingLg),
          // Actions
          Row(
            children: [
              ShimmerWidget(
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
              ),
              const SizedBox(width: WithdrawalTheme.spacingSm),
              ShimmerWidget(
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(WithdrawalTheme.radiusSm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Empty State Widget
class WithdrawalEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const WithdrawalEmptyState({
    super.key,
    this.title = 'No withdrawals found',
    this.subtitle = 'Your withdrawal requests will appear here',
    this.icon = Icons.account_balance_wallet_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WithdrawalTheme.spacing3Xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WithdrawalTheme.primary.withValues(alpha: 0.1),
                  WithdrawalTheme.primaryLight.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: WithdrawalTheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: WithdrawalTheme.spacingXl),
          Text(
            title,
            style: WithdrawalTheme.headingMedium.copyWith(
              color: WithdrawalTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WithdrawalTheme.spacingSm),
          Text(
            subtitle,
            style: WithdrawalTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
