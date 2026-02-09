import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/controllers/add_product_auction_admin_controller.dart';
import 'package:tjara/app/modules/modules_admin/admin/add_product_auction_admin/widgets/auction_admin_theme.dart';

class AuctionProductManagementWidget extends StatelessWidget {
  const AuctionProductManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuctionAddProductAdminController>(
      builder: (controller) {
        return AuctionFormCard(
          title: 'Auction Management',
          icon: Icons.settings_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Section
              _StatusSection(controller: controller),
              const SizedBox(height: AuctionAdminTheme.spacingXl),

              // Stock Section
              _StockSection(controller: controller),
              const SizedBox(height: AuctionAdminTheme.spacingXl),

              // Timing Section
              _TimingSection(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

/// Status Section Widget
class _StatusSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _StatusSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Auction Status',
          description:
              'Choose the status that best reflects the availability of this auction for customers.',
        ),
        Obx(() => _StatusToggle(
              isActive: controller.selectedStatus.value,
              onChanged: (value) => controller.selectedStatus.value = value,
            )),
      ],
    );
  }
}

/// Status Toggle Widget
class _StatusToggle extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const _StatusToggle({
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
      decoration: BoxDecoration(
        color: AuctionAdminTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        border: Border.all(
          color: isActive ? AuctionAdminTheme.success : AuctionAdminTheme.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
            decoration: BoxDecoration(
              color: isActive
                  ? AuctionAdminTheme.successLight
                  : AuctionAdminTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
            ),
            child: Icon(
              isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
              color: isActive
                  ? AuctionAdminTheme.success
                  : AuctionAdminTheme.textTertiary,
              size: 20,
            ),
          ),
          const SizedBox(width: AuctionAdminTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AuctionAdminTheme.success
                        : AuctionAdminTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive
                      ? 'Auction is live and accepting bids'
                      : 'Auction is paused and not visible',
                  style: AuctionAdminTheme.bodySmall,
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch.adaptive(
              value: isActive,
              onChanged: onChanged,
              activeColor: AuctionAdminTheme.success,
              activeTrackColor: AuctionAdminTheme.successLight,
              inactiveThumbColor: AuctionAdminTheme.textTertiary,
              inactiveTrackColor: AuctionAdminTheme.border,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stock Section Widget
class _StockSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _StockSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Auction Stock',
          description:
              'Enter the total quantity of this item currently available for auction.',
        ),
        TextField(
          controller: controller.inputProductStock,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: AuctionAdminTheme.bodyLarge,
          decoration: AuctionAdminTheme.inputDecoration(
            hintText: 'Enter stock quantity',
            prefixIcon: Icons.inventory_2_rounded,
          ),
        ),
      ],
    );
  }
}

/// Timing Section Widget
class _TimingSection extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _TimingSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildSectionHeader(),
        const SizedBox(height: AuctionAdminTheme.spacingLg),

        // Schedule Type Selector
        _ScheduleTypeSelector(controller: controller),
        const SizedBox(height: AuctionAdminTheme.spacingLg),

        // Time pickers only visible when "Schedule Now" is selected
        Obx(() {
          if (controller.auctionScheduleType.value == 'future') {
            return Container(
              padding: const EdgeInsets.all(AuctionAdminTheme.spacingLg),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.accentLight,
                borderRadius:
                    BorderRadius.circular(AuctionAdminTheme.radiusMd),
                border: Border.all(
                  color: AuctionAdminTheme.accent.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AuctionAdminTheme.accent,
                  ),
                  SizedBox(width: AuctionAdminTheme.spacingSm),
                  Expanded(
                    child: Text(
                      'Auction will be scheduled for future. Start and end times will be set later.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AuctionAdminTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Start Time
              _TimePickerField(
                label: 'Start Time',
                description: 'When the auction will begin accepting bids',
                icon: Icons.play_circle_outline_rounded,
                controller: controller.selectedStartTimeController,
                onTap: () => controller.selectStartTime(context),
                isRequired: true,
                accentColor: AuctionAdminTheme.success,
              ),
              const SizedBox(height: AuctionAdminTheme.spacingLg),

              // End Time
              _TimePickerField(
                label: 'End Time',
                description: 'When the auction will close',
                icon: Icons.stop_circle_outlined,
                controller: controller.selectedEndTimeController,
                onTap: () => controller.selectEndTime(context),
                isRequired: true,
                accentColor: AuctionAdminTheme.error,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
          decoration: BoxDecoration(
            color: AuctionAdminTheme.accentLight,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusSm),
          ),
          child: const Icon(
            Icons.schedule_rounded,
            color: AuctionAdminTheme.accent,
            size: 18,
          ),
        ),
        const SizedBox(width: AuctionAdminTheme.spacingMd),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auction Timing',
                style: AuctionAdminTheme.headingSmall,
              ),
              SizedBox(height: 2),
              Text(
                'Set when the auction starts and ends',
                style: AuctionAdminTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Schedule Type Selector Widget
class _ScheduleTypeSelector extends StatelessWidget {
  final AuctionAddProductAdminController controller;

  const _ScheduleTypeSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          label: 'Schedule Type',
          description: 'Choose when to start the auction',
        ),
        const SizedBox(height: AuctionAdminTheme.spacingSm),
        Obx(() {
          final isNow = controller.auctionScheduleType.value == 'now';
          return Row(
            children: [
              Expanded(
                child: _buildOption(
                  label: 'Schedule Now',
                  icon: Icons.play_arrow_rounded,
                  description: 'Set start & end time now',
                  isSelected: isNow,
                  onTap: () {
                    controller.auctionScheduleType.value = 'now';
                  },
                ),
              ),
              const SizedBox(width: AuctionAdminTheme.spacingMd),
              Expanded(
                child: _buildOption(
                  label: 'Schedule Later',
                  icon: Icons.schedule_rounded,
                  description: 'Set timing later',
                  isSelected: !isNow,
                  onTap: () {
                    controller.auctionScheduleType.value = 'future';
                    controller.selectedStartTime.value = null;
                    controller.selectedEndTime.value = null;
                    controller.selectedStartTimeController.clear();
                    controller.selectedEndTimeController.clear();
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AuctionAdminTheme.spacingMd),
          decoration: BoxDecoration(
            color: isSelected
                ? AuctionAdminTheme.accentLight
                : AuctionAdminTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            border: Border.all(
              color: isSelected
                  ? AuctionAdminTheme.accent
                  : AuctionAdminTheme.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AuctionAdminTheme.accent.withValues(alpha: 0.1)
                      : AuctionAdminTheme.surface,
                  borderRadius:
                      BorderRadius.circular(AuctionAdminTheme.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AuctionAdminTheme.accent
                      : AuctionAdminTheme.textTertiary,
                ),
              ),
              const SizedBox(height: AuctionAdminTheme.spacingSm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AuctionAdminTheme.accent
                      : AuctionAdminTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AuctionAdminTheme.textTertiary,
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

/// Time Picker Field Widget
class _TimePickerField extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final TextEditingController controller;
  final VoidCallback onTap;
  final bool isRequired;
  final Color accentColor;

  const _TimePickerField({
    required this.label,
    required this.description,
    required this.icon,
    required this.controller,
    required this.onTap,
    this.isRequired = false,
    this.accentColor = AuctionAdminTheme.accent,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AuctionAdminTheme.headingSmall),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuctionAdminTheme.spacingSm,
                  vertical: AuctionAdminTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AuctionAdminTheme.errorLight,
                  borderRadius: BorderRadius.circular(
                    AuctionAdminTheme.radiusSm,
                  ),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AuctionAdminTheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AuctionAdminTheme.spacingXs),
        Text(description, style: AuctionAdminTheme.bodySmall),
        const SizedBox(height: AuctionAdminTheme.spacingSm),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AuctionAdminTheme.spacingLg,
                vertical: AuctionAdminTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                color: AuctionAdminTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(AuctionAdminTheme.radiusMd),
                border: Border.all(
                  color: hasValue ? accentColor : AuctionAdminTheme.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AuctionAdminTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: hasValue
                          ? accentColor.withValues(alpha: 0.1)
                          : AuctionAdminTheme.surface,
                      borderRadius:
                          BorderRadius.circular(AuctionAdminTheme.radiusSm),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: hasValue ? accentColor : AuctionAdminTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AuctionAdminTheme.spacingMd),
                  Expanded(
                    child: Text(
                      hasValue ? controller.text : 'Select date and time',
                      style: TextStyle(
                        fontSize: 14,
                        color: hasValue
                            ? AuctionAdminTheme.textPrimary
                            : AuctionAdminTheme.textTertiary,
                        fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: hasValue ? accentColor : AuctionAdminTheme.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
