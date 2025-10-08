/// driver_repository.dart - Driver Repository Interface
/// 
/// Purpose:
/// - Defines the contract for driver-related data operations
/// - Provides abstract methods for driver profile and status management
/// - Establishes consistent interface for driver data access across layers
/// 
/// Key Logic:
/// - Abstract methods for driver profile CRUD operations
/// - Driver availability and status management interface
/// - Real-time location tracking and updates for drivers
/// - Trip assignment and driver-customer matching interface
/// - Driver performance metrics and rating management
/// - Vehicle information and driver verification data access
/// - Integration points for location services and trip management
/// - Error handling contracts for driver operation failures
library;

import '../../../../core/models/driver_model.dart';

abstract class DriverRepository {
  /// Get the current driver's profile
  Future<Driver> getDriverProfile();

  /// Update the current driver's profile
  Future<Driver> updateDriverProfile({
    String? licenseNumber,
    bool? isAvailable,
    String? fcmToken,
    double? latitude,
    double? longitude,
  });

  /// Create a new driver profile
  Future<Driver> createDriverProfile({
    required String licenseNumber,
    bool isAvailable = true,
    String? fcmToken,
  });

  /// Update driver location only
  Future<Driver> updateDriverLocation({
    required double latitude,
    required double longitude,
  });

  /// Update driver FCM token only
  Future<Driver> updateDriverFcmToken(String fcmToken);
} 