// contest_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:tjara/app/modules/contests/model/contest_model.dart';
import 'package:tjara/app/modules/contests/model/selected_contest_model.dart';

enum LoadingStatus { initial, loading, loaded, error }

class ContestController extends GetxController {
  final Rx<LoadingStatus> status = LoadingStatus.initial.obs;
  final RxList<ContestModel> contests = <ContestModel>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContests();
  }

  Future<void> fetchContests() async {
    try {
      // Check internet connectivity before making the request
      // var connectivityResult = await Connectivity().checkConnectivity();
      // if (connectivityResult == ConnectivityResult.none) {
      //   status.value = LoadingStatus.error;
      //   errorMessage.value = 'No internet connection';
      //   return;
      // }

      status.value = LoadingStatus.loading;

      final response = await http
          .get(
            Uri.parse('https://api.libanbuy.com/api/contests'),
            headers: {
              'Content-Type': 'application/json',
              "X-Request-From": "Application",
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Connection timeout. Please try again.');
            },
          );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final contestsResponse = ContestsResponse.fromJson(jsonData);

        if (contestsResponse.contests?.data != null) {
          contests.value = contestsResponse.contests!.data!;
          status.value = LoadingStatus.loaded;
        } else {
          status.value = LoadingStatus.error;
          errorMessage.value = 'No Contests data found';
        }
      } else {
        status.value = LoadingStatus.error;
        errorMessage.value = 'Failed to load Contests: ${response.statusCode}';
      }
    } catch (e) {
      status.value = LoadingStatus.error;
      errorMessage.value = 'Error: ${e.toString()}';
    }
  }

  final selectedModel = Rxn<ContestModel>();
  setSelectedModel(ContestModel? model) {
    selectedModel.value = model;
    update();
  }

  void retryFetch() {
    fetchContests();
  }

  var contest = ContestModel().obs;
  var isLoading = true.obs;
  var error = ''.obs;

  Future<void> fetchContest(String id) async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/contests/$id'),
        headers: {
          'Content-Type': 'application/json',
          "X-Request-From": "Application",
        },
      );
      if (response.statusCode == 200) {
        contest.value = ContestModel.fromJson(
          json.decode(response.body)['contest'],
        );
      } else {
        throw Exception('Failed to load contest');
      }
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  String getFormattedDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
