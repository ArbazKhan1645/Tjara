import 'dart:convert';
import 'package:http/http.dart' as http;

class AnalyticsReportingService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'X-Request-From': 'Website',
  };

  static Map<String, String> get _headersWithJson => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Request-From': 'Website',
  };

  /// Fetch settings from server
  static Future<SettingsResponse> fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/settings?_t=${DateTime.now().microsecondsSinceEpoch}',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final options = data['options'] as Map<String, dynamic>? ?? {};

        return SettingsResponse(
          success: true,
          settings: AnalyticsReportingSettings.fromJson(options),
        );
      } else {
        return SettingsResponse(
          success: false,
          error: 'Failed to fetch settings. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SettingsResponse(success: false, error: 'Network error: $e');
    }
  }

  /// Update settings
  static Future<UpdateResponse> updateSettings(
    Map<String, String> settings,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/settings/update'),
        headers: _headersWithJson,
        body: jsonEncode(settings),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return UpdateResponse(
          success: true,
          message: data['message'] ?? 'Settings updated successfully',
        );
      } else {
        return UpdateResponse(
          success: false,
          message: data['message'] ?? 'Failed to update settings',
        );
      }
    } catch (e) {
      return UpdateResponse(success: false, message: 'Network error: $e');
    }
  }

  /// Search shops/stores
  static Future<List<ShopItem>> searchShops({String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '$_baseUrl/shops',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final shopsData = data['shops']['data'] as List? ?? [];

        return shopsData.map((shop) => ShopItem.fromJson(shop)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

// ============================================
// Models
// ============================================

/// Analytics Reporting Settings
class AnalyticsReportingSettings {
  final bool enabled;
  final String scope; // 'all' or 'specific_store'
  final String storeId;
  final String frequency;
  final String time;
  final String recipients;

  AnalyticsReportingSettings({
    required this.enabled,
    required this.scope,
    required this.storeId,
    required this.frequency,
    required this.time,
    required this.recipients,
  });

  factory AnalyticsReportingSettings.fromJson(Map<String, dynamic> json) {
    return AnalyticsReportingSettings(
      enabled: json['analytics_reporting_enabled']?.toString() == '1',
      scope: json['analytics_reporting_scope']?.toString() ?? 'all',
      storeId: json['analytics_reporting_store_id']?.toString() ?? '',
      frequency: json['analytics_reporting_frequency']?.toString() ?? 'daily',
      time: json['analytics_reporting_time']?.toString() ?? '10:00',
      recipients: json['analytics_reporting_recipients']?.toString() ?? '',
    );
  }

  Map<String, String> toUpdatePayload() {
    return {
      'analytics_reporting_enabled': enabled ? '1' : '0',
      'analytics_reporting_scope': scope,
      'analytics_reporting_store_id': storeId,
      'analytics_reporting_frequency': frequency,
      'analytics_reporting_time': time,
      'analytics_reporting_recipients': recipients,
    };
  }
}

/// Shop Item
class ShopItem {
  final String id;
  final String name;

  ShopItem({required this.id, required this.name});

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

// ============================================
// Response Models
// ============================================

class SettingsResponse {
  final bool success;
  final AnalyticsReportingSettings? settings;
  final String? error;

  SettingsResponse({required this.success, this.settings, this.error});
}

class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}
