import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:tjara/app/services/dashbopard_services/admin_products_service.dart';

// Custom exceptions for better error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException(this.message, {this.errors});

  @override
  String toString() => 'ValidationException: $message';
}

// Mixin for error handling
mixin ErrorHandlingMixin {
  final Logger _logger = Logger();

  void handleError(dynamic error, {String? context, StackTrace? stackTrace}) {
    _logger.e('Error in $context', error: error, stackTrace: stackTrace);
    
    final String userMessage = _getUserFriendlyMessage(error);
    _showErrorSnackbar(userMessage);
  }

  String _getUserFriendlyMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is FormatException) {
      return 'Invalid data format received from server.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  void _showErrorSnackbar(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  void showSuccessSnackbar(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  void showInfoSnackbar(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      shouldIconPulse: false,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}

// Network utilities
class NetworkUtils {
  static const int _defaultTimeoutSeconds = 30;
  static const int _defaultRetryAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = _defaultRetryAttempts,
    Duration delay = _retryDelay,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        if (attempts >= maxAttempts) {
          rethrow;
        }
        
        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }
        
        // Default retry conditions
        if (!_shouldRetryByDefault(error)) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(delay * attempts);
      }
    }
    
    throw Exception('Max retry attempts exceeded');
  }

  static bool _shouldRetryByDefault(dynamic error) {
    // Retry on network errors, timeouts, and specific HTTP status codes
    if (error is SocketException || 
        error is TimeoutException ||
        error is NetworkException) {
      return true;
    }
    
    if (error is ApiException) {
      // Retry on server errors (5xx) but not client errors (4xx)
      return error.statusCode != null && error.statusCode! >= 500;
    }
    
    return false;
  }

  static Future<T> withTimeout<T>(
    Future<T> future, {
    int timeoutSeconds = _defaultTimeoutSeconds,
  }) async {
    return future.timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () => throw TimeoutException(
        'Request timed out after $timeoutSeconds seconds',
        Duration(seconds: timeoutSeconds),
      ),
    );
  }

  static Map<String, String> getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Request-From': 'Application',
    };
  }

  static ApiException parseHttpError(int statusCode, String responseBody) {
    try {
      final Map<String, dynamic> body = jsonDecode(responseBody);
      final String message = body['message'] ?? 'Unknown error occurred';
      final Map<String, dynamic>? errors = body['errors'];
      
      return ApiException(
        message,
        statusCode: statusCode,
        errors: errors,
      );
    } catch (e) {
      return ApiException(
        'Failed to parse error response',
        statusCode: statusCode,
      );
    }
  }
}

// Loading state manager
class LoadingStateManager {
  final RxBool _isLoading = false.obs;
  final RxString _loadingMessage = ''.obs;
  final RxDouble _progress = 0.0.obs;

  bool get isLoading => _isLoading.value;
  String get loadingMessage => _loadingMessage.value;
  double get progress => _progress.value;

  void startLoading([String message = 'Loading...']) {
    _isLoading.value = true;
    _loadingMessage.value = message;
    _progress.value = 0.0;
  }

  void updateProgress(double progress, [String? message]) {
    _progress.value = progress.clamp(0.0, 1.0);
    if (message != null) {
      _loadingMessage.value = message;
    }
  }

  void updateMessage(String message) {
    _loadingMessage.value = message;
  }

  void stopLoading() {
    _isLoading.value = false;
    _loadingMessage.value = '';
    _progress.value = 0.0;
  }

  Widget buildLoadingOverlay({Widget? child}) {
    return Obx(() {
      if (!_isLoading.value) {
        return child ?? const SizedBox.shrink();
      }

      return Stack(
        children: [
          if (child != null) child,
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _loadingMessage.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_progress.value > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: _progress.value,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_progress.value * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// Cache manager for products
class ProductsCacheManager {
  static const String _cacheKey = 'admin_products_cache';
  static const Duration _cacheExpiry = Duration(minutes: 10);
  
  static final Map<String, CacheEntry> _cache = {};

  static void cacheProducts(String key, dynamic data) {
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
  }

  static T? getCachedProducts<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (DateTime.now().difference(entry.timestamp) > _cacheExpiry) {
      _cache.remove(key);
      return null;
    }
    
    return entry.data as T?;
  }

  static void clearCache() {
    _cache.clear();
  }

  static void removeCacheEntry(String key) {
    _cache.remove(key);
  }

  static String generateCacheKey({
    String? searchQuery,
    String? searchField,
    ProductStatus? status,
    List<ProductFilter>? filters,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? perPage,
  }) {
    final parts = <String>[
      'products',
      if (searchQuery?.isNotEmpty == true) 'search_$searchQuery',
      if (searchField?.isNotEmpty == true) 'field_$searchField',
      if (status != ProductStatus.all) 'status_${status?.name}',
      if (filters?.isNotEmpty == true) 
        'filters_${filters!.map((f) => '${f.column.name}_${f.value}').join('_')}',
      if (startDate != null) 'start_${startDate.millisecondsSinceEpoch}',
      if (endDate != null) 'end_${endDate.millisecondsSinceEpoch}',
      'page_${page ?? 1}',
      'per_${perPage ?? 40}',
    ];
    
    return parts.join('_');
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  CacheEntry({required this.data, required this.timestamp});
}

// Analytics and performance tracking
class PerformanceTracker {
  static final Map<String, DateTime> _startTimes = {};
  static final Logger _logger = Logger();

  static void startTracking(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  static void endTracking(String operation, {Map<String, dynamic>? metadata}) {
    final startTime = _startTimes[operation];
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);
    _startTimes.remove(operation);

    _logger.i(
      'Performance: $operation completed in ${duration.inMilliseconds}ms',
      error: metadata,
    );

    // You can integrate with analytics services here
    _reportToAnalytics(operation, duration, metadata);
  }

  static void _reportToAnalytics(
    String operation, 
    Duration duration, 
    Map<String, dynamic>? metadata,
  ) {
    // Integrate with your analytics service (Firebase, Mixpanel, etc.)
    // Example:
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'performance_metric',
    //   parameters: {
    //     'operation': operation,
    //     'duration_ms': duration.inMilliseconds,
    //     ...?metadata,
    //   },
    // );
  }
}

// Utility extensions
extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  bool get isValidEmail {
     return true;
  }

  bool get isValidPhoneNumber {
    return true;
  }
}

extension DateTimeExtensions on DateTime {
  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  String get formattedDateTime {
    return DateFormat('MMM dd, yyyy - HH:mm').format(this);
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }
}

extension ListExtensions<T> on List<T> {
  List<T> get uniqueItems {
    return toSet().toList();
  }

  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  T? get lastOrNull {
    return isEmpty ? null : last;
  }
}