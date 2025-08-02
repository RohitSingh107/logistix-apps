import 'package:dio/dio.dart';
import '../models/wallet_model.dart';
import '../network/api_client.dart';

abstract class WalletRepository {
  Future<double> getWalletBalance();
  Future<Map<String, dynamic>> topupWallet(double amount, {String? remarks});
  Future<List<WalletTransactionModel>> getWalletTransactions({
    String? transactionType,
    DateTime? startTime,
    DateTime? endTime,
    int? page,
    int? pageSize,
  });
}

class WalletRepositoryImpl implements WalletRepository {
  final ApiClient _apiClient;

  WalletRepositoryImpl(this._apiClient);

  @override
  Future<double> getWalletBalance() async {
    try {
      final response = await _apiClient.get('/api/payments/wallet/balance/');
      return (response.data['balance'] as num).toDouble();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> topupWallet(double amount, {String? remarks}) async {
    try {
      final data = <String, dynamic>{
        'amount': amount,
      };
      if (remarks != null) {
        data['remarks'] = remarks;
      }

      final response = await _apiClient.post('/api/payments/wallet/topup/', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<WalletTransactionModel>> getWalletTransactions({
    String? transactionType,
    DateTime? startTime,
    DateTime? endTime,
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (transactionType != null) {
        queryParams['transaction_type'] = transactionType;
      }
      if (startTime != null) {
        queryParams['start_time'] = startTime.toIso8601String();
      }
      if (endTime != null) {
        queryParams['end_time'] = endTime.toIso8601String();
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (pageSize != null) {
        queryParams['page_size'] = pageSize;
      }

      final response = await _apiClient.get('/api/payments/wallet/transactions/', queryParameters: queryParams);
      
      final List<dynamic> transactionsJson = response.data['results'] as List;
      return transactionsJson.map((json) => WalletTransactionModel.fromJson(json)).toList();
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