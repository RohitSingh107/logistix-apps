// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      phone: json['phone'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      profilePicture: json['profile_picture'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'profile_picture': instance.profilePicture,
      'fcm_token': instance.fcmToken,
    };

UserRequest _$UserRequestFromJson(Map<String, dynamic> json) => UserRequest(
      phone: json['phone'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      profilePicture: json['profile_picture'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );

Map<String, dynamic> _$UserRequestToJson(UserRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'profile_picture': instance.profilePicture,
      'fcm_token': instance.fcmToken,
    };

OTPRequest _$OTPRequestFromJson(Map<String, dynamic> json) => OTPRequest(
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$OTPRequestToJson(OTPRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
    };

OTPVerification _$OTPVerificationFromJson(Map<String, dynamic> json) =>
    OTPVerification(
      phone: json['phone'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$OTPVerificationToJson(OTPVerification instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'otp': instance.otp,
    };

TokenRefresh _$TokenRefreshFromJson(Map<String, dynamic> json) => TokenRefresh(
      access: json['access'] as String,
    );

Map<String, dynamic> _$TokenRefreshToJson(TokenRefresh instance) =>
    <String, dynamic>{
      'access': instance.access,
    };

TokenRefreshRequest _$TokenRefreshRequestFromJson(Map<String, dynamic> json) =>
    TokenRefreshRequest(
      refresh: json['refresh'] as String,
    );

Map<String, dynamic> _$TokenRefreshRequestToJson(
        TokenRefreshRequest instance) =>
    <String, dynamic>{
      'refresh': instance.refresh,
    };
