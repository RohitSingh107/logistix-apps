/**
 * booking_repository.dart - Booking Repository Interface
 * 
 * Purpose:
 * - Defines the contract for booking-related data operations
 * - Provides abstraction layer for booking management functionality
 * - Ensures consistent booking data access patterns across the application
 * 
 * Key Logic:
 * - Abstract repository interface following domain-driven design
 * - Creates new booking requests with comprehensive location and timing data
 * - Handles booking acceptance process with trip creation
 * - Retrieves individual booking details and lists
 * - Supports all booking parameters including pickup/dropoff coordinates
 * - Manages goods information, payment modes, and fare estimation
 * - Returns structured BookingRequest and BookingAcceptResponse models
 * - Follows async/await pattern for all data operations
 */

import '../../../../core/models/booking_model.dart';

abstract class BookingRepository {
  /// Create a new booking request
  Future<BookingRequest> createBooking({
    required String senderName,
    required String receiverName,
    required String senderPhone,
    required String receiverPhone,
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required DateTime pickupTime,
    required String pickupAddress,
    required String dropoffAddress,
    required int vehicleTypeId,
    required String goodsType,
    required String goodsQuantity,
    required PaymentMode paymentMode,
    required double estimatedFare,
  });

  /// Accept a booking request and return the trip details
  Future<BookingAcceptResponse> acceptBooking(int bookingRequestId);

  /// Get details of a specific booking request
  Future<BookingRequest> getBookingDetail(int bookingRequestId);

  /// Get list of booking requests
  Future<List<BookingRequest>> getBookingList();
} 