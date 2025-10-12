import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/models/vehicle_estimation_model.dart';
import '../../domain/repositories/vehicle_estimation_repository_interface.dart';
import 'dart:math' as math;

class VehicleEstimationRepository implements VehicleEstimationRepositoryInterface {
  final ApiClient _apiClient;

  VehicleEstimationRepository(this._apiClient);

  @override
  Future<VehicleEstimationResponse> getVehicleEstimates({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
  }) async {
    try {
      final request = VehicleEstimationRequest(
        stopLocations: [
          Location(
            latitude: pickupLatitude,
            longitude: pickupLongitude,
          ),
          Location(
            latitude: dropoffLatitude,
            longitude: dropoffLongitude,
          ),
        ],
      );

      print('Making vehicle estimates API call with: ${request.toJson()}');

      final response = await _apiClient.post(
        ApiEndpoints.vehicleEstimates,
        data: request.toJson(),
      );

      if (response.data == null) {
        print('API returned null data, using fallback estimates');
        return _getFallbackEstimates(pickupLatitude, pickupLongitude, dropoffLatitude, dropoffLongitude);
      }

      try {
        print('Vehicle estimation API response: ${response.data}');
        
        // The API now returns a direct array of estimates
        final List<dynamic> estimatesData = response.data as List<dynamic>;
        final estimates = estimatesData.map((item) => VehicleEstimate.fromJson(item as Map<String, dynamic>)).toList();
        
        // Calculate distance and duration for each estimate
        final distance = _calculateDistance(pickupLatitude, pickupLongitude, dropoffLatitude, dropoffLongitude);
        final duration = _calculateDuration(distance);
        
        // Update estimates with calculated distance and duration
        final updatedEstimates = estimates.map((estimate) => VehicleEstimate(
          estimatedFare: estimate.estimatedFare,
          pickupReachTime: estimate.pickupReachTime,
          vehicleType: estimate.vehicleType,
          vehicleTitle: estimate.vehicleTitle,
          vehicleCapacity: estimate.vehicleCapacity,
          vehicleBaseFare: estimate.vehicleBaseFare,
          vehicleBaseDistance: estimate.vehicleBaseDistance,
          vehicleDimensionHeight: estimate.vehicleDimensionHeight,
          vehicleDimensionWeight: estimate.vehicleDimensionWeight,
          vehicleDimensionDepth: estimate.vehicleDimensionDepth,
          vehicleDimensionUnit: estimate.vehicleDimensionUnit,
          estimatedDistance: distance,
          estimatedDuration: duration,
        )).toList();
        
        return VehicleEstimationResponse(estimates: updatedEstimates);
      } catch (e) {
        print('Error parsing vehicle estimation response: $e');
        return _getFallbackEstimates(pickupLatitude, pickupLongitude, dropoffLatitude, dropoffLongitude);
      }
    } catch (e) {
      print('Error getting vehicle estimates: $e');
      print('Using fallback estimates due to API error');
      
      // Return fallback estimates instead of throwing error
      return _getFallbackEstimates(pickupLatitude, pickupLongitude, dropoffLatitude, dropoffLongitude);
    }
  }

  VehicleEstimationResponse _getFallbackEstimates(
    double pickupLat,
    double pickupLng,
    double dropoffLat,
    double dropoffLng,
  ) {
    // Calculate distance for pricing
    final distance = _calculateDistance(pickupLat, pickupLng, dropoffLat, dropoffLng);
    final duration = _calculateDuration(distance);
    
    final estimates = [
      VehicleEstimate(
        estimatedFare: _calculateFare(distance, 40, 12), // Base 40, per km 12
        pickupReachTime: _calculatePickupTime(distance),
        vehicleType: 1,
        vehicleTitle: 'MOTORCYCLE',
        vehicleCapacity: 200,
        vehicleBaseFare: 40.0,
        vehicleBaseDistance: 2.0,
        vehicleDimensionHeight: 12.0,
        vehicleDimensionWeight: 12.0,
        vehicleDimensionDepth: 12.0,
        vehicleDimensionUnit: 'cm',
        estimatedDistance: distance,
        estimatedDuration: duration,
      ),
      VehicleEstimate(
        estimatedFare: _calculateFare(distance, 60, 18), // Base 60, per km 18
        pickupReachTime: _calculatePickupTime(distance),
        vehicleType: 2,
        vehicleTitle: 'W3',
        vehicleCapacity: 500,
        vehicleBaseFare: 60.0,
        vehicleBaseDistance: 2.0,
        vehicleDimensionHeight: 24.0,
        vehicleDimensionWeight: 24.0,
        vehicleDimensionDepth: 24.0,
        vehicleDimensionUnit: 'cm',
        estimatedDistance: distance,
        estimatedDuration: duration,
      ),
      VehicleEstimate(
        estimatedFare: _calculateFare(distance, 100, 25), // Base 100, per km 25
        pickupReachTime: _calculatePickupTime(distance),
        vehicleType: 3,
        vehicleTitle: 'MINI TRUCK',
        vehicleCapacity: 1000,
        vehicleBaseFare: 100.0,
        vehicleBaseDistance: 2.0,
        vehicleDimensionHeight: 36.0,
        vehicleDimensionWeight: 36.0,
        vehicleDimensionDepth: 36.0,
        vehicleDimensionUnit: 'cm',
        estimatedDistance: distance,
        estimatedDuration: duration,
      ),
    ];

    return VehicleEstimationResponse(estimates: estimates);
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // Haversine formula
    const double R = 6371; // Earth's radius in kilometers
    
    double lat1Rad = lat1 * (math.pi / 180);
    double lat2Rad = lat2 * (math.pi / 180);
    double deltaLatRad = (lat2 - lat1) * (math.pi / 180);
    double deltaLngRad = (lng2 - lng1) * (math.pi / 180);

    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  double _calculateFare(double distance, double baseFare, double perKmRate) {
    if (distance <= 2.0) { // Base distance is typically 2km
      return baseFare;
    }
    return baseFare + ((distance - 2.0) * perKmRate);
  }

  int _calculatePickupTime(double distance) {
    // Estimate pickup time based on distance (assuming 30 km/h average speed)
    final timeInHours = distance / 30;
    final timeInMinutes = (timeInHours * 60).round();
    return math.max(5, math.min(timeInMinutes, 45)); // Between 5-45 minutes
  }

  int _calculateDuration(double distance) {
    // Estimate trip duration based on distance (assuming 25 km/h average speed for delivery)
    final timeInHours = distance / 25;
    final timeInMinutes = (timeInHours * 60).round();
    return math.max(10, timeInMinutes); // Minimum 10 minutes
  }
} 