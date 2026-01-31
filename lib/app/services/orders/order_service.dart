import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tjara/app/services/auth/auth_service.dart';

class OrderService {
  static const String apiUrl = "https://api.libanbuy.com/api/orders/insert/";

  static Future<Map<String, dynamic>> placeOrder({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String streetAddress,
    required String postalCode,
    required String countryId,
    required String stateId,
    required String cityId,
    required String paymentMethod,
    required String successUrl,
    required String cancelUrl,
    double walletCheckoutAmount = 0.0,
    String? couponCode,
    String? couponUsageId,
  }) async {
    try {
      // Validate required fields
      if (firstName.isEmpty) {
        return {"error": "First name is required"};
      }
      if (lastName.isEmpty) {
        return {"error": "Last name is required"};
      }
      if (email.isEmpty) {
        return {"error": "Email is required"};
      }
      if (phone.isEmpty) {
        return {"error": "Phone is required"};
      }
      if (streetAddress.isEmpty) {
        return {"error": "Street address is required"};
      }
      if (countryId.isEmpty) {
        return {"error": "Country selection is required"};
      }

      // Get user ID from auth service
      final userId = AuthService.instance.authCustomer?.user?.id ?? '';
      if (userId.isEmpty) {
        return {"error": "User authentication required. Please login again."};
      }

      // Build order data matching your API structure
      final Map<String, dynamic> orderData = {
        "user_details": {
          "first_name": firstName.trim(),
          "last_name": lastName.trim(),
          "email": email.trim(),
          "phone": phone.trim(),
        },
        "user_address": {
          "street_address": streetAddress.trim(),
          "postal_code": postalCode.isNotEmpty ? postalCode : "12345",
          "country_id": countryId,
          "state_id": stateId.isNotEmpty ? stateId : "",
          "city_id": cityId.isNotEmpty ? cityId : "",
        },
        "payment_method":
            paymentMethod, // Fixed payment method as per your requirement
        "success_url": successUrl,
        "cancel_url": cancelUrl,
      };

      // Add wallet checkout amount only if greater than 0
      if (walletCheckoutAmount > 0) {
        orderData["wallet_checkout_amount"] = walletCheckoutAmount;
      }

      // Add coupon code if provided
      if (couponCode != null && couponCode.isNotEmpty) {
        orderData["coupon_code"] = couponCode;
      }

      // Add coupon usage id if provided
      if (couponUsageId != null && couponUsageId.isNotEmpty) {
        orderData["coupon_usage_id"] = couponUsageId;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          'user-id': userId,
          'X-Request-From': 'Website',
        },
        body: jsonEncode(orderData),
      );

      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Check if the response contains an error message
        if (responseData.containsKey('error')) {
          return {"error": responseData['error']};
        }

        return responseData;
      } else if (response.statusCode == 400) {
        // Bad request - usually validation errors
        final errorData = jsonDecode(response.body);
        return {
          "error":
              errorData['message'] ??
              errorData['error'] ??
              "Invalid request data. Please check all fields.",
        };
      } else if (response.statusCode == 401) {
        return {"error": "Authentication failed. Please login again."};
      } else if (response.statusCode == 422) {
        // Unprocessable entity - validation errors
        final errorData = jsonDecode(response.body);
        String errorMessage = "Validation failed: ";

        if (errorData.containsKey('errors')) {
          // Handle Laravel-style validation errors
          final Map<String, dynamic> errors = errorData['errors'];
          final List<String> errorMessages = [];
          errors.forEach((field, messages) {
            if (messages is List) {
              errorMessages.addAll(messages.cast<String>());
            }
          });
          errorMessage += errorMessages.join(', ');
        } else {
          errorMessage += errorData['message'] ?? "Please check your input";
        }

        return {"error": errorMessage};
      } else if (response.statusCode >= 500) {
        return {
          "error":
              "Server error occurred. Please try again later. (${response.statusCode})",
        };
      } else {
        return {
          "error":
              "Failed to place order. Status: ${response.statusCode}. Please try again.",
        };
      }
    } catch (e) {
      print('Exception in placeOrder: $e');

      // Handle different types of exceptions
      if (e.toString().contains('SocketException')) {
        return {"error": "No internet connection. Please check your network."};
      } else if (e.toString().contains('TimeoutException')) {
        return {"error": "Request timeout. Please try again."};
      } else if (e.toString().contains('FormatException')) {
        return {"error": "Invalid response from server. Please try again."};
      } else {
        return {"error": "An unexpected error occurred: ${e.toString()}"};
      }
    }
  }

  // Method to validate order data before sending
  static Map<String, String?> validateOrderData({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String streetAddress,
    required String countryId,
  }) {
    final Map<String, String?> errors = {};

    if (firstName.trim().isEmpty) {
      errors['firstName'] = 'First name is required';
    }

    if (lastName.trim().isEmpty) {
      errors['lastName'] = 'Last name is required';
    }

    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors['email'] = 'Please enter a valid email';
    }

    if (phone.trim().isEmpty) {
      errors['phone'] = 'Phone number is required';
    } else if (phone.trim().length < 8) {
      errors['phone'] = 'Phone number must be at least 8 digits';
    }

    if (streetAddress.trim().isEmpty) {
      errors['address'] = 'Street address is required';
    }

    if (countryId.isEmpty) {
      errors['country'] = 'Country selection is required';
    }

    return errors;
  }
}
