import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final AuthService _authService;

  AuthRepositoryImpl(this._apiClient, this._authService);

  /// Extracts a user-friendly error message from various error response formats
  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      // Handle connection errors
      if (error.type == DioExceptionType.connectionError) {
        return "Network error: Couldn't connect to the server. Please check your internet connection.";
      } else if (error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.sendTimeout) {
        return "Connection timeout: Server is taking too long to respond. Please try again later.";
      }
      
      // Handle response errors (server responded with error status)
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;
        
        // Try to extract error message from response data in different formats
        if (data is Map<String, dynamic>) {
          // Check for error key
          if (data.containsKey('error')) {
            final errorMsg = data['error'];
            
            // Handle duplicate phone number
            if (errorMsg is String && errorMsg.contains('duplicate key value') && 
                errorMsg.contains('phone')) {
              return "This phone number is already registered. Please login instead.";
            }
            
            return errorMsg.toString();
          }
          
          // Check for detail key (Django REST Framework style)
          if (data.containsKey('detail')) {
            return data['detail'].toString();
          }
          
          // Check for message key
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
        }
        
        // If we couldn't extract a specific message, use a generic one based on status code
        switch (statusCode) {
          case 400:
            return "Invalid request data. Please check your information.";
          case 401:
            return "Authentication required. Please log in again.";
          case 403:
            return "You don't have permission to access this resource.";
          case 404:
            return "Resource not found.";
          case 409:
            return "Conflict with existing data.";
          case 429:
            return "Too many requests. Please try again later.";
          case 500:
          case 502:
          case 503:
          case 504:
            return "Server error. Please try again later.";
          default:
            return "An unexpected error occurred (Status $statusCode).";
        }
      }
    }
    
    // For any other kind of error
    return error.toString();
  }

  @override
  Future<void> requestOtp(String phone) async {
    try {
      await _apiClient.post(ApiEndpoints.requestOtp, data: {'phone': phone});
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

    @override
  Future<void> requestOtpForLogin(String phone) async {
    try {
      await _apiClient.post(ApiEndpoints.requestOtpForLogin, data: {'phone': phone});
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp, String sessionId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
          'session_id': sessionId,
        },
      );

      if (response.data['access'] != null && response.data['refresh'] != null) {
        await _authService.saveTokens(
          response.data['access'],
          response.data['refresh'],
        );
      }

      return response.data;
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }


   @override
  Future<Map<String, dynamic>> verifyOtpForLogin(String phone, String otp, String sessionId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtpForLogin,
        data: {
          'phone': phone,
          'otp': otp,
          'session_id': sessionId,
        },
      );

      if (response.data['access'] != null && response.data['refresh'] != null) {
        await _authService.saveTokens(
          response.data['access'],
          response.data['refresh'],
        );
      }

      return response.data;
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<void> register(String phone, String firstName, String lastName) async {
    try {
      await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'phone': phone,
          'first_name': firstName,
          'last_name': lastName,
        },
      );
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    await _authService.clearTokens();
  }
} 