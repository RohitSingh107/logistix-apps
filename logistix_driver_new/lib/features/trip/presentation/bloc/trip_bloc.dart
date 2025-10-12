/// trip_bloc.dart - Trip BLoC Implementation
/// 
/// Purpose:
/// - Manages trip-related state and business logic
/// - Handles trip data fetching and pagination
/// - Provides state management for trip UI components
/// 
/// Key Logic:
/// - LoadTrips: Fetches initial trip list with pagination
/// - LoadMoreTrips: Handles pagination for loading additional trips
/// - RefreshTrips: Implements pull-to-refresh functionality
/// - FilterTrips: Applies filters to trip data
/// - UpdateTripStatus: Updates individual trip status
/// - Error handling with user-friendly messages
/// - State transitions for loading, success, and error states
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_model.dart';
import '../../domain/repositories/trip_repository.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository _tripRepository;

  TripBloc(this._tripRepository) : super(const TripInitial()) {
    on<LoadTrips>(_onLoadTrips);
    on<LoadMoreTrips>(_onLoadMoreTrips);
    on<RefreshTrips>(_onRefreshTrips);
    on<FilterTrips>(_onFilterTrips);
    on<UpdateTripStatus>(_onUpdateTripStatus);
  }

  /// Load initial trips
  Future<void> _onLoadTrips(LoadTrips event, Emitter<TripState> emit) async {
    try {
      emit(const TripLoading());

      final result = await _tripRepository.getTripList(
        forDriver: event.forDriver,
        page: event.page,
        pageSize: event.pageSize,
      );

      emit(TripLoaded(
        trips: result.results,
        currentPage: event.page,
        hasNextPage: result.next != null,
        hasPreviousPage: result.previous != null,
        totalCount: result.count,
      ));
    } catch (e) {
      emit(TripError(
        message: 'Failed to load trips: ${e.toString()}',
      ));
    }
  }

  /// Load more trips for pagination
  Future<void> _onLoadMoreTrips(LoadMoreTrips event, Emitter<TripState> emit) async {
    try {
      final currentState = state;
      if (currentState is! TripLoaded || currentState.isLoadingMore) {
        return;
      }

      // Emit loading more state
      emit(currentState.copyWith(isLoadingMore: true));

      final result = await _tripRepository.getTripList(
        forDriver: event.forDriver,
        page: event.page,
        pageSize: event.pageSize,
      );

      // Combine existing trips with new ones
      final allTrips = [...currentState.trips, ...result.results];

      emit(TripLoaded(
        trips: allTrips,
        currentPage: event.page,
        hasNextPage: result.next != null,
        hasPreviousPage: result.previous != null,
        totalCount: result.count,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(TripError(
        message: 'Failed to load more trips: ${e.toString()}',
        previousTrips: state is TripLoaded ? (state as TripLoaded).trips : null,
      ));
    }
  }

  /// Refresh trips (pull-to-refresh)
  Future<void> _onRefreshTrips(RefreshTrips event, Emitter<TripState> emit) async {
    try {
      final currentState = state;
      if (currentState is! TripLoaded) {
        // If no current data, just load initial trips
        add(const LoadTrips());
        return;
      }

      // Emit refreshing state
      emit(TripRefreshing(
        trips: currentState.trips,
        currentPage: currentState.currentPage,
        hasNextPage: currentState.hasNextPage,
        hasPreviousPage: currentState.hasPreviousPage,
        totalCount: currentState.totalCount,
      ));

      final result = await _tripRepository.getTripList(
        forDriver: true,
        page: 1,
        pageSize: 25,
      );

      emit(TripLoaded(
        trips: result.results,
        currentPage: 1,
        hasNextPage: result.next != null,
        hasPreviousPage: result.previous != null,
        totalCount: result.count,
      ));
    } catch (e) {
      emit(TripError(
        message: 'Failed to refresh trips: ${e.toString()}',
        previousTrips: state is TripLoaded ? (state as TripLoaded).trips : null,
      ));
    }
  }

  /// Filter trips
  Future<void> _onFilterTrips(FilterTrips event, Emitter<TripState> emit) async {
    try {
      emit(const TripLoading());

      final result = await _tripRepository.getTripList(
        forDriver: true,
        page: 1,
        pageSize: 25,
      );

      // Apply filters to results
      List<Trip> filteredTrips = result.results;

      if (event.status != null) {
        filteredTrips = filteredTrips.where((trip) {
          return trip.status.toString().split('.').last.toUpperCase() == event.status!.toUpperCase();
        }).toList();
      }

      if (event.startDate != null) {
        filteredTrips = filteredTrips.where((trip) {
          return trip.createdAt.isAfter(event.startDate!) || trip.createdAt.isAtSameMomentAs(event.startDate!);
        }).toList();
      }

      if (event.endDate != null) {
        filteredTrips = filteredTrips.where((trip) {
          return trip.createdAt.isBefore(event.endDate!) || trip.createdAt.isAtSameMomentAs(event.endDate!);
        }).toList();
      }

      emit(TripLoaded(
        trips: filteredTrips,
        currentPage: 1,
        hasNextPage: result.next != null,
        hasPreviousPage: result.previous != null,
        totalCount: filteredTrips.length,
      ));
    } catch (e) {
      emit(TripError(
        message: 'Failed to filter trips: ${e.toString()}',
      ));
    }
  }

  /// Update trip status
  Future<void> _onUpdateTripStatus(UpdateTripStatus event, Emitter<TripState> emit) async {
    try {
      final currentState = state;
      if (currentState is! TripLoaded) {
        return;
      }

      // Find and update the trip in the list
      final updatedTrips = currentState.trips.map((trip) {
        if (trip.id == event.tripId) {
          // Create updated trip with new status
          return trip.copyWith(
            status: TripStatus.values.firstWhere(
              (status) => status.toString().split('.').last.toUpperCase() == event.status.toUpperCase(),
            ),
          );
        }
        return trip;
      }).toList();

      emit(currentState.copyWith(trips: updatedTrips));
    } catch (e) {
      emit(TripError(
        message: 'Failed to update trip status: ${e.toString()}',
        previousTrips: state is TripLoaded ? (state as TripLoaded).trips : null,
      ));
    }
  }
}
