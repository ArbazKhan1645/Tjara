// ignore_for_file: depend_on_referenced_packages

import 'package:tjara/app/repo/network_repository.dart';

class ContactUSApiRepository {
  static String endpoint = '';
  static final String _baseUrl = 'https://api.libanbuy.com/api/$endpoint';
  final NetworkRepository _repository = NetworkRepository();

  Future<dynamic> fetchData(String endpoint) async {
    try {
      final String postResponse = await _repository.postData<String>(
        url: _baseUrl,
        body: {'name': 'New Item'},
        fromJson: null,
      );

      return postResponse;
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
