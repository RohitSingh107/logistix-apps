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
      final response = await _apiClient.post(
        ApiEndpoints.createBooking,
        data: {
          'sender_name': senderName,
          'receiver_name': receiverName,
          'sender_phone': senderPhone,
          'receiver_phone': receiverPhone,
          'pickup_latitude': pickupLatitude,
          'pickup_longitude': pickupLongitude,
          'dropoff_latitude': dropoffLatitude,
          'dropoff_longitude': dropoffLongitude,
          'pickup_time': pickupTime.toIso8601String(),
          'pickup_address': pickupAddress,
          'dropoff_address': dropoffAddress,
          'vehicle_type_id': vehicleTypeId,
          'goods_type': goodsType,
          'goods_quantity': goodsQuantity,
          'payment_mode': paymentMode.toString().split('.').last.toUpperCase(),
          'estimated_fare': estimatedFare,
        },
      );

      // Extract the booking_request data from the nested response
      final bookingData = response.data['booking_request'] as Map<String, dynamic>;
      return BookingRequest.fromJson(bookingData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> acceptBooking(int bookingRequestId) async {
    try {
      final request = BookingAcceptRequest(bookingRequestId: bookingRequestId);
      await _apiClient.post(
        ApiEndpoints.acceptBooking,
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
} 