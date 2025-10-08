/// booking_repository.dart - Booking Repository Interface
/// 
/// Purpose:
/// - Defines the contract for booking-related data operations
/// - Provides abstraction layer for booking management
/// - Ensures consistent booking data access patterns across the application
/// 
/// Key Logic:
/// - Abstract repository interface following domain-driven design
/// - Manages booking creation, acceptance, and listing
/// - Supports booking detail retrieval and status updates
/// - Handles booking request lifecycle management
/// - Returns structured booking models for type safety
/// - Follows async/await pattern for all booking operations
/// - Supports comprehensive booking management functionality
library;

import '../../../../core/models/booking_model.dart';
import '../../../../core/models/trip_model.dart';

abstract class BookingRepository {
  /// Create a new booking request
  Future<Booking> createBooking(Map<String, dynamic> requestData);
  
  /// Accept a booking request (driver only)
  Future<Trip> acceptBooking(int bookingRequestId);
  
  /// Get booking request details
  Future<Booking> getBookingDetail(int bookingRequestId);
  
  /// Get list of booking requests
  Future<List<Booking>> getBookingList();
} 