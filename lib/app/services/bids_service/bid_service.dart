import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

// ============== MODELS ==============

class BidResponse {
  final String message;
  final bool isWinner;
  final int currentBid;
  final int highestBid;

  BidResponse({
    required this.message,
    required this.isWinner,
    required this.currentBid,
    required this.highestBid,
  });

  factory BidResponse.fromJson(Map<String, dynamic> json) {
    return BidResponse(
      message: json['message'] ?? '',
      isWinner: json['is_winner'] ?? false,
      currentBid: json['current_bid'] ?? 0,
      highestBid: json['highest_bid'] ?? 0,
    );
  }
}

class ApiResult<T> {
  final bool success;
  final T? data;
  final String message;
  final int statusCode;

  ApiResult({
    required this.success,
    this.data,
    required this.message,
    required this.statusCode,
  });

  factory ApiResult.success(T data, String message, {int statusCode = 200}) {
    return ApiResult(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResult.failure(String message, {int statusCode = 0}) {
    return ApiResult(
      success: false,
      data: null,
      message: message,
      statusCode: statusCode,
    );
  }
}

// ============== SERVICE ==============

class BidService {
  static const String _baseUrl = 'https://api.libanbuy.com/api';
  static const int _timeout = 30;

  final Dio _dio;
  final String userId;

  BidService({required this.userId}) : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: _timeout),
      receiveTimeout: const Duration(seconds: _timeout),
      sendTimeout: const Duration(seconds: _timeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Request-From': 'Application',
        'user-id': userId,
      },
    );
  }

  /// Place a bid on a product
  Future<ApiResult<BidResponse>> placeBid({
    required String productId,
    required int bidPrice,
  }) async {
    // Validation
    if (productId.isEmpty) {
      return ApiResult.failure('Product ID is required', statusCode: 400);
    }
    if (bidPrice <= 0) {
      return ApiResult.failure(
        'Bid amount must be greater than 0',
        statusCode: 400,
      );
    }

    try {
      final response = await _dio.post(
        '/products/$productId/bids/insert',
        data: {'product_id': productId, 'auction_bid_price': bidPrice},
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } on SocketException {
      return ApiResult.failure(
        'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on TimeoutException {
      return ApiResult.failure(
        'Request timed out. Please try again.',
        statusCode: 408,
      );
    } on FormatException {
      return ApiResult.failure(
        'Invalid response format from server.',
        statusCode: 500,
      );
    } catch (e) {
      return ApiResult.failure(
        'An unexpected error occurred: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  ApiResult<BidResponse> _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        final bidResponse = BidResponse.fromJson(data);
        return ApiResult.success(
          bidResponse,
          bidResponse.message,
          statusCode: statusCode,
        );
      } catch (e) {
        return ApiResult.failure(
          'Failed to parse response',
          statusCode: statusCode,
        );
      }
    }

    return ApiResult.failure(
      _getStatusMessage(statusCode, data),
      statusCode: statusCode,
    );
  }

  ApiResult<BidResponse> _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiResult.failure(
          'Connection timeout. Please check your internet.',
          statusCode: 408,
        );

      case DioExceptionType.sendTimeout:
        return ApiResult.failure(
          'Send timeout. Please try again.',
          statusCode: 408,
        );

      case DioExceptionType.receiveTimeout:
        return ApiResult.failure(
          'Server took too long to respond.',
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return ApiResult.failure(
          'Connection failed. Please check your internet.',
          statusCode: 0,
        );

      case DioExceptionType.badCertificate:
        return ApiResult.failure(
          'Security certificate error.',
          statusCode: 495,
        );

      case DioExceptionType.cancel:
        return ApiResult.failure('Request was cancelled.', statusCode: 0);

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final data = e.response?.data;
        return ApiResult.failure(
          _getStatusMessage(statusCode, data),
          statusCode: statusCode,
        );

      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          return ApiResult.failure('No internet connection.', statusCode: 0);
        }
        return ApiResult.failure(
          'An unexpected error occurred.',
          statusCode: 0,
        );
    }
  }

  String _getStatusMessage(int statusCode, dynamic data) {
    // Try to get message from response first
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'].toString();
    }

    // Fallback to status code messages
    switch (statusCode) {
      case 200:
      case 201:
        return 'Bid placed successfully!';
      case 400:
        return 'Invalid request. Please check your bid amount.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You are not allowed to place this bid.';
      case 404:
        return 'Product not found or auction has ended.';
      case 409:
        return 'Bid conflict. Someone placed a higher bid.';
      case 422:
        return 'Invalid bid data. Please verify your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
