import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../network/api_client.dart';

abstract class BookingRepository {
  Future<List<BookingRequestModel>> getBookingRequests();
  Future<BookingRequestModel> getBookingRequestById(int id);
  Future<BookingRequestModel> createBookingRequest(Map<String, dynamic> bookingData);
  Future<void> acceptBooking(int bookingRequestId);
}

class CoreBookingRepositoryImpl implements BookingRepository {
  final ApiClient _apiClient;

  CoreBookingRepositoryImpl(this._apiClient);

  @override
  Future<List<BookingRequestModel>> getBookingRequests() async {
    try {
      final response = await _apiClient.get('/api/booking/list/');
      
      final List<dynamic> bookingsJson = response.data as List;
      return bookingsJson.map((json) => BookingRequestModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<BookingRequestModel> getBookingRequestById(int id) async {
    try {
      final response = await _apiClient.get('/api/booking/detail/$id/');
      return BookingRequestModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<BookingRequestModel> createBookingRequest(Map<String, dynamic> bookingData) async {
    try {
      final response = await _apiClient.post('/api/booking/create/', data: bookingData);
      
      // The API returns a nested structure with the booking data under 'booking_request' key
      final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
      final Map<String, dynamic> bookingJson = responseData['booking_request'] as Map<String, dynamic>;
      
      return BookingRequestModel.fromJson(bookingJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> acceptBooking(int bookingRequestId) async {
    try {
      await _apiClient.post('/api/booking/accept/', data: {
        'booking_request_id': bookingRequestId,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        print('DEBUG: API Error Response: $responseData');
        
        String message = 'An error occurred';
        if (responseData is Map<String, dynamic>) {
          // Try to extract error message from different possible fields
          message = responseData['message'] ?? 
                   responseData['error'] ?? 
                   responseData['detail'] ?? 
                   responseData.toString();
        }
        
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      default:
        return Exception('Network error occurred: ${e.message}');
    }
  }
} 