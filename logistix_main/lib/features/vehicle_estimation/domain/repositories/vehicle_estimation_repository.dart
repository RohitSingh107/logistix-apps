import '../../../../core/models/vehicle_estimation_model.dart';

abstract class VehicleEstimationRepository {
  /// Get vehicle estimation quotes for the given pickup and dropoff locations
  Future<List<VehicleEstimationRequest>> getVehicleEstimates({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
  });
} 