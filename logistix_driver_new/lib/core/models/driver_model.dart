/**
 * driver_model.dart - Driver Entity Data Models
 * 
 * Purpose:
 * - Defines data models for driver entities and related operations
 * - Handles driver profile information and availability status
 * - Manages driver license and rating information
 * 
 * Key Logic:
 * - Driver: Core driver entity linked to User with additional driver-specific data
 * - DriverRequest: Payload for creating or updating driver profiles
 * - Includes license verification and availability management
 * - Tracks driver ratings, earnings, and performance metrics
 * - Uses JSON serialization with snake_case field mapping
 * - Provides helper method for rating conversion (string to double)
 * - Integrates with User model for complete driver profile
 * - Handles driver availability toggle for ride assignment
 */

import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'driver_model.g.dart';

@JsonSerializable()
class Driver {
  final int id;
  final User user;
  @JsonKey(name: 'license_number')
  final String licenseNumber;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;
  @JsonKey(name: 'average_rating')
  final String averageRating;
  @JsonKey(name: 'total_earnings')
  final double totalEarnings;

  Driver({
    required this.id,
    required this.user,
    required this.licenseNumber,
    required this.isAvailable,
    this.fcmToken,
    required this.averageRating,
    required this.totalEarnings,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
  Map<String, dynamic> toJson() => _$DriverToJson(this);

  // Helper method to convert string rating to double
  double get rating {
    try {
      return double.parse(averageRating);
    } catch (e) {
      return 0.0;
    }
  }
}

@JsonSerializable()
class DriverRequest {
  @JsonKey(name: 'license_number')
  final String licenseNumber;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  DriverRequest({
    required this.licenseNumber,
    this.isAvailable = true,
    this.fcmToken,
  });

  factory DriverRequest.fromJson(Map<String, dynamic> json) => _$DriverRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DriverRequestToJson(this);
} 