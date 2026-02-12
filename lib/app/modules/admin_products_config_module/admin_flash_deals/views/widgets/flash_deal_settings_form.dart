import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals/controller/flash_deal_controller.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/admin_ui_components.dart';

class FlashDealSettingsForm extends GetView<FlashDealController> {
  const FlashDealSettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enable Flash Deals Toggle
        _buildEnableToggle(),
        const SizedBox(height: 16),
        // Duration Section
        _buildDurationSection(),
        const SizedBox(height: 16),
        // Interval Section
        _buildIntervalSection(),
        const SizedBox(height: 16),
        // Start Time Section
        _buildStartTimeSection(context),
      ],
    );
  }

  Widget _buildEnableToggle() {
    return AdminCard(
      title: 'Flash Deals Status',
      icon: Icons.flash_on_outlined,
      child: Obx(
        () => AdminToggleSwitch(
          title:
              controller.flashDealsEnabled.value
                  ? 'Flash Deals Enabled'
                  : 'Flash Deals Disabled',
          subtitle:
              controller.flashDealsEnabled.value
                  ? 'Flash deals are currently active and visible to customers'
                  : 'Flash deals are currently hidden from customers',
          value: controller.flashDealsEnabled.value,
          onChanged: (value) => controller.toggleFlashDealsEnabled(value),
        ),
      ),
    );
  }

  Widget _buildDurationSection() {
    return AdminCard(
      title: 'Flash Deal Active Time',
      icon: Icons.timer_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Duration',
            subtitle:
                'Set the time interval in which users can purchase each flash deal. This controls how long each deal remains active before moving to the next one.',
            isRequired: true,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AdminTextField(
                  controller: controller.activeTimeController,
                  hint: 'Enter duration',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.schedule,
                  onChanged: (value) => controller.updateActiveTimeValue(value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildTimeUnitDropdown(
                  value: controller.activeTimeUnit,
                  onChanged: controller.updateActiveTimeUnit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () =>
                _buildInfoChip(controller.durationDisplay, Icons.info_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalSection() {
    return AdminCard(
      title: 'Interval Between Deals',
      icon: Icons.hourglass_empty_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Interval Duration',
            subtitle:
                'Set the waiting time between each flash deal. This creates a pause after one deal ends before the next deal begins. Leave empty for no interval.',
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AdminTextField(
                  controller: controller.intervalTimeController,
                  hint: 'Enter interval',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.pause_circle_outline,
                  onChanged:
                      (value) => controller.updateIntervalTimeValue(value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildTimeUnitDropdown(
                  value: controller.intervalTimeUnit,
                  onChanged: controller.updateIntervalTimeUnit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () =>
                _buildInfoChip(controller.intervalDisplay, Icons.info_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildStartTimeSection(BuildContext context) {
    return AdminCard(
      title: 'Deals Start Time',
      icon: Icons.event_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(
            title: 'Configure when deals should start',
            subtitle:
                'Choose "Live Now" for immediate activation or "Schedule" to set a specific date and time.',
            isRequired: true,
          ),
          // Mode Selection
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildModeChip(
                    label: 'Live Now',
                    isSelected: controller.schedulingMode.value == 'live',
                    onTap: () => controller.updateSchedulingMode('live'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeChip(
                    label: 'Schedule',
                    isSelected: controller.schedulingMode.value == 'schedule',
                    onTap: () => controller.updateSchedulingMode('schedule'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Date Time Picker (only for schedule mode)
          Obx(() {
            if (controller.schedulingMode.value == 'schedule') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Start Date & Time (Local Time)',
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDateTimePicker(context),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 12),
          Obx(
            () =>
                _buildInfoChip(controller.startTimeDisplay, Icons.access_time),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnitDropdown({
    required RxString value,
    required Function(String) onChanged,
  }) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AdminTheme.bgColor,
          borderRadius: AdminTheme.borderRadiusSm,
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value.value.isEmpty ? null : value.value,
            isExpanded: true,
            hint: Text(
              'Unit',
              style: TextStyle(color: AdminTheme.textMuted, fontSize: 14),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AdminTheme.textSecondary,
            ),
            style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
            items:
                controller.timeUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(_capitalizeFirst(unit)),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AdminTheme.primaryColor : Colors.transparent,
          borderRadius: AdminTheme.borderRadiusSm,
          border: Border.all(
            color:
                isSelected ? AdminTheme.primaryColor : AdminTheme.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label == 'Live Now' ? Icons.play_circle_outline : Icons.schedule,
              size: 20,
              color: isSelected ? Colors.white : AdminTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AdminTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDateTimePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AdminTheme.bgColor,
          borderRadius: AdminTheme.borderRadiusSm,
          border: Border.all(color: AdminTheme.borderColor),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AdminTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final dt = controller.scheduledStartTime.value;
                if (dt == null) {
                  return Text(
                    'Tap to select date and time',
                    style: TextStyle(color: AdminTheme.textMuted, fontSize: 14),
                  );
                }
                return Text(
                  _formatDateTimeDisplay(dt),
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 14,
                  ),
                );
              }),
            ),
            const Icon(Icons.arrow_drop_down, color: AdminTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = controller.scheduledStartTime.value ?? now;

    // Pick date
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AdminTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    // Pick time
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AdminTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    controller.updateScheduledStartTime(selectedDateTime);
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AdminTheme.primarySurface,
        borderRadius: AdminTheme.borderRadiusSm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AdminTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AdminTheme.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDateTimeDisplay(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hour12 = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    return '$month/$day/$year ${hour12.toString().padLeft(2, '0')}:$minute $period';
  }
}
