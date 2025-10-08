/// driver_model.dart - Driver Entity Data Models
/// 
/// Purpose:
/// - Defines data models for driver entities and related operations
/// - Handles driver profile information and availability status
/// - Manages driver license and rating information
/// 
/// Key Logic:
/// - Driver: Core driver entity linked to User with additional driver-specific data
/// - DriverRequest: Payload for creating or updating driver profiles
/// - Includes license verification and availability management
/// - Tracks driver ratings, earnings, and performance metrics
/// - Uses JSON serialization with snake_case field mapping
/// - Provides helper method for rating conversion (string to double)
/// - Integrates with User model for complete driver profile
/// - Handles driver availability toggle for ride assignment

import 'package:equatable/equatable.dart';
import 'user_model.dart';

class DriverModel extends Equatable {
  final int id;
  final UserModel user;
  final String licenseNumber;
  final int? vehicleType;
  final bool isAvailable;
  final String? fcmToken;
  final String averageRating;
  final double totalEarnings;
  final String location;

  const DriverModel({
    required this.id,
    required this.user,
    required this.licenseNumber,
    this.vehicleType,
    required this.isAvailable,
    this.fcmToken,
    required this.averageRating,
    required this.totalEarnings,
    required this.location,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      licenseNumber: json['license_number'] as String,
      vehicleType: json['vehicle_type'] as int?,
      isAvailable: json['is_available'] as bool,
      fcmToken: json['fcm_token'] as String?,
      averageRating: json['average_rating'] as String,
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'license_number': licenseNumber,
      'vehicle_type': vehicleType,
      'is_available': isAvailable,
      'fcm_token': fcmToken,
      'average_rating': averageRating,
      'total_earnings': totalEarnings,
      'location': location,
    };
  }

  DriverModel copyWith({
    int? id,
    UserModel? user,
    String? licenseNumber,
    int? vehicleType,
    bool? isAvailable,
    String? fcmToken,
    String? averageRating,
    double? totalEarnings,
    String? location,
  }) {
    return DriverModel(
      id: id ?? this.id,
      user: user ?? this.user,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isAvailable: isAvailable ?? this.isAvailable,
      fcmToken: fcmToken ?? this.fcmToken,
      averageRating: averageRating ?? this.averageRating,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [
        id,
        user,
        licenseNumber,
        vehicleType,
        isAvailable,
        fcmToken,
        averageRating,
        totalEarnings,
        location,
      ];
}

// Legacy classes for backward compatibility
class Driver extends Equatable {
  final int id;
  final User user;
  final String licenseNumber;
  final bool isAvailable;
  final String? fcmToken;
  final String averageRating;
  final double totalEarnings;

  const Driver({
    required this.id,
    required this.user,
    required this.licenseNumber,
    required this.isAvailable,
    this.fcmToken,
    required this.averageRating,
    required this.totalEarnings,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      licenseNumber: json['license_number'] as String,
      isAvailable: json['is_available'] as bool,
      fcmToken: json['fcm_token'] as String?,
      averageRating: json['average_rating'] as String,
      totalEarnings: (json['total_earnings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'license_number': licenseNumber,
      'is_available': isAvailable,
      'fcm_token': fcmToken,
      'average_rating': averageRating,
      'total_earnings': totalEarnings,
    };
  }

  @override
  List<Object?> get props => [id, user, licenseNumber, isAvailable, fcmToken, averageRating, totalEarnings];
}

class DriverRequest extends Equatable {
  final String licenseNumber;
  final bool isAvailable;
  final String? fcmToken;

  const DriverRequest({
    required this.licenseNumber,
    this.isAvailable = true,
    this.fcmToken,
  });

  factory DriverRequest.fromJson(Map<String, dynamic> json) {
    return DriverRequest(
      licenseNumber: json['license_number'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'license_number': licenseNumber,
      'is_available': isAvailable,
      'fcm_token': fcmToken,
    };
  }

  @override
  List<Object?> get props => [licenseNumber, isAvailable, fcmToken];
} 