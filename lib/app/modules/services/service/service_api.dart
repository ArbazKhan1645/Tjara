import 'package:tjara/app/modules/services/model/sevices_model.dart';
import 'package:tjara/app/repo/network_repository.dart';

class ServicesApiService {
  final NetworkRepository _repository = NetworkRepository();

  Future<ServicesResponse> fetchServices() async {
    try {
      final result = await _repository.fetchData<ServicesResponse>(
        url: 'https://api.libanbuy.com/api/services',
        fromJson: (json) => ServicesResponse.fromJson(json),
        forceRefresh: true,
      );

      return result;
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
