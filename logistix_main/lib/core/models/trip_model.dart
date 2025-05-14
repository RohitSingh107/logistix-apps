import 'package:equatable/equatable.dart';
import 'base_model.dart';
import 'booking_model.dart';
import 'user_model.dart';

enum TripStatus {
  accepted,
  loadingPending,
  loadingStarted,
  loadingDone,
  reachedDestination,
  unloadingStarted,
  unloadingDone,
  completed,
  cancelled,
}

class Trip extends BaseModel {
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
    required this.finalFare,
    this.finalDuration,
    this.finalDistance,
    required this.isPaymentDone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      driver: Driver.fromJson(json['driver']),
      bookingRequest: BookingRequest.fromJson(json['booking_request']),
      status: TripStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['status'],
      ),
      loadingStartTime: json['loading_start_time'] != null
          ? DateTime.parse(json['loading_start_time'])
          : null,
      loadingEndTime: json['loading_end_time'] != null
          ? DateTime.parse(json['loading_end_time'])
          : null,
      unloadingStartTime: json['unloading_start_time'] != null
          ? DateTime.parse(json['unloading_start_time'])
          : null,
      unloadingEndTime: json['unloading_end_time'] != null
          ? DateTime.parse(json['unloading_end_time'])
          : null,
      paymentTime: json['payment_time'] != null
          ? DateTime.parse(json['payment_time'])
          : null,
      finalFare: json['final_fare'].toDouble(),
      finalDuration: json['final_duration'],
      finalDistance: json['final_distance']?.toDouble(),
      isPaymentDone: json['is_payment_done'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
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