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
  }) async {
    try {
      final request = DriverRequest(
        licenseNumber: licenseNumber,
        isAvailable: isAvailable ?? true,
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
  }) async {
    try {
      final request = DriverRequest(
        licenseNumber: licenseNumber,
        isAvailable: isAvailable,
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