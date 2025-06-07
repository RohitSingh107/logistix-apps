import '../../../../core/models/trip_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  final ApiClient _apiClient;

  TripRepositoryImpl(this._apiClient);

  @override
  Future<Trip> getTripDetails(int tripId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.tripDetail(tripId));
      return Trip.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Trip> updateTrip({
    required int tripId,
    required TripStatus status,
    required double finalFare,
    DateTime? loadingStartTime,
    DateTime? loadingEndTime,
    DateTime? unloadingStartTime,
    DateTime? unloadingEndTime,
    DateTime? paymentTime,
    int? finalDuration,
    double? finalDistance,
    bool? isPaymentDone,
  }) async {
    try {
      final request = TripUpdateRequest(
        status: status,
        finalFare: finalFare,
        loadingStartTime: loadingStartTime,
        loadingEndTime: loadingEndTime,
        unloadingStartTime: unloadingStartTime,
        unloadingEndTime: unloadingEndTime,
        paymentTime: paymentTime,
        finalDuration: finalDuration,
        finalDistance: finalDistance,
        isPaymentDone: isPaymentDone,
      );

      final response = await _apiClient.post(
        ApiEndpoints.updateTrip(tripId),
        data: request.toJson(),
      );

      return Trip.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
} 