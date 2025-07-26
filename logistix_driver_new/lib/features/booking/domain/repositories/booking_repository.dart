/**
 * booking_repository.dart - Booking Repository Interface
 * 
 * Purpose:
 * - Defines the contract for booking-related data operations
 * - Provides abstraction layer for booking management
 * - Ensures consistent booking data access patterns across the application
 * 
 * Key Logic:
 * - Abstract repository interface following domain-driven design
 * - Manages booking creation, acceptance, and listing
 * - Supports booking detail retrieval and status updates
 * - Handles booking request lifecycle management
 * - Returns structured booking models for type safety
 * - Follows async/await pattern for all booking operations
 * - Supports comprehensive booking management functionality
 */

import '../../../../core/models/booking_model.dart';

abstract class BookingRepository {
  /// Create a new booking request
  Future<BookingRequest> createBooking(BookingRequestRequest request);
  
  /// Accept a booking request (driver only)
  Future<BookingAcceptResponse> acceptBooking(int bookingRequestId);
  
  /// Get booking request details
  Future<BookingRequest> getBookingDetail(int bookingRequestId);
  
  /// Get list of booking requests
  Future<List<BookingRequest>> getBookingList();
} 