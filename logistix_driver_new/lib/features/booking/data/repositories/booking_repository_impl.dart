/**
 * booking_repository_impl.dart - Booking Repository Implementation
 * 
 * Purpose:
 * - Concrete implementation of BookingRepository interface
 * - Handles HTTP API communication for booking operations
 * - Manages booking creation, acceptance, and listing functionality
 * 
 * Key Logic:
 * - Implements BookingRepository interface with ApiClient integration
 * - Creates new booking requests with proper request serialization
 * - Handles booking acceptance for drivers with response parsing
 * - Fetches booking details and lists with error handling
 * - Uses structured data models for all booking operations
 * - Provides comprehensive error propagation for API failures
 * - Manages JSON serialization for API communication
 */

import '../../../../core/models/booking_model.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiClient _apiClient;

  BookingRepositoryImpl(this._apiClient);

  @override
  Future<Booking> createBooking(Map<String, dynamic> requestData) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createBooking,
        data: requestData,
      );

      return Booking.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Trip> acceptBooking(int bookingRequestId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.acceptBooking,
        data: {
          'booking_request_id': bookingRequestId,
        },
      );

      // Parse the trip data from the response
      final tripData = response.data['trip'];
      return Trip.fromJson(tripData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Booking> getBookingDetail(int bookingRequestId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.bookingDetail(bookingRequestId),
      );

      return Booking.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Booking>> getBookingList() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.bookingList);
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Booking.fromJson(json))
            .toList();
      }
      
      // Handle paginated response
      if (response.data is Map && response.data['results'] is List) {
        return (response.data['results'] as List)
            .map((json) => Booking.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
} 