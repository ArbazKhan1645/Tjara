// ignore_for_file: depend_on_referenced_packages, constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tjara/app/core/utils/helpers/api_exceptions.dart';

class ApiConfig {
  static const String baseUrl = 'https://dash.imei.info/api/check/';
  static const String upcoming = '/upcoming';
  static const String basixServiceImeiId = '/upcoming';

  static const String api_key = '0611ecea-3a98-490d-a4ad-522fe86c29a7';

  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  static bool shouldRetry(Exception e) {
    if (e is ApiException) {
      return e.statusCode != null &&
          (e.statusCode! >= 500 || e.statusCode == 429);
    }
    return e is SocketException || e is TimeoutException;
  }

  static String? getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return null;
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized - Check your API key';
      case 403:
        return 'Forbidden - You don\'t have access';
      case 404:
        return 'Not found - Check the API endpoint';
      case 429:
        return 'Rate limit exceeded';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Server error - Please try again later';
      default:
        return 'Unexpected status code: $statusCode';
    }
  }

  static void validateResponse(http.Response response) {
    final statusCode = response.statusCode;
    final errorMessage = ApiConfig.getErrorMessage(statusCode);
    if (errorMessage != null) {
      throw ApiException(
        errorMessage,
        statusCode: statusCode,
        response: response.body,
      );
    }
  }
}
