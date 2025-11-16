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
import 'stop_point_model.dart';
import 'trip_update_model.dart';

part 'trip_model.g.dart';

enum TripStatus {
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('IN_PROGRESS')
  inProgress,
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
  final int? finalDuration;
  @JsonKey(name: 'final_distance')
  final String? finalDistance;
  @JsonKey(name: 'is_payment_done')
  final bool isPaymentDone;
  @JsonKey(name: 'stop_points')
  final List<StopPoint>? stopPoints;
  final List<TripUpdate>? updates;
  @JsonKey(name: 'updates_count', fromJson: _updatesCountFromJson, toJson: _updatesCountToJson)
  final String? updatesCount;
  @JsonKey(name: 'latest_update', fromJson: _latestUpdateFromJson, toJson: _latestUpdateToJson)
  final String? latestUpdate;
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
    this.stopPoints,
    this.updates,
    this.updatesCount,
    this.latestUpdate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TripToJson(this);

  /// Convert updates_count from API format (int or String) to String
  static String? _updatesCountFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is num) return json.toString();
    return json.toString();
  }

  /// Convert updates_count String to API format
  static dynamic _updatesCountToJson(String? updatesCount) {
    if (updatesCount == null) return null;
    return int.tryParse(updatesCount) ?? updatesCount;
  }

  /// Convert latest_update from API format (int or String) to String
  static String? _latestUpdateFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is num) return json.toString();
    return json.toString();
  }

  /// Convert latest_update String to API format
  static dynamic _latestUpdateToJson(String? latestUpdate) {
    return latestUpdate;
  }

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
    int? finalDuration,
    String? finalDistance,
    bool? isPaymentDone,
    List<StopPoint>? stopPoints,
    List<TripUpdate>? updates,
    String? updatesCount,
    String? latestUpdate,
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
      stopPoints: stopPoints ?? this.stopPoints,
      updates: updates ?? this.updates,
      updatesCount: updatesCount ?? this.updatesCount,
      latestUpdate: latestUpdate ?? this.latestUpdate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if trip is accepted
  bool get isAccepted => status == TripStatus.accepted;

  /// Check if trip is started
  bool get isStarted => status == TripStatus.inProgress;

  /// Check if trip is completed
  bool get isCompleted => status == TripStatus.completed;

  /// Check if trip is cancelled
  bool get isCancelled => status == TripStatus.cancelled;

  /// Get trip status display text
  String get statusText {
    switch (status) {
      case TripStatus.accepted:
        return 'Accepted';
      case TripStatus.inProgress:
        return 'In Progress';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get formatted final fare
  String get formattedFinalFare => finalFare != null ? '₹${finalFare!.toStringAsFixed(2)}' : 'N/A';

  /// Get formatted final duration
  String get formattedFinalDuration => finalDuration != null ? '$finalDuration mins' : 'N/A';

  /// Get formatted final distance
  String get formattedFinalDistance => finalDistance != null ? '$finalDistance km' : 'N/A';

  /// Get stop points count
  int get stopPointsCount => stopPoints?.length ?? 0;

  /// Get updates count
  int get totalUpdates {
    if (updatesCount == null) return 0;
    return int.tryParse(updatesCount!) ?? 0;
  }

  /// Get latest update message
  String get latestUpdateMessage => latestUpdate ?? 'No updates available';

  /// Get formatted latest update time
  String get latestUpdateTime => latestUpdate ?? 'N/A';

  /// Check if trip has stop points
  bool get hasStopPoints => stopPoints != null && stopPoints!.isNotEmpty;

  /// Check if trip has updates
  bool get hasUpdates => updates != null && updates!.isNotEmpty;
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
  @JsonKey(name: 'update_message')
  final String? updateMessage;

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
    this.updateMessage,
  });

  factory TripUpdateRequest.fromJson(Map<String, dynamic> json) => _$TripUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TripUpdateRequestToJson(this);
}

@JsonSerializable()
class PatchedTripUpdateRequest {
  final TripStatus? status;
  @JsonKey(name: 'final_fare')
  final double? finalFare;
  @JsonKey(name: 'final_duration')
  final int? finalDuration;
  @JsonKey(name: 'final_distance')
  final String? finalDistance;
  @JsonKey(name: 'is_payment_done')
  final bool? isPaymentDone;
  @JsonKey(name: 'update_message')
  final String? updateMessage;

  const PatchedTripUpdateRequest({
    this.status,
    this.finalFare,
    this.finalDuration,
    this.finalDistance,
    this.isPaymentDone,
    this.updateMessage,
  });

  factory PatchedTripUpdateRequest.fromJson(Map<String, dynamic> json) => _$PatchedTripUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PatchedTripUpdateRequestToJson(this);
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