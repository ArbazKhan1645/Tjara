import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/modules/web_settings/log_monitor/log_monitor_service.dart';

class LogMonitorController extends GetxController {
  // Log file options
  final List<LogFileOption> logFileOptions = [
    LogFileOption(name: 'laravel.log', displayName: 'laravel.log'),
    LogFileOption(name: 'worker.log', displayName: 'worker.log'),
  ];

  // Lines options
  final List<int> linesOptions = [10, 25, 50, 100, 200, 500];

  // Interval options (in seconds)
  final List<int> intervalOptions = [1, 2, 5, 10, 30, 60];

  // Selected values
  var selectedLogFile = 'laravel.log'.obs;
  var selectedLines = 50.obs;
  var selectedInterval = 2.obs;

  // Settings checkboxes
  var enableApiPerformanceLogs = false.obs;
  var enableEtagLogs = false.obs;

  // State
  var isMonitoring = false.obs;
  var isLoading = false.obs;
  var isSavingSettings = false.obs;
  var autoScrollToBottom = true.obs;

  // Log content
  var logContent = ''.obs;
  var errorCount = 0.obs;
  var warningCount = 0.obs;
  var lastUpdateTime = Rxn<DateTime>();

  // Error message
  var errorMessage = Rxn<String>();

  // Timer for periodic fetching
  Timer? _fetchTimer;

  // Scroll controller for log content
  final ScrollController scrollController = ScrollController();

  // File size (for display)
  var fileSize = ''.obs;

  @override
  void onClose() {
    stopMonitoring();
    scrollController.dispose();
    super.onClose();
  }

  /// Start monitoring logs
  void startMonitoring() {
    if (isMonitoring.value) return;

    isMonitoring.value = true;
    errorMessage.value = null;

    // Fetch immediately
    _fetchLogs();

    // Start periodic fetching
    _fetchTimer = Timer.periodic(
      Duration(seconds: selectedInterval.value),
      (_) => _fetchLogs(),
    );
  }

  /// Stop monitoring logs
  void stopMonitoring() {
    isMonitoring.value = false;
    _fetchTimer?.cancel();
    _fetchTimer = null;
  }

  /// Toggle monitoring
  void toggleMonitoring() {
    if (isMonitoring.value) {
      stopMonitoring();
    } else {
      startMonitoring();
    }
  }

  /// Fetch logs from server
  Future<void> _fetchLogs() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await LogMonitorService.fetchLogs(
        file: selectedLogFile.value,
        lines: selectedLines.value,
      );

      if (response.success) {
        logContent.value = response.content;
        lastUpdateTime.value = DateTime.now();

        // Count errors and warnings
        _countErrorsAndWarnings(response.content);

        // Auto scroll to bottom if enabled
        if (autoScrollToBottom.value) {
          _scrollToBottom();
        }
      } else {
        errorMessage.value = response.error ?? 'Failed to fetch logs';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Count errors and warnings in log content
  void _countErrorsAndWarnings(String content) {
    // Count ERROR occurrences
    final errorRegex = RegExp(r'\.ERROR:', caseSensitive: false);
    errorCount.value = errorRegex.allMatches(content).length;

    // Count WARNING occurrences
    final warningRegex = RegExp(r'\.WARNING:', caseSensitive: false);
    warningCount.value = warningRegex.allMatches(content).length;
  }

  /// Scroll to bottom of log content
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Manual scroll to bottom
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Clear log content
  void clearLogs() {
    logContent.value = '';
    errorCount.value = 0;
    warningCount.value = 0;
  }

  /// Update selected log file
  void setLogFile(String file) {
    selectedLogFile.value = file;
    if (isMonitoring.value) {
      // Restart monitoring with new file
      stopMonitoring();
      clearLogs();
      startMonitoring();
    }
  }

  /// Update selected lines
  void setLines(int lines) {
    selectedLines.value = lines;
    if (isMonitoring.value) {
      _fetchLogs();
    }
  }

  /// Update selected interval
  void setInterval(int interval) {
    selectedInterval.value = interval;
    if (isMonitoring.value) {
      // Restart timer with new interval
      _fetchTimer?.cancel();
      _fetchTimer = Timer.periodic(
        Duration(seconds: interval),
        (_) => _fetchLogs(),
      );
    }
  }

  /// Toggle auto scroll
  void toggleAutoScroll() {
    autoScrollToBottom.value = !autoScrollToBottom.value;
    if (autoScrollToBottom.value) {
      _scrollToBottom();
    }
  }

  /// Save settings
  Future<void> saveSettings() async {
    if (isSavingSettings.value) return;

    isSavingSettings.value = true;

    try {
      final response = await LogMonitorService.updateSettings(
        enableApiPerformanceLogs: enableApiPerformanceLogs.value,
        enableEtagLogs: enableEtagLogs.value,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save settings: ${e.toString()}',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSavingSettings.value = false;
    }
  }

  /// Get formatted last update time
  String getFormattedLastUpdate() {
    if (lastUpdateTime.value == null) return '--:--:--';
    return DateFormat('HH:mm:ss').format(lastUpdateTime.value!);
  }

  /// Get file size display name
  String getFileSizeDisplay(String fileName) {
    // This would need to come from API, for now just show the name
    return fileName;
  }
}

/// Model for log file option
class LogFileOption {
  final String name;
  final String displayName;

  LogFileOption({
    required this.name,
    required this.displayName,
  });
}
