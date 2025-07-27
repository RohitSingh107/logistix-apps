// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
      id: (json['id'] as num).toInt(),
      tripId: (json['tripId'] as num?)?.toInt(),
      senderName: json['senderName'] as String,
      receiverName: json['receiverName'] as String,
      senderPhone: json['senderPhone'] as String,
      receiverPhone: json['receiverPhone'] as String,
      pickupLocation: json['pickupLocation'] as String,
      dropoffLocation: json['dropoffLocation'] as String,
      pickupTime: DateTime.parse(json['pickupTime'] as String),
      pickupAddress: json['pickupAddress'] as String,
      dropoffAddress: json['dropoffAddress'] as String,
      goodsType: json['goodsType'] as String,
      goodsQuantity: json['goodsQuantity'] as String,
      paymentMode: $enumDecode(_$PaymentModeEnumMap, json['paymentMode']),
      estimatedFare: (json['estimatedFare'] as num).toDouble(),
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      instructions: json['instructions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'senderName': instance.senderName,
      'receiverName': instance.receiverName,
      'senderPhone': instance.senderPhone,
      'receiverPhone': instance.receiverPhone,
      'pickupLocation': instance.pickupLocation,
      'dropoffLocation': instance.dropoffLocation,
      'pickupTime': instance.pickupTime.toIso8601String(),
      'pickupAddress': instance.pickupAddress,
      'dropoffAddress': instance.dropoffAddress,
      'goodsType': instance.goodsType,
      'goodsQuantity': instance.goodsQuantity,
      'paymentMode': _$PaymentModeEnumMap[instance.paymentMode]!,
      'estimatedFare': instance.estimatedFare,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'instructions': instance.instructions,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
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
