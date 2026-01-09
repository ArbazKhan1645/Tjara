// services/reseller_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/resseller_programs_my/model.dart';

// Pagination response model
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data:
          (json['data'] as List)
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList(),
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      hasMorePages: (json['current_page'] ?? 1) < (json['last_page'] ?? 1),
    );
  }
}

class ResellerService {
  static const String baseUrl = 'https://api.libanbuy.com/api';

  Future<ResellerProgramModel> getResellerProgram(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reseller-programs/$userId/user-id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain, */*',
          'X-Request-From': 'Dashboard',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ResellerProgramModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load reseller program: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching reseller program: $e');
    }
  }

  Future<List<ResellerProgramModel>> getReferralMembers(
    String resellerProgramId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.tjara.com/api/reseller-programs/$resellerProgramId/referrels?with=member_status,orders',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Handle both single object and array responses
        if (jsonData is Map<String, dynamic>) {
          // If it's a single object, wrap it in a list
          final data =
              (jsonData['reseller_program_referrels']['data'] as List)
                  .map((item) => ResellerProgramModel.fromJson(item))
                  .toList();

          return data;
        } else if (jsonData is List) {
          // If it's an array, map each item
          return jsonData
              .map((item) => ResellerProgramModel.fromJson(item))
              .toList();
        } else if (jsonData.containsKey('data') && jsonData['data'] is List) {
          // If it's paginated response with 'data' key
          return (jsonData['data'] as List)
              .map((item) => ResellerProgramModel.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Failed to load referral members: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching referral members: $e');
    }
  }

  // Updated method with pagination support
  Future<PaginatedResponse<ResellerProgramModel>>
  getAllReferralMembersPaginated({int page = 1, int perPage = 15}) async {
    try {
      final uri = Uri.parse('$baseUrl/reseller-programs').replace(
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Request-From': 'Application',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Handle paginated response structure
        if (jsonData is Map<String, dynamic>) {
          // Check if it's a Laravel paginated response
          if (jsonData.containsKey('data') &&
              jsonData.containsKey('current_page') &&
              jsonData.containsKey('last_page')) {
            return PaginatedResponse.fromJson(
              jsonData,
              (json) => ResellerProgramModel.fromJson(json),
            );
          }
          // Handle nested structure like {'reseller_programs': {'data': [...], ...}}
          else if (jsonData.containsKey('reseller_programs') &&
              jsonData['reseller_programs'] is Map<String, dynamic>) {
            final resellerData =
                jsonData['reseller_programs'] as Map<String, dynamic>;
            return PaginatedResponse.fromJson(
              resellerData,
              (json) => ResellerProgramModel.fromJson(json),
            );
          }
          // Handle simple structure with data array
          else if (jsonData.containsKey('data') && jsonData['data'] is List) {
            return PaginatedResponse<ResellerProgramModel>(
              data:
                  (jsonData['data'] as List)
                      .map((item) => ResellerProgramModel.fromJson(item))
                      .toList(),
              currentPage: page,
              lastPage: page,
              perPage: perPage,
              total: (jsonData['data'] as List).length,
              hasMorePages: false,
            );
          }
        }
        // Handle direct array response (fallback)
        else if (jsonData is List) {
          return PaginatedResponse<ResellerProgramModel>(
            data:
                jsonData
                    .map((item) => ResellerProgramModel.fromJson(item))
                    .toList(),
            currentPage: page,
            lastPage: page,
            perPage: perPage,
            total: jsonData.length,
            hasMorePages: false,
          );
        }

        // Return empty response if structure is unexpected
        return PaginatedResponse<ResellerProgramModel>(
          data: [],
          currentPage: page,
          lastPage: page,
          perPage: perPage,
          total: 0,
          hasMorePages: false,
        );
      } else {
        throw Exception(
          'Failed to load referral members: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching referral members: $e');
    }
  }

  // Keep the old method for backward compatibility
  Future<List<ResellerProgramModel>> getAllReferralMembers() async {
    final paginatedResponse = await getAllReferralMembersPaginated(
      page: 1,
      perPage: 100, // Get more items for backward compatibility
    );
    return paginatedResponse.data;
  }
}
