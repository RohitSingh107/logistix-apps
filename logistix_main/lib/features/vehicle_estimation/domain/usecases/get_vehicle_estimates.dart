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
    return await _repository.getVehicleEstimates(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
    );
  }
} 