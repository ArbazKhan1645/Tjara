import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_admin/widgets/product_details/product_details_editor_widget.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';

class AuctionProductDetailsCardWidget extends StatelessWidget {
  const AuctionProductDetailsCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      builder: (controller) {
        return AuctionFormCard(
          title: 'Auction Details',
          icon: Icons.description_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description Section
              _DescriptionSection(controller: controller),
              const SizedBox(height: AuctionAdminTheme.spacingXl),

              // Pricing Section
              _PricingSection(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

/// Description Section Widget
class _DescriptionSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _DescriptionSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Auction Description',
          description:
              'Provide a detailed description of your auction item. Include key features, condition, and any relevant information.',
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            border: Border.all(color: AuctionAdminTheme.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            child: ProductDetailsEditorWidget(
              controller: controller.productdescriptionController,
            ),
          ),
        ),
      ],
    );
  }
}

/// Pricing Section Widget
class _PricingSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _PricingSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildSectionHeader(),
        const SizedBox(height: AuctionAdminTheme.spacingLg),

        // Price Field
        _PriceField(controller: controller),
        const SizedBox(height: AuctionAdminTheme.spacingXl),

        // Reserved Price Field
        _ReservedPriceField(controller: controller),
        const SizedBox(height: AuctionAdminTheme.spacingXl),

        // Bids Increment Field
        _BidsIncrementField(controller: controller),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
          decoration: BoxDecoration(
            color: AuctionAdminTheme.primaryLight,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          ),
          child: const Icon(
            Icons.attach_money_rounded,
            color: AuctionAdminTheme.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: AuctionAdminTheme.spacingMd),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pricing Information',
                style: AuctionAdminTheme.headingSmall,
              ),
              SizedBox(height: 2),
              Text(
                'Set the starting price and bid increments',
                style: AuctionAdminTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Price Field Widget
class _PriceField extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _PriceField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Starting Price',
          isRequired: true,
          description:
              'Set the minimum starting price for your auction. Bidding will begin from this amount.',
        ),
        TextField(
          controller: controller.priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: AuctionAdminTheme.bodyLarge,
          decoration: AuctionAdminTheme.inputDecoration(
            hintText: '0.00',
            prefixIcon: Icons.attach_money_rounded,
          ),
        ),
        const SizedBox(height: AuctionAdminTheme.spacingXs),
        const _HelperText(text: 'Price will be in decimals e.g: 10.00'),
      ],
    );
  }
}

/// Reserved Price Field Widget
class _ReservedPriceField extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _ReservedPriceField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Reserved Price',
          description:
              'Set a minimum price the item must reach for the sale to complete. This is optional.',
        ),
        TextField(
          controller: controller.salepriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: AuctionAdminTheme.bodyLarge,
          decoration: AuctionAdminTheme.inputDecoration(
            hintText: '0.00',
            prefixIcon: Icons.lock_outline_rounded,
          ),
        ),
        const SizedBox(height: AuctionAdminTheme.spacingXs),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AuctionAdminTheme.spacingSm,
                vertical: AuctionAdminTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.infoLight,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 12,
                    color: AuctionAdminTheme.info,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AuctionAdminTheme.info,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AuctionAdminTheme.spacingSm),
            const Expanded(
              child: Text(
                'Leave empty for no minimum',
                style: AuctionAdminTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Bids Increment Field Widget
class _BidsIncrementField extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _BidsIncrementField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Bid Increment',
          isRequired: true,
          description:
              'Set the minimum amount each new bid must increase by. For example, if set to 10, bids would be 100, 110, 120, etc.',
        ),
        TextField(
          controller: controller.bidsIncrementBy,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: AuctionAdminTheme.bodyLarge,
          decoration: AuctionAdminTheme.inputDecoration(
            hintText: '0',
            prefixIcon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(height: AuctionAdminTheme.spacingMd),
        _buildIncrementExamples(),
      ],
    );
  }

  Widget _buildIncrementExamples() {
    return Container(
      padding: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
      decoration: BoxDecoration(
        color: AuctionAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
        border: Border.all(color: AuctionAdminTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
            decoration: BoxDecoration(
              color: AuctionAdminTheme.accentLight,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AuctionAdminTheme.accent,
              size: 16,
            ),
          ),
          const SizedBox(width: AuctionAdminTheme.spacingMd),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Example',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AuctionAdminTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'If increment is 10, bids will be: 10 → 20 → 30 → 40...',
                  style: AuctionAdminTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper Text Widget
class _HelperText extends StatelessWidget {
  final String text;

  const _HelperText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 14,
          color: AuctionAdminTheme.textTertiary,
        ),
        const SizedBox(width: AuctionAdminTheme.spacingXs),
        Text(
          text,
          style: AuctionAdminTheme.bodySmall,
        ),
      ],
    );
  }
}
