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

  /// Accept a booking request
  Future<void> acceptBooking(int bookingRequestId);
} 