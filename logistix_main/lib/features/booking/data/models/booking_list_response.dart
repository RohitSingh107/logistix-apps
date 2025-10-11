import 'package:flutter/material.dart';
import 'stop_point.dart';

class BookingListItem {
  final int id;
  final int? tripId;
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
  final DateTime pickupTime;
  final String goodsType;
  final String goodsQuantity;
  final String paymentMode;
  final double estimatedFare;
  final String status;
  final String instructions;
  final List<StopPoint> stopPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingListItem({
    required this.id,
    this.tripId,
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
    required this.pickupTime,
    required this.goodsType,
    required this.goodsQuantity,
    required this.paymentMode,
    required this.estimatedFare,
    required this.status,
    required this.instructions,
    required this.stopPoints,
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
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      goodsType: json['goods_type'] as String,
      goodsQuantity: json['goods_quantity'] as String,
      paymentMode: json['payment_mode'] as String,
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      status: json['status'] as String,
      instructions: json['instructions'] as String? ?? '',
      stopPoints: (json['stop_points'] as List<dynamic>?)
          ?.map((stopPoint) => StopPoint.fromJson(stopPoint as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Helper methods to check status
  bool get isRequested => status == 'REQUESTED';
  bool get isSearching => status == 'SEARCHING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isDriversNotFound => status == 'DRIVERS_NOT_FOUND';

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
      case 'DRIVERS_NOT_FOUND':
        return 'No Drivers Available';
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
      case 'DRIVERS_NOT_FOUND':
        return const Color(0xFFFF5722); // Deep Orange
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  // Get pickup address from stop points
  String get pickupAddress {
    final pickupStop = stopPoints.firstWhere(
      (stop) => stop.isPickup || stop.stopOrder == 0,
      orElse: () => stopPoints.isNotEmpty ? stopPoints.first : StopPoint(
        id: 0,
        location: '',
        address: 'Unknown',
        stopOrder: 0,
        stopType: 'PICKUP',
        contactName: '',
        contactPhone: '',
        notes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return pickupStop.address;
  }

  // Get dropoff address from stop points
  String get dropoffAddress {
    final dropoffStop = stopPoints.firstWhere(
      (stop) => stop.isDropoff || stop.stopOrder == stopPoints.length - 1,
      orElse: () => stopPoints.isNotEmpty ? stopPoints.last : StopPoint(
        id: 0,
        location: '',
        address: 'Unknown',
        stopOrder: 0,
        stopType: 'DROPOFF',
        contactName: '',
        contactPhone: '',
        notes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return dropoffStop.address;
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
  final int count;
  final String? next;
  final String? previous;
  final List<BookingListItem> results;

  BookingListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((item) => BookingListItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // Helper method to check if there are more pages
  bool get hasNext => next != null && next!.isNotEmpty;
  
  // Helper method to get next page number
  int? get nextPageNumber {
    if (next == null) return null;
    final uri = Uri.parse(next!);
    final pageParam = uri.queryParameters['page'];
    return pageParam != null ? int.tryParse(pageParam) : null;
  }
} 