// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      phone: (json['phone'] as num).toInt(),
      firstName: (json['first_name'] ?? json['firstName'] ?? '') as String,
      lastName: (json['last_name'] ?? json['lastName'] ?? '') as String,
      profilePicture: (json['profile_picture'] ?? json['profilePicture']) as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profilePicture': instance.profilePicture,
    };

UserRequest _$UserRequestFromJson(Map<String, dynamic> json) => UserRequest(
      phone: (json['phone'] as num).toInt(),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$UserRequestToJson(UserRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profilePicture': instance.profilePicture,
    };
