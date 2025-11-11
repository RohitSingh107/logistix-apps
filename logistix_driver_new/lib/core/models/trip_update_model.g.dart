// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripUpdate _$TripUpdateFromJson(Map<String, dynamic> json) => TripUpdate(
      id: (json['id'] as num).toInt(),
      trip: (json['trip'] as num).toInt(),
      updateMessage: json['update_message'] as String,
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdByPhone: json['created_by_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TripUpdateToJson(TripUpdate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trip': instance.trip,
      'update_message': instance.updateMessage,
      'created_by': instance.createdBy,
      'created_by_phone': instance.createdByPhone,
      'created_at': instance.createdAt.toIso8601String(),
    };
