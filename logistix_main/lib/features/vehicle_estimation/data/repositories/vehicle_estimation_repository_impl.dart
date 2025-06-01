import 'package:dio/dio.dart';
import '../../../../core/models/vehicle_estimation_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../domain/repositories/vehicle_estimation_repository.dart';

class VehicleEstimationRepositoryImpl implements VehicleEstimationRepository {
  final ApiClient _apiClient;

  VehicleEstimationRepositoryImpl(this._apiClient);

  @override
  Future<List<VehicleEstimationRequest>> getVehicleEstimates({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
  }) async {
    try {
      final request = VehicleEstimationRequest(
        pickupLocation: Location(
          latitude: pickupLatitude,
          longitude: pickupLongitude,
        ),
        dropoffLocation: Location(
          latitude: dropoffLatitude,
          longitude: dropoffLongitude,
        ),
      );

      final response = await _apiClient.post(
        ApiEndpoints.vehicleEstimates,
        data: request.toJson(),
      );

      return (response.data as List)
          .map((json) => VehicleEstimationRequest.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
} 