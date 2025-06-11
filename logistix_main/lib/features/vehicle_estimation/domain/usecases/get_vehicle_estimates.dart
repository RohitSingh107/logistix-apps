import '../repositories/vehicle_estimation_repository_interface.dart';
import '../../data/models/vehicle_estimate_response.dart';

class GetVehicleEstimates {
  final VehicleEstimationRepositoryInterface _repository;

  GetVehicleEstimates(this._repository);

  Future<List<VehicleEstimateResponse>> call({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
  }) async {
    final response = await _repository.getVehicleEstimates(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
    );
    
    // Convert VehicleEstimate to VehicleEstimateResponse
    return response.estimates.map((estimate) => VehicleEstimateResponse(
      estimatedFare: estimate.estimatedFare,
      pickupReachTime: estimate.pickupReachTime,
      vehicleType: estimate.vehicleTypeId,
      vehicleTitle: estimate.vehicleType,
      vehicleBaseFare: estimate.estimatedFare, // Using estimated fare as base fare
      vehicleBaseDistance: estimate.estimatedDistance ?? 0.0,
      vehicleDimensionHeight: 0.0, // Default value, not provided by API
      vehicleDimensionWeight: 0.0, // Default value, not provided by API
      vehicleDimensionDepth: 0.0, // Default value, not provided by API
    )).toList();
  }
} 