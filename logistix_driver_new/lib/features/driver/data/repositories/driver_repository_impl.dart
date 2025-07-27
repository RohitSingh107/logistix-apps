/**
 * driver_repository_impl.dart - Driver Repository Implementation
 * 
 * Purpose:
 * - Implements the DriverRepository interface
 * - Handles driver profile CRUD operations
 * - Manages driver availability and location updates
 * - Provides driver-specific API calls
 * 
 * Key Logic:
 * - Uses ApiClient for HTTP requests with authentication
 * - Handles driver profile creation and updates
 * - Manages driver availability status
 * - Updates driver location for real-time tracking
 * - Includes FCM token management for push notifications
 */

import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/models/driver_model.dart';
import '../../domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  final ApiClient _apiClient;

  DriverRepositoryImpl(this._apiClient);

  @override
  Future<Driver> getDriverProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.driverProfile);
      return Driver.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Driver> updateDriverProfile({
    String? licenseNumber,
    bool? isAvailable,
    String? fcmToken,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final request = PatchedDriverRequest(
        licenseNumber: licenseNumber,
        isAvailable: isAvailable,
        fcmToken: fcmToken,
        latitude: latitude,
        longitude: longitude,
      );

      final response = await _apiClient.patch(
        ApiEndpoints.driverProfile,
        data: request.toJson(),
      );

      return Driver.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Driver> createDriverProfile({
    required String licenseNumber,
    bool isAvailable = true,
    String? fcmToken,
  }) async {
    try {
      final request = DriverRequest(
        licenseNumber: licenseNumber,
        isAvailable: isAvailable,
        fcmToken: fcmToken,
      );

      final response = await _apiClient.post(
        ApiEndpoints.createDriver,
        data: request.toJson(),
      );

      return Driver.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Driver> updateDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Create a request with only location fields
      final request = {
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await _apiClient.patch(
        ApiEndpoints.driverProfile,
        data: request,
      );

      return Driver.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Driver> updateDriverFcmToken(String fcmToken) async {
    try {
      // Create a request with only FCM token field
      final request = {
        'fcm_token': fcmToken,
      };

      final response = await _apiClient.patch(
        ApiEndpoints.driverProfile,
        data: request,
      );

      print('✅ Driver FCM token updated successfully on server');
      return Driver.fromJson(response.data);
    } catch (e) {
      print('❌ Failed to update driver FCM token on server: $e');
      rethrow;
    }
  }
} 