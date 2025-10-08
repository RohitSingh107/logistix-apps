/// trip_repository.dart - Trip Repository Interface
/// 
/// Purpose:
/// - Defines the contract for trip-related data operations
/// - Provides abstract methods for trip lifecycle management
/// - Establishes consistent interface for trip data access across layers
/// 
/// Key Logic:
/// - Abstract methods for trip CRUD operations (create, read, update, delete)
/// - Trip status management interface (pending, active, completed, cancelled)
/// - Pagination support for trip history and listing
/// - Real-time trip tracking and status updates interface
/// - Driver-customer trip relationship management
/// - Trip filtering and search capabilities
/// - Integration points for location tracking and route management
/// - Error handling contracts for trip operation failures
library;

import '../../../../core/models/trip_model.dart';

abstract class TripRepository {
  /// Get details of a specific trip
  Future<Trip> getTripDetails(int tripId);

  /// Get paginated list of trips
  Future<PaginatedTripList> getTripList({
    bool? forDriver,
    int? page,
    int? pageSize,
  });

  /// Update a trip's status and details
  Future<Trip> updateTrip({
    required int tripId,
    required TripStatus status,
    required double finalFare,
    DateTime? loadingStartTime,
    DateTime? loadingEndTime,
    DateTime? unloadingStartTime,
    DateTime? unloadingEndTime,
    DateTime? paymentTime,
    int? finalDuration,
    String? finalDistance,
    bool? isPaymentDone,
  });
} 