import 'dart:convert';
import 'package:http/http.dart' as http;

class LogMonitorService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';

  /// Fetch log content from server
  /// [file] - log file name (laravel.log, worker.log)
  /// [lines] - number of lines to fetch
  static Future<LogResponse> fetchLogs({
    required String file,
    required int lines,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/logs/tail',
      ).replace(queryParameters: {'file': file, 'lines': lines.toString()});

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json', 'X-Request-From': 'Website'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LogResponse(
          success: data['success'] ?? false,
          content: data['content'] ?? '',
          hasNewContent: data['has_new_content'] ?? false,
          lastModified: data['last_modified'],
        );
      } else if (response.statusCode == 401) {
        return LogResponse(
          success: false,
          content: '',
          error: 'Unauthorized. Please login again.',
          statusCode: 401,
        );
      } else if (response.statusCode == 403) {
        return LogResponse(
          success: false,
          content: '',
          error: 'Access denied. You don\'t have permission to view logs.',
          statusCode: 403,
        );
      } else if (response.statusCode == 404) {
        return LogResponse(
          success: false,
          content: '',
          error: 'Log file not found.',
          statusCode: 404,
        );
      } else if (response.statusCode >= 500) {
        return LogResponse(
          success: false,
          content: '',
          error: 'Server error. Please try again later.',
          statusCode: response.statusCode,
        );
      } else {
        final data = jsonDecode(response.body);
        return LogResponse(
          success: false,
          content: '',
          error: data['message'] ?? 'Failed to fetch logs',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return LogResponse(
        success: false,
        content: '',
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update log settings
  /// [enableApiPerformanceLogs] - enable/disable API performance logs
  /// [enableEtagLogs] - enable/disable E-Tag logs
  static Future<SettingsResponse> updateSettings({
    required bool enableApiPerformanceLogs,
    required bool enableEtagLogs,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/settings/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Website',
        },
        body: jsonEncode({
          'enable_api_performance_logs': enableApiPerformanceLogs ? '1' : '0',
          'enable_etag_logs': enableEtagLogs ? '1' : '0',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SettingsResponse(
          success: true,
          message: data['message'] ?? 'Settings updated successfully',
        );
      } else if (response.statusCode == 401) {
        return SettingsResponse(
          success: false,
          message: 'Unauthorized. Please login again.',
        );
      } else if (response.statusCode == 403) {
        return SettingsResponse(
          success: false,
          message: 'Access denied. You don\'t have permission.',
        );
      } else {
        final data = jsonDecode(response.body);
        return SettingsResponse(
          success: false,
          message: data['message'] ?? 'Failed to update settings',
        );
      }
    } catch (e) {
      return SettingsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}

/// Response model for log fetch API
class LogResponse {
  final bool success;
  final String content;
  final bool hasNewContent;
  final int? lastModified;
  final String? error;
  final int? statusCode;

  LogResponse({
    required this.success,
    required this.content,
    this.hasNewContent = false,
    this.lastModified,
    this.error,
    this.statusCode,
  });
}

/// Response model for settings update API
class SettingsResponse {
  final bool success;
  final String message;

  SettingsResponse({required this.success, required this.message});
}
