// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingRequest _$BookingRequestFromJson(Map<String, dynamic> json) =>
    BookingRequest(
      id: (json['id'] as num).toInt(),
      tripId: (json['trip_id'] as num?)?.toInt(),
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
      paymentMode: $enumDecode(_$PaymentModeEnumMap, json['payment_mode']),
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      instructions: json['instructions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BookingRequestToJson(BookingRequest instance) =>
    <String, dynamic>{
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
};

const _$BookingStatusEnumMap = {
  BookingStatus.requested: 'REQUESTED',
  BookingStatus.searching: 'SEARCHING',
  BookingStatus.accepted: 'ACCEPTED',
  BookingStatus.cancelled: 'CANCELLED',
  BookingStatus.driversNotFound: 'DRIVERS_NOT_FOUND',
};

BookingRequestRequest _$BookingRequestRequestFromJson(
        Map<String, dynamic> json) =>
    BookingRequestRequest(
      senderName: json['sender_name'] as String,
      receiverName: json['receiver_name'] as String,
      senderPhone: json['sender_phone'] as String,
      receiverPhone: json['receiver_phone'] as String,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      pickupAddress: json['pickup_address'] as String,
      dropoffAddress: json['dropoff_address'] as String,
      vehicleTypeId: (json['vehicle_type_id'] as num).toInt(),
      goodsType: json['goods_type'] as String,
      goodsQuantity: json['goods_quantity'] as String,
      paymentMode: $enumDecode(_$PaymentModeEnumMap, json['payment_mode']),
      instructions: json['instructions'] as String,
    );

Map<String, dynamic> _$BookingRequestRequestToJson(
        BookingRequestRequest instance) =>
    <String, dynamic>{
      'sender_name': instance.senderName,
      'receiver_name': instance.receiverName,
      'sender_phone': instance.senderPhone,
      'receiver_phone': instance.receiverPhone,
      'pickup_latitude': instance.pickupLatitude,
      'pickup_longitude': instance.pickupLongitude,
      'dropoff_latitude': instance.dropoffLatitude,
      'dropoff_longitude': instance.dropoffLongitude,
      'pickup_time': instance.pickupTime.toIso8601String(),
      'pickup_address': instance.pickupAddress,
      'dropoff_address': instance.dropoffAddress,
      'vehicle_type_id': instance.vehicleTypeId,
      'goods_type': instance.goodsType,
      'goods_quantity': instance.goodsQuantity,
      'payment_mode': _$PaymentModeEnumMap[instance.paymentMode]!,
      'instructions': instance.instructions,
    };

BookingAcceptRequest _$BookingAcceptRequestFromJson(
        Map<String, dynamic> json) =>
    BookingAcceptRequest(
      bookingRequestId: (json['booking_request_id'] as num).toInt(),
    );

Map<String, dynamic> _$BookingAcceptRequestToJson(
        BookingAcceptRequest instance) =>
    <String, dynamic>{
      'booking_request_id': instance.bookingRequestId,
    };

BookingAcceptResponse _$BookingAcceptResponseFromJson(
        Map<String, dynamic> json) =>
    BookingAcceptResponse(
      message: json['message'] as String,
      trip: Trip.fromJson(json['trip'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookingAcceptResponseToJson(
        BookingAcceptResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'trip': instance.trip,
    };

BookingAccept _$BookingAcceptFromJson(Map<String, dynamic> json) =>
    BookingAccept(
      bookingRequestId: (json['booking_request_id'] as num).toInt(),
    );

Map<String, dynamic> _$BookingAcceptToJson(BookingAccept instance) =>
    <String, dynamic>{
      'booking_request_id': instance.bookingRequestId,
    };
