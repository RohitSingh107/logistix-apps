/**
 * booking_model.dart - Booking Model
 * 
 * Purpose:
 * - Represents a booking request in the system
 * - Contains booking details, sender/receiver info, and trip details
 * - Used for ride requests and booking management
 * 
 * Key Logic:
 * - Booking request creation and management
 * - Booking status tracking
 * - Sender and receiver information
 * - Payment and timing details
 */

import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'booking_model.g.dart';

enum BookingStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('COMPLETED')
  completed,
}

enum PaymentMode {
  @JsonValue('CASH')
  cash,
  @JsonValue('WALLET')
  wallet,
  @JsonValue('CARD')
  card,
  @JsonValue('UPI')
  upi,
}

@JsonSerializable()
class Booking extends BaseModel {
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

  const Booking({
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

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);

  /// Create a copy of this booking with updated fields
  Booking copyWith({
    int? id,
    int? tripId,
    String? senderName,
    String? receiverName,
    String? senderPhone,
    String? receiverPhone,
    String? pickupLocation,
    String? dropoffLocation,
    DateTime? pickupTime,
    String? pickupAddress,
    String? dropoffAddress,
    String? goodsType,
    String? goodsQuantity,
    PaymentMode? paymentMode,
    double? estimatedFare,
    BookingStatus? status,
    String? instructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      senderPhone: senderPhone ?? this.senderPhone,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupTime: pickupTime ?? this.pickupTime,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      goodsType: goodsType ?? this.goodsType,
      goodsQuantity: goodsQuantity ?? this.goodsQuantity,
      paymentMode: paymentMode ?? this.paymentMode,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      status: status ?? this.status,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if booking is available for acceptance
  bool get isAvailable => status == BookingStatus.pending;

  /// Check if booking is accepted
  bool get isAccepted => status == BookingStatus.accepted;

  /// Check if booking is completed
  bool get isCompleted => status == BookingStatus.completed;

  /// Check if booking is cancelled
  bool get isCancelled => status == BookingStatus.cancelled;

  /// Get formatted estimated fare
  String get formattedEstimatedFare => '₹${estimatedFare.toStringAsFixed(2)}';

  /// Get booking status display text
  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  /// Get payment mode display text
  String get paymentModeText {
    switch (paymentMode) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.wallet:
        return 'Wallet';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.upi:
        return 'UPI';
    }
  }

  /// Get pickup time formatted
  String get formattedPickupTime {
    return '${pickupTime.hour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get pickup date formatted
  String get formattedPickupDate {
    return '${pickupTime.day}/${pickupTime.month}/${pickupTime.year}';
  }

  /// Get short pickup address (first 2 parts)
  String get shortPickupAddress {
    final parts = pickupAddress.split(',');
    return parts.take(2).join(',');
  }

  /// Get short dropoff address (first 2 parts)
  String get shortDropoffAddress {
    final parts = dropoffAddress.split(',');
    return parts.take(2).join(',');
  }
} 