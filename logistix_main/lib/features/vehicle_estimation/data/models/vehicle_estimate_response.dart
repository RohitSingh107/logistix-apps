class VehicleEstimateResponse {
  final double estimatedFare;
  final int pickupReachTime;
  final int vehicleType;
  final String vehicleTitle;
  final double vehicleBaseFare;
  final double vehicleBaseDistance;
  final double vehicleDimensionHeight;
  final double vehicleDimensionWeight;
  final double vehicleDimensionDepth;
  final String vehicleDimensionUnit;
  final double? estimatedDistance;
  final int? estimatedDuration;

  VehicleEstimateResponse({
    required this.estimatedFare,
    required this.pickupReachTime,
    required this.vehicleType,
    required this.vehicleTitle,
    required this.vehicleBaseFare,
    required this.vehicleBaseDistance,
    required this.vehicleDimensionHeight,
    required this.vehicleDimensionWeight,
    required this.vehicleDimensionDepth,
    required this.vehicleDimensionUnit,
    this.estimatedDistance,
    this.estimatedDuration,
  });

  factory VehicleEstimateResponse.fromJson(Map<String, dynamic> json) {
    return VehicleEstimateResponse(
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      pickupReachTime: json['pickup_reach_time'] as int,
      vehicleType: json['vehicle_type'] as int,
      vehicleTitle: json['vehicle_title'] as String,
      vehicleBaseFare: (json['vehicle_base_fare'] as num).toDouble(),
      vehicleBaseDistance: (json['vehicle_base_distance'] as num).toDouble(),
      vehicleDimensionHeight: (json['vehicle_dimension_height'] as num).toDouble(),
      vehicleDimensionWeight: (json['vehicle_dimension_weight'] as num).toDouble(),
      vehicleDimensionDepth: (json['vehicle_dimension_depth'] as num).toDouble(),
      vehicleDimensionUnit: json['vehicle_dimension_unit'] as String,
    );
  }

  // Helper method to get vehicle icon based on type
  String get vehicleIcon {
    switch (vehicleType) {
      case 1:
        return '🛵'; // Two wheeler (motorcycle)
      case 2:
        return '🛺'; // Three wheeler (auto-rickshaw)
      default:
        return '🚗'; // Default car icon
    }
  }

  // Helper method to get vehicle type description
  String get vehicleTypeDescription {
    switch (vehicleType) {
      case 1:
        return 'Two Wheeler';
      case 2:
        return 'Three Wheeler';
      default:
        return 'Vehicle';
    }
  }
} 