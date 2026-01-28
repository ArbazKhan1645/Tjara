import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Response model for order insert
class OrderInsertResponse {
  final bool success;
  final String? message;
  final List<String>? orderIds;
  final String? errorMessage;
  final int? statusCode;

  OrderInsertResponse({
    required this.success,
    this.message,
    this.orderIds,
    this.errorMessage,
    this.statusCode,
  });

  String? get firstOrderId =>
      orderIds?.isNotEmpty == true ? orderIds!.first : null;
}

/// Response model for order update
class OrderUpdateResponse {
  final bool success;
  final String? message;
  final String? errorMessage;
  final int? statusCode;

  OrderUpdateResponse({
    required this.success,
    this.message,
    this.errorMessage,
    this.statusCode,
  });
}

/// User details for checkout
class CheckoutUserDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  CheckoutUserDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
  };

  bool get isValid =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty;
}

/// User address for checkout
class CheckoutUserAddress {
  final String streetAddress;
  final String countryId;
  final String stateId;
  final String cityId;
  final String postalCode;

  CheckoutUserAddress({
    this.streetAddress = '',
    this.countryId = '',
    this.stateId = '',
    this.cityId = '',
    this.postalCode = '',
  });

  Map<String, dynamic> toJson() => {
    'street_address': streetAddress,
    'country_id': countryId,
    'state_id': stateId,
    'city_id': cityId,
    'postal_code': postalCode,
  };

  /// Check if address has any data
  bool get hasData =>
      streetAddress.isNotEmpty || postalCode.isNotEmpty || cityId.isNotEmpty;
}

/// Service class for Flash Deal Checkout API calls
class FlashDealCheckoutService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';
  static const String _paymentMethod = 'cash-on-delivery';
  static const String _successUrl =
      'https://libanbuy.com/checkout?payment=success';
  static const String _cancelUrl =
      'https://libanbuy.com/checkout?payment=cancel';

  // Lebanon country ID
  static const String defaultCountryId = '485c93c9-0fd5-4055-bdac-05896595023a';

  /// Generates a unique idempotency key for the order
  static String _generateIdempotencyKey(String productId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final randomSuffix =
        List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
    return 'flash_deal_${timestamp}_${productId}_$randomSuffix';
  }

  /// Get headers for API calls
  static Map<String, String> _getHeaders(String? userId) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Request-From': 'Application',
      'Accept': 'application/json',
    };

    if (userId != null && userId.isNotEmpty) {
      headers['user-id'] = userId;
    }

    return headers;
  }

  /// Insert a new flash deal order
  ///
  /// [productId] - The flash deal product ID
  /// [quantity] - The quantity to order
  /// [userDetails] - User's contact information
  /// [userAddress] - User's shipping address (can be empty for flash deals)
  /// [userId] - Current user's ID for authentication
  static Future<OrderInsertResponse> insertOrder({
    required String productId,
    required int quantity,
    required CheckoutUserDetails userDetails,
    CheckoutUserAddress? userAddress,
    String? userId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/orders/insert');

      final body = {
        'is_flash_deal': true,
        'flash_deal_product_id': productId,
        'flash_deal_quantity': quantity,
        'idempotency_key': _generateIdempotencyKey(productId),
        'payment_method': _paymentMethod,
        'success_url': _successUrl,
        'cancel_url': _cancelUrl,
        'user_details': userDetails.toJson(),
        'user_address': (userAddress ?? CheckoutUserAddress()).toJson(),
      };

      final response = await http
          .post(uri, headers: _getHeaders(userId), body: json.encode(body))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        List<String>? orderIds;
        if (data['order_ids'] != null) {
          orderIds = List<String>.from(data['order_ids']);
        }

        return OrderInsertResponse(
          success: true,
          message: data['message'] ?? 'Order placed successfully!',
          orderIds: orderIds,
          statusCode: response.statusCode,
        );
      } else {
        String errorMessage = 'Failed to place order';
        try {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {}

        return OrderInsertResponse(
          success: false,
          errorMessage: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (_) {
      return OrderInsertResponse(
        success: false,
        errorMessage: 'No internet connection. Please check your network.',
      );
    } on TimeoutException catch (_) {
      return OrderInsertResponse(
        success: false,
        errorMessage: 'Connection timeout. Please try again.',
      );
    } on FormatException catch (_) {
      return OrderInsertResponse(
        success: false,
        errorMessage: 'Invalid response from server.',
      );
    } catch (e) {
      return OrderInsertResponse(
        success: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Update order with shipping address
  ///
  /// [orderId] - The order ID to update
  /// [streetAddress] - Street address
  /// [postalCode] - Postal code
  /// [cityId] - City ID (optional)
  /// [stateId] - State ID (optional)
  /// [countryId] - Country ID (defaults to Lebanon)
  /// [userId] - Current user's ID for authentication
  static Future<OrderUpdateResponse> updateOrderAddress({
    required String orderId,
    required String streetAddress,
    required String postalCode,
    String cityId = '',
    String stateId = '',
    String? countryId,
    String? userId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/orders/$orderId/update');

      final effectiveCountryId = countryId ?? defaultCountryId;

      // Build formatted address
      final addressParts = <String>[];
      if (streetAddress.isNotEmpty) addressParts.add(streetAddress);
      addressParts.add('Pakistan'); // Default country name
      if (postalCode.isNotEmpty) addressParts.add(postalCode);
      final formattedAddress = addressParts.join(', ');

      final body = {
        'meta': [
          {'custom_buyer_street_address': streetAddress},
          {'custom_buyer_postal_code': postalCode},
          {'custom_buyer_city_id': cityId},
          {'custom_buyer_state_id': stateId},
          {'custom_buyer_country_id': effectiveCountryId},
          {'custom_buyer_formatted_address': formattedAddress},
        ],
      };

      final response = await http
          .put(uri, headers: _getHeaders(userId), body: json.encode(body))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        return OrderUpdateResponse(
          success: true,
          message: data['message'] ?? 'Address updated successfully!',
          statusCode: response.statusCode,
        );
      } else {
        String errorMessage = 'Failed to update address';
        try {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {}

        return OrderUpdateResponse(
          success: false,
          errorMessage: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (_) {
      return OrderUpdateResponse(
        success: false,
        errorMessage: 'No internet connection. Please check your network.',
      );
    } on TimeoutException catch (_) {
      return OrderUpdateResponse(
        success: false,
        errorMessage: 'Connection timeout. Please try again.',
      );
    } on FormatException catch (_) {
      return OrderUpdateResponse(
        success: false,
        errorMessage: 'Invalid response from server.',
      );
    } catch (e) {
      return OrderUpdateResponse(
        success: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }
}
