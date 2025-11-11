/// vehicle_estimation_model.dart - Vehicle Estimation Data Models
/// 
/// Purpose:
/// - Defines data models for vehicle estimation and fare calculation
/// - Handles location data and estimation requests/responses
/// - Manages vehicle type selection and pricing estimates
/// 
/// Key Logic:
/// - Location: Represents geographical coordinates (latitude, longitude)
/// - LocationRequest: Request payload for location data
/// - VehicleEstimationRequest: Request for vehicle estimation quotes
/// - VehicleEstimationRequestRequest: Request payload for estimation
/// - Uses JSON serialization with snake_case field mapping
/// - Supports location-based fare estimation
/// - Handles coordinate precision and validation
library;

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
class LocationRequest {
  final double latitude;
  final double longitude;

  LocationRequest({
    required this.latitude,
    required this.longitude,
  });

  factory LocationRequest.fromJson(Map<String, dynamic> json) => _$LocationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LocationRequestToJson(this);
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
class VehicleEstimationRequestRequest {
  @JsonKey(name: 'stop_locations')
  final List<LocationRequest> stopLocations;

  VehicleEstimationRequestRequest({
    required this.stopLocations,
  });

  factory VehicleEstimationRequestRequest.fromJson(Map<String, dynamic> json) => _$VehicleEstimationRequestRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleEstimationRequestRequestToJson(this);
} 