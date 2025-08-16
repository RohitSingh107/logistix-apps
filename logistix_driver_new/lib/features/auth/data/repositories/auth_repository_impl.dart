/**
 * auth_repository_impl.dart - Authentication Repository Implementation
 * 
 * Purpose:
 * - Concrete implementation of AuthRepository interface
 * - Handles HTTP API communication for authentication operations
 * - Integrates with ApiClient and AuthService for complete auth flow
 * 
 * Key Logic:
 * - Implements OTP-based authentication via API endpoints
 * - Handles OTP request and verification through HTTP calls
 * - Manages token operations (refresh, save) via AuthService
 * - Provides comprehensive error handling for API failures
 * - Extracts meaningful error messages from API responses
 * - Handles DioException errors with user-friendly messages
 * - Delegates token storage to AuthService for consistency
 * - Implements logout by clearing local token storage
 * - Uses structured error handling with Exception wrapping
 */

import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/location_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final AuthService _authService;

  AuthRepositoryImpl(this._apiClient, this._authService);

  @override
  Future<void> requestOtp(String phone) async {
    try {
      await _apiClient.post(
        ApiEndpoints.login,
        data: {'phone': phone},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
      );

      return response.data['access'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('🗑️ AuthRepository: Starting logout process');
      
      // Stop location tracking
      print('📍 AuthRepository: Stopping location tracking');
      LocationService().stopLocationTracking();
      
      // Clear all stored tokens locally
      print('🗑️ AuthRepository: Clearing all stored tokens locally');
      await _authService.clearTokens();
      
      // Clear cached headers in ApiClient
      print('🧹 AuthRepository: Clearing cached headers');
      _apiClient.clearCachedHeaders();
      
      print('✅ AuthRepository: Logout completed successfully');
    } catch (e) {
      print('❌ AuthRepository: Failed to logout: $e');
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await _authService.saveTokens(accessToken, refreshToken);
    } catch (e) {
      throw Exception('Failed to save tokens: ${e.toString()}');
    }
  }

  Exception _handleError(DioException error) {
    if (error.response?.data is Map) {
      final data = error.response?.data as Map;
      if (data.containsKey('detail')) {
        return Exception(data['detail']);
      }
    }
    return Exception(error.message ?? 'An error occurred');
  }
} 