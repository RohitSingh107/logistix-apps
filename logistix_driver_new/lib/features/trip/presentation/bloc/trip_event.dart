/// trip_event.dart - Trip BLoC Events
/// 
/// Purpose:
/// - Defines events for trip-related state management
/// - Handles trip data loading and pagination
/// - Manages trip status updates and filtering
/// 
/// Key Logic:
/// - LoadTrips: Initial trip loading with pagination support
/// - LoadMoreTrips: Pagination for loading additional trips
/// - RefreshTrips: Pull-to-refresh functionality
/// - FilterTrips: Filter trips by status or date range
/// - UpdateTripStatus: Update individual trip status
library;

import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial trips for the driver
class LoadTrips extends TripEvent {
  final int page;
  final int pageSize;
  final bool forDriver;

  const LoadTrips({
    this.page = 1,
    this.pageSize = 25,
    this.forDriver = true,
  });

  @override
  List<Object?> get props => [page, pageSize, forDriver];
}

/// Load more trips for pagination
class LoadMoreTrips extends TripEvent {
  final int page;
  final int pageSize;
  final bool forDriver;

  const LoadMoreTrips({
    required this.page,
    this.pageSize = 25,
    this.forDriver = true,
  });

  @override
  List<Object?> get props => [page, pageSize, forDriver];
}

/// Refresh trips (pull-to-refresh)
class RefreshTrips extends TripEvent {
  const RefreshTrips();
}

/// Filter trips by status
class FilterTrips extends TripEvent {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterTrips({
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, startDate, endDate];
}

/// Update trip status
class UpdateTripStatus extends TripEvent {
  final int tripId;
  final String status;

  const UpdateTripStatus({
    required this.tripId,
    required this.status,
  });

  @override
  List<Object?> get props => [tripId, status];
}
