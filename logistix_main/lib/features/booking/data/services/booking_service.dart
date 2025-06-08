import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../models/booking_request.dart';
import '../models/trip_detail.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  Future<BookingResponse> createBooking(BookingRequest request) async {
    try {
      print('Creating booking with data: ${request.toJson()}');
      
      final response = await _apiClient.post(
        ApiEndpoints.createBooking,
        data: request.toJson(),
      );

      return BookingResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  Future<TripDetail> getTripDetail(int tripId) async {
    try {
      print('Getting trip detail for trip ID: $tripId');
      
      final response = await _apiClient.get(
        ApiEndpoints.tripDetail(tripId),
      );

      return TripDetail.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error getting trip detail: $e');
      rethrow;
    }
  }

  // Polling method to check trip status until driver is assigned
  Stream<TripDetail> pollTripStatus(int tripId, {Duration interval = const Duration(seconds: 3)}) async* {
    while (true) {
      try {
        final tripDetail = await getTripDetail(tripId);
        yield tripDetail;
        
        // Stop polling if driver is assigned or trip is completed/cancelled
        if (tripDetail.hasDriver || tripDetail.isCompleted || tripDetail.isCancelled) {
          break;
        }
        
        await Future.delayed(interval);
      } catch (e) {
        print('Error polling trip status: $e');
        await Future.delayed(interval);
      }
    }
  }
} 