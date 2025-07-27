/**
 * trip_model.dart - Trip Model
 * 
 * Purpose:
 * - Represents a trip/ride in the system
 * - Contains trip details, driver info, and booking info
 * - Used for ride acceptance and trip management
 * 
 * Key Logic:
 * - Trip creation after ride acceptance
 * - Trip status management
 * - Driver and booking information
 * - Payment and timing details
 */

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
  final Booking bookingRequest;
  final TripStatus status;
  final DateTime? loadingStartTime;
  final DateTime? loadingEndTime;
  final DateTime? unloadingStartTime;
  final DateTime? unloadingEndTime;
  final DateTime? paymentTime;
  final double? finalFare;
  final double? finalDuration;
  final double? finalDistance;
  final bool isPaymentDone;
  final DateTime createdAt;
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
    double? finalDistance,
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

  /// Check if trip is active (accepted or started)
  bool get isActive => status == TripStatus.accepted || status == TripStatus.started;

  /// Check if trip is completed
  bool get isCompleted => status == TripStatus.completed;

  /// Check if trip is cancelled
  bool get isCancelled => status == TripStatus.cancelled;

  /// Get trip duration in minutes
  double? get durationInMinutes {
    if (loadingStartTime == null || loadingEndTime == null) return null;
    return loadingEndTime!.difference(loadingStartTime!).inMinutes.toDouble();
  }

  /// Get formatted fare
  String get formattedFare {
    if (finalFare != null) {
      return '₹${finalFare!.toStringAsFixed(2)}';
    }
    return '₹${bookingRequest.estimatedFare.toStringAsFixed(2)}';
  }

  /// Get trip status display text
  String get statusText {
    switch (status) {
      case TripStatus.accepted:
        return 'Accepted';
      case TripStatus.started:
        return 'In Progress';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get trip status color
  String get statusColor {
    switch (status) {
      case TripStatus.accepted:
        return '#4CAF50'; // Green
      case TripStatus.started:
        return '#2196F3'; // Blue
      case TripStatus.completed:
        return '#8BC34A'; // Light Green
      case TripStatus.cancelled:
        return '#F44336'; // Red
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