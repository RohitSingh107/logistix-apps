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