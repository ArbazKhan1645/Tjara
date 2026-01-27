import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

/// Response model for add to cart
class AddToCartResponse {
  final bool success;
  final String? message;
  final String? cartItemId;
  final String? errorMessage;
  final int? statusCode;

  AddToCartResponse({
    required this.success,
    this.message,
    this.cartItemId,
    this.errorMessage,
    this.statusCode,
  });
}

/// Response model for quick buy order insert
class QuickBuyOrderResponse {
  final bool success;
  final String? message;
  final List<String>? orderIds;
  final String? errorMessage;
  final int? statusCode;

  QuickBuyOrderResponse({
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
class QuickBuyOrderUpdateResponse {
  final bool success;
  final String? message;
  final String? errorMessage;
  final int? statusCode;

  QuickBuyOrderUpdateResponse({
    required this.success,
    this.message,
    this.errorMessage,
    this.statusCode,
  });
}

/// User details for quick buy checkout
class QuickBuyUserDetails {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  QuickBuyUserDetails({
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

/// User address for quick buy checkout
class QuickBuyUserAddress {
  final String streetAddress;
  final String countryId;
  final String stateId;
  final String cityId;
  final String postalCode;

  QuickBuyUserAddress({
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

  bool get hasData =>
      streetAddress.isNotEmpty || postalCode.isNotEmpty || cityId.isNotEmpty;
}

/// Service class for Quick Buy Checkout API calls
class QuickBuyCheckoutService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';
  static const String _paymentMethod = 'cash-on-delivery';
  static const String _successUrl =
      'https://libanbuy.com/checkout?payment=success';
  static const String _cancelUrl =
      'https://libanbuy.com/checkout?payment=cancel';

  // Lebanon country ID
  static const String defaultCountryId = '485c93c9-0fd5-4055-bdac-05896595023a';

  /// Generates a unique idempotency key for the order
  static String _generateIdempotencyKey(String uniqueId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final randomSuffix =
        List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
    return 'quick_buy_${timestamp}_${uniqueId}_$randomSuffix';
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

  /// Step 1: Add product to cart and get cart_item_id
  static Future<AddToCartResponse> _addToCart({
    required String productId,
    required String shopId,
    required int quantity,
    String? variationId,
    String? userId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/cart/add-to-cart');

      final Map<String, dynamic> body = {
        'shop_id': shopId,
        'product_id': productId,
        'quantity': quantity,
      };

      // Only add variation_id if it's not null and not empty
      if (variationId != null && variationId.isNotEmpty) {
        body['variation_id'] = variationId;
      }

      final response = await http
          .post(uri, headers: _getHeaders(userId), body: json.encode(body))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Extract cart_item.id from response
        String? cartItemId;
        if (data['cart_item'] != null && data['cart_item']['id'] != null) {
          cartItemId = data['cart_item']['id'].toString();
        }

        if (cartItemId == null || cartItemId.isEmpty) {
          return AddToCartResponse(
            success: false,
            errorMessage: 'Failed to get cart item ID from response',
            statusCode: response.statusCode,
          );
        }

        return AddToCartResponse(
          success: true,
          message: data['message'] ?? 'Product added to cart successfully.',
          cartItemId: cartItemId,
          statusCode: response.statusCode,
        );
      } else {
        String errorMessage = 'Failed to add to cart';
        try {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {}

        return AddToCartResponse(
          success: false,
          errorMessage: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (_) {
      return AddToCartResponse(
        success: false,
        errorMessage: 'No internet connection. Please check your network.',
      );
    } on TimeoutException catch (_) {
      return AddToCartResponse(
        success: false,
        errorMessage: 'Connection timeout. Please try again.',
      );
    } catch (e) {
      return AddToCartResponse(
        success: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Step 2: Place order using cart_item_ids
  static Future<QuickBuyOrderResponse> _placeOrderWithCartItems({
    required List<String> cartItemIds,
    required QuickBuyUserDetails userDetails,
    QuickBuyUserAddress? userAddress,
    String? userId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/orders/insert');

      final body = {
        'cart_item_ids': cartItemIds,
        'idempotency_key': _generateIdempotencyKey(userId ?? 'guest'),
        'payment_method': _paymentMethod,
        'success_url': _successUrl,
        'cancel_url': _cancelUrl,
        'user_details': userDetails.toJson(),
        'user_address': (userAddress ?? QuickBuyUserAddress()).toJson(),
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

        return QuickBuyOrderResponse(
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

        return QuickBuyOrderResponse(
          success: false,
          errorMessage: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (_) {
      return QuickBuyOrderResponse(
        success: false,
        errorMessage: 'No internet connection. Please check your network.',
      );
    } on TimeoutException catch (_) {
      return QuickBuyOrderResponse(
        success: false,
        errorMessage: 'Connection timeout. Please try again.',
      );
    } on FormatException catch (_) {
      return QuickBuyOrderResponse(
        success: false,
        errorMessage: 'Invalid response from server.',
      );
    } catch (e) {
      return QuickBuyOrderResponse(
        success: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Main method: Insert a new quick buy order
  /// This performs two steps:
  /// 1. Add product to cart -> get cart_item_id
  /// 2. Place order with cart_item_ids
  ///
  /// [productId] - The product ID
  /// [shopId] - The shop ID
  /// [quantity] - The quantity to order
  /// [userDetails] - User's contact information
  /// [variationId] - Optional variation ID
  /// [userAddress] - User's shipping address (can be empty initially)
  /// [userId] - Current user's ID for authentication
  static Future<QuickBuyOrderResponse> insertOrder({
    required String productId,
    required String shopId,
    required int quantity,
    required QuickBuyUserDetails userDetails,
    String? variationId,
    QuickBuyUserAddress? userAddress,
    String? userId,
  }) async {
    // Step 1: Add to cart
    final cartResponse = await _addToCart(
      productId: productId,
      shopId: shopId,
      quantity: quantity,
      variationId: variationId,
      userId: userId,
    );

    if (!cartResponse.success || cartResponse.cartItemId == null) {
      return QuickBuyOrderResponse(
        success: false,
        errorMessage: cartResponse.errorMessage ?? 'Failed to add to cart',
        statusCode: cartResponse.statusCode,
      );
    }

    // Step 2: Place order with cart_item_ids
    final orderResponse = await _placeOrderWithCartItems(
      cartItemIds: [cartResponse.cartItemId!],
      userDetails: userDetails,
      userAddress: userAddress,
      userId: userId,
    );

    return orderResponse;
  }

  /// Update order with shipping address
  static Future<QuickBuyOrderUpdateResponse> updateOrderAddress({
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

      final addressParts = <String>[];
      if (streetAddress.isNotEmpty) addressParts.add(streetAddress);
      addressParts.add('Lebanon');
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

        return QuickBuyOrderUpdateResponse(
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

        return QuickBuyOrderUpdateResponse(
          success: false,
          errorMessage: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (_) {
      return QuickBuyOrderUpdateResponse(
        success: false,
        errorMessage: 'No internet connection. Please check your network.',
      );
    } on TimeoutException catch (_) {
      return QuickBuyOrderUpdateResponse(
        success: false,
        errorMessage: 'Connection timeout. Please try again.',
      );
    } on FormatException catch (_) {
      return QuickBuyOrderUpdateResponse(
        success: false,
        errorMessage: 'Invalid response from server.',
      );
    } catch (e) {
      return QuickBuyOrderUpdateResponse(
        success: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }
}
