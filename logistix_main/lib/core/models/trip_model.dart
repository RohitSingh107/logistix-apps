import 'package:equatable/equatable.dart';
import 'base_model.dart';
import 'booking_model.dart';
import 'user_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'driver_model.dart';

part 'trip_model.g.dart';

enum TripStatus {
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('LOADING_PENDING')
  loadingPending,
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
  final double? finalDistance;
  @JsonKey(name: 'is_payment_done')
  final bool isPaymentDone;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Trip({
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
  final double? finalDistance;
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

class Driver extends BaseModel {
  final int id;
  final User user;
  final String licenseNumber;
  final bool isAvailable;
  final double averageRating;
  final double totalEarnings;

  const Driver({
    required this.id,
    required this.user,
    required this.licenseNumber,
    required this.isAvailable,
    required this.averageRating,
    required this.totalEarnings,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      user: User.fromJson(json['user']),
      licenseNumber: json['license_number'],
      isAvailable: json['is_available'],
      averageRating: double.parse(json['average_rating']),
      totalEarnings: json['total_earnings'].toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'license_number': licenseNumber,
      'is_available': isAvailable,
      'average_rating': averageRating.toString(),
      'total_earnings': totalEarnings,
    };
  }

  @override
  List<Object?> get props => [
        id,
        user,
        licenseNumber,
        isAvailable,
        averageRating,
        totalEarnings,
      ];
} 