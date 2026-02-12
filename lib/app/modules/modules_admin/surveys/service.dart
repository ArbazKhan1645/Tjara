import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/modules/modules_admin/surveys/model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class SurveyService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  /// Get surveys with pagination and filters
  Future<Map<String, dynamic>> getSurveys({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    String orderBy = 'created_at',
    String order = 'desc',
  }) async {
    try {
      final queryParams = {
        'with': 'thumbnail,questions',
        'orderBy': orderBy,
        'order': order,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['filterByColumns[filterJoin]'] = 'AND';
        queryParams['filterByColumns[columns][0][column]'] = 'status';
        queryParams['filterByColumns[columns][0][value]'] = status;
        queryParams['filterByColumns[columns][0][operator]'] = '=';
      }

      final uri = Uri.parse(
        '$baseUrl/surveys',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
          'X-Request-From': 'Dashboard',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['surveys'];

        final surveys =
            (data['data'] as List<dynamic>?)
                ?.map((json) => SurveyModel.fromJson(json))
                .toList() ??
            [];

        final meta =
            data['meta'] != null
                ? PaginationMeta.fromJson(data['meta'])
                : PaginationMeta(
                  currentPage: page,
                  lastPage: 1,
                  perPage: perPage,
                  total: surveys.length,
                  from: 1,
                  to: surveys.length,
                );

        return {'surveys': surveys, 'meta': meta};
      } else if (response.statusCode == 404) {
        throw Exception('Resource not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Failed to load surveys: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Create new survey
  Future<bool> createSurvey(Map<String, dynamic> surveyData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/surveys'),
        headers: {
          'Content-Type': 'application/json',

          'Accept': 'application/json',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
          'X-Request-From': 'Dashboard',
        },
        body: json.encode(surveyData),
      );

      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request data');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Validation error');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Failed to create survey: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Update survey
  Future<bool> updateSurvey(
    String surveyId,
    Map<String, dynamic> surveyData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/surveys/$surveyId'),
        headers: {
          'Content-Type': 'application/json',

          'Accept': 'application/json',
          'shop-id':
              AuthService.instance.authCustomer?.user?.shop?.shop?.id ?? '',
          'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
          'X-Request-From': 'Dashboard',
        },
        body: json.encode(surveyData),
      );

      print(response.body);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request data');
      } else if (response.statusCode == 404) {
        throw Exception('Survey not found');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Validation error');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Failed to update survey: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Delete survey
  Future<bool> deleteSurvey(String surveyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/surveys/$surveyId'),
        headers: {'X-Request-From': 'Dashboard'},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Survey not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Failed to delete survey: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  /// Get single survey
  Future<SurveyModel> getSurvey(String surveyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/surveys/$surveyId?with=thumbnail,questions'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SurveyModel.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Survey not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred');
      } else {
        throw Exception('Failed to load survey: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }
}
