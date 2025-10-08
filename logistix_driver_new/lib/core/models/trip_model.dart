/// trip_model.dart - Trip Model
/// 
/// Purpose:
/// - Represents a trip/ride in the system
/// - Contains trip details, driver info, and booking info
/// - Used for ride acceptance and trip management
/// 
/// Key Logic:
/// - Trip creation after ride acceptance
/// - Trip status management
/// - Driver and booking information
/// - Payment and timing details
library;

import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'driver_model.dart';
import 'booking_model.dart';

part 'trip_model.g.dart';

enum TripStatus {
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('STARTED')
  started,
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
  final Booking bookingRequest;
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
  final double? finalFare;
  @JsonKey(name: 'final_duration')
  final double? finalDuration;
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
    this.finalFare,
    this.finalDuration,
    this.finalDistance,
    required this.isPaymentDone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TripToJson(this);

  /// Create a copy of this trip with updated fields
  Trip copyWith({
    int? id,
    Driver? driver,
    Booking? bookingRequest,
    TripStatus? status,
    DateTime? loadingStartTime,
    DateTime? loadingEndTime,
    DateTime? unloadingStartTime,
    DateTime? unloadingEndTime,
    DateTime? paymentTime,
    double? finalFare,
    double? finalDuration,
    String? finalDistance,
    bool? isPaymentDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      driver: driver ?? this.driver,
      bookingRequest: bookingRequest ?? this.bookingRequest,
      status: status ?? this.status,
      loadingStartTime: loadingStartTime ?? this.loadingStartTime,
      loadingEndTime: loadingEndTime ?? this.loadingEndTime,
      unloadingStartTime: unloadingStartTime ?? this.unloadingStartTime,
      unloadingEndTime: unloadingEndTime ?? this.unloadingEndTime,
      paymentTime: paymentTime ?? this.paymentTime,
      finalFare: finalFare ?? this.finalFare,
      finalDuration: finalDuration ?? this.finalDuration,
      finalDistance: finalDistance ?? this.finalDistance,
      isPaymentDone: isPaymentDone ?? this.isPaymentDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if trip is accepted
  bool get isAccepted => status == TripStatus.accepted;

  /// Check if trip is started
  bool get isStarted => status == TripStatus.started;

  /// Check if trip is completed
  bool get isCompleted => status == TripStatus.completed;

  /// Check if trip is cancelled
  bool get isCancelled => status == TripStatus.cancelled;

  /// Get trip status display text
  String get statusText {
    switch (status) {
      case TripStatus.accepted:
        return 'Accepted';
      case TripStatus.started:
        return 'Started';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get formatted final fare
  String get formattedFinalFare => finalFare != null ? '₹${finalFare!.toStringAsFixed(2)}' : 'N/A';

  /// Get formatted final duration
  String get formattedFinalDuration => finalDuration != null ? '${finalDuration!.toStringAsFixed(1)} mins' : 'N/A';

  /// Get formatted final distance
  String get formattedFinalDistance => finalDistance != null ? '$finalDistance km' : 'N/A';
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

  const TripUpdateRequest({
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