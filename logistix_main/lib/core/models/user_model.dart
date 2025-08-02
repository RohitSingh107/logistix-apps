/**
 * user_model.dart - User Data Models and Serialization
 * 
 * Purpose:
 * - Defines data models for user-related entities
 * - Provides JSON serialization/deserialization for API communication
 * - Handles OTP authentication request/response models
 * 
 * Key Logic:
 * - User model: Core user entity with profile information
 * - UserRequest model: User creation/update request payload
 * - OTPRequest model: OTP generation request structure
 * - OTPVerification model: OTP validation request structure
 * - TokenRefresh models: JWT token refresh functionality
 * - Uses json_annotation for automatic JSON serialization
 * - Maps API field names to Dart property names using JsonKey
 */

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      phone: json['phone'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      profilePicture: json['profile_picture'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'fcm_token': fcmToken,
    };
  }

  UserModel copyWith({
    int? id,
    String? phone,
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicture: profilePicture ?? this.profilePicture,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        phone,
        firstName,
        lastName,
        profilePicture,
        fcmToken,
      ];
}

// Legacy classes for backward compatibility
class User extends Equatable {
  final int id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String? fcmToken;

  const User({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      phone: json['phone'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      profilePicture: json['profile_picture'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'fcm_token': fcmToken,
    };
  }

  @override
  List<Object?> get props => [id, phone, firstName, lastName, profilePicture, fcmToken];
}

class UserRequest extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? profilePicture;
  final String? fcmToken;

  const UserRequest({
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.fcmToken,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      profilePicture: json['profile_picture'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
      'fcm_token': fcmToken,
    };
  }

  @override
  List<Object?> get props => [firstName, lastName, profilePicture, fcmToken];
}

class OTPRequest extends Equatable {
  final String phone;

  const OTPRequest({
    required this.phone,
  });

  factory OTPRequest.fromJson(Map<String, dynamic> json) {
    return OTPRequest(
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [phone];
}

class OTPVerification extends Equatable {
  final String phone;
  final String otp;

  const OTPVerification({
    required this.phone,
    required this.otp,
  });

  factory OTPVerification.fromJson(Map<String, dynamic> json) {
    return OTPVerification(
      phone: json['phone'] as String,
      otp: json['otp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
    };
  }

  @override
  List<Object?> get props => [phone, otp];
}

class TokenRefresh extends Equatable {
  final String access;

  const TokenRefresh({
    required this.access,
  });

  factory TokenRefresh.fromJson(Map<String, dynamic> json) {
    return TokenRefresh(
      access: json['access'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
    };
  }

  @override
  List<Object?> get props => [access];
}

class TokenRefreshRequest extends Equatable {
  final String refresh;

  const TokenRefreshRequest({
    required this.refresh,
  });

  factory TokenRefreshRequest.fromJson(Map<String, dynamic> json) {
    return TokenRefreshRequest(
      refresh: json['refresh'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
    };
  }

  @override
  List<Object?> get props => [refresh];
} 