import '../../../../core/models/driver_model.dart';

abstract class DriverRepository {
  /// Get the current driver's profile
  Future<Driver> getDriverProfile();

  /// Update the current driver's profile
  Future<Driver> updateDriverProfile({
    required String licenseNumber,
    bool? isAvailable,
  });

  /// Create a new driver profile
  Future<Driver> createDriverProfile({
    required String licenseNumber,
    bool isAvailable = true,
  });
} 