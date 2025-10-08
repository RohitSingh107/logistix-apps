/// user_repository_impl.dart - User Repository Implementation
/// 
/// Purpose:
/// - Concrete implementation of UserRepository interface
/// - Handles HTTP API communication for user operations
/// - Provides comprehensive error handling and user-friendly error messages
/// 
/// Key Logic:
/// - Implements UserRepository interface with ApiClient integration
/// - Ensures authentication tokens are valid before API calls
/// - Provides detailed error message extraction from API responses
/// - Handles various DioException types (connection, timeout, response errors)
/// - Maps HTTP status codes to meaningful error messages
/// - Preserves existing user data during partial profile updates
/// - Uses JSON serialization for API communication
/// - Implements proper error propagation with Exception wrapping
library;

import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../services/api_endpoints.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;

  UserRepositoryImpl(this._apiClient);

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
      
      // Handle response errors
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('error')) {
            return data['error'].toString();
          }
          
          if (data.containsKey('detail')) {
            return data['detail'].toString();
          }
          
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
          default:
            return "An unexpected error occurred (Status $statusCode).";
        }
      }
    }
    
    // For any other kind of error
    return error.toString();
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      // Ensure we have a valid token before making this request
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.get(ApiEndpoints.userProfile);
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? profilePicture,
  }) async {
    try {
      // Ensure we have a valid token before making this request
      await _apiClient.ensureValidToken();
      
      // Build request data with only provided fields
      final Map<String, dynamic> requestData = {};
      
      if (firstName != null) {
        requestData['first_name'] = firstName;
      }
      if (lastName != null) {
        requestData['last_name'] = lastName;
      }
      if (profilePicture != null) {
        requestData['profile_picture'] = profilePicture;
      }
      
      final response = await _apiClient.put(
        ApiEndpoints.userProfile,
        data: requestData,
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  @override
  Future<User> updateFcmToken(String fcmToken) async {
    try {
      // Ensure we have a valid token before making this request
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.patch(
        ApiEndpoints.userProfile,
        data: {'fcm_token': fcmToken},
      );
      
      print('✅ FCM token updated successfully on server');
      return User.fromJson(response.data);
    } catch (e) {
      print('❌ Failed to update FCM token on server: ${_getErrorMessage(e)}');
      throw Exception(_getErrorMessage(e));
    }
  }
} 