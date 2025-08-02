import 'package:dio/dio.dart';
import '../models/trip_model.dart';
import '../network/api_client.dart';

abstract class TripRepository {
  Future<List<TripModel>> getTrips({bool? forDriver});
  Future<TripModel> getTripById(int id);
  Future<TripModel> updateTrip(int id, Map<String, dynamic> tripData);
}

class TripRepositoryImpl implements TripRepository {
  final ApiClient _apiClient;

  TripRepositoryImpl(this._apiClient);

  @override
  Future<List<TripModel>> getTrips({bool? forDriver}) async {
    try {
      final response = await _apiClient.get('/api/trip/list/', queryParameters: {
        if (forDriver != null) 'for_driver': forDriver,
      });
      
      final List<dynamic> tripsJson = response.data['results'] as List;
      return tripsJson.map((json) => TripModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TripModel> getTripById(int id) async {
    try {
      final response = await _apiClient.get('/api/trip/detail/$id/');
      return TripModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TripModel> updateTrip(int id, Map<String, dynamic> tripData) async {
    try {
      final response = await _apiClient.post('/api/trip/update/$id/', data: tripData);
      return TripModel.fromJson(response.data);
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
        final message = e.response?.data?['message'] ?? 'Server error occurred.';
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      default:
        return Exception('Network error occurred. Please try again.');
    }
  }
} 