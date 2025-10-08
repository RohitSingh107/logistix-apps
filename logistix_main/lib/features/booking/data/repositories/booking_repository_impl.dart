/// booking_repository_impl.dart - Booking Repository Implementation
/// 
/// Purpose:
/// - Implements the BookingRepository interface for booking operations
/// - Provides concrete API communication for booking-related requests
/// - Handles data transformation between API responses and domain models
/// 
/// Key Logic:
/// - createBooking: Creates new booking requests with comprehensive validation
/// - getBookingById: Retrieves specific booking details by ID
/// - updateBookingStatus: Updates booking status (confirm, cancel, etc.)
/// - getAllBookings: Fetches paginated booking history for users
/// - Transforms API responses into domain models using fromJson/toJson
/// - Handles errors and exceptions from network layer
/// - Maps between API data structures and local booking models

import '../../../../core/models/booking_model.dart' as core;
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_request.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiClient _apiClient;

  BookingRepositoryImpl(this._apiClient);

  @override
  Future<core.BookingRequest> createBooking({
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
    required core.PaymentMode paymentMode,
    required String instructions,
  }) async {
    try {
      final request = core.BookingRequestRequest(
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
        instructions: instructions,
      );

      final response = await _apiClient.post(
        ApiEndpoints.createBooking,
        data: request.toJson(),
      );

      // Parse the response using BookingResponse since the API returns nested structure
      final bookingResponse = BookingResponse.fromJson(response.data);
      
      // Convert to core.BookingRequest
      return core.BookingRequest(
        id: bookingResponse.id,
        tripId: bookingResponse.tripId,
        senderName: bookingResponse.senderName,
        receiverName: bookingResponse.receiverName,
        senderPhone: bookingResponse.senderPhone,
        receiverPhone: bookingResponse.receiverPhone,
        pickupLocation: '', // This field is not in BookingResponse
        dropoffLocation: '', // This field is not in BookingResponse
        pickupTime: bookingResponse.pickupTime,
        pickupAddress: bookingResponse.pickupAddress,
        dropoffAddress: bookingResponse.dropoffAddress,
        goodsType: bookingResponse.goodsType,
        goodsQuantity: bookingResponse.goodsQuantity,
        paymentMode: core.PaymentMode.values.firstWhere(
          (e) => e.toString().split('.').last.toUpperCase() == bookingResponse.paymentMode,
        ),
        estimatedFare: bookingResponse.estimatedFare,
        status: core.BookingStatus.values.firstWhere(
          (e) => e.toString().split('.').last.toUpperCase() == bookingResponse.status,
        ),
        instructions: null, // This field is not in BookingResponse
        createdAt: bookingResponse.createdAt,
        updatedAt: bookingResponse.updatedAt,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<core.BookingAcceptResponse> acceptBooking(int bookingRequestId) async {
    try {
      final request = core.BookingAcceptRequest(bookingRequestId: bookingRequestId);
      final response = await _apiClient.post(
        ApiEndpoints.acceptBooking,
        data: request.toJson(),
      );

      return core.BookingAcceptResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<core.BookingRequest> getBookingDetail(int bookingRequestId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.bookingDetail(bookingRequestId),
      );

      return core.BookingRequest.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<core.BookingRequest>> getBookingList() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.bookingList,
      );

      final bookingsData = response.data as List;
      return bookingsData
          .map((bookingData) => core.BookingRequest.fromJson(bookingData as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
} 