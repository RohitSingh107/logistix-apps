// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) => Driver(
      id: (json['id'] as num?)?.toInt() ?? 0,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      licenseNumber: json['license_number'] as String? ?? '',
      vehicleType: (json['vehicle_type'] as num?)?.toInt(),
      isAvailable: json['is_available'] as bool,
      fcmToken: json['fcm_token'] as String?,
      averageRating: json['average_rating'] as String? ?? '0.00',
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'license_number': instance.licenseNumber,
      'vehicle_type': instance.vehicleType,
      'is_available': instance.isAvailable,
      'fcm_token': instance.fcmToken,
      'average_rating': instance.averageRating,
      'total_earnings': instance.totalEarnings,
      'location': instance.location,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
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
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PatchedDriverRequestToJson(
        PatchedDriverRequest instance) =>
    <String, dynamic>{
      'license_number': instance.licenseNumber,
      'is_available': instance.isAvailable,
      'fcm_token': instance.fcmToken,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
