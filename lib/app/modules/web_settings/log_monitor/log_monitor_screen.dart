import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/log_monitor/log_monitor_controller.dart';

class LogMonitorScreen extends StatelessWidget {
  const LogMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LogMonitorController());

    return Scaffold(
      backgroundColor: WebSettingsTheme.backgroundColor,
      appBar: const WebSettingsAppBar(title: 'Real-time Log Monitor'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            const WebSettingsHeaderCard(
              title: 'Log Monitor',
              description:
                  'Monitor server logs in real-time. Configure log files, refresh intervals, and view errors/warnings.',
              icon: Icons.terminal_rounded,
              badge: 'Tools',
            ),

            // Settings Section (Checkboxes + Save Button)
            _SettingsSection(controller: controller),

            const SizedBox(height: 12),

            // Controls Section (Dropdowns + Start/Stop)
            _ControlsSection(controller: controller),

            const SizedBox(height: 12),

            // Stats Section (Errors, Warnings, Last Update)
            _StatsSection(controller: controller),

            const SizedBox(height: 12),

            // Monitoring Status
            _MonitoringStatus(controller: controller),

            const SizedBox(height: 8),

            // Log Content Section
            _LogContentSection(controller: controller),

            const SizedBox(height: 12),

            // Instructions Section
            const _InstructionsSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============================================
// Settings Section (Checkboxes + Save Button)
// ============================================
class _SettingsSection extends StatelessWidget {
  final LogMonitorController controller;

  const _SettingsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebSettingsSectionCard(
      title: 'Log Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkboxes Row
          Obx(
            () => WebSettingsToggleRow(
              title: 'Enable Api Performance Logs',
              subtitle: 'Log API response times and performance metrics',
              value: controller.enableApiPerformanceLogs.value,
              onChanged:
                  (value) => controller.enableApiPerformanceLogs.value = value,
              icon: Icons.speed_rounded,
            ),
          ),

          const SizedBox(height: 8),

          Obx(
            () => WebSettingsToggleRow(
              title: 'Enable E-Tag Logs',
              subtitle: 'Log ETag cache hit/miss events',
              value: controller.enableEtagLogs.value,
              onChanged: (value) => controller.enableEtagLogs.value = value,
              icon: Icons.cached_rounded,
            ),
          ),

          const SizedBox(height: 16),

          // Save Settings Button
          Obx(
            () => WebSettingsPrimaryButton(
              label: 'Save Settings',
              icon: Icons.save_rounded,
              isLoading: controller.isSavingSettings.value,
              onPressed: controller.saveSettings,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Controls Section (Dropdowns + Start/Stop)
// ============================================
class _ControlsSection extends StatelessWidget {
  final LogMonitorController controller;

  const _ControlsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebSettingsSectionCard(
      title: 'Monitor Controls',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Log File Dropdown
          _buildDropdownField(
            label: 'Log File',
            child: Obx(() {
              final isDisabled = controller.isMonitoring.value;
              return Opacity(
                opacity: isDisabled ? 0.6 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color:
                        isDisabled
                            ? Colors.grey.shade200
                            : WebSettingsTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: WebSettingsTheme.dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedLogFile.value,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color:
                            isDisabled
                                ? Colors.grey
                                : WebSettingsTheme.textSecondary,
                      ),
                      items:
                          controller.logFileOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option.name,
                              child: Text(option.displayName),
                            );
                          }).toList(),
                      onChanged:
                          isDisabled
                              ? null
                              : (value) {
                                if (value != null) controller.setLogFile(value);
                              },
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Number of Lines & Refresh Interval Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Number of Lines',
                  child: Obx(() {
                    final isDisabled = controller.isMonitoring.value;
                    return Opacity(
                      opacity: isDisabled ? 0.6 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color:
                              isDisabled
                                  ? Colors.grey.shade200
                                  : WebSettingsTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: WebSettingsTheme.dividerColor,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: controller.selectedLines.value,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color:
                                  isDisabled
                                      ? Colors.grey
                                      : WebSettingsTheme.textSecondary,
                            ),
                            items:
                                controller.linesOptions.map((lines) {
                                  return DropdownMenuItem<int>(
                                    value: lines,
                                    child: Text('$lines lines'),
                                  );
                                }).toList(),
                            onChanged:
                                isDisabled
                                    ? null
                                    : (value) {
                                      if (value != null) {
                                        controller.setLines(value);
                                      }
                                    },
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildDropdownField(
                  label: 'Refresh Interval',
                  child: Obx(() {
                    final isDisabled = controller.isMonitoring.value;
                    return Opacity(
                      opacity: isDisabled ? 0.6 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color:
                              isDisabled
                                  ? Colors.grey.shade200
                                  : WebSettingsTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: WebSettingsTheme.dividerColor,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: controller.selectedInterval.value,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color:
                                  isDisabled
                                      ? Colors.grey
                                      : WebSettingsTheme.textSecondary,
                            ),
                            items:
                                controller.intervalOptions.map((interval) {
                                  return DropdownMenuItem<int>(
                                    value: interval,
                                    child: Text('$interval sec'),
                                  );
                                }).toList(),
                            onChanged:
                                isDisabled
                                    ? null
                                    : (value) {
                                      if (value != null) {
                                        controller.setInterval(value);
                                      }
                                    },
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Start/Stop and Clear Buttons Row
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.toggleMonitoring,
                    icon: Icon(
                      controller.isMonitoring.value
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      size: 20,
                    ),
                    label: Text(
                      controller.isMonitoring.value ? 'Stop' : 'Start',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          controller.isMonitoring.value
                              ? WebSettingsTheme.errorColor
                              : WebSettingsTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Container(
                decoration: BoxDecoration(
                  color: WebSettingsTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: WebSettingsTheme.dividerColor),
                ),
                child: IconButton(
                  onPressed: controller.clearLogs,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: WebSettingsTheme.textSecondary,
                  tooltip: 'Clear Logs',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Auto-scroll checkbox
          Obx(
            () => InkWell(
              onTap: () {
                controller.autoScrollToBottom.value =
                    !controller.autoScrollToBottom.value;
                if (controller.autoScrollToBottom.value) {
                  controller.scrollToBottom();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: controller.autoScrollToBottom.value,
                        onChanged: (value) {
                          controller.autoScrollToBottom.value = value ?? false;
                          if (value == true) {
                            controller.scrollToBottom();
                          }
                        },
                        activeColor: WebSettingsTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Auto-scroll to bottom',
                      style: TextStyle(
                        fontSize: 14,
                        color: WebSettingsTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: WebSettingsTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ============================================
// Stats Section (Errors, Warnings, Last Update)
// ============================================
class _StatsSection extends StatelessWidget {
  final LogMonitorController controller;

  const _StatsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Errors Count
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: WebSettingsTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Obx(
                  () => Text(
                    '${controller.errorCount.value}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: WebSettingsTheme.errorColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Errors',
                  style: TextStyle(
                    fontSize: 12,
                    color: WebSettingsTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Warnings Count
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: WebSettingsTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Obx(
                  () => Text(
                    '${controller.warningCount.value}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: WebSettingsTheme.warningColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Warnings',
                  style: TextStyle(
                    fontSize: 12,
                    color: WebSettingsTheme.warningColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Last Update
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: WebSettingsTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Last Update',
                  style: TextStyle(
                    fontSize: 11,
                    color: WebSettingsTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.getFormattedLastUpdate(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: WebSettingsTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// Monitoring Status
// ============================================
class _MonitoringStatus extends StatelessWidget {
  final LogMonitorController controller;

  const _MonitoringStatus({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              controller.isMonitoring.value
                  ? WebSettingsTheme.successColor.withValues(alpha: 0.1)
                  : WebSettingsTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                controller.isMonitoring.value
                    ? WebSettingsTheme.successColor.withValues(alpha: 0.3)
                    : WebSettingsTheme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color:
                    controller.isMonitoring.value
                        ? WebSettingsTheme.successColor
                        : WebSettingsTheme.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.isMonitoring.value
                    ? 'Monitoring ${controller.selectedLogFile.value} (${controller.selectedInterval.value}s interval, ${controller.selectedLines.value} lines)'
                    : 'Not monitoring',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      controller.isMonitoring.value
                          ? WebSettingsTheme.successColor
                          : WebSettingsTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (controller.isLoading.value) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: WebSettingsTheme.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// Log Content Section
// ============================================
class _LogContentSection extends StatelessWidget {
  final LogMonitorController controller;

  const _LogContentSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Obx(() {
          if (controller.errorMessage.value != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: WebSettingsTheme.errorColor,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value!,
                      style: const TextStyle(
                        color: WebSettingsTheme.errorColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.logContent.value.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.terminal_rounded,
                      color: Colors.grey.shade600,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No logs to display.\nClick "Start" to begin monitoring.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Scrollbar(
            controller: controller.scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(12),
              child: SelectableText.rich(
                _buildLogTextSpan(controller.logContent.value),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Build colored text span for log content
  TextSpan _buildLogTextSpan(String content) {
    final List<TextSpan> spans = [];
    final lines = content.split('\n');

    for (var line in lines) {
      Color textColor = const Color(0xFF94A3B8); // Default gray

      if (line.contains('.ERROR:') || line.toLowerCase().contains('error')) {
        textColor = WebSettingsTheme.errorColor;
      } else if (line.contains('.WARNING:') ||
          line.toLowerCase().contains('warning')) {
        textColor = WebSettingsTheme.warningColor;
      } else if (line.contains('.INFO:')) {
        textColor = WebSettingsTheme.successColor;
      } else if (line.contains('.DEBUG:')) {
        textColor = WebSettingsTheme.primaryColor;
      }

      // Highlight timestamps
      if (line.startsWith('[')) {
        final timestampEnd = line.indexOf(']');
        if (timestampEnd > 0) {
          spans.add(
            TextSpan(
              text: line.substring(0, timestampEnd + 1),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          );
          spans.add(
            TextSpan(
              text: '${line.substring(timestampEnd + 1)}\n',
              style: TextStyle(color: textColor),
            ),
          );
          continue;
        }
      }

      spans.add(TextSpan(text: '$line\n', style: TextStyle(color: textColor)));
    }

    return TextSpan(children: spans);
  }
}

// ============================================
// Instructions Section
// ============================================
class _InstructionsSection extends StatelessWidget {
  const _InstructionsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebSettingsTheme.successColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WebSettingsTheme.successColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: WebSettingsTheme.successColor,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: WebSettingsTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstruction(
            'Select a log file and configure the number of lines to monitor',
          ),
          _buildInstruction(
            'Set your preferred refresh interval (1-60 seconds)',
          ),
          _buildInstruction('Click "Start" to begin real-time monitoring'),
          _buildInstruction(
            'Use auto-scroll to automatically scroll to the latest entries',
          ),
          _buildInstruction(
            'Error and warning counts are displayed above the log content',
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: WebSettingsTheme.successColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: WebSettingsTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
