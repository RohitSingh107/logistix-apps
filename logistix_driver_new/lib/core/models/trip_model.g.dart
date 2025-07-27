// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
      id: (json['id'] as num).toInt(),
      driver: Driver.fromJson(json['driver'] as Map<String, dynamic>),
      bookingRequest:
          Booking.fromJson(json['bookingRequest'] as Map<String, dynamic>),
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
      finalFare: (json['finalFare'] as num?)?.toDouble(),
      finalDuration: (json['finalDuration'] as num?)?.toDouble(),
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
  TripStatus.started: 'STARTED',
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
      finalDistance: json['final_distance'] as String?,
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

PaginatedTripList _$PaginatedTripListFromJson(Map<String, dynamic> json) =>
    PaginatedTripList(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => Trip.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$PaginatedTripListToJson(PaginatedTripList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };
