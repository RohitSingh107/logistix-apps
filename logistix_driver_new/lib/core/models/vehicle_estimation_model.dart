/**
 * vehicle_estimation_model.dart - Vehicle Estimation Data Models
 * 
 * Purpose:
 * - Defines data models for vehicle estimation and fare calculation
 * - Handles serialization for vehicle estimation API communication
 * - Manages location data and estimation request/response structures
 * 
 * Key Logic:
 * - Location: Geographic coordinates for pickup and dropoff points
 * - VehicleEstimationRequest: Payload for requesting fare estimates
 * - VehicleEstimate: Individual vehicle type estimate with fare and timing
 * - VehicleEstimationResponse: Complete response with multiple vehicle options
 * - Includes fare estimation, duration, distance, and pickup reach time
 * - Uses JSON serialization with snake_case field mapping
 * - Provides nullable fields for optional estimation data
 * - Supports multiple vehicle types in single response
 */

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
  @JsonKey(name: 'vehicle_type')
  final String vehicleType;
  @JsonKey(name: 'vehicle_type_id')
  final int vehicleTypeId;
  @JsonKey(name: 'estimated_fare')
  final double estimatedFare;
  @JsonKey(name: 'pickup_reach_time')
  final int pickupReachTime; // in minutes
  @JsonKey(name: 'estimated_duration')
  final int? estimatedDuration; // in minutes
  @JsonKey(name: 'estimated_distance')
  final double? estimatedDistance; // in kilometers

  VehicleEstimate({
    required this.vehicleType,
    required this.vehicleTypeId,
    required this.estimatedFare,
    required this.pickupReachTime,
    this.estimatedDuration,
    this.estimatedDistance,
  });

  factory VehicleEstimate.fromJson(Map<String, dynamic> json) => _$VehicleEstimateFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleEstimateToJson(this);
}

@JsonSerializable()
class VehicleEstimationResponse {
  final List<VehicleEstimate> estimates;

  VehicleEstimationResponse({
    required this.estimates,
  });

  factory VehicleEstimationResponse.fromJson(Map<String, dynamic> json) => _$VehicleEstimationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleEstimationResponseToJson(this);
} 