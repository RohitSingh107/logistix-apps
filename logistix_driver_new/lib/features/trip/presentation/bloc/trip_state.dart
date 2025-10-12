/// trip_state.dart - Trip BLoC States
/// 
/// Purpose:
/// - Defines states for trip-related UI management
/// - Handles loading, success, and error states
/// - Manages pagination and data accumulation
/// 
/// Key Logic:
/// - TripInitial: Initial state before any data loading
/// - TripLoading: Loading state for initial data fetch
/// - TripLoaded: Success state with trip data and pagination info
/// - TripLoadingMore: Loading state for pagination
/// - TripError: Error state with error message
/// - TripRefreshing: Refreshing state for pull-to-refresh
library;

import 'package:equatable/equatable.dart';
import '../../../../core/models/trip_model.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data loading
class TripInitial extends TripState {
  const TripInitial();
}

/// Loading state for initial data fetch
class TripLoading extends TripState {
  const TripLoading();
}

/// Success state with trip data and pagination info
class TripLoaded extends TripState {
  final List<Trip> trips;
  final int currentPage;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final int totalCount;
  final bool isLoadingMore;

  const TripLoaded({
    required this.trips,
    required this.currentPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.totalCount,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        trips,
        currentPage,
        hasNextPage,
        hasPreviousPage,
        totalCount,
        isLoadingMore,
      ];

  /// Create a copy with updated fields
  TripLoaded copyWith({
    List<Trip>? trips,
    int? currentPage,
    bool? hasNextPage,
    bool? hasPreviousPage,
    int? totalCount,
    bool? isLoadingMore,
  }) {
    return TripLoaded(
      trips: trips ?? this.trips,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Loading state for pagination
class TripLoadingMore extends TripState {
  final List<Trip> trips;
  final int currentPage;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final int totalCount;

  const TripLoadingMore({
    required this.trips,
    required this.currentPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [
        trips,
        currentPage,
        hasNextPage,
        hasPreviousPage,
        totalCount,
      ];
}

/// Error state with error message
class TripError extends TripState {
  final String message;
  final List<Trip>? previousTrips;

  const TripError({
    required this.message,
    this.previousTrips,
  });

  @override
  List<Object?> get props => [message, previousTrips];
}

/// Refreshing state for pull-to-refresh
class TripRefreshing extends TripState {
  final List<Trip> trips;
  final int currentPage;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final int totalCount;

  const TripRefreshing({
    required this.trips,
    required this.currentPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [
        trips,
        currentPage,
        hasNextPage,
        hasPreviousPage,
        totalCount,
      ];
}
