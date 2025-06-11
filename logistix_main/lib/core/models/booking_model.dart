/**
 * booking_model.dart - Booking and Trip Request Data Models
 * 
 * Purpose:
 * - Defines data models for booking and trip request functionality
 * - Handles serialization for booking-related API communication
 * - Manages booking states and payment modes through enums
 * 
 * Key Logic:
 * - BookingRequest: Core booking entity with complete booking information
 * - BookingRequestRequest: Payload for creating new booking requests
 * - BookingAcceptRequest/Response: Models for driver accepting bookings
 * - BookingStatus enum: Tracks booking lifecycle (requested, searching, accepted, cancelled)
 * - PaymentMode enum: Defines payment options (cash, wallet)
 * - Uses JSON serialization with snake_case field mapping
 * - Extends BaseModel for consistent model behavior
 * - Includes comprehensive booking details (pickup, dropoff, goods, pricing)
 */

import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';
import 'trip_model.dart';

part 'booking_model.g.dart';

enum BookingStatus {
  @JsonValue('REQUESTED')
  requested,
  @JsonValue('SEARCHING')
  searching,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('CANCELLED')
  cancelled,
}

enum PaymentMode {
  @JsonValue('CASH')
  cash,
  @JsonValue('WALLET')
  wallet,
}

@JsonSerializable()
class BookingRequest extends BaseModel {
  final int id;
  @JsonKey(name: 'trip_id')
  final int? tripId;
  @JsonKey(name: 'sender_name')
  final String senderName;
  @JsonKey(name: 'receiver_name')
  final String receiverName;
  @JsonKey(name: 'sender_phone')
  final String senderPhone;
  @JsonKey(name: 'receiver_phone')
  final String receiverPhone;
  @JsonKey(name: 'pickup_location')
  final String pickupLocation;
  @JsonKey(name: 'dropoff_location')
  final String dropoffLocation;
  @JsonKey(name: 'pickup_time')
  final DateTime pickupTime;
  @JsonKey(name: 'pickup_address')
  final String pickupAddress;
  @JsonKey(name: 'dropoff_address')
  final String dropoffAddress;
  @JsonKey(name: 'goods_type')
  final String goodsType;
  @JsonKey(name: 'goods_quantity')
  final String goodsQuantity;
  @JsonKey(name: 'payment_mode')
  final PaymentMode paymentMode;
  @JsonKey(name: 'estimated_fare')
  final double estimatedFare;
  final BookingStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) => _$BookingRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingRequestToJson(this);

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
        createdAt,
        updatedAt,
      ];
}

@JsonSerializable()
class BookingRequestRequest {
  @JsonKey(name: 'sender_name')
  final String senderName;
  @JsonKey(name: 'receiver_name')
  final String receiverName;
  @JsonKey(name: 'sender_phone')
  final String senderPhone;
  @JsonKey(name: 'receiver_phone')
  final String receiverPhone;
  @JsonKey(name: 'pickup_latitude')
  final double pickupLatitude;
  @JsonKey(name: 'pickup_longitude')
  final double pickupLongitude;
  @JsonKey(name: 'dropoff_latitude')
  final double dropoffLatitude;
  @JsonKey(name: 'dropoff_longitude')
  final double dropoffLongitude;
  @JsonKey(name: 'pickup_time')
  final DateTime pickupTime;
  @JsonKey(name: 'pickup_address')
  final String pickupAddress;
  @JsonKey(name: 'dropoff_address')
  final String dropoffAddress;
  @JsonKey(name: 'vehicle_type_id')
  final int vehicleTypeId;
  @JsonKey(name: 'goods_type')
  final String goodsType;
  @JsonKey(name: 'goods_quantity')
  final String goodsQuantity;
  @JsonKey(name: 'payment_mode')
  final PaymentMode paymentMode;
  @JsonKey(name: 'estimated_fare')
  final double estimatedFare;

  BookingRequestRequest({
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
    required this.estimatedFare,
  });

  factory BookingRequestRequest.fromJson(Map<String, dynamic> json) => _$BookingRequestRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BookingRequestRequestToJson(this);
}

@JsonSerializable()
class BookingAcceptRequest {
  @JsonKey(name: 'booking_request_id')
  final int bookingRequestId;

  BookingAcceptRequest({
    required this.bookingRequestId,
  });

  factory BookingAcceptRequest.fromJson(Map<String, dynamic> json) => _$BookingAcceptRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BookingAcceptRequestToJson(this);
}

@JsonSerializable()
class BookingAcceptResponse {
  final String message;
  final Trip trip;

  BookingAcceptResponse({
    required this.message,
    required this.trip,
  });

  factory BookingAcceptResponse.fromJson(Map<String, dynamic> json) => _$BookingAcceptResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BookingAcceptResponseToJson(this);
} 