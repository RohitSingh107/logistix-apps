/**
 * booking_repository_impl.dart - Booking Repository Implementation
 * 
 * Purpose:
 * - Implements the BookingRepository interface for booking operations
 * - Provides concrete API communication for booking-related requests
 * - Handles data transformation between API responses and domain models
 * 
 * Key Logic:
 * - createBooking: Creates new booking requests with comprehensive validation
 * - getBookingById: Retrieves specific booking details by ID
 * - updateBookingStatus: Updates booking status (confirm, cancel, etc.)
 * - getAllBookings: Fetches paginated booking history for users
 * - Transforms API responses into domain models using fromJson/toJson
 * - Handles errors and exceptions from network layer
 * - Maps between API data structures and local booking models
 */

import '../../../../core/models/booking_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiClient _apiClient;

  BookingRepositoryImpl(this._apiClient);

  @override
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
  }) async {
    try {
      final request = BookingRequestRequest(
        senderName: senderName,
        receiverName: receiverName,
        senderPhone: senderPhone,
        receiverPhone: receiverPhone,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        dropoffLatitude: dropoffLatitude,
        dropoffLongitude: dropoffLongitude,
        pickupTime: pickupTime,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        vehicleTypeId: vehicleTypeId,
        goodsType: goodsType,
        goodsQuantity: goodsQuantity,
        paymentMode: paymentMode,
        estimatedFare: estimatedFare,
      );

      final response = await _apiClient.post(
        ApiEndpoints.createBooking,
        data: request.toJson(),
      );

      return BookingRequest.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BookingAcceptResponse> acceptBooking(int bookingRequestId) async {
    try {
      final request = BookingAcceptRequest(bookingRequestId: bookingRequestId);
      final response = await _apiClient.post(
        ApiEndpoints.acceptBooking,
        data: request.toJson(),
      );

      return BookingAcceptResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BookingRequest> getBookingDetail(int bookingRequestId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.bookingDetail(bookingRequestId),
      );

      return BookingRequest.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BookingRequest>> getBookingList() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.bookingList,
      );

      final bookingsData = response.data as List;
      return bookingsData
          .map((bookingData) => BookingRequest.fromJson(bookingData as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
} 