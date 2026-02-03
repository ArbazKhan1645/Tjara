import 'dart:convert';
import 'package:http/http.dart' as http;

class InventoryReportingService {
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
          settings: InventoryReportingSettings.fromJson(options),
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

  /// Search shops
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

  /// Search categories
  static Future<List<CategoryItem>> searchCategories({String? search}) async {
    try {
      final queryParams = <String, String>{
        'limit': 'all',
        'hide_empty': 'true',
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '$_baseUrl/product-attributes/categories',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attributeItems =
            data['product_attribute']?['attribute_items']?['product_attribute_items']
                as List? ??
            [];

        return attributeItems.map((cat) => CategoryItem.fromJson(cat)).toList();
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

/// Inventory Reporting Settings
class InventoryReportingSettings {
  final bool enabled;
  final String frequency;
  final String time;
  final String recipients;
  final List<ReportConfig> reportConfigs;

  InventoryReportingSettings({
    required this.enabled,
    required this.frequency,
    required this.time,
    required this.recipients,
    required this.reportConfigs,
  });

  factory InventoryReportingSettings.fromJson(Map<String, dynamic> json) {
    // Parse report configs from JSON string
    List<ReportConfig> configs = [];
    final configsJson = json['inventory_reports_config'];
    if (configsJson != null &&
        configsJson is String &&
        configsJson.isNotEmpty) {
      try {
        final parsed = jsonDecode(configsJson) as List;
        configs = parsed.map((e) => ReportConfig.fromJson(e)).toList();
      } catch (_) {}
    }

    return InventoryReportingSettings(
      enabled: json['inventory_reporting_enabled']?.toString() == '1',
      frequency: json['inventory_reporting_frequency']?.toString() ?? 'daily',
      time: json['inventory_reporting_time']?.toString() ?? '10:00',
      recipients: json['inventory_reporting_recipients']?.toString() ?? '',
      reportConfigs: configs,
    );
  }

  Map<String, String> toUpdatePayload() {
    // Convert report configs to JSON string
    final configsJson = jsonEncode(
      reportConfigs.map((e) => e.toJson()).toList(),
    );

    return {
      'inventory_reporting_enabled': enabled ? '1' : '0',
      'inventory_reporting_frequency': frequency,
      'inventory_reporting_time': time,
      'inventory_reporting_recipients': recipients,
      'inventory_reports_config': configsJson,
    };
  }
}

/// Report Configuration
class ReportConfig {
  String id;
  String name;
  bool enabled;
  String storeId; // 'all' or specific store id
  String category; // 'all' or specific category id
  String categoryFilterType; // 'include' or 'exclude'
  String description;

  // Display names (not saved, just for UI)
  String? storeName;
  String? categoryName;

  ReportConfig({
    required this.id,
    required this.name,
    required this.enabled,
    required this.storeId,
    required this.category,
    required this.categoryFilterType,
    required this.description,
    this.storeName,
    this.categoryName,
  });

  factory ReportConfig.fromJson(Map<String, dynamic> json) {
    return ReportConfig(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? '',
      enabled: json['enabled'] == true || json['enabled'] == 'true',
      storeId: json['store_id']?.toString() ?? 'all',
      category: json['category']?.toString() ?? 'all',
      categoryFilterType: json['category_filter_type']?.toString() ?? 'include',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'enabled': enabled,
      'store_id': storeId,
      'category': category,
      'category_filter_type': categoryFilterType,
      'description': description,
    };
  }

  ReportConfig copyWith({
    String? id,
    String? name,
    bool? enabled,
    String? storeId,
    String? category,
    String? categoryFilterType,
    String? description,
    String? storeName,
    String? categoryName,
  }) {
    return ReportConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      storeId: storeId ?? this.storeId,
      category: category ?? this.category,
      categoryFilterType: categoryFilterType ?? this.categoryFilterType,
      description: description ?? this.description,
      storeName: storeName ?? this.storeName,
      categoryName: categoryName ?? this.categoryName,
    );
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

/// Category Item
class CategoryItem {
  final String id;
  final String name;

  CategoryItem({required this.id, required this.name});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
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
  final InventoryReportingSettings? settings;
  final String? error;

  SettingsResponse({required this.success, this.settings, this.error});
}

class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}
