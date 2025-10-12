/// trip_status_service.dart - Trip Status Update Service
/// 
/// Purpose:
/// - Handles trip status updates through API integration
/// - Manages status transitions (ACCEPTED -> IN_PROGRESS, IN_PROGRESS -> COMPLETED, etc.)
/// - Provides real-time status updates and error handling
/// 
/// Key Logic:
/// - Status update API calls with proper error handling
/// - Status transition validation
/// - Real-time feedback and notifications
/// - Integration with trip management system
library;

import '../network/api_client.dart';
import '../models/trip_model.dart';

class TripStatusService {
  final ApiClient _apiClient;

  TripStatusService(this._apiClient);

  /// Update trip status with API integration
  Future<Trip> updateTripStatus(int tripId, TripStatus newStatus) async {
    try {
      print("🔄 Updating trip $tripId status to ${newStatus.name}");
      
      // Validate status transition
      if (!_isValidStatusTransition(newStatus)) {
        throw Exception('Invalid status transition to ${newStatus.name}');
      }

      // Make API call to update trip status
      final response = await _apiClient.patch(
        '/api/trip/update/$tripId/',
        data: {
          'status': _getStatusApiValue(newStatus),
        },
      );

      print("✅ Trip status updated successfully: ${response.data}");

      // Parse the response to get updated trip details
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
      print("🔍 Attempting to parse trip data...");
      Trip trip;
      try {
        trip = Trip.fromJson(tripData);
        print("✅ Trip object created successfully: ${trip.id}");
      } catch (e, stackTrace) {
        print("❌ Error parsing trip data: $e");
        print("❌ Stack trace: $stackTrace");
        print("❌ Trip data: $tripData");
        rethrow;
      }

      return trip;
    } catch (e) {
      print("❌ Error updating trip status: $e");
      
      // Provide user-friendly error messages
      String errorMessage = 'Failed to update trip status';
      if (e.toString().contains('no longer available')) {
        errorMessage = 'This trip is no longer available';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('unauthorized')) {
        errorMessage = 'Please log in again to update trip status';
      } else if (e.toString().contains('Invalid response')) {
        errorMessage = 'Server error. Please try again';
      } else if (e.toString().contains('No trip data')) {
        errorMessage = 'Status updated but trip data is missing';
      } else if (e.toString().contains('403')) {
        errorMessage = 'You are not authorized to update this trip';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Trip not found';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid status update request';
      } else if (e.toString().contains('Invalid status transition')) {
        errorMessage = e.toString();
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Check if status transition is valid
  bool _isValidStatusTransition(TripStatus newStatus) {
    // Define valid status transitions
    // ACCEPTED -> IN_PROGRESS or CANCELLED
    // IN_PROGRESS -> COMPLETED or CANCELLED
    // COMPLETED and CANCELLED are final states
    
    switch (newStatus) {
      case TripStatus.accepted:
        return false; // Cannot go back to accepted
      case TripStatus.inProgress:
        return true; // Can transition to inProgress (IN_PROGRESS)
      case TripStatus.completed:
        return true; // Can transition to completed
      case TripStatus.cancelled:
        return true; // Can transition to cancelled
    }
  }

  /// Get available status transitions for current status
  List<TripStatus> getAvailableTransitions(TripStatus currentStatus) {
    switch (currentStatus) {
      case TripStatus.accepted:
        return [TripStatus.inProgress, TripStatus.cancelled];
      case TripStatus.inProgress:
        return [TripStatus.completed, TripStatus.cancelled];
      case TripStatus.completed:
        return []; // Final state
      case TripStatus.cancelled:
        return []; // Final state
    }
  }

  /// Get status display text
  String getStatusDisplayText(TripStatus status) {
    switch (status) {
      case TripStatus.accepted:
        return 'ACCEPTED';
      case TripStatus.inProgress:
        return 'IN_PROGRESS';
      case TripStatus.completed:
        return 'COMPLETED';
      case TripStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Get status button text
  String getStatusButtonText(TripStatus status) {
    switch (status) {
      case TripStatus.accepted:
        return 'Start Trip';
      case TripStatus.inProgress:
        return 'Complete Trip';
      case TripStatus.completed:
        return 'Trip Completed';
      case TripStatus.cancelled:
        return 'Trip Cancelled';
    }
  }

  /// Get status icon
  String getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.accepted:
        return '✅';
      case TripStatus.inProgress:
        return '🚗';
      case TripStatus.completed:
        return '🏁';
      case TripStatus.cancelled:
        return '❌';
    }
  }

  /// Get status color
  String getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.accepted:
        return 'blue';
      case TripStatus.inProgress:
        return 'orange';
      case TripStatus.completed:
        return 'green';
      case TripStatus.cancelled:
        return 'red';
    }
  }

  /// Get the correct API value for status
  String _getStatusApiValue(TripStatus status) {
    switch (status) {
      case TripStatus.accepted:
        return 'ACCEPTED';
      case TripStatus.inProgress:
        return 'IN_PROGRESS';
      case TripStatus.completed:
        return 'COMPLETED';
      case TripStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Send update message to trip
  Future<void> sendTripUpdateMessage(int tripId, String message) async {
    try {
      print("📝 Sending trip update message: $message");
      
      // Make API call to send update message
      final response = await _apiClient.patch(
        '/api/trip/update/$tripId/',
        data: {
          'update_message': message,
        },
      );

      print("✅ Trip update message sent successfully: ${response.data}");
    } catch (e) {
      print("❌ Error sending trip update message: $e");
      
      // Provide user-friendly error messages
      String errorMessage = 'Failed to send update message';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('unauthorized')) {
        errorMessage = 'Please log in again to send update';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Trip not found';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid update message';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Send cash collection update to trip
  Future<void> sendCashCollectionUpdate(int tripId, String message) async {
    try {
      print("💰 Sending cash collection update: $message");
      
      // Make API call to send cash collection update
      final response = await _apiClient.patch(
        '/api/trip/update/$tripId/',
        data: {
          'update_message': message,
          'is_payment_done': true,
        },
      );

      print("✅ Cash collection update sent successfully: ${response.data}");
    } catch (e) {
      print("❌ Error sending cash collection update: $e");
      
      // Provide user-friendly error messages
      String errorMessage = 'Failed to record cash collection';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('unauthorized')) {
        errorMessage = 'Please log in again to record cash collection';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Trip not found';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid cash collection update';
      }
      
      throw Exception(errorMessage);
    }
  }
}
