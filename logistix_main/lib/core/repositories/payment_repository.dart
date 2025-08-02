import 'package:dio/dio.dart';
import '../models/payment_model.dart';
import '../network/api_client.dart';

abstract class PaymentRepository {
  Future<List<PaymentModel>> getPayments({String? status});
  Future<PaymentModel> getPaymentById(String id);
  Future<PaymentModel> createPayment(Map<String, dynamic> paymentData);
  Future<PaymentModel> processPayment(String paymentId);
  Future<PaymentModel> refundPayment(String paymentId, {double? amount});
  Future<List<PaymentModel>> getCustomerPayments(String customerId);
  Future<Map<String, dynamic>> getPaymentMethods();
  Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> methodData);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepositoryImpl(this._apiClient);

  @override
  Future<List<PaymentModel>> getPayments({String? status}) async {
    try {
      final response = await _apiClient.get('/payments', queryParameters: {
        if (status != null) 'status': status,
      });
      
      final List<dynamic> paymentsJson = response.data['data'] as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String id) async {
    try {
      final response = await _apiClient.get('/payments/$id');
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaymentModel> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await _apiClient.post('/payments', data: paymentData);
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaymentModel> processPayment(String paymentId) async {
    try {
      final response = await _apiClient.post('/payments/$paymentId/process');
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaymentModel> refundPayment(String paymentId, {double? amount}) async {
    try {
      final response = await _apiClient.post('/payments/$paymentId/refund', data: {
        if (amount != null) 'amount': amount,
      });
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<PaymentModel>> getCustomerPayments(String customerId) async {
    try {
      final response = await _apiClient.get('/customers/$customerId/payments');
      final List<dynamic> paymentsJson = response.data['data'] as List;
      return paymentsJson.map((json) => PaymentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get('/payment-methods');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> methodData) async {
    try {
      final response = await _apiClient.post('/payment-methods', data: methodData);
      return response.data as Map<String, dynamic>;
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
        final message = e.response?.data?['message'] ?? 'An error occurred';
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      default:
        return Exception('Network error occurred');
    }
  }
} 