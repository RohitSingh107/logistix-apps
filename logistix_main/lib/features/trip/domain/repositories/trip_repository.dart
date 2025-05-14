import '../../../../core/models/trip_model.dart';

abstract class TripRepository {
  Future<Trip> getTripDetails(int tripId);
  
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