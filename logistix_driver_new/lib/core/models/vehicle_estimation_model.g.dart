// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_estimation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

LocationRequest _$LocationRequestFromJson(Map<String, dynamic> json) =>
    LocationRequest(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationRequestToJson(LocationRequest instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

VehicleEstimationRequest _$VehicleEstimationRequestFromJson(
        Map<String, dynamic> json) =>
    VehicleEstimationRequest(
      pickupLocation:
          Location.fromJson(json['pickup_location'] as Map<String, dynamic>),
      dropoffLocation:
          Location.fromJson(json['dropoff_location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VehicleEstimationRequestToJson(
        VehicleEstimationRequest instance) =>
    <String, dynamic>{
      'pickup_location': instance.pickupLocation,
      'dropoff_location': instance.dropoffLocation,
    };

VehicleEstimationRequestRequest _$VehicleEstimationRequestRequestFromJson(
        Map<String, dynamic> json) =>
    VehicleEstimationRequestRequest(
      stopLocations: (json['stop_locations'] as List<dynamic>)
          .map((e) => LocationRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VehicleEstimationRequestRequestToJson(
        VehicleEstimationRequestRequest instance) =>
    <String, dynamic>{
      'stop_locations': instance.stopLocations,
    };
