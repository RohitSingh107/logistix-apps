import '../../../../core/models/trip_model.dart';

abstract class TripRepository {
  /// Get details of a specific trip
  Future<Trip> getTripDetails(int tripId);

  /// Update a trip's status and details
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
  });
} 