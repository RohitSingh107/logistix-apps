// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
      id: (json['id'] as num).toInt(),
      tripId: (json['trip_id'] as num?)?.toInt(),
      senderName: json['sender_name'] as String,
      receiverName: json['receiver_name'] as String,
      senderPhone: json['sender_phone'] as String,
      receiverPhone: json['receiver_phone'] as String,
      pickupLocation: json['pickup_location'] as String?,
      dropoffLocation: json['dropoff_location'] as String?,
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      pickupAddress: json['pickup_address'] as String?,
      dropoffAddress: json['dropoff_address'] as String?,
      goodsType: json['goods_type'] as String,
      goodsQuantity: json['goods_quantity'] as String,
      paymentMode: $enumDecode(_$PaymentModeEnumMap, json['payment_mode']),
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      instructions: json['instructions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
      'id': instance.id,
      'trip_id': instance.tripId,
      'sender_name': instance.senderName,
      'receiver_name': instance.receiverName,
      'sender_phone': instance.senderPhone,
      'receiver_phone': instance.receiverPhone,
      'pickup_location': instance.pickupLocation,
      'dropoff_location': instance.dropoffLocation,
      'pickup_time': instance.pickupTime.toIso8601String(),
      'pickup_address': instance.pickupAddress,
      'dropoff_address': instance.dropoffAddress,
      'goods_type': instance.goodsType,
      'goods_quantity': instance.goodsQuantity,
      'payment_mode': _$PaymentModeEnumMap[instance.paymentMode]!,
      'estimated_fare': instance.estimatedFare,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'instructions': instance.instructions,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$PaymentModeEnumMap = {
  PaymentMode.cash: 'CASH',
  PaymentMode.wallet: 'WALLET',
  PaymentMode.card: 'CARD',
  PaymentMode.upi: 'UPI',
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'PENDING',
  BookingStatus.accepted: 'ACCEPTED',
  BookingStatus.rejected: 'REJECTED',
  BookingStatus.cancelled: 'CANCELLED',
  BookingStatus.completed: 'COMPLETED',
};
