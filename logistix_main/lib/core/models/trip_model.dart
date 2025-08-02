/**
 * trip_model.dart - Trip and Journey Data Models
 * 
 * Purpose:
 * - Defines data models for trip management and tracking
 * - Handles trip lifecycle states and driver assignment
 * - Manages trip update requests and paginated responses
 * 
 * Key Logic:
 * - TripStatus enum: Tracks trip progression from accepted to completed
 * - Trip: Core trip entity linking driver, booking, and status information
 * - TripUpdateRequest: Payload for updating trip status and details
 * - PaginatedTripList: Handles paginated trip list responses
 * - Includes timing data for loading/unloading phases
 * - Manages payment status and final fare calculation
 * - Extends BaseModel for consistent behavior
 * - Provides helper methods for data conversion (distanceAsDouble)
 * - Uses JSON serialization with comprehensive field mapping
 */

import 'package:equatable/equatable.dart';
import 'driver_model.dart';
import 'booking_model.dart';

class TripModel extends Equatable {
  final int id;
  final DriverModel driver;
  final BookingRequestModel bookingRequest;
  final String status;
  final DateTime? loadingStartTime;
  final DateTime? loadingEndTime;
  final DateTime? unloadingStartTime;
  final DateTime? unloadingEndTime;
  final DateTime? paymentTime;
  final double finalFare;
  final int? finalDuration; // minutes
  final String? finalDistance; // km as string
  final bool isPaymentDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripModel({
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

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as int,
      driver: DriverModel.fromJson(json['driver'] as Map<String, dynamic>),
      bookingRequest: BookingRequestModel.fromJson(json['booking_request'] as Map<String, dynamic>),
      status: json['status'] as String,
      loadingStartTime: json['loading_start_time'] != null
          ? DateTime.parse(json['loading_start_time'] as String)
          : null,
      loadingEndTime: json['loading_end_time'] != null
          ? DateTime.parse(json['loading_end_time'] as String)
          : null,
      unloadingStartTime: json['unloading_start_time'] != null
          ? DateTime.parse(json['unloading_start_time'] as String)
          : null,
      unloadingEndTime: json['unloading_end_time'] != null
          ? DateTime.parse(json['unloading_end_time'] as String)
          : null,
      paymentTime: json['payment_time'] != null
          ? DateTime.parse(json['payment_time'] as String)
          : null,
      finalFare: (json['final_fare'] as num).toDouble(),
      finalDuration: json['final_duration'] as int?,
      finalDistance: json['final_distance'] as String?,
      isPaymentDone: json['is_payment_done'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver.toJson(),
      'booking_request': bookingRequest.toJson(),
      'status': status,
      'loading_start_time': loadingStartTime?.toIso8601String(),
      'loading_end_time': loadingEndTime?.toIso8601String(),
      'unloading_start_time': unloadingStartTime?.toIso8601String(),
      'unloading_end_time': unloadingEndTime?.toIso8601String(),
      'payment_time': paymentTime?.toIso8601String(),
      'final_fare': finalFare,
      'final_duration': finalDuration,
      'final_distance': finalDistance,
      'is_payment_done': isPaymentDone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TripModel copyWith({
    int? id,
    DriverModel? driver,
    BookingRequestModel? bookingRequest,
    String? status,
    DateTime? loadingStartTime,
    DateTime? loadingEndTime,
    DateTime? unloadingStartTime,
    DateTime? unloadingEndTime,
    DateTime? paymentTime,
    double? finalFare,
    int? finalDuration,
    String? finalDistance,
    bool? isPaymentDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
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
}

enum TripStatus {
  accepted,
  tripStarted,
  loadingStarted,
  loadingDone,
  reachedDestination,
  unloadingStarted,
  unloadingDone,
  completed,
  cancelled,
}

// Legacy classes for backward compatibility
class Trip extends Equatable {
  final int id;
  final Driver driver;
  final BookingRequest bookingRequest;
  final TripStatus status;
  final DateTime? loadingStartTime;
  final DateTime? loadingEndTime;
  final DateTime? unloadingStartTime;
  final DateTime? unloadingEndTime;
  final DateTime? paymentTime;
  final double finalFare;
  final int? finalDuration;
  final String? finalDistance;
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
    required this.finalFare,
    this.finalDuration,
    this.finalDistance,
    required this.isPaymentDone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as int,
      driver: Driver.fromJson(json['driver'] as Map<String, dynamic>),
      bookingRequest: BookingRequest.fromJson(json['booking_request'] as Map<String, dynamic>),
      status: TripStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['status'],
        orElse: () => TripStatus.accepted,
      ),
      loadingStartTime: json['loading_start_time'] != null
          ? DateTime.parse(json['loading_start_time'] as String)
          : null,
      loadingEndTime: json['loading_end_time'] != null
          ? DateTime.parse(json['loading_end_time'] as String)
          : null,
      unloadingStartTime: json['unloading_start_time'] != null
          ? DateTime.parse(json['unloading_start_time'] as String)
          : null,
      unloadingEndTime: json['unloading_end_time'] != null
          ? DateTime.parse(json['unloading_end_time'] as String)
          : null,
      paymentTime: json['payment_time'] != null
          ? DateTime.parse(json['payment_time'] as String)
          : null,
      finalFare: (json['final_fare'] as num).toDouble(),
      finalDuration: json['final_duration'] as int?,
      finalDistance: json['final_distance'] as String?,
      isPaymentDone: json['is_payment_done'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver.toJson(),
      'booking_request': bookingRequest.toJson(),
      'status': status.toString().split('.').last.toUpperCase(),
      'loading_start_time': loadingStartTime?.toIso8601String(),
      'loading_end_time': loadingEndTime?.toIso8601String(),
      'unloading_start_time': unloadingStartTime?.toIso8601String(),
      'unloading_end_time': unloadingEndTime?.toIso8601String(),
      'payment_time': paymentTime?.toIso8601String(),
      'final_fare': finalFare,
      'final_duration': finalDuration,
      'final_distance': finalDistance,
      'is_payment_done': isPaymentDone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

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
}

class TripUpdateRequest extends Equatable {
  final TripStatus status;
  final DateTime? loadingStartTime;
  final DateTime? loadingEndTime;
  final DateTime? unloadingStartTime;
  final DateTime? unloadingEndTime;
  final DateTime? paymentTime;
  final double finalFare;
  final int? finalDuration;
  final String? finalDistance;
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

  factory TripUpdateRequest.fromJson(Map<String, dynamic> json) {
    return TripUpdateRequest(
      status: TripStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['status'],
        orElse: () => TripStatus.accepted,
      ),
      loadingStartTime: json['loading_start_time'] != null
          ? DateTime.parse(json['loading_start_time'] as String)
          : null,
      loadingEndTime: json['loading_end_time'] != null
          ? DateTime.parse(json['loading_end_time'] as String)
          : null,
      unloadingStartTime: json['unloading_start_time'] != null
          ? DateTime.parse(json['unloading_start_time'] as String)
          : null,
      unloadingEndTime: json['unloading_end_time'] != null
          ? DateTime.parse(json['unloading_end_time'] as String)
          : null,
      paymentTime: json['payment_time'] != null
          ? DateTime.parse(json['payment_time'] as String)
          : null,
      finalFare: (json['final_fare'] as num).toDouble(),
      finalDuration: json['final_duration'] as int?,
      finalDistance: json['final_distance'] as String?,
      isPaymentDone: json['is_payment_done'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last.toUpperCase(),
      'loading_start_time': loadingStartTime?.toIso8601String(),
      'loading_end_time': loadingEndTime?.toIso8601String(),
      'unloading_start_time': unloadingStartTime?.toIso8601String(),
      'unloading_end_time': unloadingEndTime?.toIso8601String(),
      'payment_time': paymentTime?.toIso8601String(),
      'final_fare': finalFare,
      'final_duration': finalDuration,
      'final_distance': finalDistance,
      'is_payment_done': isPaymentDone,
    };
  }

  @override
  List<Object?> get props => [
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
      ];
}

class PaginatedTripList extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<Trip> results;

  const PaginatedTripList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedTripList.fromJson(Map<String, dynamic> json) {
    return PaginatedTripList(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => Trip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [count, next, previous, results];
}