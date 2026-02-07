import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tjara/app/services/auth/auth_service.dart';

class MyBidsController extends GetxController {
  final RxList<Map<String, dynamic>> bids = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBids();
  }

  Future<void> fetchBids() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    try {
      final response = await http
          .get(
            Uri.parse('https://api.libanbuy.com/api/products/my/bids'),
            headers: {
              'Content-Type': 'application/json',
              'X-Request-From': 'Application',
              'user-id':
                  AuthService.instance.authCustomer?.user?.id.toString() ?? '',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['bids'] ?? [];
        bids.assignAll(list.cast<Map<String, dynamic>>());
      } else {
        error.value = 'Failed to load bids (${response.statusCode})';
      }
    } on SocketException {
      error.value = 'No internet connection';
    } on TimeoutException {
      error.value = 'Connection timeout';
    } catch (e) {
      error.value = 'Something went wrong';
      debugPrint('Error fetching bids: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await fetchBids();
  }
}
