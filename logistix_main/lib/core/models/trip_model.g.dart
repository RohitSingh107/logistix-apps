// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
      id: (json['id'] as num).toInt(),
      driver: Driver.fromJson(json['driver'] as Map<String, dynamic>),
      bookingRequest: BookingRequest.fromJson(
          json['bookingRequest'] as Map<String, dynamic>),
      status: $enumDecode(_$TripStatusEnumMap, json['status']),
      loadingStartTime: json['loadingStartTime'] == null
          ? null
          : DateTime.parse(json['loadingStartTime'] as String),
      loadingEndTime: json['loadingEndTime'] == null
          ? null
          : DateTime.parse(json['loadingEndTime'] as String),
      unloadingStartTime: json['unloadingStartTime'] == null
          ? null
          : DateTime.parse(json['unloadingStartTime'] as String),
      unloadingEndTime: json['unloadingEndTime'] == null
          ? null
          : DateTime.parse(json['unloadingEndTime'] as String),
      paymentTime: json['paymentTime'] == null
          ? null
          : DateTime.parse(json['paymentTime'] as String),
      finalFare: (json['finalFare'] as num).toDouble(),
      finalDuration: (json['finalDuration'] as num?)?.toInt(),
      finalDistance: (json['finalDistance'] as num?)?.toDouble(),
      isPaymentDone: json['isPaymentDone'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
      'id': instance.id,
      'driver': instance.driver,
      'bookingRequest': instance.bookingRequest,
      'status': _$TripStatusEnumMap[instance.status]!,
      'loadingStartTime': instance.loadingStartTime?.toIso8601String(),
      'loadingEndTime': instance.loadingEndTime?.toIso8601String(),
      'unloadingStartTime': instance.unloadingStartTime?.toIso8601String(),
      'unloadingEndTime': instance.unloadingEndTime?.toIso8601String(),
      'paymentTime': instance.paymentTime?.toIso8601String(),
      'finalFare': instance.finalFare,
      'finalDuration': instance.finalDuration,
      'finalDistance': instance.finalDistance,
      'isPaymentDone': instance.isPaymentDone,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
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
      loadingStartTime: json['loadingStartTime'] == null
          ? null
          : DateTime.parse(json['loadingStartTime'] as String),
      loadingEndTime: json['loadingEndTime'] == null
          ? null
          : DateTime.parse(json['loadingEndTime'] as String),
      unloadingStartTime: json['unloadingStartTime'] == null
          ? null
          : DateTime.parse(json['unloadingStartTime'] as String),
      unloadingEndTime: json['unloadingEndTime'] == null
          ? null
          : DateTime.parse(json['unloadingEndTime'] as String),
      paymentTime: json['paymentTime'] == null
          ? null
          : DateTime.parse(json['paymentTime'] as String),
      finalFare: (json['finalFare'] as num).toDouble(),
      finalDuration: (json['finalDuration'] as num?)?.toInt(),
      finalDistance: (json['finalDistance'] as num?)?.toDouble(),
      isPaymentDone: json['isPaymentDone'] as bool?,
    );

Map<String, dynamic> _$TripUpdateRequestToJson(TripUpdateRequest instance) =>
    <String, dynamic>{
      'status': _$TripStatusEnumMap[instance.status]!,
      'loadingStartTime': instance.loadingStartTime?.toIso8601String(),
      'loadingEndTime': instance.loadingEndTime?.toIso8601String(),
      'unloadingStartTime': instance.unloadingStartTime?.toIso8601String(),
      'unloadingEndTime': instance.unloadingEndTime?.toIso8601String(),
      'paymentTime': instance.paymentTime?.toIso8601String(),
      'finalFare': instance.finalFare,
      'finalDuration': instance.finalDuration,
      'finalDistance': instance.finalDistance,
      'isPaymentDone': instance.isPaymentDone,
    };
