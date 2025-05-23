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
      
      final data = <String, dynamic>{};
      
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (profilePicture != null) data['profile_picture'] = profilePicture;
      
      final response = await _apiClient.put(ApiEndpoints.userProfile, data: data);
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
} 