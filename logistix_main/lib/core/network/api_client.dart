import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/api_endpoints.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class ApiClient {
  late final Dio _dio;
  final AuthService _authService;
  
  // List of endpoints that don't require authentication
  final List<String> _noAuthRequired = [
    ApiEndpoints.requestOtp,
    ApiEndpoints.verifyOtp,
    ApiEndpoints.requestOtpForLogin,
    ApiEndpoints.verifyOtpForLogin,
    ApiEndpoints.register,
    ApiEndpoints.refreshToken,
  ];

  ApiClient(this._authService) {
    final baseUrl = AppConfig.baseUrl;
    print('DEBUG: Initializing ApiClient with baseUrl: $baseUrl');
    
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
          
          print('DEBUG: Processing request for ${options.path}');
          
          // Only add auth header if endpoint requires authentication
          if (!_isAuthExcluded(options.path)) {
            print('DEBUG: Auth required for ${options.path}');
            final token = _authService.accessToken;
            
            if (token != null) {
              print('DEBUG: Adding Authorization header with token');
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              print('DEBUG: No token available, trying to refresh');
              // If token is required but missing, try refresh first
              final refreshSuccess = await _authService.refreshAccessToken();
              if (refreshSuccess) {
                print('DEBUG: Token refresh succeeded, adding new token to header');
                options.headers['Authorization'] = 'Bearer ${_authService.accessToken}';
              } else {
                print('DEBUG: Token refresh failed, proceeding without Authorization header');
              }
            }
            
            // Log the headers being sent
            print('DEBUG: Final request headers: ${options.headers}');
          } else {
            print('DEBUG: Auth not required for ${options.path}');
          }
          
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          print('DEBUG: Error intercepted: ${error.message}, status: ${error.response?.statusCode}');
          
          // Skip token refresh for authentication endpoints
          if (_isAuthExcluded(error.requestOptions.path)) {
            print('DEBUG: Auth error in excluded path, not refreshing token');
            return handler.next(error);
          }
          
          if (error.response?.statusCode == 401) {
            print('DEBUG: 401 Unauthorized error, attempting token refresh');
            // Try to refresh the token
            final refreshed = await _authService.refreshAccessToken();
            if (refreshed) {
              print('DEBUG: Token refreshed successfully, retrying request');
              // Update auth header with new token
              final token = _authService.accessToken;
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              
              // Make sure the baseUrl is correct on retry
              error.requestOptions.baseUrl = AppConfig.baseUrl;
              
              // Print debug info about retry
              print('DEBUG: Retrying request to ${error.requestOptions.path} with new token');
              print('DEBUG: Headers for retry: ${error.requestOptions.headers}');
              
              // Retry the original request with updated token
              return handler.resolve(await _dio.fetch(error.requestOptions));
            } else {
              print('DEBUG: Token refresh failed, unable to retry request');
            }
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          print('DEBUG: Received response for ${response.requestOptions.path} with status ${response.statusCode}');
          return handler.next(response);
        },
      ),
    ]);
  }
  
  // Check if the endpoint is in the excluded list
  bool _isAuthExcluded(String path) {
    final excluded = _noAuthRequired.any((endpoint) => path.contains(endpoint));
    print('DEBUG: Path $path auth excluded: $excluded');
    return excluded;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      print('DEBUG: GET request to $path');
      _dio.options.baseUrl = AppConfig.baseUrl;
      
      // Manual verification that JWT is present for auth-required endpoints
      if (!_isAuthExcluded(path)) {
        final token = _authService.accessToken;
        if (token != null) {
          print('DEBUG: Manual set of Authorization header: Bearer ${token.substring(0, math.min(token.length, 10))}...');
          _dio.options.headers['Authorization'] = 'Bearer $token';
        } else {
          print('DEBUG: No token available for GET request to $path');
        }
      }
      
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      print('DEBUG: Error in GET request to $path: $e');
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      print('DEBUG: POST request to $path');
      _dio.options.baseUrl = AppConfig.baseUrl;
      
      // Manual verification that JWT is present for auth-required endpoints
      if (!_isAuthExcluded(path)) {
        final token = _authService.accessToken;
        if (token != null) {
          print('DEBUG: Manual set of Authorization header: Bearer ${token.substring(0, math.min(token.length, 10))}...');
          _dio.options.headers['Authorization'] = 'Bearer $token';
        } else {
          print('DEBUG: No token available for POST request to $path');
        }
      }
      
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      print('DEBUG: Error in POST request to $path: $e');
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      print('DEBUG: PUT request to $path');
      _dio.options.baseUrl = AppConfig.baseUrl;
      
      // Manual verification that JWT is present for auth-required endpoints
      if (!_isAuthExcluded(path)) {
        final token = _authService.accessToken;
        if (token != null) {
          print('DEBUG: Manual set of Authorization header: Bearer ${token.substring(0, math.min(token.length, 10))}...');
          _dio.options.headers['Authorization'] = 'Bearer $token';
        } else {
          print('DEBUG: No token available for PUT request to $path');
        }
      }
      
      final response = await _dio.put(path, data: data);
      return response;
    } catch (e) {
      print('DEBUG: Error in PUT request to $path: $e');
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      print('DEBUG: DELETE request to $path');
      _dio.options.baseUrl = AppConfig.baseUrl;
      
      // Manual verification that JWT is present for auth-required endpoints
      if (!_isAuthExcluded(path)) {
        final token = _authService.accessToken;
        if (token != null) {
          print('DEBUG: Manual set of Authorization header: Bearer ${token.substring(0, math.min(token.length, 10))}...');
          _dio.options.headers['Authorization'] = 'Bearer $token';
        } else {
          print('DEBUG: No token available for DELETE request to $path');
        }
      }
      
      final response = await _dio.delete(path);
      return response;
    } catch (e) {
      print('DEBUG: Error in DELETE request to $path: $e');
      rethrow;
    }
  }
  
  // Utility method to ensure token is valid before making a request
  Future<bool> ensureValidToken() async {
    print('DEBUG: Ensuring valid token before request');
    return await _authService.ensureValidToken();
  }
}

 