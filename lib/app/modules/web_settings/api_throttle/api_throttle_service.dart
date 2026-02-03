import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiThrottleService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';

  /// Fetch all settings from server
  static Future<SettingsResponse> fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/settings?_t=${DateTime.now().microsecondsSinceEpoch}',
        ),
        headers: {'Accept': 'application/json', 'X-Request-From': 'Website'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final options = data['options'] as Map<String, dynamic>? ?? {};

        return SettingsResponse(
          success: true,
          settings: ApiThrottleSettings.fromJson(options),
        );
      } else {
        return SettingsResponse(
          success: false,
          error: 'Failed to fetch settings. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SettingsResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update settings
  static Future<UpdateResponse> updateSettings(
    Map<String, String> settings,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/settings/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Website',
        },
        body: jsonEncode(settings),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UpdateResponse(
          success: true,
          message: data['message'] ?? 'Settings updated successfully',
        );
      } else {
        final data = jsonDecode(response.body);
        return UpdateResponse(
          success: false,
          message: data['message'] ?? 'Failed to update settings',
        );
      }
    } catch (e) {
      return UpdateResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

/// Model for API Throttle Settings
class ApiThrottleSettings {
  // Read Rate Limiting
  final String readRateLimitNormal;
  final String readRateLimitFlash;
  final String readKeyRateLimit;
  final String readKeyRateLimitFlash;
  final bool flashModeEnabled;

  // Write Rate Limiting
  final String writeRateLimitPerSecond;
  final String writeRateLimitPerMinute;

  // Soft Gate (Micro-Queue)
  final String softGateMaxRequests;
  final String softGateTimeWindow;
  final String softGateWaitTime;
  final bool enableSoftGate;

  // Order Locking
  final String orderLockDuration;
  final String flashDealLockDuration;
  final String orderLockRetryAttempts;
  final bool enableOrderLocking;

  // Idempotency Protection
  final String idempotencyCacheDuration;
  final bool enableIdempotencyProtection;

  // Logging & Monitoring
  final bool detailedRateLimitLogging;
  final bool rateLimitMetricsEnabled;

  ApiThrottleSettings({
    required this.readRateLimitNormal,
    required this.readRateLimitFlash,
    required this.readKeyRateLimit,
    required this.readKeyRateLimitFlash,
    required this.flashModeEnabled,
    required this.writeRateLimitPerSecond,
    required this.writeRateLimitPerMinute,
    required this.softGateMaxRequests,
    required this.softGateTimeWindow,
    required this.softGateWaitTime,
    required this.enableSoftGate,
    required this.orderLockDuration,
    required this.flashDealLockDuration,
    required this.orderLockRetryAttempts,
    required this.enableOrderLocking,
    required this.idempotencyCacheDuration,
    required this.enableIdempotencyProtection,
    required this.detailedRateLimitLogging,
    required this.rateLimitMetricsEnabled,
  });

  factory ApiThrottleSettings.fromJson(Map<String, dynamic> json) {
    print(json['read_rate_limit_normal']);
    return ApiThrottleSettings(
      // Read Rate Limiting
      readRateLimitNormal: json['read_rate_limit_normal']?.toString() ?? '',
      readRateLimitFlash: json['read_rate_limit_flash']?.toString() ?? '',
      readKeyRateLimit: json['read_key_rate_limit']?.toString() ?? '',
      readKeyRateLimitFlash:
          json['read_key_rate_limit_flash']?.toString() ?? '',
      flashModeEnabled: json['flash_mode_enabled']?.toString() == '1',

      // Write Rate Limiting
      writeRateLimitPerSecond:
          json['write_rate_limit_per_second']?.toString() ?? '',
      writeRateLimitPerMinute:
          json['write_rate_limit_per_minute']?.toString() ?? '',

      // Soft Gate (Micro-Queue)
      softGateMaxRequests: json['soft_gate_max_requests']?.toString() ?? '',
      softGateTimeWindow: json['soft_gate_time_window']?.toString() ?? '',
      softGateWaitTime: json['soft_gate_wait_time']?.toString() ?? '',
      enableSoftGate: json['enable_soft_gate']?.toString() == '1',

      // Order Locking
      orderLockDuration: json['order_lock_duration']?.toString() ?? '',
      flashDealLockDuration: json['flash_deal_lock_duration']?.toString() ?? '',
      orderLockRetryAttempts:
          json['order_lock_retry_attempts']?.toString() ?? '',
      enableOrderLocking: json['enable_order_locking']?.toString() == '1',

      // Idempotency Protection
      idempotencyCacheDuration:
          json['idempotency_cache_duration']?.toString() ?? '',
      enableIdempotencyProtection:
          json['enable_idempotency_protection']?.toString() == '1',

      // Logging & Monitoring
      detailedRateLimitLogging:
          json['detailed_rate_limit_logging']?.toString() == '1',
      rateLimitMetricsEnabled:
          json['rate_limit_metrics_enabled']?.toString() == '1',
    );
  }

  Map<String, String> toUpdatePayload() {
    return {
      // Read Rate Limiting
      'read_rate_limit_normal': readRateLimitNormal,
      'read_rate_limit_flash': readRateLimitFlash,
      'read_key_rate_limit': readKeyRateLimit,
      'read_key_rate_limit_flash': readKeyRateLimitFlash,
      'flash_mode_enabled': flashModeEnabled ? '1' : '0',

      // Write Rate Limiting
      'write_rate_limit_per_second': writeRateLimitPerSecond,
      'write_rate_limit_per_minute': writeRateLimitPerMinute,

      // Soft Gate (Micro-Queue)
      'soft_gate_max_requests': softGateMaxRequests,
      'soft_gate_time_window': softGateTimeWindow,
      'soft_gate_wait_time': softGateWaitTime,
      'enable_soft_gate': enableSoftGate ? '1' : '0',

      // Order Locking
      'order_lock_duration': orderLockDuration,
      'flash_deal_lock_duration': flashDealLockDuration,
      'order_lock_retry_attempts': orderLockRetryAttempts,
      'enable_order_locking': enableOrderLocking ? '1' : '0',

      // Idempotency Protection
      'idempotency_cache_duration': idempotencyCacheDuration,
      'enable_idempotency_protection': enableIdempotencyProtection ? '1' : '0',

      // Logging & Monitoring
      'detailed_rate_limit_logging': detailedRateLimitLogging ? '1' : '0',
      'rate_limit_metrics_enabled': rateLimitMetricsEnabled ? '1' : '0',
    };
  }
}

/// Response model for fetching settings
class SettingsResponse {
  final bool success;
  final ApiThrottleSettings? settings;
  final String? error;

  SettingsResponse({required this.success, this.settings, this.error});
}

/// Response model for updating settings
class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}
