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
      vehicleType: estimate.vehicleType,
      vehicleTitle: estimate.vehicleTitle,
      vehicleBaseFare: estimate.vehicleBaseFare,
      vehicleBaseDistance: estimate.vehicleBaseDistance,
      vehicleDimensionHeight: estimate.vehicleDimensionHeight,
      vehicleDimensionWeight: estimate.vehicleDimensionWeight,
      vehicleDimensionDepth: estimate.vehicleDimensionDepth,
      vehicleDimensionUnit: estimate.vehicleDimensionUnit,
      estimatedDistance: estimate.estimatedDistance,
      estimatedDuration: estimate.estimatedDuration,
    )).toList();
  }
} 