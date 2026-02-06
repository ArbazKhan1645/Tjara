import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';

class AuctionShippingWidget extends StatelessWidget {
  const AuctionShippingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      builder: (controller) {
        return Container(
          decoration: AuctionAdminTheme.elevatedCardDecoration,
          child: Column(
            children: [
              // Header
              Obx(() => _ShippingHeader(
                    isExpanded: controller.isExpanded.value,
                    onToggle: controller.toggleExpansion,
                  )),

              // Expandable Content
              Obx(() => _ExpandableContent(
                    isExpanded: controller.isExpanded.value,
                    controller: controller,
                  )),
            ],
          ),
        );
      },
    );
  }
}

/// Shipping Header Widget
class _ShippingHeader extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ShippingHeader({
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AuctionAdminTheme.accent, AuctionAdminTheme.accentDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: isExpanded
                ? const BorderRadius.vertical(
                    top: Radius.circular(AuctionAdminTheme.radiusLg),
                  )
                : BorderRadius.circular(AuctionAdminTheme.radiusLg),
            boxShadow: AuctionAdminTheme.shadowColored(AuctionAdminTheme.accent),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AuctionAdminTheme.spacingMd),
              const Expanded(
                child: Text(
                  'Shipping Options',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable Content Widget
class _ExpandableContent extends StatelessWidget {
  final bool isExpanded;
  final AuctionAddProductAdminController controller;

  const _ExpandableContent({
    required this.isExpanded,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: Padding(
        padding: const EdgeInsets.all(AuctionAdminTheme.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Company Section
            _ShippingCompanySection(controller: controller),
            const SizedBox(height: AuctionAdminTheme.spacingXl),

            // Shipping Time Section
            _ShippingTimeSection(controller: controller),
            const SizedBox(height: AuctionAdminTheme.spacingXl),

            // Shipping Fees Section
            _ShippingFeesSection(controller: controller),
          ],
        ),
      ),
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}

/// Shipping Company Section Widget
class _ShippingCompanySection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _ShippingCompanySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Shipping Company',
          description:
              'Enter the preferred shipping company or method for delivering this item to customers.',
        ),
        Obx(() => TextFormField(
              initialValue: controller.selectedShippingCompany.value,
              style: AuctionAdminTheme.bodyLarge,
              decoration: AuctionAdminTheme.inputDecoration(
                hintText: 'e.g., FedEx, DHL, UPS',
                prefixIcon: Icons.business_rounded,
              ),
              onChanged: controller.updateShippingCompany,
            )),
        const SizedBox(height: AuctionAdminTheme.spacingSm),
        Obx(() {
          final company = controller.selectedShippingCompany.value;
          if (company.isEmpty) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AuctionAdminTheme.spacingMd,
              vertical: AuctionAdminTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AuctionAdminTheme.successLight,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AuctionAdminTheme.success,
                ),
                const SizedBox(width: AuctionAdminTheme.spacingXs),
                Text(
                  'Carrier: $company',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AuctionAdminTheme.success,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Shipping Time Section Widget
class _ShippingTimeSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _ShippingTimeSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Shipping Time',
          description:
              'Enter the estimated delivery time range for this item.',
        ),
        Row(
          children: [
            // From field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'From',
                    style: AuctionAdminTheme.labelMedium,
                  ),
                  const SizedBox(height: AuctionAdminTheme.spacingXs),
                  Obx(() => TextFormField(
                        initialValue: controller.shippingTimeFrom.value,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: AuctionAdminTheme.bodyLarge,
                        textAlign: TextAlign.center,
                        decoration: AuctionAdminTheme.inputDecoration(
                          hintText: '1',
                        ),
                        onChanged: controller.updateShippingTimeFrom,
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AuctionAdminTheme.spacingSm,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AuctionAdminTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // To field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To',
                    style: AuctionAdminTheme.labelMedium,
                  ),
                  const SizedBox(height: AuctionAdminTheme.spacingXs),
                  Obx(() => TextFormField(
                        initialValue: controller.shippingTimeTo.value,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: AuctionAdminTheme.bodyLarge,
                        textAlign: TextAlign.center,
                        decoration: AuctionAdminTheme.inputDecoration(
                          hintText: '7',
                        ),
                        onChanged: controller.updateShippingTimeTo,
                      )),
                ],
              ),
            ),
            const SizedBox(width: AuctionAdminTheme.spacingMd),
            // Unit dropdown
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unit',
                    style: AuctionAdminTheme.labelMedium,
                  ),
                  const SizedBox(height: AuctionAdminTheme.spacingXs),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AuctionAdminTheme.spacingMd,
                        ),
                        decoration: BoxDecoration(
                          color: AuctionAdminTheme.surfaceSecondary,
                          borderRadius:
                              BorderRadius.circular(AuctionAdminTheme.radiusMd),
                          border: Border.all(color: AuctionAdminTheme.accent),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedTimeUnit.value,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AuctionAdminTheme.accent,
                            ),
                            style: AuctionAdminTheme.bodyLarge,
                            dropdownColor: AuctionAdminTheme.surface,
                            borderRadius: BorderRadius.circular(
                                AuctionAdminTheme.radiusMd),
                            items: controller.timeUnits.map((String unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                controller.updateTimeUnit(newValue);
                              }
                            },
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AuctionAdminTheme.spacingMd),
        Obx(() {
          final from = controller.shippingTimeFrom.value;
          final to = controller.shippingTimeTo.value;
          if (from.isEmpty && to.isEmpty) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
            decoration: BoxDecoration(
              color: AuctionAdminTheme.accentLight,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AuctionAdminTheme.accent,
                ),
                const SizedBox(width: AuctionAdminTheme.spacingSm),
                Expanded(
                  child: Text(
                    'Estimated: $from - $to ${controller.selectedTimeUnit.value}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AuctionAdminTheme.accent,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Shipping Fees Section Widget
class _ShippingFeesSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _ShippingFeesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Shipping Fees',
          description:
              'Enter the shipping cost for delivering this item to customers.',
        ),
        Obx(() => TextFormField(
              initialValue: controller.shippingFees.value,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: AuctionAdminTheme.bodyLarge,
              decoration: AuctionAdminTheme.inputDecoration(
                hintText: '0.00',
                prefixIcon: Icons.attach_money_rounded,
              ),
              onChanged: controller.updateShippingFees,
            )),
        const SizedBox(height: AuctionAdminTheme.spacingSm),
        Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: AuctionAdminTheme.textTertiary,
            ),
            const SizedBox(width: AuctionAdminTheme.spacingXs),
            const Text(
              'Price will be in decimals e.g: 10.00',
              style: AuctionAdminTheme.bodySmall,
            ),
            const Spacer(),
            Obx(() {
              final fees = controller.shippingFees.value;
              if (fees.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuctionAdminTheme.spacingMd,
                  vertical: AuctionAdminTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AuctionAdminTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(AuctionAdminTheme.radiusSm),
                ),
                child: Text(
                  '\$$fees',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AuctionAdminTheme.primary,
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
