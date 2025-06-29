/**
 * driver_repository_impl.dart - Driver Repository Implementation
 * 
 * Purpose:
 * - Implements the DriverRepository interface for driver operations
 * - Provides API communication for driver-related requests
 * - Handles driver profile, status, and location management
 * 
 * Key Logic:
 * - getDriverProfile: Retrieves driver profile information and status
 * - updateDriverLocation: Updates driver's real-time location
 * - updateDriverStatus: Changes driver availability status
 * - getDriverTrips: Fetches driver's trip history and active trips
 * - handleTripRequests: Manages incoming trip requests for drivers
 * - Transforms API responses into Driver domain models
 * - Handles location tracking and status synchronization
 */

import '../../../../core/models/driver_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
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
    required String licenseNumber,
    bool? isAvailable,
    String? fcmToken,
  }) async {
    try {
      final request = DriverRequest(
        licenseNumber: licenseNumber,
        isAvailable: isAvailable ?? true,
        fcmToken: fcmToken,
      );

      final response = await _apiClient.put(
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
} 