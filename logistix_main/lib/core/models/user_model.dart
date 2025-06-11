import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String phone;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  User({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserRequest {
  final String phone;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  UserRequest({
    required this.phone,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.fcmToken,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) => _$UserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserRequestToJson(this);
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