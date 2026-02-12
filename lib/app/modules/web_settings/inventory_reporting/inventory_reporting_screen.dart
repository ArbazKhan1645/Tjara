import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/inventory_reporting/inventory_reporting_controller.dart';
import 'package:tjara/app/modules/web_settings/inventory_reporting/inventory_reporting_service.dart';

class InventoryReportingScreen extends StatelessWidget {
  const InventoryReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryReportingController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WebSettingsAppBar(
        title: 'Inventory Reporting',
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
                  title: 'Inventory Reports',
                  description: 'Configure automated inventory reports for your stores with customizable schedules and recipients.',
                  icon: Icons.inventory_2_rounded,
                  badge: 'Pro',
                ),

                // Main Toggle Card
                _buildMainToggleCard(controller),

                // Show other settings only when enabled
                Obx(() {
                  if (!controller.isEnabled.value) {
                    return _buildDisabledMessage();
                  }
                  return Column(
                    children: [
                      _buildGeneralSettingsCard(controller),
                      _buildReportConfigsSection(controller),
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

  Widget _buildMainToggleCard(InventoryReportingController controller) {
    return WebSettingsSectionCard(
      child: Obx(
        () => WebSettingsToggleRow(
          title: 'Enable Inventory Reporting',
          subtitle: 'Turn on automated inventory reports',
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
              'Enable Inventory Reporting to configure report schedules and recipients.',
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

  Widget _buildGeneralSettingsCard(InventoryReportingController controller) {
    return WebSettingsSectionCard(
      title: 'Schedule Settings',
      child: Column(
        children: [
          // Frequency Dropdown
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

          // Time Picker
          _TimePicker(
            label: 'Report Time',
            value: controller.time.value,
            onChanged: (value) => controller.time.value = value,
          ),
          const SizedBox(height: 16),

          // Recipients Field
          WebSettingsTextField(
            label: 'Email Recipients',
            controller: controller.recipientsController,
            hint: 'email1@example.com, email2@example.com',
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Text(
            'Comma-separated email addresses',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportConfigsSection(InventoryReportingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Report Configurations',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: WebSettingsTheme.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: controller.addReportConfig,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Report'),
                style: TextButton.styleFrom(
                  foregroundColor: WebSettingsTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        Obx(() {
          if (controller.reportConfigs.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: WebSettingsTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: WebSettingsTheme.dividerColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No report configurations yet',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click "Add Report" to create one',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: controller.reportConfigs
                  .map((config) => _buildReportConfigCard(controller, config))
                  .toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReportConfigCard(
    InventoryReportingController controller,
    ReportConfig config,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: WebSettingsTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebSettingsTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Obx(() {
                final currentConfig = controller.reportConfigs.firstWhereOrNull(
                  (c) => c.id == config.id,
                );
                return Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: currentConfig?.enabled ?? config.enabled,
                    onChanged: (value) =>
                        controller.toggleReportConfig(config.id, value),
                    activeThumbColor: WebSettingsTheme.primaryColor,
                  ),
                );
              }),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  config.name.isNotEmpty ? config.name : 'Unnamed Report',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade400,
              size: 22,
            ),
            onPressed: () => _confirmDelete(controller, config),
          ),
          children: [
            _ReportConfigForm(controller: controller, config: config),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    InventoryReportingController controller,
    ReportConfig config,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${config.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.removeReportConfig(config.id);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Shimmer Loading Widget
class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header shimmer
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
          // Toggle card shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Settings card shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Config cards shimmer
          ...List.generate(
            2,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Button shimmer
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

/// Report Config Form Widget
class _ReportConfigForm extends StatefulWidget {
  final InventoryReportingController controller;
  final ReportConfig config;

  const _ReportConfigForm({required this.controller, required this.config});

  @override
  State<_ReportConfigForm> createState() => _ReportConfigFormState();
}

class _ReportConfigFormState extends State<_ReportConfigForm> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config.name);
    _descriptionController = TextEditingController(
      text: widget.config.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateConfig({
    String? name,
    String? storeId,
    String? storeName,
    String? category,
    String? categoryName,
    String? categoryFilterType,
    String? description,
  }) {
    final updated = widget.config.copyWith(
      name: name ?? widget.config.name,
      storeId: storeId ?? widget.config.storeId,
      storeName: storeName ?? widget.config.storeName,
      category: category ?? widget.config.category,
      categoryName: categoryName ?? widget.config.categoryName,
      categoryFilterType: categoryFilterType ?? widget.config.categoryFilterType,
      description: description ?? widget.config.description,
    );
    widget.controller.updateReportConfig(widget.config.id, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Report Name
        WebSettingsTextField(
          label: 'Report Name',
          controller: _nameController,
          hint: 'Enter report name',
        ),

        const SizedBox(height: 16),

        // Shop Searchable Dropdown
        _SearchableDropdown<ShopItem>(
          label: 'Store',
          currentValue: widget.config.storeId,
          currentDisplayName: widget.config.storeId == 'all'
              ? 'All Stores'
              : (widget.config.storeName ?? 'Store #${widget.config.storeId}'),
          onSearch: (query) async {
            final results = await InventoryReportingService.searchShops(
              search: query.isEmpty ? null : query,
            );
            return results;
          },
          itemBuilder: (item) => item.name,
          itemId: (item) => item.id,
          onSelected: (item) {
            if (item == null) {
              _updateConfig(storeId: 'all', storeName: null);
            } else {
              _updateConfig(storeId: item.id, storeName: item.name);
            }
          },
          allowAll: true,
          allLabel: 'All Stores',
        ),

        const SizedBox(height: 16),

        // Category Searchable Dropdown
        _SearchableDropdown<CategoryItem>(
          label: 'Category',
          currentValue: widget.config.category,
          currentDisplayName: widget.config.category == 'all'
              ? 'All Categories'
              : (widget.config.categoryName ?? 'Category #${widget.config.category}'),
          onSearch: (query) async {
            final results = await InventoryReportingService.searchCategories(
              search: query.isEmpty ? null : query,
            );
            return results;
          },
          itemBuilder: (item) => item.name,
          itemId: (item) => item.id,
          onSelected: (item) {
            if (item == null) {
              _updateConfig(category: 'all', categoryName: null);
            } else {
              _updateConfig(category: item.id, categoryName: item.name);
            }
          },
          allowAll: true,
          allLabel: 'All Categories',
        ),

        const SizedBox(height: 16),

        // Category Filter Type
        WebSettingsDropdown<String>(
          label: 'Category Filter Type',
          value: widget.config.categoryFilterType,
          items: widget.controller.categoryFilterTypes
              .map((item) => DropdownMenuItem(
                    value: item['value'],
                    child: Text(item['label']!),
                  ))
              .toList(),
          onChanged: (value) => _updateConfig(categoryFilterType: value),
          hint: 'Include or exclude selected category',
        ),

        const SizedBox(height: 16),

        // Description
        WebSettingsTextField(
          label: 'Description',
          controller: _descriptionController,
          hint: 'Optional description for this report',
          maxLines: 3,
        ),
      ],
    );
  }
}

/// Custom Searchable Dropdown Widget
class _SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String currentValue;
  final String currentDisplayName;
  final Future<List<T>> Function(String query) onSearch;
  final String Function(T item) itemBuilder;
  final String Function(T item) itemId;
  final void Function(T? item) onSelected;
  final bool allowAll;
  final String allLabel;

  const _SearchableDropdown({
    required this.label,
    required this.currentValue,
    required this.currentDisplayName,
    required this.onSearch,
    required this.itemBuilder,
    required this.itemId,
    required this.onSelected,
    this.allowAll = false,
    this.allLabel = 'All',
  });

  @override
  State<_SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<_SearchableDropdown<T>> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<T> _results = [];
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
        final results = await widget.onSearch(query);
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

  void _selectItem(T? item) {
    widget.onSelected(item);
    _closeDropdown();
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
                    style: const TextStyle(fontSize: 14),
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
                      hintText: 'Search...',
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
                      if (widget.allowAll)
                        _buildListItem(
                          title: widget.allLabel,
                          isSelected: widget.currentValue == 'all',
                          onTap: () => _selectItem(null),
                        ),
                      ..._results.map((item) {
                        final isSelected = widget.itemId(item) == widget.currentValue;
                        return _buildListItem(
                          title: widget.itemBuilder(item),
                          isSelected: isSelected,
                          onTap: () => _selectItem(item),
                        );
                      }),
                      if (_results.isEmpty && !_isLoading)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No results found',
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

  Widget _buildListItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? WebSettingsTheme.primaryColor.withOpacity(0.1) : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
    final formatted = '${hour24.toString().padLeft(2, '0')}:00';
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
                ':00',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
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
