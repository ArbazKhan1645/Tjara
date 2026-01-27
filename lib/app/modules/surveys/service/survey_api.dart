import 'dart:convert';

import 'package:tjara/app/modules/surveys/model/surveys_model.dart';
import 'package:tjara/app/repo/network_repository.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/services/auth/auth_service.dart';

class SurveyApiService {
  final NetworkRepository _repository = NetworkRepository();

  Future<SurveysResponse> fetchSurveys({
    String? search,
    int page = 1,
    int perPage = 12,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'with': 'thumbnail',
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Add filter for published status and active surveys
      queryParams['filterByColumns[filterJoin]'] = 'AND';
      queryParams['filterByColumns[columns][0][column]'] = 'status';
      queryParams['filterByColumns[columns][0][value]'] = 'published';
      queryParams['filterByColumns[columns][0][operator]'] = '=';

      // Filter for surveys that haven't ended yet
      queryParams['filterByColumns[columns][1][column]'] = 'end_time';
      queryParams['filterByColumns[columns][1][value]'] =
          DateTime.now().toUtc().toIso8601String();
      queryParams['filterByColumns[columns][1][operator]'] = '>';

      // Order by created_at desc (newest first)
      queryParams['orderBy'] = 'created_at';
      queryParams['order'] = 'desc';

      // Build URL with query parameters
      String url = 'https://api.libanbuy.com/api/surveys';
      if (queryParams.isNotEmpty) {
        url +=
            '?${queryParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&')}';
      }

      final result = await _repository.fetchData<SurveysResponse>(
        url: url,
        fromJson: (json) => SurveysResponse.fromJson(json),
        forceRefresh: true,
      );

      return result;
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<SurveySubmitResponse> submitSurvey({
    required String surveyId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          'https://api.libanbuy.com/api/public/surveys/$surveyId/submit',
        ),
        headers: {
          "X-Request-From": "Website",
          "Content-Type": "application/json",
          'user-id': AuthService.instance.authCustomer?.user?.id ?? '',
        },
        body: jsonEncode({
          "answers": answers, // now properly inside JSON
        }),
      );

      if (res.statusCode == 200) {
        return SurveySubmitResponse.fromJson(json.decode(res.body));
      } else {
        throw Exception('Failed to submit survey');
      }
    } catch (e) {
      throw Exception('Failed to submit survey: ${e.toString()}');
    }
  }
}
