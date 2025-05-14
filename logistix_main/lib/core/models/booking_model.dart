import 'package:equatable/equatable.dart';
import 'base_model.dart';

enum BookingStatus {
  requested,
  searching,
  accepted,
  cancelled,
}

enum PaymentMode {
  cash,
  wallet,
}

class BookingRequest extends BaseModel {
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
  final PaymentMode paymentMode;
  final double estimatedFare;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingRequest({
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

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      id: json['id'],
      senderName: json['sender_name'],
      receiverName: json['receiver_name'],
      senderPhone: json['sender_phone'],
      receiverPhone: json['receiver_phone'],
      pickupTime: DateTime.parse(json['pickup_time']),
      pickupAddress: json['pickup_address'],
      dropoffAddress: json['dropoff_address'],
      goodsType: json['goods_type'],
      goodsQuantity: json['goods_quantity'],
      paymentMode: PaymentMode.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['payment_mode'],
      ),
      estimatedFare: json['estimated_fare'].toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['status'],
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_name': senderName,
      'receiver_name': receiverName,
      'sender_phone': senderPhone,
      'receiver_phone': receiverPhone,
      'pickup_time': pickupTime.toIso8601String(),
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'goods_type': goodsType,
      'goods_quantity': goodsQuantity,
      'payment_mode': paymentMode.toString().split('.').last.toUpperCase(),
      'estimated_fare': estimatedFare,
      'status': status.toString().split('.').last.toUpperCase(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        senderName,
        receiverName,
        senderPhone,
        receiverPhone,
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