import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class EventsAnalyticsController extends GetxController {
  static const String _baseUrl =
      'https://api.libanbuy.com/api/global-events-analytics';

  // Date filter
  final RxString selectedDateFilter = 'all-time'.obs;
  final Rxn<DateTime> customStartDate = Rxn<DateTime>();
  final Rxn<DateTime> customEndDate = Rxn<DateTime>();

  final List<Map<String, String>> dateFilterOptions = [
    {'value': 'today', 'label': 'Today'},
    {'value': 'yesterday', 'label': 'Yesterday'},
    {'value': 'this-week', 'label': 'This Week'},
    {'value': 'this-month', 'label': 'This Month'},
    {'value': 'all-time', 'label': 'All Time'},
    {'value': 'custom-date', 'label': 'Custom Date Range'},
  ];

  // Summary data
  final RxMap<String, dynamic> summaryData = <String, dynamic>{}.obs;
  final RxBool isSummaryLoading = false.obs;
  final RxString summaryError = ''.obs;

  // Available events
  final RxList<Map<String, dynamic>> availableEvents =
      <Map<String, dynamic>>[].obs;
  final RxBool isEventsLoading = false.obs;
  final RxString eventsError = ''.obs;

  // Selected event for chart
  final Rxn<Map<String, dynamic>> selectedEvent = Rxn<Map<String, dynamic>>();

  // Time series data
  final RxList<Map<String, dynamic>> timeSeriesData =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> timeSeriesSummary = <String, dynamic>{}.obs;
  final RxBool isTimeSeriesLoading = false.obs;
  final RxString timeSeriesError = ''.obs;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Request-From': 'Dashboard',
    'user-id': AuthService.instance.authCustomer?.user?.id.toString() ?? '',
  };

  String get _dateFilterQuery {
    final filter = selectedDateFilter.value;
    // API doesn't support all-time, convert to custom-date with wide range
    if (filter == 'all-time') {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final now = DateTime.now();
      final yearBack = DateTime(now.year - 1, now.month, now.day);

      return 'date_filter=custom-date&start_date=$yearBack&end_date=$today';
    }
    String query = 'date_filter=$filter';
    if (filter == 'custom-date') {
      if (customStartDate.value != null) {
        query +=
            '&start_date=${DateFormat('yyyy-MM-dd').format(customStartDate.value!)}';
      }
      if (customEndDate.value != null) {
        query +=
            '&end_date=${DateFormat('yyyy-MM-dd').format(customEndDate.value!)}';
      }
    }
    return query;
  }

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([fetchSummary(), fetchAvailableEvents()]);
  }

  void onDateFilterChanged(String value) {
    selectedDateFilter.value = value;
    if (value != 'custom-date') {
      customStartDate.value = null;
      customEndDate.value = null;
      _loadAll();
    }
  }

  Future<void> pickCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start:
            customStartDate.value ??
            DateTime.now().subtract(const Duration(days: 30)),
        end: customEndDate.value ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      customStartDate.value = picked.start;
      customEndDate.value = picked.end;
      _loadAll();
    }
  }

  // ─── Summary API ───
  Future<void> fetchSummary() async {
    isSummaryLoading.value = true;
    summaryError.value = '';

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/summary?$_dateFilterQuery'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        summaryData.value = (json['data'] as Map<String, dynamic>?) ?? {};
      } else {
        summaryError.value = 'Failed to load summary (${response.statusCode})';
      }
    } on SocketException {
      summaryError.value = 'No internet connection';
    } on TimeoutException {
      summaryError.value = 'Connection timeout';
    } catch (e) {
      summaryError.value = 'Something went wrong';
      debugPrint('Error fetching summary: $e');
    } finally {
      isSummaryLoading.value = false;
    }
  }

  // ─── Available Events API ───
  Future<void> fetchAvailableEvents() async {
    isEventsLoading.value = true;
    eventsError.value = '';

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/available-events?$_dateFilterQuery'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> events = json['events'] ?? [];
        availableEvents.assignAll(events.cast<Map<String, dynamic>>());

        // Auto-select first event if none selected or current not in list
        if (availableEvents.isNotEmpty) {
          final currentKey = selectedEvent.value?['key'];
          final stillExists = availableEvents.any(
            (e) => e['key'] == currentKey,
          );

          if (selectedEvent.value == null || !stillExists) {
            selectedEvent.value = availableEvents.first;
          }
          fetchTimeSeries();
        } else {
          selectedEvent.value = null;
          timeSeriesData.clear();
          timeSeriesSummary.clear();
        }
      } else {
        eventsError.value = 'Failed to load events (${response.statusCode})';
      }
    } on SocketException {
      eventsError.value = 'No internet connection';
    } on TimeoutException {
      eventsError.value = 'Connection timeout';
    } catch (e) {
      eventsError.value = 'Something went wrong';
      debugPrint('Error fetching available events: $e');
    } finally {
      isEventsLoading.value = false;
    }
  }

  void onEventSelected(Map<String, dynamic> event) {
    selectedEvent.value = event;
    fetchTimeSeries();
  }

  // ─── Time Series API ───
  Future<void> fetchTimeSeries() async {
    final eventKey = selectedEvent.value?['key'];
    if (eventKey == null) return;

    isTimeSeriesLoading.value = true;
    timeSeriesError.value = '';

    print('$_baseUrl/time-series?event_key=$eventKey&$_dateFilterQuery');

    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/time-series?event_key=$eventKey&$_dateFilterQuery',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> series = json['time_series_data'] ?? [];
        timeSeriesData.assignAll(series.cast<Map<String, dynamic>>());
        timeSeriesSummary.value =
            (json['summary'] as Map<String, dynamic>?) ?? {};
      } else {
        timeSeriesError.value =
            'Failed to load chart data (${response.statusCode})';
      }
    } on SocketException {
      timeSeriesError.value = 'No internet connection';
    } on TimeoutException {
      timeSeriesError.value = 'Connection timeout';
    } catch (e) {
      timeSeriesError.value = 'Something went wrong';
      debugPrint('Error fetching time series: $e');
    } finally {
      isTimeSeriesLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await _loadAll();
  }
}
