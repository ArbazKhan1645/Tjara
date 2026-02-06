import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';

class AuctionProductSettingsWidget extends StatelessWidget {
  const AuctionProductSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      builder: (controller) {
        return AuctionFormCard(
          title: 'Auction Settings',
          icon: Icons.tune_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visibility Settings Section
              _buildSectionHeader(
                icon: Icons.visibility_rounded,
                title: 'Visibility Settings',
                subtitle: 'Control how this auction appears to customers',
              ),
              const SizedBox(height: AuctionAdminTheme.spacingLg),

              // Featured Toggle
              _FeatureToggle(
                title: 'Featured Auction',
                description:
                    'Featured auctions appear prominently on the homepage and get more visibility.',
                icon: Icons.star_rounded,
                value: controller.isFeatured,
                activeColor: AuctionAdminTheme.warning,
              ),
              const SizedBox(height: AuctionAdminTheme.spacingMd),

              // Deal Toggle
              _FeatureToggle(
                title: 'Mark as Deal',
                description:
                    'Deal auctions are highlighted with special badges and shown in deal sections.',
                icon: Icons.local_offer_rounded,
                value: controller.isDeal,
                activeColor: AuctionAdminTheme.error,
              ),
              const SizedBox(height: AuctionAdminTheme.spacingXl),

              // SKU Section
              _SKUSection(controller: controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
          decoration: BoxDecoration(
            color: AuctionAdminTheme.accentLight,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          ),
          child: Icon(
            icon,
            color: AuctionAdminTheme.accent,
            size: 18,
          ),
        ),
        const SizedBox(width: AuctionAdminTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AuctionAdminTheme.headingSmall),
              const SizedBox(height: 2),
              Text(subtitle, style: AuctionAdminTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// Feature Toggle Widget
class _FeatureToggle extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final RxBool value;
  final Color activeColor;

  const _FeatureToggle({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = value.value;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => value.value = !value.value,
          borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: 0.05)
                  : AuctionAdminTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
              border: Border.all(
                color: isActive ? activeColor : AuctionAdminTheme.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withValues(alpha: 0.1)
                        : AuctionAdminTheme.surface,
                    borderRadius:
                        BorderRadius.circular(AuctionAdminTheme.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? activeColor : AuctionAdminTheme.textTertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AuctionAdminTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? activeColor
                                  : AuctionAdminTheme.textPrimary,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: AuctionAdminTheme.spacingSm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AuctionAdminTheme.spacingSm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: activeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AuctionAdminTheme.radiusSm),
                              ),
                              child: Text(
                                'Enabled',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: activeColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: AuctionAdminTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Switch.adaptive(
                    value: isActive,
                    onChanged: (val) => value.value = val,
                    activeColor: activeColor,
                    activeTrackColor: activeColor.withValues(alpha: 0.3),
                    inactiveThumbColor: AuctionAdminTheme.textTertiary,
                    inactiveTrackColor: AuctionAdminTheme.border,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// SKU Section Widget
class _SKUSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _SKUSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.infoLight,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              ),
              child: const Icon(
                Icons.qr_code_rounded,
                color: AuctionAdminTheme.info,
                size: 18,
              ),
            ),
            const SizedBox(width: AuctionAdminTheme.spacingMd),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Identifier',
                    style: AuctionAdminTheme.headingSmall,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Add a unique SKU for inventory tracking',
                    style: AuctionAdminTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AuctionAdminTheme.spacingLg),
        const FieldLabel(
          label: 'SKU (Stock Keeping Unit)',
          description:
              'A unique identifier for this auction item used for inventory management.',
        ),
        TextField(
          controller: controller.skuController,
          style: AuctionAdminTheme.bodyLarge,
          decoration: AuctionAdminTheme.inputDecoration(
            hintText: 'e.g., AUC-2024-001',
            prefixIcon: Icons.tag_rounded,
          ),
        ),
        const SizedBox(height: AuctionAdminTheme.spacingSm),
        _buildSKUHint(),
      ],
    );
  }

  Widget _buildSKUHint() {
    return Container(
      padding: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
      decoration: BoxDecoration(
        color: AuctionAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
        border: Border.all(color: AuctionAdminTheme.borderLight),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AuctionAdminTheme.textTertiary,
            size: 16,
          ),
          SizedBox(width: AuctionAdminTheme.spacingSm),
          Expanded(
            child: Text(
              'Tip: Use a consistent format like AUC-YYYY-XXX for easy tracking',
              style: AuctionAdminTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
