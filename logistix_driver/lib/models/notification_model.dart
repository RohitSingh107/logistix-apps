import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationModel {
  final String? title;
  final String? body;
  final DateTime? timestamp;
  final String? type;
  final int? bookingId;
  final String? paymentMode;
  final int? goodsQuantity;
  final double? estimatedFare;
  final String? pickupAddress;
  final DateTime? pickupTime;
  final String? goodsType;
  final String? dropoffAddress;

  NotificationModel({
    this.title,
    this.body,
    this.timestamp,
    this.type,
    this.bookingId,
    this.paymentMode,
    this.goodsQuantity,
    this.estimatedFare,
    this.pickupAddress,
    this.pickupTime,
    this.goodsType,
    this.dropoffAddress,
  });

  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    
    return NotificationModel(
      title: message.notification?.title,
      body: message.notification?.body,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (double.tryParse(data['timestamp'] ?? '0')?.toInt() ?? 0) * 1000
      ),
      type: data['type'],
      bookingId: int.tryParse(data['booking_id'] ?? '0'),
      paymentMode: data['payment_mode'],
      goodsQuantity: int.tryParse(data['goods_quantity'] ?? '0'),
      estimatedFare: double.tryParse(data['estimated_fare'] ?? '0'),
      pickupAddress: data['pickup_address'],
      pickupTime: DateTime.tryParse(data['pickup_time'] ?? ''),
      goodsType: data['goods_type'],
      dropoffAddress: data['dropoff_address'],
    );
  }
} 