/// ride_action_service.dart - Professional Ride Action Service
/// 
/// Purpose:
/// - Handles ride accept/reject actions with professional API integration
/// - Manages ride state and driver availability
/// - Provides real-time feedback and status updates
/// - Implements Uber-like ride acceptance flow
/// 
/// Key Logic:
/// - Accepts rides with proper API integration
/// - Updates driver availability status
/// - Handles ride state transitions
/// - Provides comprehensive error handling
/// - Manages trip creation and status updates
library;

import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../di/service_locator.dart';
import '../models/trip_model.dart';
import '../models/booking_model.dart';

class RideActionService {
  final ApiClient _apiClient;

  RideActionService(this._apiClient);

  /// Accept a ride request (Professional Uber-like implementation)
  Future<Trip> acceptRide(String bookingRequestId) async {
    try {
      print("🚗 Accepting ride request: $bookingRequestId");
      
      // Validate booking request ID
      if (bookingRequestId.isEmpty) {
        throw Exception('Invalid booking request ID');
      }

      // Make API call to accept the booking directly
      final response = await _apiClient.post(
        '/api/booking/accept/',
        data: {
          'booking_request_id': int.parse(bookingRequestId),
        },
      );

      print("✅ Ride accepted successfully: ${response.data}");

      // Parse the response to get trip details
      if (response.data == null) {
        throw Exception('Invalid response from server');
      }

      final responseData = response.data;
      print("🔍 Response data: $responseData");

      // Handle different response formats
      Map<String, dynamic> tripData;
      
      if (responseData['trip'] != null) {
        // Format: {"message": "...", "trip": {...}}
        tripData = responseData['trip'];
        print("🔍 Found trip data in response: $tripData");
      } else if (responseData['id'] != null) {
        // Format: direct trip object
        tripData = responseData;
        print("🔍 Found direct trip data: $tripData");
      } else {
        print("❌ No trip data found in response");
        throw Exception('No trip data received from server');
      }

      // Create Trip object from JSON
      final trip = Trip.fromJson(tripData);
      print("✅ Trip object created successfully: ${trip.id}");

      // Update driver availability status
      await _updateDriverAvailability(false);

      // Emit trip accepted event (for real-time updates)
      _emitTripAcceptedEvent(trip);

      return trip;
    } catch (e) {
      print("❌ Error accepting ride: $e");
      
      // Provide user-friendly error messages
      String errorMessage = 'Failed to accept ride';
      if (e.toString().contains('no longer available')) {
        errorMessage = 'This ride is no longer available';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('unauthorized')) {
        errorMessage = 'Please log in again to accept rides';
      } else if (e.toString().contains('Invalid response')) {
        errorMessage = 'Server error. Please try again';
      } else if (e.toString().contains('No trip data')) {
        errorMessage = 'Booking accepted but trip data is missing';
      } else if (e.toString().contains('403')) {
        errorMessage = 'You are not authorized to accept this booking';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Booking not found';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid booking request';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Reject a ride request
  Future<void> rejectRide(String bookingRequestId) async {
    try {
      print("❌ Rejecting ride request: $bookingRequestId");
      
      // Validate booking request ID
      if (bookingRequestId.isEmpty) {
        throw Exception('Invalid booking request ID');
      }

      // For reject, we just close the popup without making any API call
      print("✅ Ride rejected - popup closed");
      
    } catch (e) {
      print("❌ Error rejecting ride: $e");
      throw Exception('Failed to reject ride: $e');
    }
  }

  /// Check if ride is still available
  Future<bool> _checkRideAvailability(String bookingRequestId) async {
    try {
      final response = await _apiClient.get('/api/booking/detail/$bookingRequestId/');
      final status = response.data['booking_request']['status'];
      
      // Ride is available if status is SEARCHING, PENDING, or AVAILABLE
      return status == 'SEARCHING' || status == 'PENDING' || status == 'AVAILABLE';
    } catch (e) {
      print("❌ Error checking ride availability: $e");
      return false;
    }
  }

  /// Update driver availability status
  Future<void> _updateDriverAvailability(bool isAvailable) async {
    try {
      final driverId = await _getCurrentDriverId();
      
      await _apiClient.patch(
        '/api/driver/profile/',
        data: {
          'is_available': isAvailable,
        },
      );
      
      print("✅ Driver availability updated: $isAvailable");
    } catch (e) {
      print("❌ Error updating driver availability: $e");
      // Don't throw here as it's not critical for ride acceptance
    }
  }

  /// Get current driver ID
  Future<String> _getCurrentDriverId() async {
    try {
      // This would typically come from the auth service or user profile
      // For now, return a placeholder - in production, get from user session
      return '1'; // Replace with actual driver ID from auth service
    } catch (e) {
      print("❌ Error getting driver ID: $e");
      throw Exception('Failed to get driver ID: $e');
    }
  }

  /// Emit trip accepted event for real-time updates
  void _emitTripAcceptedEvent(Trip trip) {
    try {
      // This would typically emit to a stream or event bus
      // For now, just log the event
      print("🎉 Trip accepted event emitted: ${trip.id}");
      
      // In a full implementation, you might:
      // - Emit to a stream for UI updates
      // - Send to a real-time service
      // - Update local storage
      // - Trigger navigation to trip screen
    } catch (e) {
      print("❌ Error emitting trip accepted event: $e");
    }
  }

  /// Get booking details
  Future<Booking> getBookingDetails(String bookingRequestId) async {
    try {
      final response = await _apiClient.get('/api/booking/detail/$bookingRequestId/');
      return Booking.fromJson(response.data);
    } catch (e) {
      print("❌ Error getting booking details: $e");
      throw Exception('Failed to get booking details: $e');
    }
  }

  /// Get available bookings for driver
  Future<List<Booking>> getAvailableBookings() async {
    try {
      final response = await _apiClient.get('/api/booking/list/');
      final List<dynamic> bookingsData = response.data['results'] ?? [];
      return bookingsData.map((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      print("❌ Error getting available bookings: $e");
      throw Exception('Failed to get available bookings: $e');
    }
  }
} 