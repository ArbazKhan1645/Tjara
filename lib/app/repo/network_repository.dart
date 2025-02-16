// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_import, avoid_print, depend_on_referenced_packages

import 'dart:convert';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:retry/retry.dart';
import '../core/utils/helpers/api_exceptions.dart';
import '../data/configs/api_configs.dart';
import '../core/locators/cache_images.dart';
import '../models/categories/categories_model.dart';
import '../models/users_model.dart/customer_models.dart';
import '../services/app/app_service.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class NetworkRepository {
  final Dio _dio;

  NetworkRepository()
      : _dio = Dio(BaseOptions(
            connectTimeout:
                Duration(milliseconds: ApiConfig.timeout.inMilliseconds),
            receiveTimeout:
                Duration(milliseconds: ApiConfig.timeout.inMilliseconds))) {
    _initializeInterceptors();
  }

  Future<CacheOptions> getCacheOptions() async {
    final dir = await getApplicationDocumentsDirectory();
    return CacheOptions(
      store: HiveCacheStore(dir.path),
      policy: CachePolicy.refreshForceCache,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(days: 7),
    );
  }

  void _initializeInterceptors() async {
    final cacheOptions = await getCacheOptions();
    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  Future<T> fetchData<T>({
    required String url,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // if (_appService.currentConnectivity == ConnectivityResult.none) {
    //   throw ApiException('No internet connection');
    // }
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.statusCode != 200) {
        throw ApiException(
            'Failed to fetch data: ${response.statusCode} ${response.statusMessage}');
      }
      final data = response.data;
      return fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException('Request timed out');
      } else if (e.type == DioExceptionType.badResponse) {
        throw ApiException(
            'Server error: ${e.response?.statusCode} ${e.response?.statusMessage}');
      } else {
        throw ApiException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
}
