import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/analytics_reporting/analytics_reporting_controller.dart';
import 'package:tjara/app/modules/web_settings/analytics_reporting/analytics_reporting_service.dart';

class AnalyticsReportingScreen extends StatelessWidget {
  const AnalyticsReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsReportingController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WebSettingsAppBar(
        title: 'Order Analytics Reporting',
        actions: [
          Obx(
            () => controller.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save_rounded),
                    onPressed: controller.saveSettings,
                    tooltip: 'Save Settings',
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _ShimmerLoading();
        }

        if (controller.errorMessage.value != null) {
          return WebSettingsErrorState(
            message: controller.errorMessage.value!,
            onRetry: controller.fetchSettings,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchSettings,
          color: WebSettingsTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const WebSettingsHeaderCard(
                  title: 'Analytics Reports',
                  description: 'Configure automated order analytics reports with customizable schedules and delivery options.',
                  icon: Icons.analytics_rounded,
                  badge: 'Pro',
                ),

                // Main Toggle
                _buildMainToggleCard(controller),

                // Show other settings only when enabled
                Obx(() {
                  if (!controller.isEnabled.value) {
                    return _buildDisabledMessage();
                  }
                  return Column(
                    children: [
                      _buildScopeCard(controller),
                      _buildScheduleCard(controller),
                      _buildRecipientsCard(controller),
                      _buildInfoCard(controller),
                    ],
                  );
                }),

                // Save Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(
                    () => WebSettingsPrimaryButton(
                      label: 'Save Settings',
                      icon: Icons.save_rounded,
                      isLoading: controller.isSaving.value,
                      onPressed: controller.saveSettings,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMainToggleCard(AnalyticsReportingController controller) {
    return WebSettingsSectionCard(
      child: Obx(
        () => WebSettingsToggleRow(
          title: 'Enable Automatic Reporting',
          subtitle: 'Send order analytics reports via email',
          icon: Icons.power_settings_new_rounded,
          value: controller.isEnabled.value,
          onChanged: (value) => controller.isEnabled.value = value,
        ),
      ),
    );
  }

  Widget _buildDisabledMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebSettingsTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WebSettingsTheme.warningColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WebSettingsTheme.warningColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: WebSettingsTheme.warningColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enable Automatic Reporting to configure report schedules and recipients.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeCard(AnalyticsReportingController controller) {
    return WebSettingsSectionCard(
      title: 'Report Scope',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose whether to include all orders or orders from a specific store.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => WebSettingsRadioGroup(
              value: controller.scope.value,
              options: const [
                {'value': 'all', 'label': 'All Orders'},
                {'value': 'specific_store', 'label': 'Specific Store'},
              ],
              onChanged: controller.changeScope,
            ),
          ),
          // Store dropdown when specific store selected
          Obx(() {
            if (controller.scope.value != 'specific_store') {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _StoreSearchableDropdown(
                currentValue: controller.storeId.value,
                currentDisplayName: controller.storeName.value.isNotEmpty
                    ? controller.storeName.value
                    : 'Select a store...',
                onSelected: controller.selectStore,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(AnalyticsReportingController controller) {
    return WebSettingsSectionCard(
      title: 'Schedule Settings',
      child: Column(
        children: [
          WebSettingsDropdown<String>(
            label: 'Report Frequency',
            value: controller.frequency.value,
            items: controller.frequencyOptions
                .map((item) => DropdownMenuItem(
                      value: item['value'],
                      child: Text(item['label']!),
                    ))
                .toList(),
            onChanged: (value) => controller.frequency.value = value!,
          ),
          const SizedBox(height: 16),
          _TimePicker(
            label: 'Report Time',
            value: controller.time.value,
            onChanged: (value) => controller.time.value = value,
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientsCard(AnalyticsReportingController controller) {
    return WebSettingsSectionCard(
      title: 'Email Recipients',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter email addresses separated by commas. These recipients will receive the analytics reports.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          WebSettingsTextField(
            label: 'Recipients',
            controller: controller.recipientsController,
            hint: 'admin@tjara.com, manager@tjara.com',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AnalyticsReportingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebSettingsTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WebSettingsTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: WebSettingsTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Report Schedule Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: WebSettingsTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              children: [
                _buildInfoRow('Scope', controller.scope.value == 'all' ? 'All Orders' : 'Specific Store'),
                _buildInfoRow('Frequency', controller.frequencyLabel),
                _buildInfoRow('Time', controller.formattedTime),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WebSettingsTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: WebSettingsTheme.accentColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reports include order status summaries, financial data, and are delivered as Excel attachments.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: WebSettingsTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: WebSettingsTheme.primaryDark,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: WebSettingsTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer Loading
class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Store Searchable Dropdown
class _StoreSearchableDropdown extends StatefulWidget {
  final String currentValue;
  final String currentDisplayName;
  final void Function(ShopItem? item) onSelected;

  const _StoreSearchableDropdown({
    required this.currentValue,
    required this.currentDisplayName,
    required this.onSelected,
  });

  @override
  State<_StoreSearchableDropdown> createState() => _StoreSearchableDropdownState();
}

class _StoreSearchableDropdownState extends State<_StoreSearchableDropdown> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<ShopItem> _results = [];
  bool _isLoading = false;
  bool _isOpen = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isOpen) {
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() => _isOpen = true);
    _search('');
  }

  void _closeDropdown() {
    setState(() {
      _isOpen = false;
      _searchController.clear();
      _results = [];
    });
  }

  void _search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isLoading = true);
      try {
        final results = await AnalyticsReportingService.searchShops(
          search: query.isEmpty ? null : query,
        );
        if (mounted) {
          setState(() {
            _results = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _results = [];
            _isLoading = false;
          });
        }
      }
    });
  }

  void _selectItem(ShopItem? item) {
    widget.onSelected(item);
    _closeDropdown();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Store',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: WebSettingsTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            if (_isOpen) {
              _closeDropdown();
            } else {
              _openDropdown();
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: WebSettingsTheme.dividerColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.currentDisplayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.currentValue.isEmpty
                          ? Colors.grey.shade500
                          : WebSettingsTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: WebSettingsTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_isOpen) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: WebSettingsTheme.dividerColor),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search stores...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                      suffixIcon: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: WebSettingsTheme.primaryColor,
                                ),
                              ),
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: WebSettingsTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: _search,
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      ..._results.map((item) {
                        final isSelected = item.id == widget.currentValue;
                        return InkWell(
                          onTap: () => _selectItem(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            color: isSelected
                                ? WebSettingsTheme.primaryColor.withOpacity(0.1)
                                : null,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? WebSettingsTheme.primaryColor
                                          : WebSettingsTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: WebSettingsTheme.primaryColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (_results.isEmpty && !_isLoading)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No stores found',
                            style: TextStyle(color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Time Picker Widget
class _TimePicker extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _TimePicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<_TimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _parseValue(widget.value);
  }

  @override
  void didUpdateWidget(_TimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _parseValue(widget.value);
    }
  }

  void _parseValue(String value) {
    final parts = value.split(':');
    final int hour24 = int.tryParse(parts[0]) ?? 10;
    _selectedMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    if (hour24 == 0) {
      _selectedHour = 12;
      _selectedPeriod = 'AM';
    } else if (hour24 < 12) {
      _selectedHour = hour24;
      _selectedPeriod = 'AM';
    } else if (hour24 == 12) {
      _selectedHour = 12;
      _selectedPeriod = 'PM';
    } else {
      _selectedHour = hour24 - 12;
      _selectedPeriod = 'PM';
    }
  }

  void _updateValue() {
    int hour24;
    if (_selectedPeriod == 'AM') {
      hour24 = _selectedHour == 12 ? 0 : _selectedHour;
    } else {
      hour24 = _selectedHour == 12 ? 12 : _selectedHour + 12;
    }
    final formatted =
        '${hour24.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
    widget.onChanged(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: WebSettingsTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: WebSettingsTheme.dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Hour dropdown
              Expanded(
                flex: 2,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedHour,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    items: List.generate(12, (i) => i + 1)
                        .map((hour) => DropdownMenuItem(
                              value: hour,
                              child: Text(
                                hour.toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedHour = value);
                        _updateValue();
                      }
                    },
                  ),
                ),
              ),
              const Text(
                ':',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              // Minute dropdown
              Expanded(
                flex: 2,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedMinute,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    items: List.generate(60, (i) => i)
                        .map((minute) => DropdownMenuItem(
                              value: minute,
                              child: Text(
                                minute.toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedMinute = value);
                        _updateValue();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // AM/PM toggle
              Container(
                decoration: BoxDecoration(
                  color: WebSettingsTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPeriodButton('AM'),
                    _buildPeriodButton('PM'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = period);
        _updateValue();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? WebSettingsTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : WebSettingsTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
