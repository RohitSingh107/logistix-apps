import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/services/auth_service.dart';

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
      // Clear all stored tokens locally
      await _authService.clearTokens();
    } catch (e) {
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