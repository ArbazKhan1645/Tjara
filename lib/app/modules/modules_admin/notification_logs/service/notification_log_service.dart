import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/modules_admin/notification_logs/model/notification_log_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class NotificationLogApiException implements Exception {
  final String message;
  final int? statusCode;

  NotificationLogApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NotificationLogService {
  static const String baseUrl = 'https://api.libanbuy.com/api';
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'shop-id': AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
    'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
    'X-Request-From': 'Dashboard',
  };

  /// Fetch notification logs with filters and pagination
  Future<NotificationLogResponse> fetchLogs({
    int page = 1,
    int perPage = 10,
    String? receiverName,
    String? receiverEmail,
    String? receiverPhone,
    String? couponCodeValidity,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, String>{
        'type': '',
        'status': '',
        'event_type': 'daily_coupon',
        'user_id': '',
        'search': '',
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (receiverName != null && receiverName.isNotEmpty) {
        queryParams['receiver_name'] = receiverName;
      }
      if (receiverEmail != null && receiverEmail.isNotEmpty) {
        queryParams['receiver_email'] = receiverEmail;
      }
      if (receiverPhone != null && receiverPhone.isNotEmpty) {
        queryParams['receiver_phone'] = receiverPhone;
      }
      if (couponCodeValidity != null && couponCodeValidity.isNotEmpty) {
        queryParams['coupon_code_validity'] = couponCodeValidity;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['date_from'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['date_to'] = dateTo;
      }

      final uri = Uri.parse(
        '$baseUrl/notification-logs',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NotificationLogResponse.fromJson(jsonData);
      } else {
        throw NotificationLogApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NotificationLogApiException('No Internet connection');
    } on TimeoutException {
      throw NotificationLogApiException('Connection timeout');
    } catch (e) {
      if (e is NotificationLogApiException) rethrow;
      throw NotificationLogApiException('Failed to load logs: ${e.toString()}');
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final jsonData = json.decode(response.body);
      return jsonData['message'] ??
          'Request failed with status: ${response.statusCode}';
    } catch (e) {
      return 'Request failed with status: ${response.statusCode}';
    }
  }
}
