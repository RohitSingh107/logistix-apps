// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) => Driver(
      id: (json['id'] as num).toInt(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      licenseNumber: json['licenseNumber'] as String,
      isAvailable: json['isAvailable'] as bool,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
    );

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'licenseNumber': instance.licenseNumber,
      'isAvailable': instance.isAvailable,
      'averageRating': instance.averageRating,
      'totalEarnings': instance.totalEarnings,
    };

DriverRequest _$DriverRequestFromJson(Map<String, dynamic> json) =>
    DriverRequest(
      licenseNumber: json['licenseNumber'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );

Map<String, dynamic> _$DriverRequestToJson(DriverRequest instance) =>
    <String, dynamic>{
      'licenseNumber': instance.licenseNumber,
      'isAvailable': instance.isAvailable,
    };
