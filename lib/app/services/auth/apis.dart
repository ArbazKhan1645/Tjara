// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'dart:async';
import 'package:tjara/app/core/utils/helpers/alerts.dart';

class AuthenticationApiService {
  // Add this method to your existing AuthenticationApiService class

  static Future<void> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String role,
    String? storeName,
    int? thumbnailId,
    required BuildContext context,
  }) async {
    final String url = 'https://api.libanbuy.com/api/users/$userId/update';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-Request-From": "Application",
        },
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'role': role,
          if (storeName != null) 'store_name': storeName,
          if (thumbnailId != null) 'thumbnail_id': thumbnailId.toString(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        NotificationHelper.showSuccess(
          context,
          'User created successfully.',
          'New user has been added to the system.',
        );
      } else {
        String errorMessage;

        switch (response.statusCode) {
          case 400:
            errorMessage = 'Bad request. Please check the submitted data.';
            break;
          case 401:
            errorMessage = 'Unauthorized. Please log in and try again.';
            break;
          case 403:
            errorMessage = 'You don’t have permission to perform this action.';
            break;
          case 404:
            errorMessage = 'API endpoint not found.';
            break;
          case 409:
            errorMessage = 'A user with similar details already exists.';
            break;
          case 422:
            errorMessage = 'Some fields are invalid or missing.';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = 'An unexpected error occurred. Please try again.';
        }

        NotificationHelper.showError(
          context,
          'Failed to create user.',
          errorMessage,
        );
      }
    } catch (e) {
      NotificationHelper.showError(
        context,
        'Failed to update user.',
        e.toString(),
      );
    }
  }

  static Future<dynamic> loginUser(String email, String password) async {
    const String url = 'https://api.libanbuy.com/api/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-Request-From": "Application",
        },
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final LoginResponse login = parseLoginResponse(response.body);

        return login;
      } else {
        return response.body;
      }
    } catch (e) {
      print(e);
      "Error: $e";
    }
  }

  static Future<bool> resendEmail(String email) async {
    const String url = 'https://api.libanbuy.com/api/email/resend';
    try {
      await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
              "X-Request-From": "Application",
            },
            body: {'email': email},
          )
          .timeout(const Duration(seconds: 10));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<dynamic> forgetPassword(String email) async {
    const String url = 'https://api.libanbuy.com/api/forgot-password';
    try {
      final result = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
              "X-Request-From": "Application",
            },
            body: {'email': email},
          )
          .timeout(const Duration(seconds: 10));
      if (result.statusCode == 200) {
        return true;
      } else {
        return result.body;
      }
    } catch (e) {
      return {'message': e.toString()};
    }
  }

  static Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? storeName,
    int? thumbnailId,
    String? invitedBy,
    required BuildContext context,
  }) async {
    const String url = 'https://api.libanbuy.com/api/register';

    try {
      // Create the body map
      final Map<String, dynamic> bodyData = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'registration_type': 'quick',
        "status": "",
        "thumbnail": "",
        "thumbnail_id": "",
      };

      // Add optional fields if they exist
      // if (storeName != null) bodyData['store_name'] = storeName;
      // if (thumbnailId != null) bodyData['thumbnail_id'] = thumbnailId;
      // if (invitedBy != null) bodyData['invited_by'] = invitedBy;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "X-Request-From": "Dashboard",
          "accept": "application/json, text/plain, */*",
        },
        body: jsonEncode(bodyData), // Convert Map to JSON string
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        resendEmail(email);
        return true;
      } else {
        NotificationHelper.showError(
          context,
          'Account registered Unsuccessfully.',
          'Error Occurred ',
        );
        print('Error Response: ${response.statusCode}');
        print('Error Response: ${response.body}');
        return false;
      }
    } catch (e) {
      NotificationHelper.showError(
        context,
        'Account registered Unsuccessfully.',
        'Error Occurred',
      );
      print('Exception: ${e.toString()}');
      return false;
    }
  }
}
// ignore_for_file: avoid_print

class CategoryApiService {
  static const String baseUrl = 'https://api.libanbuy.com/api/products';

  int currentPage = 1;
  final int perPage = 40;
  bool isFetching = false;
  bool hasMoreData = true;

  /// Utility to print long strings in chunks so nothing is truncated
  void _printFull(String text) {
    const chunkSize = 800;
    for (var i = 0; i < text.length; i += chunkSize) {
      print(
        text.substring(
          i,
          i + chunkSize > text.length ? text.length : i + chunkSize,
        ),
      );
    }
  }

  Future<dynamic> fetchProducts({
    int page = 1,
    String? categoryId,
    required bool product_group_car,
  }) async {
    // if (isFetching) return {};
    // isFetching = true;

    // Get current time info
    final DateTime now = DateTime.now();
    final String currentTime = now.toIso8601String();
    const String timezone = 'Asia/Karachi';
    const int timezoneOffset = -300; // UTC+5 = -300 minutes
    final int timestamp = now.millisecondsSinceEpoch;

    final Uri url = Uri.parse(
      '$baseUrl?with=thumbnail,shop,variations,rating&filterJoin=OR'
      '&time_info[current_time]=$currentTime'
      '&time_info[timezone]=$timezone'
      '&time_info[timezone_offset]=$timezoneOffset'
      '&time_info[timestamp]=$timestamp'
      '&page=$page'
      '&per_page=$perPage'
      '&customOrder=featured_products_first'
      '&filterByColumns[filterJoin]=AND'
      '&filterByColumns[columns][0][column]=price'
      '&filterByColumns[columns][0][value]=100000000'
      '&filterByColumns[columns][0][operator]=%3C%3D'
      '&filterByColumns[columns][1][column]=product_group'
      '&filterByColumns[columns][1][value]=car'
      '&filterByColumns[columns][1][operator]=${product_group_car == true ? '%3D' : '!%3D'} '
      '&filterByColumns[columns][2][column]=status'
      '&filterByColumns[columns][2][value]=active'
      '&filterByColumns[columns][2][operator]=%3D'
      '&filterByAttributes[filterJoin]=AND'
      '&filterByAttributes[attributes][0][key]=categories'
      '&filterByAttributes[attributes][0][value]=$categoryId'
      '&filterByAttributes[attributes][0][operator]=%3D',
    );

    // Print full URL (no truncation)

    try {
      final response = await http.get(
        url,
        headers: {"X-Request-From": "Application"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> fetchProductsOfShop({
    int page = 1,
    String? shopId,
    String? search = '',
    int perPage = 14,
  }) async {
    final String url =
        'https://api.libanbuy.com/api/products?include_analytics=true'
        '&with=thumbnail,shop,variations,rating'
        '&filterJoin=OR'
        '&orderBy=created_at&order=desc'
        '&search=$search&page=$page&per_page=$perPage'
        // Filter Join AND
        '&filterByColumns[filterJoin]=AND'
        // Price Filter
        '&filterByColumns[columns][0][column]=price'
        '&filterByColumns[columns][0][value]=10000000000'
        '&filterByColumns[columns][0][operator]=%3C%3D'
        // Shop ID Filter
        '&filterByColumns[columns][1][column]=shop_id'
        '&filterByColumns[columns][1][value]=$shopId'
        '&filterByColumns[columns][1][operator]=%3D'
        // Status Filter
        '&filterByColumns[columns][2][column]=status'
        '&filterByColumns[columns][2][value]=active'
        '&filterByColumns[columns][2][operator]=%3D';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"X-Request-From": "Application"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Example pagination handler (optional)
  // Future<Map<String, dynamic>> fetchNextPage() async {
  //   if (!hasMoreData) {
  //     return {'success': false, 'message': 'No more data available'};
  //   }
  //   currentPage++;
  //   return await fetchProducts(page: currentPage);
  // }
}
