/**
 * vehicle_estimation_repository.dart - Vehicle Estimation Repository Interface
 * 
 * Purpose:
 * - Defines the contract for vehicle estimation and fare calculation operations
 * - Provides abstract methods for pricing and vehicle type selection
 * - Establishes consistent interface for estimation data access across layers
 * 
 * Key Logic:
 * - Abstract methods for fare estimation based on distance and vehicle type
 * - Vehicle availability checking and real-time pricing interface
 * - Dynamic pricing calculations considering demand and time factors
 * - Multiple vehicle type support (bike, car, truck, etc.)
 * - Route-based estimation using pickup and dropoff coordinates
 * - Integration points for map services and distance calculation
 * - Pricing tier management and promotional pricing support
 * - Error handling contracts for estimation operation failures
 */

import '../../../../core/models/vehicle_estimation_model.dart';

abstract class VehicleEstimationRepository {
  /// Get vehicle estimation quotes for the given pickup and dropoff locations
  Future<List<VehicleEstimationRequest>> getVehicleEstimates({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
  });
} 