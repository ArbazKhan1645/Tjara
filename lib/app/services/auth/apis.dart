// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'dart:async';
import 'package:tjara/app/services/auth/auth_service.dart';

class AuthenticationApiService {
  static Future<dynamic> loginUser(String email, String password) async {
    const String url = 'https://api.tjara.com/api/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'email': email, 'password': password},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        LoginResponse login = parseLoginResponse(response.body);
        return login;
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      "Error: $e";
    }
  }

  static registerUser(
      {required String firstName,
      required String lastName,
      required String email,
      required String phone,
      required String password,
      required String role,
      String? storeName,
      int? thumbnailId,
      String? invitedBy,
      required BuildContext context}) async {
    const String url = 'https://api.tjara.com/api/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'role': '0',
          // 'store_name': storeName,
          // 'thumbnail_id': thumbnailId,
          // 'invited_by': invitedBy,
        },
      );

      if (response.statusCode == 200) {
        final responseLogin = await http.post(
          Uri.parse('https://api.tjara.com/api/login'),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {'email': email, 'password': password},
        ).timeout(Duration(seconds: 10));

        if (responseLogin.statusCode == 200) {
          LoginResponse login = parseLoginResponse(responseLogin.body);
          _authService.saveAuthState(login);
          Get.back();
          Get.snackbar('Success', 'User Register Sucessfully',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          return "Error: ${response.statusCode} - ${response.body}";
        }
      } else {
        Get.snackbar('Error', 'User Register failed ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'User Register failed  $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  static final _authService = Get.find<AuthService>();
}

void login() async {
  AuthenticationApiService.loginUser('johndoes3@example.com', 'securepassword');
  // final NetworkRepository _repository = NetworkRepository();
  // final result = await _repository.postData(
  //     url: 'https://api.tjara.com/api/login',
  //     queryParameters: {
  //       'email': 'user@example.com',
  //       'password': 'password123'
  //     });
}

class CategoryApiService {
  static const String baseUrl = 'https://api.tjara.com/api/products';

  int currentPage = 1;
  final int perPage = 16;
  bool isFetching = false;
  bool hasMoreData = true;

  Future<dynamic> fetchProducts({int page = 1, String? categoryId}) async {
    // if (isFetching) return {};
    // isFetching = true;

    final Uri url = Uri.parse(
        '$baseUrl?with=thumbnail,shop&filterJoin=OR&orderBy=created_at&order=desc&page=$page&per_page=$perPage&filterByAttributes[filterJoin]=AND&filterByAttributes[attributes][0][key]=categories&filterByAttributes[attributes][0][value]=$categoryId&filterByAttributes[attributes][0][operator]=%3D');

    try {
      final response = await http.get(url);
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

  Future<dynamic> fetchProductsOfShop({int page = 1, String? shopId}) async {
    String url =
        'https://api.tjara.com/api/products?with=thumbnail,shop&filterJoin=OR&orderBy=created_at&order=desc&page=1&per_page=50&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=shop_id&filterByColumns[columns][0][value]=$shopId&filterByColumns[columns][0][operator]=%3D';
    // final Uri url = Uri.parse(
    //     '$baseUrl?with=thumbnail,shop&filterJoin=OR&orderBy=created_at&order=desc&page=$page&per_page=$perPage&filterByColumn[filterJoin]=AND&filterByColumn[attributes][0][key]=shop_id&filterByColumn[attributes][0][value]=$shopId&filterByColumn[attributes][0][operator]=%3D');

    try {
      final response = await http.get(Uri.parse(url));

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

  // Future<Map<String, dynamic>> fetchNextPage() async {
  //   if (!hasMoreData)
  //     return {'success': false, 'message': 'No more data available'};
  //   currentPage++;
  //   return await fetchProducts(page: currentPage);
  // }
}
