import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/popups/popups-model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

// ─── Controller ───────────────────────────────────────────────────────────────

class PopupAnalyticsController extends GetxController {
  // Popup selection
  var allPopups = <Data>[].obs;
  var selectedPopups = <Data>[].obs;
  var popupSearchQuery = ''.obs;
  var isLoadingPopups = false.obs;
  final popupSearchController = TextEditingController();

  // Filters
  var selectedMetric = 'views'.obs;
  var selectedDateFilter = 'daily'.obs;
  var customStartDate = Rx<DateTime?>(null);
  var customEndDate = Rx<DateTime?>(null);

  // Analytics data
  var isLoadingAnalytics = false.obs;
  var timeSeriesData = <Map<String, dynamic>>[].obs;
  var summaryData = <Map<String, dynamic>>[].obs;
  var metaData = Rx<Map<String, dynamic>>({});
  var errorMessage = ''.obs;

  final metricOptions = [
    {'value': 'views', 'label': 'Views'},
    {'value': 'clicks', 'label': 'Clicks'},
    {'value': 'conversions', 'label': 'Conversions'},
    {'value': 'add_to_cart', 'label': 'Add to Cart'},
    {'value': 'view_details', 'label': 'View Details'},
  ];

  final dateFilterOptions = [
    {'value': 'daily', 'label': 'Today'},
    {'value': 'yesterday', 'label': 'Yesterday'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
    {'value': 'custom-date', 'label': 'Custom Date'},
  ];

  // Colors for each popup line in chart
  static const List<Color> lineColors = [
    Color(0xFF6366F1), // indigo
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF8B5CF6), // violet
    Color(0xFF06B6D4), // cyan
    Color(0xFFEC4899), // pink
    Color(0xFF14B8A6), // teal
  ];

  List<Data> get filteredPopups {
    if (popupSearchQuery.value.isEmpty) return allPopups;
    final q = popupSearchQuery.value.toLowerCase();
    return allPopups.where((p) {
      return (p.name?.toLowerCase().contains(q) ?? false) ||
          (p.id?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPopups();
  }

  @override
  void onClose() {
    popupSearchController.dispose();
    super.onClose();
  }

  Future<void> fetchPopups() async {
    try {
      isLoadingPopups.value = true;
      final uri = Uri.parse(
        'https://api.libanbuy.com/api/popups?_t=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final model = PopUpModels.fromJson(data);
        if (model.popups?.data != null) {
          allPopups.assignAll(model.popups!.data!);
        }
      }
    } catch (_) {}
    finally {
      isLoadingPopups.value = false;
    }
  }

  void selectTop5() {
    selectedPopups.clear();
    final top5 = allPopups.take(5).toList();
    selectedPopups.addAll(top5);
    _fetchAnalytics();
  }

  void clearSelection() {
    selectedPopups.clear();
    timeSeriesData.clear();
    summaryData.clear();
    metaData.value = {};
    errorMessage.value = '';
  }

  void togglePopup(Data popup) {
    final idx = selectedPopups.indexWhere((p) => p.id == popup.id);
    if (idx >= 0) {
      selectedPopups.removeAt(idx);
    } else {
      selectedPopups.add(popup);
    }
    if (selectedPopups.isNotEmpty) {
      _fetchAnalytics();
    } else {
      timeSeriesData.clear();
      summaryData.clear();
      metaData.value = {};
    }
  }

  void removePopup(Data popup) {
    selectedPopups.removeWhere((p) => p.id == popup.id);
    if (selectedPopups.isNotEmpty) {
      _fetchAnalytics();
    } else {
      timeSeriesData.clear();
      summaryData.clear();
      metaData.value = {};
    }
  }

  void onMetricChanged(String? value) {
    if (value != null) {
      selectedMetric.value = value;
      if (selectedPopups.isNotEmpty) _fetchAnalytics();
    }
  }

  void onDateFilterChanged(String? value) {
    if (value != null) {
      selectedDateFilter.value = value;
      if (value != 'custom-date') {
        customStartDate.value = null;
        customEndDate.value = null;
        if (selectedPopups.isNotEmpty) _fetchAnalytics();
      }
    }
  }

  Future<void> selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: customStartDate.value != null && customEndDate.value != null
          ? DateTimeRange(start: customStartDate.value!, end: customEndDate.value!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 7)),
              end: DateTime.now(),
            ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      customStartDate.value = picked.start;
      customEndDate.value = picked.end;
      if (selectedPopups.isNotEmpty) _fetchAnalytics();
    }
  }

  Future<void> _fetchAnalytics() async {
    if (selectedPopups.isEmpty) return;

    try {
      isLoadingAnalytics.value = true;
      errorMessage.value = '';

      final queryParams = <String, dynamic>{};
      for (int i = 0; i < selectedPopups.length; i++) {
        queryParams['popup_ids[$i]'] = selectedPopups[i].id ?? '';
      }
      queryParams['metric'] = selectedMetric.value;
      queryParams['analytics_date_filter'] = selectedDateFilter.value;

      if (selectedDateFilter.value == 'custom-date') {
        if (customStartDate.value != null) {
          queryParams['analytics_date_filter_start_date'] =
              DateFormat('dd MMM, yyyy').format(customStartDate.value!);
        }
        if (customEndDate.value != null) {
          queryParams['analytics_date_filter_end_date'] =
              DateFormat('dd MMM, yyyy').format(customEndDate.value!);
        }
      }

      final uri = Uri.parse('https://api.libanbuy.com/api/popups/time-series-analytics')
          .replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));

      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          timeSeriesData.assignAll(
            (data['time_series_data'] as List).map((e) => Map<String, dynamic>.from(e)).toList(),
          );
          summaryData.assignAll(
            (data['summary'] as List).map((e) => Map<String, dynamic>.from(e)).toList(),
          );
          metaData.value = Map<String, dynamic>.from(data['meta'] ?? {});
        } else {
          errorMessage.value = data['message'] ?? 'Failed to load analytics';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error loading analytics: $e';
    } finally {
      isLoadingAnalytics.value = false;
    }
  }

  // Get the popup keys from time series data (popup_33, popup_34, etc.)
  List<String> get popupKeys {
    if (timeSeriesData.isEmpty) return [];
    final first = timeSeriesData.first;
    return first.keys.where((k) => k.startsWith('popup_')).toList();
  }

  // Get popup name from summary by key like "popup_33"
  String getPopupName(String popupKey) {
    final idStr = popupKey.replaceFirst('popup_', '');
    final id = int.tryParse(idStr);
    if (id == null) return popupKey;
    final match = summaryData.firstWhereOrNull((s) => s['popup_id'] == id);
    return match?['popup_name'] ?? popupKey;
  }

  // Get total value from summary by key
  int getPopupTotal(String popupKey) {
    final idStr = popupKey.replaceFirst('popup_', '');
    final id = int.tryParse(idStr);
    if (id == null) return 0;
    final match = summaryData.firstWhereOrNull((s) => s['popup_id'] == id);
    return (match?['total_value'] ?? 0) as int;
  }

  Color getColorForIndex(int index) {
    return lineColors[index % lineColors.length];
  }

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Request-From': 'Dashboard',
      'shop-id': AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
      'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
    };
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class PopupAnalyticsView extends StatelessWidget {
  PopupAnalyticsView({super.key});

  final controller = Get.put(PopupAnalyticsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Popups Time Series Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFiltersCard(),
          const SizedBox(height: 16),
          _buildPopupSelectionCard(),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingAnalytics.value) {
              return _buildLoadingCard();
            }
            if (controller.errorMessage.value.isNotEmpty) {
              return _buildErrorCard();
            }
            if (controller.selectedPopups.isEmpty) {
              return _buildEmptyState();
            }
            if (controller.timeSeriesData.isEmpty) {
              return _buildEmptyState();
            }
            return Column(
              children: [
                _buildChartCard(),
                const SizedBox(height: 16),
                _buildSummaryCards(),
                const SizedBox(height: 16),
                _buildRawDataCard(),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Filters ──────────────────────────────────────────────────────────

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.filter_list, size: 18, color: Colors.teal),
              ),
              const SizedBox(width: 10),
              const Text(
                'Filters',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildDateFilterDropdown()),
            ],
          ),
          // Custom date range picker
          Obx(() {
            if (controller.selectedDateFilter.value != 'custom-date') {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildCustomDateRange(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metric', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedMetric.value,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[500]),
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                  items: controller.metricOptions.map((o) {
                    return DropdownMenuItem(value: o['value'], child: Text(o['label']!));
                  }).toList(),
                  onChanged: controller.onMetricChanged,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildDateFilterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Period', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedDateFilter.value,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[500]),
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                  items: controller.dateFilterOptions.map((o) {
                    return DropdownMenuItem(value: o['value'], child: Text(o['label']!));
                  }).toList(),
                  onChanged: controller.onDateFilterChanged,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildCustomDateRange() {
    return Builder(builder: (context) {
      return Obx(() {
        final start = controller.customStartDate.value;
        final end = controller.customEndDate.value;
        final hasRange = start != null && end != null;

        return GestureDetector(
          onTap: () => controller.selectCustomDateRange(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: hasRange ? Colors.teal.withValues(alpha: 0.04) : Colors.grey[50],
              border: Border.all(
                color: hasRange ? Colors.teal.withValues(alpha: 0.3) : Colors.grey[200]!,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.date_range, size: 18, color: hasRange ? Colors.teal : Colors.grey[400]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasRange
                        ? '${DateFormat('dd MMM yyyy').format(start)} — ${DateFormat('dd MMM yyyy').format(end)}'
                        : 'Select date range',
                    style: TextStyle(
                      fontSize: 13,
                      color: hasRange ? Colors.grey[800] : Colors.grey[400],
                      fontWeight: hasRange ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (hasRange)
                  Icon(Icons.check_circle, size: 16, color: Colors.teal.withValues(alpha: 0.6)),
              ],
            ),
          ),
        );
      });
    });
  }

  // ─── Popup Selection ──────────────────────────────────────────────────

  Widget _buildPopupSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.campaign_outlined, size: 18, color: Colors.teal),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Select Popups',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                ),
              ),
              Obx(() => Text(
                    '${controller.selectedPopups.length} selected',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  )),
            ],
          ),
          const SizedBox(height: 12),

          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[400], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.popupSearchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search popups...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) => controller.popupSearchQuery.value = v,
                  ),
                ),
                Obx(() => controller.popupSearchQuery.value.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller.popupSearchController.clear();
                          controller.popupSearchQuery.value = '';
                        },
                        child: Icon(Icons.clear, size: 16, color: Colors.grey[400]),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick actions
          Row(
            children: [
              _buildQuickAction('Select Top 5', Icons.auto_awesome, controller.selectTop5),
              const SizedBox(width: 8),
              _buildQuickAction('Clear All', Icons.clear_all, controller.clearSelection,
                  color: const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 10),

          // Selected chips
          Obx(() {
            if (controller.selectedPopups.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: controller.selectedPopups.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final popup = entry.value;
                  final color = PopupAnalyticsController.lineColors[idx % PopupAnalyticsController.lineColors.length];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            popup.name ?? 'Unnamed',
                            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => controller.removePopup(popup),
                          child: Icon(Icons.close, size: 14, color: color),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),

          // Popup list
          Obx(() {
            if (controller.isLoadingPopups.value) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2)),
              );
            }
            final popups = controller.filteredPopups;
            if (popups.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text('No popups found', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                ),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: popups.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (_, i) {
                  final popup = popups[i];
                  return Obx(() {
                    final isSelected = controller.selectedPopups.any((p) => p.id == popup.id);
                    return InkWell(
                      onTap: () => controller.togglePopup(popup),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.teal : Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected ? Colors.teal : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    popup.name ?? 'Unnamed',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? Colors.teal[800] : Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    'ID: ${popup.popupId ?? popup.id ?? '-'}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ),
                            if (popup.isAbTest == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('A/B', style: TextStyle(fontSize: 9, color: Colors.purple[700], fontWeight: FontWeight.w600)),
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap, {Color? color}) {
    final c = color ?? Colors.teal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ─── States ───────────────────────────────────────────────────────────

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.teal, strokeWidth: 2.5),
            SizedBox(height: 16),
            Text('Loading analytics...', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Obx(() => Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                textAlign: TextAlign.center,
              )),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (controller.selectedPopups.isNotEmpty) {
                controller.onMetricChanged(controller.selectedMetric.value);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Select popups to view analytics',
              style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose popups above and pick a metric to start',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Chart ────────────────────────────────────────────────────────────

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final keys = controller.popupKeys;
        if (keys.isEmpty || controller.timeSeriesData.isEmpty) {
          return const SizedBox(height: 200, child: Center(child: Text('No data')));
        }

        // Build line chart data
        final lineBarsData = <LineChartBarData>[];
        for (int k = 0; k < keys.length; k++) {
          final key = keys[k];
          final color = controller.getColorForIndex(k);
          final spots = <FlSpot>[];
          for (int i = 0; i < controller.timeSeriesData.length; i++) {
            final point = controller.timeSeriesData[i];
            final val = (point[key] ?? 0).toDouble();
            spots.add(FlSpot(i.toDouble(), val));
          }
          lineBarsData.add(
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 2.5,
              dotData: FlDotData(
                show: controller.timeSeriesData.length <= 24,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: color,
                ),
              ),
              belowBarData: BarAreaData(
                show: keys.length == 1,
                color: color.withValues(alpha: 0.08),
              ),
            ),
          );
        }

        // Compute maxY
        double maxY = 4;
        for (final bar in lineBarsData) {
          for (final spot in bar.spots) {
            if (spot.y > maxY) maxY = spot.y;
          }
        }
        maxY = (maxY * 1.2).ceilToDouble();
        if (maxY < 4) maxY = 4;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart header + legend
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.show_chart, size: 18, color: Colors.teal),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Time Series Chart',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Legend
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: keys.asMap().entries.map((entry) {
                final k = entry.key;
                final key = entry.value;
                final color = controller.getColorForIndex(k);
                final name = controller.getPopupName(key);
                final total = controller.getPopupTotal(key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(
                      '$name ($total)',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Chart
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  lineBarsData: lineBarsData,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 8 ? (maxY / 4).ceilToDouble() : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: maxY > 8 ? (maxY / 4).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: _getBottomInterval(),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= controller.timeSeriesData.length) return const Text('');
                          final label = controller.timeSeriesData[idx]['period_label'] ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label.toString(),
                              style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                      left: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFF1F2937),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final key = keys[spot.barIndex];
                          final name = controller.getPopupName(key);
                          return LineTooltipItem(
                            '$name: ${spot.y.toInt()}',
                            TextStyle(
                              color: controller.getColorForIndex(spot.barIndex),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  double _getBottomInterval() {
    final len = controller.timeSeriesData.length;
    if (len <= 12) return 2;
    if (len <= 24) return 4;
    return (len / 8).ceilToDouble();
  }

  // ─── Summary ──────────────────────────────────────────────────────────

  Widget _buildSummaryCards() {
    return Obx(() {
      if (controller.summaryData.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.summarize_outlined, size: 18, color: Colors.teal),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Summary',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...controller.summaryData.asMap().entries.map((entry) {
              final idx = entry.key;
              final summary = entry.value;
              final color = controller.getColorForIndex(idx);
              final isAb = summary['is_ab_test'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  summary['popup_name'] ?? 'Unknown',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isAb) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('A/B', style: TextStyle(fontSize: 9, color: Colors.purple[700], fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildSummaryStat('Total', '${summary['total_value'] ?? 0}', color),
                              const SizedBox(width: 16),
                              _buildSummaryStat('Peak', '${summary['peak_value'] ?? 0}', color),
                              if (summary['peak_time'] != null) ...[
                                const SizedBox(width: 16),
                                _buildSummaryStat('Peak Time', _formatPeakTime(summary['peak_time']), color),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  String _formatPeakTime(dynamic peakTime) {
    if (peakTime == null) return '-';
    try {
      final dt = DateTime.parse(peakTime.toString());
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return peakTime.toString();
    }
  }

  // ─── Raw Data Table ───────────────────────────────────────────────────

  Widget _buildRawDataCard() {
    return Obx(() {
      if (controller.timeSeriesData.isEmpty) return const SizedBox.shrink();

      final keys = controller.popupKeys;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.table_chart_outlined, size: 18, color: Colors.teal),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Raw Data',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                columnSpacing: 24,
                headingTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                dataTextStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                columns: [
                  const DataColumn(label: Text('Time Period')),
                  ...keys.map((key) {
                    return DataColumn(label: Text(controller.getPopupName(key)));
                  }),
                ],
                rows: controller.timeSeriesData.map((row) {
                  return DataRow(cells: [
                    DataCell(Text(
                      _formatTimePeriod(row['time_period'], row['period_label']),
                      style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
                    )),
                    ...keys.map((key) {
                      return DataCell(Text(
                        '${row[key] ?? 0}',
                        style: const TextStyle(fontSize: 12),
                      ));
                    }),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _formatTimePeriod(dynamic timePeriod, dynamic periodLabel) {
    if (periodLabel != null && periodLabel.toString().isNotEmpty) {
      // Try to format date + period label together
      try {
        final dt = DateTime.parse(timePeriod.toString());
        final dateStr = DateFormat('dd MMM yyyy').format(dt);
        return '$dateStr\n${periodLabel.toString()}';
      } catch (_) {
        return periodLabel.toString();
      }
    }
    return timePeriod?.toString() ?? '';
  }
}
