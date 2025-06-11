import 'base_model.dart';
import 'booking_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'driver_model.dart';

part 'trip_model.g.dart';

enum TripStatus {
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('TRIP_STARTED')
  tripStarted,
  @JsonValue('LOADING_STARTED')
  loadingStarted,
  @JsonValue('LOADING_DONE')
  loadingDone,
  @JsonValue('REACHED_DESTINATION')
  reachedDestination,
  @JsonValue('UNLOADING_STARTED')
  unloadingStarted,
  @JsonValue('UNLOADING_DONE')
  unloadingDone,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}

@JsonSerializable()
class Trip extends BaseModel {
  final int id;
  final Driver driver;
  @JsonKey(name: 'booking_request')
  final BookingRequest bookingRequest;
  final TripStatus status;
  @JsonKey(name: 'loading_start_time')
  final DateTime? loadingStartTime;
  @JsonKey(name: 'loading_end_time')
  final DateTime? loadingEndTime;
  @JsonKey(name: 'unloading_start_time')
  final DateTime? unloadingStartTime;
  @JsonKey(name: 'unloading_end_time')
  final DateTime? unloadingEndTime;
  @JsonKey(name: 'payment_time')
  final DateTime? paymentTime;
  @JsonKey(name: 'final_fare')
  final double finalFare;
  @JsonKey(name: 'final_duration')
  final int? finalDuration;
  @JsonKey(name: 'final_distance')
  final String? finalDistance;
  @JsonKey(name: 'is_payment_done')
  final bool isPaymentDone;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Trip({
    required this.id,
    required this.driver,
    required this.bookingRequest,
    required this.status,
    this.loadingStartTime,
    this.loadingEndTime,
    this.unloadingStartTime,
    this.unloadingEndTime,
    this.paymentTime,
    required this.finalFare,
    this.finalDuration,
    this.finalDistance,
    required this.isPaymentDone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TripToJson(this);

  @override
  List<Object?> get props => [
        id,
        driver,
        bookingRequest,
        status,
        loadingStartTime,
        loadingEndTime,
        unloadingStartTime,
        unloadingEndTime,
        paymentTime,
        finalFare,
        finalDuration,
        finalDistance,
        isPaymentDone,
        createdAt,
        updatedAt,
      ];

  // Helper method to convert string distance to double
  double? get distanceAsDouble {
    if (finalDistance == null) return null;
    try {
      return double.parse(finalDistance!);
    } catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class TripUpdateRequest {
  final TripStatus status;
  @JsonKey(name: 'loading_start_time')
  final DateTime? loadingStartTime;
  @JsonKey(name: 'loading_end_time')
  final DateTime? loadingEndTime;
  @JsonKey(name: 'unloading_start_time')
  final DateTime? unloadingStartTime;
  @JsonKey(name: 'unloading_end_time')
  final DateTime? unloadingEndTime;
  @JsonKey(name: 'payment_time')
  final DateTime? paymentTime;
  @JsonKey(name: 'final_fare')
  final double finalFare;
  @JsonKey(name: 'final_duration')
  final int? finalDuration;
  @JsonKey(name: 'final_distance')
  final String? finalDistance;
  @JsonKey(name: 'is_payment_done')
  final bool? isPaymentDone;

  TripUpdateRequest({
    required this.status,
    this.loadingStartTime,
    this.loadingEndTime,
    this.unloadingStartTime,
    this.unloadingEndTime,
    this.paymentTime,
    required this.finalFare,
    this.finalDuration,
    this.finalDistance,
    this.isPaymentDone,
  });

  factory TripUpdateRequest.fromJson(Map<String, dynamic> json) => _$TripUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TripUpdateRequestToJson(this);
}

@JsonSerializable()
class PaginatedTripList {
  final int count;
  final String? next;
  final String? previous;
  @JsonKey(defaultValue: [])
  final List<Trip> results;

  PaginatedTripList({
    required this.count,
    this.next,
    this.previous,
    List<Trip>? results,
  }) : results = results ?? [];

  factory PaginatedTripList.fromJson(Map<String, dynamic> json) => _$PaginatedTripListFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedTripListToJson(this);
}