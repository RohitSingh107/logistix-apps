import 'stop_point_request.dart';
import 'stop_point.dart';

class BookingRequest {
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
  final DateTime pickupTime;
  final int vehicleTypeId;
  final String goodsType;
  final String goodsQuantity;
  final String paymentMode;
  final List<StopPointRequest> stopPoints;

  BookingRequest({
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
    required this.pickupTime,
    required this.vehicleTypeId,
    required this.goodsType,
    required this.goodsQuantity,
    required this.paymentMode,
    required this.stopPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_name': senderName,
      'receiver_name': receiverName,
      'sender_phone': senderPhone,
      'receiver_phone': receiverPhone,
      'pickup_time': pickupTime.toIso8601String(),
      'vehicle_type_id': vehicleTypeId,
      'goods_type': goodsType,
      'goods_quantity': goodsQuantity,
      'payment_mode': paymentMode,
      'stop_points': stopPoints.map((stop) => stop.toJson()).toList(),
    };
  }
}

class BookingResponse {
  final int id;
  final int? tripId; // Only present when status is ACCEPTED
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

  BookingResponse({
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

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested response structure - data is under 'booking_request' key
    try {
      final bookingData = json['booking_request'] as Map<String, dynamic>;
      
      return BookingResponse(
        id: bookingData['id'] as int? ?? 0,
        tripId: bookingData['trip_id'] != null ? bookingData['trip_id'] as int : null,
        senderName: bookingData['sender_name'] as String? ?? '',
        receiverName: bookingData['receiver_name'] as String? ?? '',
        senderPhone: bookingData['sender_phone'] as String? ?? '',
        receiverPhone: bookingData['receiver_phone'] as String? ?? '',
        pickupTime: DateTime.parse(bookingData['pickup_time'] as String? ?? DateTime.now().toIso8601String()),
        goodsType: bookingData['goods_type'] as String? ?? '',
        goodsQuantity: bookingData['goods_quantity'] as String? ?? '',
        paymentMode: bookingData['payment_mode'] as String? ?? 'CASH',
        estimatedFare: (bookingData['estimated_fare'] as num?)?.toDouble() ?? 0.0,
        status: bookingData['status'] as String? ?? 'REQUESTED',
        instructions: bookingData['instructions'] as String? ?? '',
        stopPoints: () {
          final stopPointsData = bookingData['stop_points'];
          
          if (stopPointsData == null) {
            return <StopPoint>[];
          }
          
          final stopPointsList = stopPointsData as List<dynamic>;
          
          return stopPointsList.map((stopPoint) {
            try {
              return StopPoint.fromJson(stopPoint as Map<String, dynamic>);
            } catch (e) {
              // Return a default stop point if parsing fails
              return StopPoint(
                id: 0,
                location: 'POINT (0 0)',
                address: 'Unknown Address',
                stopOrder: 0,
                stopType: 'WAYPOINT',
                contactName: '',
                contactPhone: '',
                notes: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
            }
          }).toList();
        }(),
        createdAt: DateTime.parse(bookingData['created_at'] as String? ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(bookingData['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      // Return a default BookingResponse instead of rethrowing
      return BookingResponse(
        id: 0,
        tripId: null,
        senderName: 'Unknown',
        receiverName: 'Unknown',
        senderPhone: '',
        receiverPhone: '',
        pickupTime: DateTime.now(),
        goodsType: 'Unknown',
        goodsQuantity: '',
        paymentMode: 'CASH',
        estimatedFare: 0.0,
        status: 'REQUESTED',
        instructions: '',
        stopPoints: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
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
        return 'Booking Requested';
      case 'SEARCHING':
        return 'Searching for Driver';
      case 'ACCEPTED':
        return 'Accepted by Driver';
      case 'CANCELLED':
        return 'Booking Cancelled';
      case 'DRIVERS_NOT_FOUND':
        return 'No Drivers Available';
      default:
        return status;
    }
  }

  // Get pickup address from stop points
  String get pickupAddress {
    if (stopPoints.isEmpty) return 'Unknown';
    
    try {
      final pickupStop = stopPoints.firstWhere(
        (stop) => stop.isPickup || stop.stopOrder == 0,
        orElse: () => stopPoints.first,
      );
      return pickupStop.address;
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get dropoff address from stop points
  String get dropoffAddress {
    if (stopPoints.isEmpty) return 'Unknown';
    
    try {
      final dropoffStop = stopPoints.firstWhere(
        (stop) => stop.isDropoff || stop.stopOrder == stopPoints.length - 1,
        orElse: () => stopPoints.last,
      );
      return dropoffStop.address;
    } catch (e) {
      return 'Unknown';
    }
  }
} 