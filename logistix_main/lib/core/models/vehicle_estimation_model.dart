/// vehicle_estimation_model.dart - Vehicle Estimation Data Models
/// 
/// Purpose:
/// - Defines data models for vehicle estimation and fare calculation
/// - Handles serialization for vehicle estimation API communication
/// - Manages location data and estimation request/response structures
/// 
/// Key Logic:
/// - Location: Geographic coordinates for pickup and dropoff points
/// - VehicleEstimationRequest: Payload for requesting fare estimates
/// - VehicleEstimate: Individual vehicle type estimate with fare and timing
/// - VehicleEstimationResponse: Complete response with multiple vehicle options
/// - Includes fare estimation, duration, distance, and pickup reach time
/// - Uses JSON serialization with snake_case field mapping
/// - Provides nullable fields for optional estimation data
/// - Supports multiple vehicle types in single response

import 'package:json_annotation/json_annotation.dart';

part 'vehicle_estimation_model.g.dart';

@JsonSerializable()
class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class VehicleEstimationRequest {
  @JsonKey(name: 'pickup_location')
  final Location pickupLocation;
  @JsonKey(name: 'dropoff_location')
  final Location dropoffLocation;

  VehicleEstimationRequest({
    required this.pickupLocation,
    required this.dropoffLocation,
  });

  factory VehicleEstimationRequest.fromJson(Map<String, dynamic> json) => _$VehicleEstimationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleEstimationRequestToJson(this);
}

@JsonSerializable()
class VehicleEstimate {
  @JsonKey(name: 'estimated_fare')
  final double estimatedFare;
  @JsonKey(name: 'pickup_reach_time')
  final int pickupReachTime; // in minutes
  @JsonKey(name: 'vehicle_type')
  final int vehicleType;
  @JsonKey(name: 'vehicle_title')
  final String vehicleTitle;
  @JsonKey(name: 'vehicle_capacity')
  final int vehicleCapacity;
  @JsonKey(name: 'vehicle_base_fare')
  final double vehicleBaseFare;
  @JsonKey(name: 'vehicle_base_distance')
  final double vehicleBaseDistance;
  @JsonKey(name: 'vehicle_dimension_height')
  final double vehicleDimensionHeight;
  @JsonKey(name: 'vehicle_dimension_weight')
  final double vehicleDimensionWeight;
  @JsonKey(name: 'vehicle_dimension_depth')
  final double vehicleDimensionDepth;
  @JsonKey(name: 'vehicle_dimension_unit')
  final String vehicleDimensionUnit;
  
  // Calculated fields for distance and duration
  final double? estimatedDistance;
  final int? estimatedDuration;

  VehicleEstimate({
    required this.estimatedFare,
    required this.pickupReachTime,
    required this.vehicleType,
    required this.vehicleTitle,
    required this.vehicleCapacity,
    required this.vehicleBaseFare,
    required this.vehicleBaseDistance,
    required this.vehicleDimensionHeight,
    required this.vehicleDimensionWeight,
    required this.vehicleDimensionDepth,
    required this.vehicleDimensionUnit,
    this.estimatedDistance,
    this.estimatedDuration,
  });

  factory VehicleEstimate.fromJson(Map<String, dynamic> json) => _$VehicleEstimateFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleEstimateToJson(this);

  // Helper method to get vehicle icon based on type
  String get vehicleIcon {
    switch (vehicleType) {
      case 1:
        return '🛵'; // Motorcycle
      case 2:
        return '🛺'; // Three wheeler
      default:
        return '🚗'; // Default car icon
    }
  }

  // Helper method to get vehicle type description
  String get vehicleTypeDescription {
    return vehicleTitle;
  }
}

@JsonSerializable()
class VehicleEstimationResponse {
  final List<VehicleEstimate> estimates;

  VehicleEstimationResponse({
    required this.estimates,
  });

  // Custom fromJson to handle the API response format (list of estimates)
  factory VehicleEstimationResponse.fromJson(dynamic json) {
    if (json is List) {
      final estimates = json.map((item) => VehicleEstimate.fromJson(item as Map<String, dynamic>)).toList();
      return VehicleEstimationResponse(estimates: estimates);
    } else if (json is Map<String, dynamic>) {
      // Fallback for nested structure if needed
      final estimates = (json['estimates'] as List?)?.map((item) => VehicleEstimate.fromJson(item as Map<String, dynamic>)).toList() ?? [];
      return VehicleEstimationResponse(estimates: estimates);
    }
    throw Exception('Invalid JSON format for VehicleEstimationResponse');
  }

  Map<String, dynamic> toJson() => {'estimates': estimates.map((e) => e.toJson()).toList()};
} 