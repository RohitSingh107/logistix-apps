import '../../../../core/models/vehicle_estimation_model.dart';

abstract class VehicleEstimationRepositoryInterface {
  Future<VehicleEstimationResponse> getVehicleEstimates({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
  });
} 