import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class WebSettingsDashboardService {
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

  /// Fetch dashboard settings (logo, status)
  static Future<DashboardSettingsResponse> fetchSettings() async {
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

        return DashboardSettingsResponse(
          success: true,
          settings: DashboardSettings.fromJson(options),
        );
      } else {
        return DashboardSettingsResponse(
          success: false,
          error: 'Failed to fetch settings. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return DashboardSettingsResponse(
        success: false,
        error: 'Network error: $e',
      );
    }
  }

  /// Fetch current server time
  static Future<ServerTimeResponse> fetchServerTime() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/current-server-time'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timeString = data['current_server_time']?.toString() ?? '';

        DateTime? serverTime;
        if (timeString.isNotEmpty) {
          serverTime = DateTime.tryParse(timeString);
        }

        return ServerTimeResponse(
          success: true,
          serverTime: serverTime ?? DateTime.now(),
        );
      } else {
        return ServerTimeResponse(
          success: false,
          serverTime: DateTime.now(),
          error: 'Failed to fetch server time',
        );
      }
    } catch (e) {
      return ServerTimeResponse(
        success: false,
        serverTime: DateTime.now(),
        error: 'Network error: $e',
      );
    }
  }

  /// Update settings (status, logo)
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

  /// Upload media and return URL (not ID)
  static Future<MediaUploadResponse> uploadMediaAndGetUrl(
    List<File> files, {
    String? directory,
    int? width,
    int? height,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/media/insert');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'X-Request-From': 'Application',
        'Accept': 'application/json',
      });

      // Add media files
      for (var file in files) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'media[]',
          stream,
          length,
          filename: path.basename(file.path),
        );

        request.files.add(multipartFile);
      }

      // Add optional parameters
      if (directory != null) {
        request.fields['directory'] = directory;
      }
      if (width != null) {
        request.fields['width'] = width.toString();
      }
      if (height != null) {
        request.fields['height'] = height.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final mediaList = jsonData['media'] as List?;

        if (mediaList != null && mediaList.isNotEmpty) {
          final mediaItem = mediaList[0] as Map<String, dynamic>;
          final url =
              mediaItem['url']?.toString() ??
              mediaItem['original_url']?.toString() ??
              '';
          final id = mediaItem['id']?.toString() ?? '';

          return MediaUploadResponse(success: true, url: url, id: id);
        }
        return MediaUploadResponse(
          success: false,
          error: 'No media returned from server',
        );
      } else {
        return MediaUploadResponse(
          success: false,
          error: 'Upload failed. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return MediaUploadResponse(success: false, error: 'Upload error: $e');
    }
  }
}

// ============================================
// Models
// ============================================

class DashboardSettings {
  final String websiteStatus;
  final String websiteLogoUrl;
  final String websiteLogoId;
  final String websiteName;

  DashboardSettings({
    required this.websiteStatus,
    required this.websiteLogoUrl,
    required this.websiteLogoId,
    required this.websiteName,
  });

  factory DashboardSettings.fromJson(Map<String, dynamic> json) {
    return DashboardSettings(
      websiteStatus: json['website_status']?.toString() ?? 'active',
      websiteLogoUrl: json['website_logo_url']?.toString() ?? '',
      websiteLogoId: json['website_logo_id']?.toString() ?? '',
      websiteName: json['website_name']?.toString() ?? 'Tjara',
    );
  }
}

// ============================================
// Response Models
// ============================================

class DashboardSettingsResponse {
  final bool success;
  final DashboardSettings? settings;
  final String? error;

  DashboardSettingsResponse({required this.success, this.settings, this.error});
}

class ServerTimeResponse {
  final bool success;
  final DateTime serverTime;
  final String? error;

  ServerTimeResponse({
    required this.success,
    required this.serverTime,
    this.error,
  });
}

class UpdateResponse {
  final bool success;
  final String message;

  UpdateResponse({required this.success, required this.message});
}

class MediaUploadResponse {
  final bool success;
  final String? url;
  final String? id;
  final String? error;

  MediaUploadResponse({required this.success, this.url, this.id, this.error});
}
