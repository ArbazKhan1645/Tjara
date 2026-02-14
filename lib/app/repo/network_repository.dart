// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_import, avoid_print, depend_on_referenced_packages, constant_identifier_names

import 'dart:convert';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:retry/retry.dart';
import 'package:tjara/app/core/utils/helpers/api_exceptions.dart';
import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/users_model.dart/customer_models.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

// Top-level functions required for compute() - cannot be inside a class
Map<String, dynamic> _decodeJsonMap(String source) {
  return json.decode(source) as Map<String, dynamic>;
}

dynamic _decodeJsonDynamic(String source) {
  return json.decode(source);
}

class NetworkRepository {
  CommonHeader original = CommonHeader(
    headers: {
      "X-Request-From": "Application",
      "Content-Type": "application/json",
    },
  );
  static const int _CACHE_EXPIRATION_DAYS = 7;
  static const int _TIMEOUT_SECONDS = 10;
  Directory? _cacheDirectory; // Nullable banao
  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  NetworkRepository() {
    _initializeCacheDirectory();
  }

  Future<void> _initializeCacheDirectory() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        _isInitialized = true;
        _initCompleter.complete();
        return;
      }

      _cacheDirectory = await getTemporaryDirectory();
      _isInitialized = true;
      _initCompleter.complete();
    } catch (e) {
      print('Cache init error: $e');
      _isInitialized = true; // Mark as initialized even on error
      _initCompleter.complete();
    }
  }

  // Generate a unique cache key from the URL
  String _generateCacheKey(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  // Save data to cache
  Future<void> _saveToCache(String url, String data) async {
    await _ensureInitialized();

    if (kIsWeb || _cacheDirectory == null) return;

    try {
      final cacheKey = _generateCacheKey(url);
      final cacheFile = File('${_cacheDirectory!.path}/$cacheKey');

      final cacheData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      };

      await cacheFile.writeAsString(json.encode(cacheData));
    } catch (e) {
      print('Cache save error: $e');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initCompleter.future;
    }
  }

  // Retrieve data from cache
  Future<String?> _getFromCache(String url) async {
    await _ensureInitialized();

    if (kIsWeb || _cacheDirectory == null) return null;

    try {
      final cacheKey = _generateCacheKey(url);
      final cacheFile = File('${_cacheDirectory!.path}/$cacheKey');

      if (await cacheFile.exists()) {
        final content = await cacheFile.readAsString();
        final cachedData = json.decode(content);

        final timestamp = DateTime.parse(cachedData['timestamp']);

        if (DateTime.now().difference(timestamp).inDays <
            _CACHE_EXPIRATION_DAYS) {
          return cachedData['data'];
        } else {
          // Cache expired, delete it
          await cacheFile.delete();
        }
      }
    } catch (e) {
      print('Cache retrieve error: $e');
    }
    return null;
  }

  // Fetch data with advanced caching and error handling
  Future<T> fetchData<T>({
    required String url,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
  }) async {
    // Construct full URL with query parameters
    final fullUrl = _buildUrlWithParams(url, queryParameters);

    try {
      // Check cache first unless force refresh is requested
      if (!forceRefresh) {
        final cachedData = await _getFromCache(fullUrl);
        if (cachedData != null) {
          return fromJson(await compute(_decodeJsonMap, cachedData));
        }
      }

      // Perform network request
      final response = await http
          .get(Uri.parse(fullUrl), headers: original.headers)
          .timeout(
            const Duration(seconds: _TIMEOUT_SECONDS),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      // Handle response
      if (response.statusCode == 200) {
        // Save to cache
        await _saveToCache(fullUrl, response.body);

        // Parse and return
        return fromJson(await compute(_decodeJsonMap, response.body));
      } else if (response.statusCode == 404) {
        // Try cache if network request fails
        final cachedData = await _getFromCache(fullUrl);
        if (cachedData != null) {
          return fromJson(await compute(_decodeJsonMap, cachedData));
        }

        return fromJson({});
      } else {
        final cachedData = await _getFromCache(fullUrl);
        if (cachedData != null) {
          return fromJson(await compute(_decodeJsonMap, cachedData));
        }

        // If no cache, throw exception
        throw ApiException(
          'Failed to fetch data: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      // Timeout handling
      final cachedData = await _getFromCache(fullUrl);
      if (cachedData != null) {
        return fromJson(await compute(_decodeJsonMap, cachedData));
      }
      throw ApiException('Request timed out');
    } on SocketException {
      // No internet connection
      final cachedData = await _getFromCache(fullUrl);
      if (cachedData != null) {
        return fromJson(await compute(_decodeJsonMap, cachedData));
      }
      throw ApiException('No internet connection');
    } catch (e) {
      // Generic error handling
      final cachedData = await _getFromCache(fullUrl);
      if (cachedData != null) {
        return fromJson(await compute(_decodeJsonMap, cachedData));
      }
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<T> fetchRawJson<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
  }) async {
    // Construct full URL with query parameters
    final fullUrl = _buildUrlWithParams(url, queryParameters);

    try {
      // Check cache first unless force refresh is requested
      if (!forceRefresh) {
        final cachedData = await _getFromCache(fullUrl);
        if (cachedData != null) {
          return await compute<String, dynamic>(_decodeJsonDynamic, cachedData)
              as T;
        }
      }

      // Perform network request
      final response = await http
          .get(Uri.parse(fullUrl), headers: original.headers)
          .timeout(
            const Duration(seconds: _TIMEOUT_SECONDS),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      // Handle response
      if (response.statusCode == 200) {
        // Save to cache
        await _saveToCache(fullUrl, response.body);

        // Parse and return
        return await compute<String, dynamic>(_decodeJsonDynamic, response.body)
            as T;
      } else {
        // Try cache if network request fails
        final cachedData = await _getFromCache(fullUrl);
        if (cachedData != null) {
          return await compute<String, dynamic>(_decodeJsonDynamic, cachedData)
              as T;
        }

        // If no cache, throw exception
        throw ApiException(
          'Failed to fetch data: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      // Timeout handling
      final cachedData = await _getFromCache(fullUrl);
      if (cachedData != null) {
        return await compute<String, dynamic>(_decodeJsonDynamic, cachedData)
            as T;
      }
      throw ApiException('Request timed out');
    } on SocketException {
      // No internet connection
      final cachedData = await _getFromCache(fullUrl);
      if (cachedData != null) {
        return await compute<String, dynamic>(_decodeJsonDynamic, cachedData)
            as T;
      }
      throw ApiException('No internet connection');
    } catch (e) {
      // Generic error handling
      final cachedData = await _getFromCache(fullUrl);
      if (cachedData != null) {
        return await compute<String, dynamic>(_decodeJsonDynamic, cachedData)
            as T;
      }
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<T> postData<T>({
    required String url,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic>? queryParameters,
    bool cacheResponse = false,
  }) async {
    // Construct full URL with query parameters
    final fullUrl = _buildUrlWithParams(url, queryParameters);

    try {
      // Perform network request
      final response = await http
          .post(
            Uri.parse(fullUrl),
            headers: original.headers,
            body: json.encode(body),
          )
          .timeout(
            const Duration(seconds: _TIMEOUT_SECONDS),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Cache the response if specified
        if (cacheResponse) {
          await _saveToCache(fullUrl, response.body);
        }

        // If fromJson is null, return response body directly
        if (fromJson == null) {
          return response.body as T;
        }

        // Parse and return
        return fromJson(await compute(_decodeJsonMap, response.body));
      } else {
        throw ApiException(
          'Failed to post data: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      throw ApiException('Request timed out');
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  // Utility to build URL with query parameters
  String _buildUrlWithParams(String url, Map<String, dynamic>? params) {
    return url;
  }

  Future<void> clearCache(String url) async {
    await _ensureInitialized();

    if (kIsWeb || _cacheDirectory == null) return;

    try {
      final cacheKey = _generateCacheKey(url);
      final cacheFile = File('${_cacheDirectory!.path}/$cacheKey');

      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
    } catch (e) {
      print('Cache clear error: $e');
    }
  }

  // Clear entire cache
  Future<void> clearAllCache() async {
    await _ensureInitialized();

    if (kIsWeb || _cacheDirectory == null) return;

    try {
      if (await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create();
      }
    } catch (e) {
      print('Clear all cache error: $e');
    }
  }
}

// Custom exception for API-related errors
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class CommonHeader {
  final Map<String, String>? headers;

  CommonHeader({this.headers});

  CommonHeader copyWith({Map<String, String>? headers}) {
    return CommonHeader(
      headers: headers ?? Map<String, String>.from(this.headers ?? {}),
    );
  }
}
