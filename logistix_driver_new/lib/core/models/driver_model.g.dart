// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) => Driver(
      id: (json['id'] as num).toInt(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      licenseNumber: json['license_number'] as String,
      isAvailable: json['is_available'] as bool,
      fcmToken: json['fcm_token'] as String?,
      averageRating: json['average_rating'] as String,
      totalEarnings: (json['total_earnings'] as num).toDouble(),
    );

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'license_number': instance.licenseNumber,
      'is_available': instance.isAvailable,
      'fcm_token': instance.fcmToken,
      'average_rating': instance.averageRating,
      'total_earnings': instance.totalEarnings,
    };

DriverRequest _$DriverRequestFromJson(Map<String, dynamic> json) =>
    DriverRequest(
      licenseNumber: json['license_number'] as String,
      isAvailable: json['is_available'] as bool,
      fcmToken: json['fcm_token'] as String?,
    );

Map<String, dynamic> _$DriverRequestToJson(DriverRequest instance) =>
    <String, dynamic>{
      'license_number': instance.licenseNumber,
      'is_available': instance.isAvailable,
      'fcm_token': instance.fcmToken,
    };

PatchedDriverRequest _$PatchedDriverRequestFromJson(
        Map<String, dynamic> json) =>
    PatchedDriverRequest(
      licenseNumber: json['license_number'] as String?,
      isAvailable: json['is_available'] as bool?,
      fcmToken: json['fcm_token'] as String?,
    );

Map<String, dynamic> _$PatchedDriverRequestToJson(
        PatchedDriverRequest instance) =>
    <String, dynamic>{
      'license_number': instance.licenseNumber,
      'is_available': instance.isAvailable,
      'fcm_token': instance.fcmToken,
    };
