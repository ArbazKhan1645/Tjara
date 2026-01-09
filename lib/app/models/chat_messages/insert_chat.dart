// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/models/chat_messages/chat_messages_model.dart';
import 'package:tjara/app/models/chat_messages/chat_messages_sub_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

Future<String?> insertProductChat(String productId) async {
  try {
    // Define the API endpoint
    final url = Uri.parse('https://api.libanbuy.com/api/products/chats/insert');

    // Prepare the request body
    final Map<String, dynamic> requestBody = {"product_id": productId};

    // Get auth token (assuming you have a method to get it)
    final LoginResponse? authToken = AuthService.instance.authCustomer;
    if (authToken == null) {
      print('Error: Authentication token is missing');
      return null;
    }

    // Set headers with authentication
    final headers = {
      'Content-Type': 'application/json',
      "X-Request-From": "Application",
      "user-id": "${authToken.user?.id}",
    };

    final response = await http
        .post(url, headers: headers, body: jsonEncode(requestBody))
        .timeout(const Duration(seconds: 15)); // Add timeout

    if (response.statusCode == 200) {
      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if chat_id exists in the response
      if (responseData.containsKey('chat_id')) {
        final String chatId = responseData['chat_id'];

        return chatId;
      } else if (responseData.containsKey('message') &&
          responseData['message'] == 'Chat already exists' &&
          responseData.containsKey('chat_id')) {
        // Handle existing chat case
        final String chatId = responseData['chat_id'];

        return chatId;
      } else {
        return null;
      }
    } else if (response.statusCode == 400) {
      // Handle bad request
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      final String errorMessage = errorData['message'] ?? 'Bad request';

      // If chat already exists, try to extract the chat_id
      if (errorMessage == 'Chat already exists' &&
          errorData.containsKey('chat_id')) {
        final String chatId = errorData['chat_id'];
        print('Chat already exists with ID: $chatId');
        return chatId;
      }

      print('Error: $errorMessage');
      return null;
    } else if (response.statusCode == 404) {
      // Handle not found
      print('Error: Product not found');
      return null;
    } else if (response.statusCode >= 500) {
      // Handle server errors
      print('Error: Server error occurred. Please try again later');
      return null;
    } else {
      // Handle other errors
      print('Error: Unexpected status code ${response.statusCode}');
      return null;
    }
  } catch (e) {
    // Handle all other exceptions
    print('Unexpected error occurred: $e');
    Get.snackbar(
      'Error',
      'An unexpected error occurred. Please try again',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return null;
  }
}

// Example usage
void startChatWithProduct(
  String productId,

  BuildContext context, {
  String? uid,
  ChatData? productChats,
}) async {
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  try {
    if (uid != null) {
      Get.back();
      showContactDialog(
        context,
        ChatDialogWidget(uid: uid, model: productChats),
      );
      return;
    }
    final chatId = await insertProductChat(productId);
    Get.back();

    if (chatId != null) {
      showContactDialog(
        context,
        ChatDialogWidget(uid: chatId, model: productChats),
      );
    } else {
      Get.snackbar(
        'Error',
        'Unable to start chat. Please try again later',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    Get.back();
    Get.snackbar(
      'Error',
      'Failed to start chat: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
