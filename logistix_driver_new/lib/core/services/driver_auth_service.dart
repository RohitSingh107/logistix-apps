/**
 * driver_auth_service.dart - Driver Authentication Service
 * 
 * Purpose:
 * - Provides driver-specific authentication and profile management
 * - Manages driver availability status and profile information
 * - Integrates with the main app's authentication system
 * 
 * Key Logic:
 * - Uses the ApiClient for proper HTTP requests with authentication
 * - Provides driver-specific API calls using proper endpoints
 * - Manages driver profile and availability status
 * - Handles driver-specific authentication flows
 */

import '../network/api_client.dart';
import 'api_endpoints.dart';

class DriverAuthService {
  final ApiClient _apiClient;
  
  DriverAuthService(this._apiClient);

  /// Get the current driver's profile information
  Future<Map<String, dynamic>?> getDriverProfile() async {
    try {
      print('🔍 DriverAuthService: Starting getDriverProfile');
      
      // Ensure we have a valid token
      print('🔑 DriverAuthService: Ensuring valid token...');
      await _apiClient.ensureValidToken();
      print('✅ DriverAuthService: Token validation complete');
      
      print('📡 DriverAuthService: Making API call to ${ApiEndpoints.driverProfile}');
      final response = await _apiClient.get(ApiEndpoints.driverProfile);
      print('📥 DriverAuthService: Received response with status ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ DriverAuthService: Successfully fetched driver profile');
        return response.data;
      } else {
        print('❌ DriverAuthService: API returned status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ DriverAuthService: Error fetching driver profile: $e');
      return null;
    }
  }

  /// Update driver availability status
  Future<Map<String, dynamic>?> updateDriverAvailability(bool isAvailable) async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.patch(
        ApiEndpoints.driverProfile,
        data: {'is_available': isAvailable},
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error updating driver availability: $e');
      return null;
    }
  }

  /// Create a new driver profile
  Future<Map<String, dynamic>?> createDriverProfile({
    required String licenseNumber,
    bool isAvailable = true,
  }) async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.post(
        ApiEndpoints.createDriver,
        data: {
          'license_number': licenseNumber,
          'is_available': isAvailable,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error creating driver profile: $e');
      return null;
    }
  }

  /// Update driver profile information
  Future<Map<String, dynamic>?> updateDriverProfile(Map<String, dynamic> profileData) async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.patch(
        ApiEndpoints.driverProfile,
        data: profileData,
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error updating driver profile: $e');
      return null;
    }
  }

  /// Get driver trips
  Future<Map<String, dynamic>?> getDriverTrips({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.get(
        ApiEndpoints.tripList,
        queryParameters: {
          'for_driver': true,
          'page': page,
          'page_size': pageSize,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error fetching driver trips: $e');
      return null;
    }
  }

  /// Accept a booking request
  Future<Map<String, dynamic>?> acceptBooking(int bookingId) async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.post(
        ApiEndpoints.acceptBooking,
        data: {'booking_request_id': bookingId},
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error accepting booking: $e');
      return null;
    }
  }

  /// Update trip status
  Future<Map<String, dynamic>?> updateTripStatus(int tripId, String status) async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.post(
        ApiEndpoints.updateTrip(tripId),
        data: {'status': status},
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error updating trip status: $e');
      return null;
    }
  }

  /// Get wallet balance
  Future<Map<String, dynamic>?> getWalletBalance() async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.get(ApiEndpoints.walletBalance);
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error fetching wallet balance: $e');
      return null;
    }
  }

  /// Get wallet transactions
  Future<Map<String, dynamic>?> getWalletTransactions({
    int page = 1,
    int pageSize = 10,
    String? startTime,
    String? endTime,
  }) async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (startTime != null) queryParams['start_time'] = startTime;
      if (endTime != null) queryParams['end_time'] = endTime;
      
      final response = await _apiClient.get(
        ApiEndpoints.walletTransactions,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error fetching wallet transactions: $e');
      return null;
    }
  }

  /// Get trip detail
  Future<Map<String, dynamic>?> getTripDetail(int tripId) async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.get(ApiEndpoints.tripDetail(tripId));
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error fetching trip detail: $e');
      return null;
    }
  }

  /// Update payment status for a trip
  Future<Map<String, dynamic>?> updatePaymentStatus(int tripId, bool isPaymentDone) async {
    try {
      // Ensure we have a valid token
      await _apiClient.ensureValidToken();
      
      final response = await _apiClient.post(
        ApiEndpoints.updateTrip(tripId),
        data: {'is_payment_done': isPaymentDone},
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error updating payment status: $e');
      return null;
    }
  }
} 