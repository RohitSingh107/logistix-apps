/// booking_service.dart - Booking Operations Service
/// 
/// Purpose:
/// - Handles all booking-related API operations and business logic
/// - Manages booking creation, status polling, and trip tracking
/// - Provides real-time updates through streaming interfaces
/// 
/// Key Logic:
/// - Creates new bookings via API with comprehensive error handling
/// - Retrieves booking details and trip information from endpoints
/// - Implements intelligent polling system that transitions from booking to trip status
/// - Provides streaming interfaces for real-time status updates
/// - Handles booking lifecycle: REQUESTED → SEARCHING → ACCEPTED → TRIP
/// - Supports trip status polling once driver is assigned
/// - Manages booking and trip list retrieval with pagination support
/// - Provides user-friendly status messages based on current state
/// - Handles various response formats (paginated, legacy, direct list)

import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../models/booking_request.dart';
import '../models/trip_detail.dart';
import '../models/booking_list_response.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  Future<BookingResponse> createBooking(BookingRequest request) async {
    try {
      print('Creating booking with data: ${request.toJson()}');
      
      final response = await _apiClient.post(
        ApiEndpoints.createBooking,
        data: request.toJson(),
      );

      return BookingResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  Future<BookingResponse> getBookingDetail(int bookingId) async {
    try {
      print('Getting booking detail for booking ID: $bookingId');
      
      final response = await _apiClient.get(
        ApiEndpoints.bookingDetail(bookingId),
      );

      return BookingResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error getting booking detail: $e');
      rethrow;
    }
  }

  Future<TripDetail> getTripDetail(int tripId) async {
    try {
      print('Getting trip detail for trip ID: $tripId');
      
      final response = await _apiClient.get(
        ApiEndpoints.tripDetail(tripId),
      );

      // Extract trip data from the "trip" wrapper
      final tripData = response.data['trip'] as Map<String, dynamic>;
      return TripDetail.fromJson(tripData);
    } catch (e) {
      print('Error getting trip detail: $e');
      rethrow;
    }
  }

  // Enhanced polling method that first polls booking status, then trip status
  Stream<dynamic> pollBookingStatus(int bookingId, {Duration interval = const Duration(seconds: 3)}) async* {
    while (true) {
      try {
        // First, poll the booking detail to check status
        final bookingDetail = await getBookingDetail(bookingId);
        
        if (bookingDetail.isAccepted && bookingDetail.tripId != null) {
          // Once accepted and trip_id is available, switch to trip polling
          yield bookingDetail; // Yield the accepted booking first
          
          // Now start polling trip detail for driver assignment and further updates
          await for (final tripDetail in pollTripStatus(bookingDetail.tripId!)) {
            yield tripDetail;
          }
          break; // Exit the main loop once trip polling starts
        } else if (bookingDetail.isCancelled) {
          // If cancelled, yield the booking and stop polling
          yield bookingDetail;
          break;
        } else {
          // Still in REQUESTED or SEARCHING state, continue polling booking
          yield bookingDetail;
        }
        
        await Future.delayed(interval);
      } catch (e) {
        print('Error polling booking status: $e');
        await Future.delayed(interval);
      }
    }
  }

  // Original trip polling method (now used internally after booking is accepted)
  Stream<TripDetail> pollTripStatus(int tripId, {Duration interval = const Duration(seconds: 3)}) async* {
    while (true) {
      try {
        final tripDetail = await getTripDetail(tripId);
        yield tripDetail;
        
        // Stop polling if trip is completed or cancelled
        if (tripDetail.isCompleted || tripDetail.isCancelled) {
          break;
        }
        
        await Future.delayed(interval);
      } catch (e) {
        print('Error polling trip status: $e');
        await Future.delayed(interval);
      }
    }
  }

  // Helper method to get appropriate status message based on booking/trip state
  String getStatusMessage(dynamic statusObject) {
    if (statusObject is BookingResponse) {
      switch (statusObject.status) {
        case 'REQUESTED':
          return 'Processing your booking request...';
        case 'SEARCHING':
          return 'Looking for drivers nearby...';
        case 'ACCEPTED':
          return 'Driver found! Getting driver details...';
        case 'CANCELLED':
          return 'Booking was cancelled';
        default:
          return 'Processing booking...';
      }
    } else if (statusObject is TripDetail) {
      if (statusObject.hasDriver) {
        return 'Driver assigned! Preparing for pickup...';
      } else {
        return 'Finalizing driver assignment...';
      }
    }
    return 'Loading...';
    }

  Future<BookingListResponse> getBookingList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('Getting booking list with pagination: page=$page, pageSize=$pageSize');
      
      final queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      
      final response = await _apiClient.get(
        ApiEndpoints.bookingList,
        queryParameters: queryParams,
      );

      return BookingListResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error getting booking list: $e');
      rethrow;
    }
  }

  Future<List<TripDetail>> getTripList({
    bool? forDriver,
    int? page,
    int? pageSize,
  }) async {
    try {
      print('Getting trip list with pagination: page=$page, pageSize=$pageSize');
      
      final queryParams = <String, dynamic>{};
      if (forDriver != null) queryParams['for_driver'] = forDriver;
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;
      
      final response = await _apiClient.get(
        ApiEndpoints.tripList,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      // Handle paginated response structure
      List<dynamic> tripsData;
      if (response.data is Map && response.data.containsKey('results')) {
        // New paginated format
        tripsData = response.data['results'] as List? ?? [];
      } else if (response.data is Map && response.data.containsKey('trips')) {
        // Legacy format
        tripsData = response.data['trips'] as List? ?? [];
      } else if (response.data is List) {
        // Direct list format
        tripsData = response.data as List;
      } else {
        tripsData = [];
      }

      return tripsData
          .map((tripData) => TripDetail.fromJson(tripData as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting trip list: $e');
      rethrow;
    }
  }
} 