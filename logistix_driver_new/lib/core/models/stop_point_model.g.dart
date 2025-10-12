// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopPoint _$StopPointFromJson(Map<String, dynamic> json) => StopPoint(
      id: (json['id'] as num?)?.toInt() ?? 0,
      location: json['location'] as String? ?? '',
      address: json['address'] as String? ?? '',
      stopOrder: (json['stop_order'] as num?)?.toInt() ?? 0,
      stopType: $enumDecode(_$StopTypeEnumMap, json['stop_type']),
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$StopPointToJson(StopPoint instance) => <String, dynamic>{
      'id': instance.id,
      'location': instance.location,
      'address': instance.address,
      'stop_order': instance.stopOrder,
      'stop_type': _$StopTypeEnumMap[instance.stopType]!,
      'contact_name': instance.contactName,
      'contact_phone': instance.contactPhone,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$StopTypeEnumMap = {
  StopType.pickup: 'PICKUP',
  StopType.dropoff: 'DROPOFF',
  StopType.waypoint: 'WAYPOINT',
};
