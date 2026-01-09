// job_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:tjara/app/core/utils/helpers/api_exceptions.dart';
import 'package:tjara/app/models/jobs/jobs_model.dart';

class JobApiService {
  static const String baseUrl = 'https://api.libanbuy.com/api';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-Request-From': 'Application',
  };

  // Fetch jobs with pagination
  Future<JobsResponse> fetchJobs({int page = 1}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/jobs?page=$page'), headers: _headers)
          .timeout(const Duration(seconds: 30));

      return _processResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection');
    } on TimeoutException {
      throw ApiException('Connection timeout');
    } catch (e) {
      throw ApiException('Something went wrong: ${e.toString()}');
    }
  }

  // Process HTTP response
  JobsResponse _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final jsonData = json.decode(response.body);
        return JobsResponse.fromJson(jsonData);
      } catch (e) {
        debugPrint('Parsing error: ${e.toString()}');
        throw ApiException('Failed to parse response data');
      }
    } else {
      final errorMessage = _getErrorMessage(response);
      throw ApiException(errorMessage);
    }
  }

  // Extract error message from response
  String _getErrorMessage(http.Response response) {
    try {
      final jsonData = json.decode(response.body);
      if (jsonData['message'] != null) {
        return jsonData['message'];
      }
      if (jsonData['error'] != null) {
        return jsonData['error'];
      }
    } catch (_) {}

    // Default error messages based on status code
    switch (response.statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Error occurred: ${response.statusCode}';
    }
  }
}
