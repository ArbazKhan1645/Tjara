import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals_analytics/model/flash_deal_analytics_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class FlashDealAnalyticsApiException implements Exception {
  final String message;
  final int? statusCode;

  FlashDealAnalyticsApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class FlashDealAnalyticsService {
  static const String baseUrl = 'https://api.libanbuy.com/api';
  static const Duration timeout = Duration(seconds: 30);

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'shop-id': AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
    'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
    'X-Request-From': 'Dashboard',
  };

  /// Fetch overall analytics with time range filter
  Future<OverallAnalyticsResponse> fetchOverallAnalytics(
    String timeRange,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/flash-deal-products/analytics/overall?time_range=$timeRange',
            ),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        return OverallAnalyticsResponse.fromJson(jsonData['analytics']);
      } else {
        throw FlashDealAnalyticsApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw FlashDealAnalyticsApiException('No Internet connection');
    } on TimeoutException {
      throw FlashDealAnalyticsApiException('Connection timeout');
    } catch (e) {
      if (e is FlashDealAnalyticsApiException) rethrow;
      throw FlashDealAnalyticsApiException(
        'Failed to load analytics: ${e.toString()}',
      );
    }
  }

  /// Fetch flash deal history with pagination and filters
  Future<FlashDealHistoryResponse> fetchHistory({
    int page = 1,
    int limit = 10,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(
        '$baseUrl/flash-deal-products',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return FlashDealHistoryResponse.fromJson(jsonData);
      } else {
        throw FlashDealAnalyticsApiException(
          _getErrorMessage(response),
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw FlashDealAnalyticsApiException('No Internet connection');
    } on TimeoutException {
      throw FlashDealAnalyticsApiException('Connection timeout');
    } catch (e) {
      if (e is FlashDealAnalyticsApiException) rethrow;
      throw FlashDealAnalyticsApiException(
        'Failed to load history: ${e.toString()}',
      );
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
