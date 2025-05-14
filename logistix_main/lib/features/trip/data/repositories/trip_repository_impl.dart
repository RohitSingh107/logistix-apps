import 'package:dio/dio.dart';
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
      final response = await _apiClient.post(
        ApiEndpoints.updateTrip(tripId),
        data: {
          'status': status.toString().split('.').last.toUpperCase(),
          'final_fare': finalFare,
          'loading_start_time': loadingStartTime?.toIso8601String(),
          'loading_end_time': loadingEndTime?.toIso8601String(),
          'unloading_start_time': unloadingStartTime?.toIso8601String(),
          'unloading_end_time': unloadingEndTime?.toIso8601String(),
          'payment_time': paymentTime?.toIso8601String(),
          'final_duration': finalDuration,
          'final_distance': finalDistance,
          'is_payment_done': isPaymentDone,
        },
      );

      return Trip.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
} 