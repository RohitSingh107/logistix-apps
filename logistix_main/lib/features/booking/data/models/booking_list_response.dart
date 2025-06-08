import 'package:flutter/material.dart';

class BookingListItem {
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
  final String paymentMode;
  final double estimatedFare;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingListItem({
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

  factory BookingListItem.fromJson(Map<String, dynamic> json) {
    return BookingListItem(
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
      paymentMode: json['payment_mode'] as String,
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Helper methods to check status
  bool get isRequested => status == 'REQUESTED';
  bool get isSearching => status == 'SEARCHING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isCancelled => status == 'CANCELLED';

  // Helper method to get user-friendly status message
  String get statusMessage {
    switch (status) {
      case 'REQUESTED':
        return 'Requested';
      case 'SEARCHING':
        return 'Finding Driver';
      case 'ACCEPTED':
        return 'Accepted';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Helper method to get status color
  Color get statusColor {
    switch (status) {
      case 'REQUESTED':
        return const Color(0xFFFF9800); // Orange
      case 'SEARCHING':
        return const Color(0xFF2196F3); // Blue
      case 'ACCEPTED':
        return const Color(0xFF4CAF50); // Green
      case 'CANCELLED':
        return const Color(0xFFE91E63); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  // Get short pickup address
  String get shortPickupAddress {
    final parts = pickupAddress.split(',');
    return parts.length > 2 ? '${parts[0]}, ${parts[1]}' : pickupAddress;
  }

  // Get short dropoff address
  String get shortDropoffAddress {
    final parts = dropoffAddress.split(',');
    return parts.length > 2 ? '${parts[0]}, ${parts[1]}' : dropoffAddress;
  }
}

class BookingListResponse {
  final List<BookingListItem> bookingRequests;

  BookingListResponse({
    required this.bookingRequests,
  });

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      bookingRequests: (json['booking_requests'] as List)
          .map((item) => BookingListItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
} 