/// user_model.dart - User Data Models and Serialization
/// 
/// Purpose:
/// - Defines data models for user-related entities
/// - Provides JSON serialization/deserialization for API communication
/// - Handles OTP authentication request/response models
/// 
/// Key Logic:
/// - User model: Core user entity with profile information
/// - UserRequest model: User creation/update request payload
/// - OTPRequest model: OTP generation request structure
/// - OTPVerification model: OTP validation request structure
/// - TokenRefresh models: JWT token refresh functionality
/// - Uses json_annotation for automatic JSON serialization
/// - Maps API field names to Dart property names using JsonKey
library;

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String phone;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  User({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserRequest {
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  UserRequest({
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.fcmToken,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) => _$UserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserRequestToJson(this);
}

@JsonSerializable()
class PatchedUserRequest {
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  PatchedUserRequest({
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.fcmToken,
  });

  factory PatchedUserRequest.fromJson(Map<String, dynamic> json) => _$PatchedUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PatchedUserRequestToJson(this);
}

@JsonSerializable()
class OTPRequest {
  final String phone;

  OTPRequest({
    required this.phone,
  });

  factory OTPRequest.fromJson(Map<String, dynamic> json) => _$OTPRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OTPRequestToJson(this);
}

@JsonSerializable()
class OTPVerification {
  final String phone;
  final String otp;

  OTPVerification({
    required this.phone,
    required this.otp,
  });

  factory OTPVerification.fromJson(Map<String, dynamic> json) => _$OTPVerificationFromJson(json);
  Map<String, dynamic> toJson() => _$OTPVerificationToJson(this);
}

@JsonSerializable()
class TokenRefresh {
  final String access;

  TokenRefresh({
    required this.access,
  });

  factory TokenRefresh.fromJson(Map<String, dynamic> json) => _$TokenRefreshFromJson(json);
  Map<String, dynamic> toJson() => _$TokenRefreshToJson(this);
}

@JsonSerializable()
class TokenRefreshRequest {
  final String refresh;

  TokenRefreshRequest({
    required this.refresh,
  });

  factory TokenRefreshRequest.fromJson(Map<String, dynamic> json) => _$TokenRefreshRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TokenRefreshRequestToJson(this);
} 