import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/modules/web_settings/common/web_settings_widgets.dart';
import 'package:tjara/app/modules/web_settings/api_throttle/api_throttle_controller.dart';

class ApiThrottleScreen extends StatelessWidget {
  const ApiThrottleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApiThrottleController());

    return Scaffold(
      backgroundColor: WebSettingsTheme.backgroundColor,
      appBar: WebSettingsAppBar(
        title: 'API Throttle Settings',
        actions: [
          Obx(
            () =>
                controller.isSaving.value
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

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              const WebSettingsHeaderCard(
                title: 'API Throttle Settings',
                description:
                    'Configure rate limits and protection for API endpoints.',
                icon: Icons.speed_rounded,
                badge: 'Advanced',
              ),

              // Read Rate Limiting Section
              _ReadRateLimitingSection(controller: controller),

              // Write Rate Limiting Section
              _WriteRateLimitingSection(controller: controller),

              // Soft Gate Section
              _SoftGateSection(controller: controller),

              // Order Locking Section
              _OrderLockingSection(controller: controller),

              // Idempotency Protection Section
              _IdempotencySection(controller: controller),

              // Logging & Monitoring Section
              _LoggingMonitoringSection(controller: controller),

              // Important Notes
              const _ImportantNotesSection(),

              // Save Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(
                  () => WebSettingsPrimaryButton(
                    label: 'Save Changes',
                    icon: Icons.save_rounded,
                    isLoading: controller.isSaving.value,
                    onPressed: controller.saveSettings,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}

// ============================================
// Read Rate Limiting Section
// ============================================
class _ReadRateLimitingSection extends StatelessWidget {
  final ApiThrottleController controller;

  const _ReadRateLimitingSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebSettingsSectionCard(
      title: 'Read Rate Limiting',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WebSettingsTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: WebSettingsTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Configure rate limits for read operations (GET requests)',
                  style: TextStyle(
                    fontSize: 12,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Normal Mode & Flash Mode Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Normal Mode (RPS per IP)',
                  controller: controller.readRateLimitNormalController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Flash Mode (RPS per IP)',
                  controller: controller.readRateLimitFlashController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Content Key Rate Limit Row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Content Key Rate Limit (Normal)',
                  controller: controller.readKeyRateLimitController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Content Key Rate Limit (Flash)',
                  controller: controller.readKeyRateLimitFlashController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Enable Flash Mode Toggle
          Obx(
            () => WebSettingsToggleRow(
              title: 'Enable Flash Mode Rate Limits',
              subtitle:
                  'Automatically applies higher rate limits during flash deals',
              value: controller.flashModeEnabled.value,
              onChanged: (val) => controller.flashModeEnabled.value = val,
              icon: Icons.flash_on_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 10,

            fontWeight: FontWeight.w500,
            color: WebSettingsTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            filled: true,
            fillColor: WebSettingsTheme.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: WebSettingsTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: WebSettingsTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebSettingsTheme.primaryColor,
              ),
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

// ============================================
// Write Rate Limiting Section
// ============================================
class _WriteRateLimitingSection extends StatelessWidget {
  final ApiThrottleController controller;

  const _WriteRateLimitingSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebSettingsSectionCard(
      title: 'Write Rate Limiting',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WebSettingsTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: WebSettingsTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Configure rate limits for write operations (POST, PUT, DELETE)',
                  style: TextStyle(
                    fontSize: 12,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Per Second Limit',
                  controller: controller.writeRateLimitPerSecondController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Per Minute Limit',
                  controller: controller.writeRateLimitPerMinuteController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: WebSettingsTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            filled: true,
            fillColor: WebSettingsTheme.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: WebSettingsTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: WebSettingsTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebSettingsTheme.primaryColor,
              ),
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

// ============================================
// Soft Gate Section
// ============================================
class _SoftGateSection extends StatelessWidget {
  final ApiThrottleController controller;

  const _SoftGateSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebSettingsSectionCard(
      title: 'Soft Gate (Micro-Queue)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WebSettingsTheme.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Advanced',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Configure micro-queue behavior to handle burst traffic gracefully',
                  style: TextStyle(
                    fontSize: 12,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Max Requests',
                  controller: controller.softGateMaxRequestsController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  label: 'Time Window (s)',
                  controller: controller.softGateTimeWindowController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  label: 'Wait Time (ms)',
                  controller: controller.softGateWaitTimeController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Obx(
            () => WebSettingsToggleRow(
              title: 'Enable Soft Gate Micro-Queue',
              subtitle:
                  'Queue requests instead of immediately returning 429 errors',
              value: controller.enableSoftGate.value,
              onChanged: (val) => controller.enableSoftGate.value = val,
              icon: Icons.queue_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: WebSettingsTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            filled: true,
            fillColor: WebSettingsTheme.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: WebSettingsTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: WebSettingsTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebSettingsTheme.primaryColor,
              ),
            ),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

// ============================================
// Order Locking Section
// ============================================
class _OrderLockingSection extends StatelessWidget {
  final ApiThrottleController controller;

  const _OrderLockingSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebSettingsSectionCard(
      title: 'Order Locking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WebSettingsTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Critical',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: WebSettingsTheme.errorColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Configure Redis-based locking for order creation to prevent duplicates',
                  style: TextStyle(
                    fontSize: 12,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Order Lock Duration (s)',
                  controller: controller.orderLockDurationController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  label: 'Flash Deal Lock (s)',
                  controller: controller.flashDealLockDurationController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  label: 'Retry Attempts',
                  controller: controller.orderLockRetryAttemptsController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Obx(
            () => WebSettingsToggleRow(
              title: 'Enable Order Locking',
              subtitle: 'Prevent duplicate orders through Redis locking',
              value: controller.enableOrderLocking.value,
              onChanged: (val) => controller.enableOrderLocking.value = val,
              icon: Icons.lock_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: WebSettingsTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            filled: true,
            fillColor: WebSettingsTheme.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: WebSettingsTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: WebSettingsTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebSettingsTheme.primaryColor,
              ),
            ),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

// ============================================
// Idempotency Protection Section
// ============================================
class _IdempotencySection extends StatelessWidget {
  final ApiThrottleController controller;

  const _IdempotencySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebSettingsSectionCard(
      title: 'Idempotency Protection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WebSettingsTheme.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Cache idempotent requests to prevent duplicate processing',
                  style: TextStyle(
                    fontSize: 12,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cache Duration (seconds)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: WebSettingsTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.idempotencyCacheDurationController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '600 (10 minutes)',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: WebSettingsTheme.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: WebSettingsTheme.dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: WebSettingsTheme.dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: WebSettingsTheme.primaryColor,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Obx(
            () => WebSettingsToggleRow(
              title: 'Enable Idempotency Protection',
              subtitle:
                  'Cache responses for identical requests within time window',
              value: controller.enableIdempotencyProtection.value,
              onChanged:
                  (val) => controller.enableIdempotencyProtection.value = val,
              icon: Icons.cached_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Logging & Monitoring Section
// ============================================
class _LoggingMonitoringSection extends StatelessWidget {
  final ApiThrottleController controller;

  const _LoggingMonitoringSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebSettingsSectionCard(
      title: 'Logging & Monitoring',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: WebSettingsTheme.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Configure detailed logging and metrics collection',
                  style: TextStyle(
                    fontSize: 12,
                    color: WebSettingsTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Obx(
            () => WebSettingsToggleRow(
              title: 'Enable Detailed Rate Limit Logging',
              subtitle: 'Log successful requests (warning: high volume)',
              value: controller.detailedRateLimitLogging.value,
              onChanged:
                  (val) => controller.detailedRateLimitLogging.value = val,
              icon: Icons.description_rounded,
            ),
          ),

          const SizedBox(height: 8),

          Obx(
            () => WebSettingsToggleRow(
              title: 'Enable Rate Limit Metrics Collection',
              subtitle: 'Collect performance metrics for monitoring',
              value: controller.rateLimitMetricsEnabled.value,
              onChanged:
                  (val) => controller.rateLimitMetricsEnabled.value = val,
              icon: Icons.analytics_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Important Notes Section
// ============================================
class _ImportantNotesSection extends StatelessWidget {
  const _ImportantNotesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebSettingsTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WebSettingsTheme.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: WebSettingsTheme.warningColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Important Configuration Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: WebSettingsTheme.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNote(
            'Performance Impact:',
            'Lower rate limits improve stability but may affect user experience during high traffic.',
          ),
          const SizedBox(height: 6),
          _buildNote(
            'Redis Required:',
            'Order locking and soft gate features require Redis to be configured and running.',
          ),
          const SizedBox(height: 6),
          _buildNote(
            'Flash Mode:',
            'Automatically switches to higher limits during flash deals to handle burst traffic.',
          ),
          const SizedBox(height: 6),
          _buildNote(
            'Monitoring:',
            'Enable metrics collection for production environments to track API performance.',
          ),
        ],
      ),
    );
  }

  Widget _buildNote(String title, String description) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: Colors.amber.shade900,
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: WebSettingsTheme.errorColor,
            ),
          ),
          TextSpan(text: ' $description'),
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
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
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
