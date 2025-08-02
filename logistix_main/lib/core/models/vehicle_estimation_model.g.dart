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
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      pickupReachTime: (json['pickup_reach_time'] as num).toInt(),
      vehicleType: (json['vehicle_type'] as num).toInt(),
      vehicleTitle: json['vehicle_title'] as String,
      vehicleCapacity: (json['vehicle_capacity'] as num).toInt(),
      vehicleBaseFare: (json['vehicle_base_fare'] as num).toDouble(),
      vehicleBaseDistance: (json['vehicle_base_distance'] as num).toDouble(),
      vehicleDimensionHeight:
          (json['vehicle_dimension_height'] as num).toDouble(),
      vehicleDimensionWeight:
          (json['vehicle_dimension_weight'] as num).toDouble(),
      vehicleDimensionDepth:
          (json['vehicle_dimension_depth'] as num).toDouble(),
      vehicleDimensionUnit: json['vehicle_dimension_unit'] as String,
      estimatedDistance: (json['estimatedDistance'] as num?)?.toDouble(),
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VehicleEstimateToJson(VehicleEstimate instance) =>
    <String, dynamic>{
      'estimated_fare': instance.estimatedFare,
      'pickup_reach_time': instance.pickupReachTime,
      'vehicle_type': instance.vehicleType,
      'vehicle_title': instance.vehicleTitle,
      'vehicle_capacity': instance.vehicleCapacity,
      'vehicle_base_fare': instance.vehicleBaseFare,
      'vehicle_base_distance': instance.vehicleBaseDistance,
      'vehicle_dimension_height': instance.vehicleDimensionHeight,
      'vehicle_dimension_weight': instance.vehicleDimensionWeight,
      'vehicle_dimension_depth': instance.vehicleDimensionDepth,
      'vehicle_dimension_unit': instance.vehicleDimensionUnit,
      'estimatedDistance': instance.estimatedDistance,
      'estimatedDuration': instance.estimatedDuration,
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
