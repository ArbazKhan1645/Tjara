import 'package:tjara/app/modules/services/model/sevices_model.dart';
import 'package:tjara/app/repo/network_repository.dart';

class ServicesApiService {
  final NetworkRepository _repository = NetworkRepository();

  Future<ServicesResponse> fetchServices({
    double? minPrice,
    double? maxPrice,
    String? orderBy,
    String? order,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'with': 'thumbnail,shop',
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      // Add price filter if provided
      int columnIndex = 0;

      if (minPrice != null) {
        queryParams['filterByColumns[filterJoin]'] = 'AND';
        queryParams['filterByColumns[columns][$columnIndex][column]'] = 'price';
        queryParams['filterByColumns[columns][$columnIndex][value]'] =
            minPrice.toInt().toString();
        queryParams['filterByColumns[columns][$columnIndex][operator]'] = '>';
        columnIndex++;
      }

      if (maxPrice != null) {
        queryParams['filterByColumns[filterJoin]'] = 'AND';
        queryParams['filterByColumns[columns][$columnIndex][column]'] = 'price';
        queryParams['filterByColumns[columns][$columnIndex][value]'] =
            maxPrice.toInt().toString();
        queryParams['filterByColumns[columns][$columnIndex][operator]'] = '<';
      }

      // Add sorting if provided
      if (orderBy != null && orderBy.isNotEmpty) {
        queryParams['orderBy'] = orderBy;
        queryParams['order'] = order ?? 'asc';
      }

      // Build URL with query parameters
      String url = 'https://api.libanbuy.com/api/services';
      if (queryParams.isNotEmpty) {
        url +=
            '?${queryParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&')}';
      }

      final result = await _repository.fetchData<ServicesResponse>(
        url: url,
        fromJson: (json) => ServicesResponse.fromJson(json),
        forceRefresh: true,
      );

      return result;
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> submitEnquiry({
    required String serviceId,
    required String fullName,
    required String phoneNumber,
    required String serviceName,
    required String message,
  }) async {
    try {
      final result = await _repository.postData<Map<String, dynamic>>(
        url: 'https://api.libanbuy.com/api/services/$serviceId/enquiry/insert',
        body: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'service_name': serviceName,
          'message': message,
        },
        fromJson: (json) => json,
      );
      return result;
    } catch (e) {
      throw Exception('Failed to submit enquiry: ${e.toString()}');
    }
  }
}
