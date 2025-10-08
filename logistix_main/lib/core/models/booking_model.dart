/// booking_model.dart - Booking and Trip Request Data Models
/// 
/// Purpose:
/// - Defines data models for booking and trip request functionality
/// - Handles serialization for booking-related API communication
/// - Manages booking states and payment modes through enums
/// 
/// Key Logic:
/// - BookingRequest: Core booking entity with complete booking information
/// - BookingRequestRequest: Payload for creating new booking requests
/// - BookingAcceptRequest/Response: Models for driver accepting bookings
/// - BookingStatus enum: Tracks booking lifecycle (requested, searching, accepted, cancelled)
/// - PaymentMode enum: Defines payment options (cash, wallet)
/// - Uses JSON serialization with snake_case field mapping
/// - Extends BaseModel for consistent model behavior
/// - Includes comprehensive booking details (pickup, dropoff, goods, pricing)

import 'package:equatable/equatable.dart';
import 'trip_model.dart';

class BookingRequestModel extends Equatable {
  final int id;
  final int? tripId;
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
  final String pickupLocation; // Read-only string from API
  final String dropoffLocation; // Read-only string from API
  final DateTime pickupTime;
  final String status;
  final String pickupAddress;
  final String dropoffAddress;
  final String goodsType;
  final String goodsQuantity;
  final String paymentMode;
  final double estimatedFare;
  final String? instructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingRequestModel({
    required this.id,
    this.tripId,
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupTime,
    required this.status,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.goodsType,
    required this.goodsQuantity,
    required this.paymentMode,
    required this.estimatedFare,
    this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'] as int,
      tripId: json['trip_id'] != null ? json['trip_id'] as int : null,
      senderName: json['sender_name'] as String,
      receiverName: json['receiver_name'] as String,
      senderPhone: json['sender_phone'] as String,
      receiverPhone: json['receiver_phone'] as String,
      pickupLocation: json['pickup_location'] as String,
      dropoffLocation: json['dropoff_location'] as String,
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      status: json['status'] as String,
      pickupAddress: json['pickup_address'] as String,
      dropoffAddress: json['dropoff_address'] as String,
      goodsType: json['goods_type'] as String,
      goodsQuantity: json['goods_quantity'] as String,
      paymentMode: json['payment_mode'] as String,
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      instructions: json['instructions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'sender_name': senderName,
      'receiver_name': receiverName,
      'sender_phone': senderPhone,
      'receiver_phone': receiverPhone,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'pickup_time': pickupTime.toIso8601String(),
      'status': status,
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'goods_type': goodsType,
      'goods_quantity': goodsQuantity,
      'payment_mode': paymentMode,
      'estimated_fare': estimatedFare,
      'instructions': instructions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BookingRequestModel copyWith({
    int? id,
    int? tripId,
    String? senderName,
    String? receiverName,
    String? senderPhone,
    String? receiverPhone,
    String? pickupLocation,
    String? dropoffLocation,
    DateTime? pickupTime,
    String? status,
    String? pickupAddress,
    String? dropoffAddress,
    String? goodsType,
    String? goodsQuantity,
    String? paymentMode,
    double? estimatedFare,
    String? instructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingRequestModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      senderPhone: senderPhone ?? this.senderPhone,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupTime: pickupTime ?? this.pickupTime,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      goodsType: goodsType ?? this.goodsType,
      goodsQuantity: goodsQuantity ?? this.goodsQuantity,
      paymentMode: paymentMode ?? this.paymentMode,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tripId,
        senderName,
        receiverName,
        senderPhone,
        receiverPhone,
        pickupLocation,
        dropoffLocation,
        pickupTime,
        status,
        pickupAddress,
        dropoffAddress,
        goodsType,
        goodsQuantity,
        paymentMode,
        estimatedFare,
        instructions,
        createdAt,
        updatedAt,
      ];
}

enum BookingStatus {
  requested,
  searching,
  accepted,
  cancelled,
  driversNotFound,
}

enum PaymentMode {
  cash,
  wallet,
}

// Legacy classes for backward compatibility
class BookingRequest extends Equatable {
  final int id;
  final int? tripId;
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime pickupTime;
  final String pickupAddress;
  final String dropoffAddress;
  final String goodsType;
  final String goodsQuantity;
  final PaymentMode paymentMode;
  final double estimatedFare;
  final BookingStatus status;
  final String? instructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingRequest({
    required this.id,
    this.tripId,
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupTime,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.goodsType,
    required this.goodsQuantity,
    required this.paymentMode,
    required this.estimatedFare,
    required this.status,
    this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      id: json['id'] as int,
      tripId: json['trip_id'] as int?,
      senderName: json['sender_name'] as String,
      receiverName: json['receiver_name'] as String,
      senderPhone: json['sender_phone'] as String,
      receiverPhone: json['receiver_phone'] as String,
      pickupLocation: json['pickup_location'] as String,
      dropoffLocation: json['dropoff_location'] as String,
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      pickupAddress: json['pickup_address'] as String,
      dropoffAddress: json['dropoff_address'] as String,
      goodsType: json['goods_type'] as String,
      goodsQuantity: json['goods_quantity'] as String,
      paymentMode: PaymentMode.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['payment_mode'],
        orElse: () => PaymentMode.cash,
      ),
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['status'],
        orElse: () => BookingStatus.requested,
      ),
      instructions: json['instructions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'sender_name': senderName,
      'receiver_name': receiverName,
      'sender_phone': senderPhone,
      'receiver_phone': receiverPhone,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'pickup_time': pickupTime.toIso8601String(),
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'goods_type': goodsType,
      'goods_quantity': goodsQuantity,
      'payment_mode': paymentMode.toString().split('.').last.toUpperCase(),
      'estimated_fare': estimatedFare,
      'status': status.toString().split('.').last.toUpperCase(),
      'instructions': instructions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        tripId,
        senderName,
        receiverName,
        senderPhone,
        receiverPhone,
        pickupLocation,
        dropoffLocation,
        pickupTime,
        pickupAddress,
        dropoffAddress,
        goodsType,
        goodsQuantity,
        paymentMode,
        estimatedFare,
        status,
        instructions,
        createdAt,
        updatedAt,
      ];
}

class BookingRequestRequest extends Equatable {
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
  final double pickupLatitude;
  final double pickupLongitude;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final DateTime pickupTime;
  final String pickupAddress;
  final String dropoffAddress;
  final int vehicleTypeId;
  final String goodsType;
  final String goodsQuantity;
  final PaymentMode paymentMode;
  final String instructions;

  const BookingRequestRequest({
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.pickupTime,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.vehicleTypeId,
    required this.goodsType,
    required this.goodsQuantity,
    required this.paymentMode,
    required this.instructions,
  });

  factory BookingRequestRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequestRequest(
      senderName: json['sender_name'] as String,
      receiverName: json['receiver_name'] as String,
      senderPhone: json['sender_phone'] as String,
      receiverPhone: json['receiver_phone'] as String,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      pickupAddress: json['pickup_address'] as String,
      dropoffAddress: json['dropoff_address'] as String,
      vehicleTypeId: json['vehicle_type_id'] as int,
      goodsType: json['goods_type'] as String,
      goodsQuantity: json['goods_quantity'] as String,
      paymentMode: PaymentMode.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['payment_mode'],
        orElse: () => PaymentMode.cash,
      ),
      instructions: json['instructions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_name': senderName,
      'receiver_name': receiverName,
      'sender_phone': senderPhone,
      'receiver_phone': receiverPhone,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'pickup_time': pickupTime.toIso8601String(),
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'vehicle_type_id': vehicleTypeId,
      'goods_type': goodsType,
      'goods_quantity': goodsQuantity,
      'payment_mode': paymentMode.toString().split('.').last.toUpperCase(),
      'instructions': instructions,
    };
  }

  @override
  List<Object?> get props => [
        senderName,
        receiverName,
        senderPhone,
        receiverPhone,
        pickupLatitude,
        pickupLongitude,
        dropoffLatitude,
        dropoffLongitude,
        pickupTime,
        pickupAddress,
        dropoffAddress,
        vehicleTypeId,
        goodsType,
        goodsQuantity,
        paymentMode,
        instructions,
      ];
}

class BookingAcceptRequest extends Equatable {
  final int bookingRequestId;

  const BookingAcceptRequest({
    required this.bookingRequestId,
  });

  factory BookingAcceptRequest.fromJson(Map<String, dynamic> json) {
    return BookingAcceptRequest(
      bookingRequestId: json['booking_request_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_request_id': bookingRequestId,
    };
  }

  @override
  List<Object?> get props => [bookingRequestId];
}

class BookingAcceptResponse extends Equatable {
  final String message;
  final Trip trip;

  const BookingAcceptResponse({
    required this.message,
    required this.trip,
  });

  factory BookingAcceptResponse.fromJson(Map<String, dynamic> json) {
    return BookingAcceptResponse(
      message: json['message'] as String,
      trip: Trip.fromJson(json['trip'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'trip': trip.toJson(),
    };
  }

  @override
  List<Object?> get props => [message, trip];
} 