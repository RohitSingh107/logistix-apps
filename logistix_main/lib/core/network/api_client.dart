import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  late final Dio _dio;
  final AuthService _authService;

  ApiClient(this._authService) {
    final baseUrl = AppConfig.baseUrl;
    print('Initializing ApiClient with baseUrl: $baseUrl');
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ensure baseUrl is always set correctly
          options.baseUrl = AppConfig.baseUrl;
          
          final token = _authService.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            final refreshed = await _authService.refreshAccessToken();
            if (refreshed) {
              // Retry the original request
              final token = _authService.accessToken;
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              // Make sure the baseUrl is correct on retry
              error.requestOptions.baseUrl = AppConfig.baseUrl;
              return handler.resolve(await _dio.fetch(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      // Make sure the baseUrl is set correctly before each request
      _dio.options.baseUrl = AppConfig.baseUrl;
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      // Make sure the baseUrl is set correctly before each request
      _dio.options.baseUrl = AppConfig.baseUrl;
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      // Make sure the baseUrl is set correctly before each request
      _dio.options.baseUrl = AppConfig.baseUrl;
      final response = await _dio.put(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      // Make sure the baseUrl is set correctly before each request
      _dio.options.baseUrl = AppConfig.baseUrl;
      final response = await _dio.delete(path);
      return response;
    } catch (e) {
      rethrow;
    }
  }
} 