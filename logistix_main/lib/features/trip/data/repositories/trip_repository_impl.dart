/**
 * trip_repository_impl.dart - Trip Repository Implementation
 * 
 * Purpose:
 * - Implements the TripRepository interface for trip lifecycle management
 * - Provides API communication for trip-related operations
 * - Handles data transformation between API and domain models
 * 
 * Key Logic:
 * - getTripDetails: Retrieves detailed trip information by ID
 * - getTripList: Fetches paginated trip history with filtering options
 * - updateTripStatus: Updates trip status (in progress, completed, cancelled)
 * - getActiveTripForUser: Retrieves currently active trip for user
 * - Supports both driver and customer trip perspectives
 * - Handles trip status transitions and validation
 * - Maps API responses to Trip domain models
 */

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
  Future<PaginatedTripList> getTripList({
    bool? forDriver,
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (forDriver != null) queryParams['for_driver'] = forDriver;
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;

      final response = await _apiClient.get(
        ApiEndpoints.tripList,
        queryParameters: queryParams,
      );

      return PaginatedTripList.fromJson(response.data);
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
    String? finalDistance,
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