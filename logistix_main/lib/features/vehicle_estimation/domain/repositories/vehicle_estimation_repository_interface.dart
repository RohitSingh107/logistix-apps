import '../../data/models/vehicle_estimate_response.dart';

abstract class VehicleEstimationRepositoryInterface {
  Future<List<VehicleEstimateResponse>> getVehicleEstimates({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
  });
} 