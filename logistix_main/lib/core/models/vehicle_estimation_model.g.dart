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

VehicleEstimate _$VehicleEstimateFromJson(Map<String, dynamic> json) =>
    VehicleEstimate(
      vehicleType: json['vehicle_type'] as String,
      vehicleTypeId: (json['vehicle_type_id'] as num).toInt(),
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      pickupReachTime: (json['pickup_reach_time'] as num).toInt(),
      estimatedDuration: (json['estimated_duration'] as num?)?.toInt(),
      estimatedDistance: (json['estimated_distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$VehicleEstimateToJson(VehicleEstimate instance) =>
    <String, dynamic>{
      'vehicle_type': instance.vehicleType,
      'vehicle_type_id': instance.vehicleTypeId,
      'estimated_fare': instance.estimatedFare,
      'pickup_reach_time': instance.pickupReachTime,
      'estimated_duration': instance.estimatedDuration,
      'estimated_distance': instance.estimatedDistance,
    };

VehicleEstimationResponse _$VehicleEstimationResponseFromJson(
        Map<String, dynamic> json) =>
    VehicleEstimationResponse(
      estimates: (json['estimates'] as List<dynamic>)
          .map((e) => VehicleEstimate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VehicleEstimationResponseToJson(
        VehicleEstimationResponse instance) =>
    <String, dynamic>{
      'estimates': instance.estimates,
    };
