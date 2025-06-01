// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
      id: (json['id'] as num).toInt(),
      driver: Driver.fromJson(json['driver'] as Map<String, dynamic>),
      bookingRequest: BookingRequest.fromJson(
          json['booking_request'] as Map<String, dynamic>),
      status: $enumDecode(_$TripStatusEnumMap, json['status']),
      loadingStartTime: json['loading_start_time'] == null
          ? null
          : DateTime.parse(json['loading_start_time'] as String),
      loadingEndTime: json['loading_end_time'] == null
          ? null
          : DateTime.parse(json['loading_end_time'] as String),
      unloadingStartTime: json['unloading_start_time'] == null
          ? null
          : DateTime.parse(json['unloading_start_time'] as String),
      unloadingEndTime: json['unloading_end_time'] == null
          ? null
          : DateTime.parse(json['unloading_end_time'] as String),
      paymentTime: json['payment_time'] == null
          ? null
          : DateTime.parse(json['payment_time'] as String),
      finalFare: (json['final_fare'] as num).toDouble(),
      finalDuration: (json['final_duration'] as num?)?.toInt(),
      finalDistance: (json['final_distance'] as num?)?.toDouble(),
      isPaymentDone: json['is_payment_done'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
      'id': instance.id,
      'driver': instance.driver,
      'booking_request': instance.bookingRequest,
      'status': _$TripStatusEnumMap[instance.status]!,
      'loading_start_time': instance.loadingStartTime?.toIso8601String(),
      'loading_end_time': instance.loadingEndTime?.toIso8601String(),
      'unloading_start_time': instance.unloadingStartTime?.toIso8601String(),
      'unloading_end_time': instance.unloadingEndTime?.toIso8601String(),
      'payment_time': instance.paymentTime?.toIso8601String(),
      'final_fare': instance.finalFare,
      'final_duration': instance.finalDuration,
      'final_distance': instance.finalDistance,
      'is_payment_done': instance.isPaymentDone,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$TripStatusEnumMap = {
  TripStatus.accepted: 'ACCEPTED',
  TripStatus.loadingPending: 'LOADING_PENDING',
  TripStatus.loadingStarted: 'LOADING_STARTED',
  TripStatus.loadingDone: 'LOADING_DONE',
  TripStatus.reachedDestination: 'REACHED_DESTINATION',
  TripStatus.unloadingStarted: 'UNLOADING_STARTED',
  TripStatus.unloadingDone: 'UNLOADING_DONE',
  TripStatus.completed: 'COMPLETED',
  TripStatus.cancelled: 'CANCELLED',
};

TripUpdateRequest _$TripUpdateRequestFromJson(Map<String, dynamic> json) =>
    TripUpdateRequest(
      status: $enumDecode(_$TripStatusEnumMap, json['status']),
      loadingStartTime: json['loading_start_time'] == null
          ? null
          : DateTime.parse(json['loading_start_time'] as String),
      loadingEndTime: json['loading_end_time'] == null
          ? null
          : DateTime.parse(json['loading_end_time'] as String),
      unloadingStartTime: json['unloading_start_time'] == null
          ? null
          : DateTime.parse(json['unloading_start_time'] as String),
      unloadingEndTime: json['unloading_end_time'] == null
          ? null
          : DateTime.parse(json['unloading_end_time'] as String),
      paymentTime: json['payment_time'] == null
          ? null
          : DateTime.parse(json['payment_time'] as String),
      finalFare: (json['final_fare'] as num).toDouble(),
      finalDuration: (json['final_duration'] as num?)?.toInt(),
      finalDistance: (json['final_distance'] as num?)?.toDouble(),
      isPaymentDone: json['is_payment_done'] as bool?,
    );

Map<String, dynamic> _$TripUpdateRequestToJson(TripUpdateRequest instance) =>
    <String, dynamic>{
      'status': _$TripStatusEnumMap[instance.status]!,
      'loading_start_time': instance.loadingStartTime?.toIso8601String(),
      'loading_end_time': instance.loadingEndTime?.toIso8601String(),
      'unloading_start_time': instance.unloadingStartTime?.toIso8601String(),
      'unloading_end_time': instance.unloadingEndTime?.toIso8601String(),
      'payment_time': instance.paymentTime?.toIso8601String(),
      'final_fare': instance.finalFare,
      'final_duration': instance.finalDuration,
      'final_distance': instance.finalDistance,
      'is_payment_done': instance.isPaymentDone,
    };
