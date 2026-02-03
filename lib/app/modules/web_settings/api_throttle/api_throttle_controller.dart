import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/web_settings/api_throttle/api_throttle_service.dart';

class ApiThrottleController extends GetxController {
  // Loading states
  var isLoading = true.obs;
  var isSaving = false.obs;
  var errorMessage = Rxn<String>();

  // Read Rate Limiting
  final readRateLimitNormalController = TextEditingController();
  final readRateLimitFlashController = TextEditingController();
  final readKeyRateLimitController = TextEditingController();
  final readKeyRateLimitFlashController = TextEditingController();
  var flashModeEnabled = false.obs;

  // Write Rate Limiting
  final writeRateLimitPerSecondController = TextEditingController();
  final writeRateLimitPerMinuteController = TextEditingController();

  // Soft Gate (Micro-Queue)
  final softGateMaxRequestsController = TextEditingController();
  final softGateTimeWindowController = TextEditingController();
  final softGateWaitTimeController = TextEditingController();
  var enableSoftGate = false.obs;

  // Order Locking
  final orderLockDurationController = TextEditingController();
  final flashDealLockDurationController = TextEditingController();
  final orderLockRetryAttemptsController = TextEditingController();
  var enableOrderLocking = false.obs;

  // Idempotency Protection
  final idempotencyCacheDurationController = TextEditingController();
  var enableIdempotencyProtection = false.obs;

  // Logging & Monitoring
  var detailedRateLimitLogging = false.obs;
  var rateLimitMetricsEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    // Dispose all controllers
    readRateLimitNormalController.dispose();
    readRateLimitFlashController.dispose();
    readKeyRateLimitController.dispose();
    readKeyRateLimitFlashController.dispose();
    writeRateLimitPerSecondController.dispose();
    writeRateLimitPerMinuteController.dispose();
    softGateMaxRequestsController.dispose();
    softGateTimeWindowController.dispose();
    softGateWaitTimeController.dispose();
    orderLockDurationController.dispose();
    flashDealLockDurationController.dispose();
    orderLockRetryAttemptsController.dispose();
    idempotencyCacheDurationController.dispose();
    super.onClose();
  }

  /// Fetch settings from API
  Future<void> fetchSettings() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await ApiThrottleService.fetchSettings();

      if (response.success && response.settings != null) {
        _populateFields(response.settings!);
      } else {
        errorMessage.value = response.error ?? 'Failed to load settings';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Populate form fields with fetched settings
  void _populateFields(ApiThrottleSettings settings) {
    // Read Rate Limiting
    readRateLimitNormalController.text = settings.readRateLimitNormal;
    readRateLimitFlashController.text = settings.readRateLimitFlash;
    readKeyRateLimitController.text = settings.readKeyRateLimit;
    readKeyRateLimitFlashController.text = settings.readKeyRateLimitFlash;
    flashModeEnabled.value = settings.flashModeEnabled;

    // Write Rate Limiting
    writeRateLimitPerSecondController.text = settings.writeRateLimitPerSecond;
    writeRateLimitPerMinuteController.text = settings.writeRateLimitPerMinute;

    // Soft Gate (Micro-Queue)
    softGateMaxRequestsController.text = settings.softGateMaxRequests;
    softGateTimeWindowController.text = settings.softGateTimeWindow;
    softGateWaitTimeController.text = settings.softGateWaitTime;
    enableSoftGate.value = settings.enableSoftGate;

    // Order Locking
    orderLockDurationController.text = settings.orderLockDuration;
    flashDealLockDurationController.text = settings.flashDealLockDuration;
    orderLockRetryAttemptsController.text = settings.orderLockRetryAttempts;
    enableOrderLocking.value = settings.enableOrderLocking;

    // Idempotency Protection
    idempotencyCacheDurationController.text = settings.idempotencyCacheDuration;
    enableIdempotencyProtection.value = settings.enableIdempotencyProtection;

    // Logging & Monitoring
    detailedRateLimitLogging.value = settings.detailedRateLimitLogging;
    rateLimitMetricsEnabled.value = settings.rateLimitMetricsEnabled;
  }

  /// Save settings to API
  Future<void> saveSettings() async {
    if (isSaving.value) return;

    isSaving.value = true;

    try {
      final settings = ApiThrottleSettings(
        // Read Rate Limiting
        readRateLimitNormal: readRateLimitNormalController.text,
        readRateLimitFlash: readRateLimitFlashController.text,
        readKeyRateLimit: readKeyRateLimitController.text,
        readKeyRateLimitFlash: readKeyRateLimitFlashController.text,
        flashModeEnabled: flashModeEnabled.value,

        // Write Rate Limiting
        writeRateLimitPerSecond: writeRateLimitPerSecondController.text,
        writeRateLimitPerMinute: writeRateLimitPerMinuteController.text,

        // Soft Gate (Micro-Queue)
        softGateMaxRequests: softGateMaxRequestsController.text,
        softGateTimeWindow: softGateTimeWindowController.text,
        softGateWaitTime: softGateWaitTimeController.text,
        enableSoftGate: enableSoftGate.value,

        // Order Locking
        orderLockDuration: orderLockDurationController.text,
        flashDealLockDuration: flashDealLockDurationController.text,
        orderLockRetryAttempts: orderLockRetryAttemptsController.text,
        enableOrderLocking: enableOrderLocking.value,

        // Idempotency Protection
        idempotencyCacheDuration: idempotencyCacheDurationController.text,
        enableIdempotencyProtection: enableIdempotencyProtection.value,

        // Logging & Monitoring
        detailedRateLimitLogging: detailedRateLimitLogging.value,
        rateLimitMetricsEnabled: rateLimitMetricsEnabled.value,
      );

      final response = await ApiThrottleService.updateSettings(
        settings.toUpdatePayload(),
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
      isSaving.value = false;
    }
  }
}
