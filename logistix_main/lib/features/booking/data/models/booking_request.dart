class BookingRequest {
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
  final String paymentMode;
  final double estimatedFare;

  BookingRequest({
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
      'payment_mode': paymentMode,
      'estimated_fare': estimatedFare,
    };
  }
}

class BookingResponse {
  final int id;
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
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

  BookingResponse({
    required this.id,
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
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

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested response structure - data is under 'booking_request' key
    final bookingData = json['booking_request'] as Map<String, dynamic>;
    
    return BookingResponse(
      id: bookingData['id'] as int,
      senderName: bookingData['sender_name'] as String,
      receiverName: bookingData['receiver_name'] as String,
      senderPhone: bookingData['sender_phone'] as String,
      receiverPhone: bookingData['receiver_phone'] as String,
      pickupTime: DateTime.parse(bookingData['pickup_time'] as String),
      pickupAddress: bookingData['pickup_address'] as String,
      dropoffAddress: bookingData['dropoff_address'] as String,
      goodsType: bookingData['goods_type'] as String,
      goodsQuantity: bookingData['goods_quantity'] as String,
      paymentMode: bookingData['payment_mode'] as String,
      estimatedFare: (bookingData['estimated_fare'] as num).toDouble(),
      status: bookingData['status'] as String,
      createdAt: DateTime.parse(bookingData['created_at'] as String),
      updatedAt: DateTime.parse(bookingData['updated_at'] as String),
    );
  }
} 