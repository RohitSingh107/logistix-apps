// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingRequest _$BookingRequestFromJson(Map<String, dynamic> json) =>
    BookingRequest(
      id: (json['id'] as num).toInt(),
      senderName: json['senderName'] as String,
      receiverName: json['receiverName'] as String,
      senderPhone: json['senderPhone'] as String,
      receiverPhone: json['receiverPhone'] as String,
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      pickupAddress: json['pickup_address'] as String,
      dropoffAddress: json['dropoff_address'] as String,
      goodsType: json['goods_type'] as String,
      goodsQuantity: json['goods_quantity'] as String,
      paymentMode: $enumDecode(_$PaymentModeEnumMap, json['payment_mode']),
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BookingRequestToJson(BookingRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderName': instance.senderName,
      'receiverName': instance.receiverName,
      'senderPhone': instance.senderPhone,
      'receiverPhone': instance.receiverPhone,
      'pickup_time': instance.pickupTime.toIso8601String(),
      'pickup_address': instance.pickupAddress,
      'dropoff_address': instance.dropoffAddress,
      'goods_type': instance.goodsType,
      'goods_quantity': instance.goodsQuantity,
      'payment_mode': _$PaymentModeEnumMap[instance.paymentMode]!,
      'estimated_fare': instance.estimatedFare,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$PaymentModeEnumMap = {
  PaymentMode.cash: 'CASH',
  PaymentMode.wallet: 'WALLET',
};

const _$BookingStatusEnumMap = {
  BookingStatus.requested: 'REQUESTED',
  BookingStatus.searching: 'SEARCHING',
  BookingStatus.accepted: 'ACCEPTED',
  BookingStatus.cancelled: 'CANCELLED',
};

BookingAcceptRequest _$BookingAcceptRequestFromJson(
        Map<String, dynamic> json) =>
    BookingAcceptRequest(
      bookingRequestId: (json['bookingRequestId'] as num).toInt(),
    );

Map<String, dynamic> _$BookingAcceptRequestToJson(
        BookingAcceptRequest instance) =>
    <String, dynamic>{
      'bookingRequestId': instance.bookingRequestId,
    };
