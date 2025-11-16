/// driver_model.dart - Driver Data Models and Serialization
/// 
/// Purpose:
/// - Defines data models for driver-related entities
/// - Provides JSON serialization/deserialization for API communication
/// - Handles driver profile management and availability status
/// 
/// Key Logic:
/// - Driver model: Core driver entity with profile and rating information
/// - DriverRequest model: Driver creation/update request payload
/// - PatchedDriverRequest model: Partial update request payload
/// - Uses json_annotation for automatic JSON serialization
/// - Maps API field names to Dart property names using JsonKey
/// - Includes driver-specific fields like license number and availability
library;

import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'driver_model.g.dart';

@JsonSerializable()
class Driver {
  final int id;
  final User user;
  @JsonKey(name: 'license_number')
  final String licenseNumber;
  @JsonKey(name: 'vehicle_type')
  final int? vehicleType;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;
  @JsonKey(name: 'average_rating')
  final String averageRating;
  @JsonKey(name: 'total_earnings')
  final double totalEarnings;
  @JsonKey(name: 'location', fromJson: _locationFromJson, toJson: _locationToJson)
  final String location;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Driver({
    required this.id,
    required this.user,
    required this.licenseNumber,
    this.vehicleType,
    required this.isAvailable,
    required this.isVerified,
    this.fcmToken,
    required this.averageRating,
    required this.totalEarnings,
    required this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
  Map<String, dynamic> toJson() => _$DriverToJson(this);

  /// Convert location from API format (Map or String) to String
  static String _locationFromJson(dynamic json) {
    if (json == null) {
      return '';
    }
    if (json is String) {
      return json;
    }
    if (json is Map<String, dynamic>) {
      // If it's a Map with latitude and longitude, convert to string format
      final lat = json['latitude']?.toString() ?? '';
      final lng = json['longitude']?.toString() ?? '';
      if (lat.isNotEmpty && lng.isNotEmpty) {
        return 'SRID=4326;POINT ($lng $lat)';
      }
      return '';
    }
    return json.toString();
  }

  /// Convert location String to API format
  static dynamic _locationToJson(String location) {
    // Try to parse the location string back to Map if it's in POINT format
    try {
      final regex = RegExp(r'POINT \(([0-9.-]+) ([0-9.-]+)\)');
      final match = regex.firstMatch(location);
      if (match != null) {
        return {
          'longitude': double.parse(match.group(1)!),
          'latitude': double.parse(match.group(2)!),
        };
      }
    } catch (e) {
      // If parsing fails, return as string
    }
    return location;
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
    required this.isAvailable,
    this.fcmToken,
  });

  factory DriverRequest.fromJson(Map<String, dynamic> json) => _$DriverRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DriverRequestToJson(this);
}

@JsonSerializable()
class PatchedDriverRequest {
  @JsonKey(name: 'license_number')
  final String? licenseNumber;
  @JsonKey(name: 'is_available')
  final bool? isAvailable;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;
  final double? latitude;
  final double? longitude;

  PatchedDriverRequest({
    this.licenseNumber,
    this.isAvailable,
    this.fcmToken,
    this.latitude,
    this.longitude,
  });

  factory PatchedDriverRequest.fromJson(Map<String, dynamic> json) => _$PatchedDriverRequestFromJson(json);
  
  Map<String, dynamic> toJson() {
    final json = _$PatchedDriverRequestToJson(this);
    // Remove null values to avoid server validation errors
    json.removeWhere((key, value) => value == null);
    return json;
  }
} 