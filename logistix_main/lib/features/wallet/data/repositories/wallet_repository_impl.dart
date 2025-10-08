/// wallet_repository_impl.dart - Wallet Repository Implementation
/// 
/// Purpose:
/// - Concrete implementation of WalletRepository interface
/// - Handles HTTP API communication for wallet operations
/// - Manages wallet balance, transactions, and topup functionality
/// 
/// Key Logic:
/// - Implements WalletRepository interface with ApiClient integration
/// - Retrieves wallet balance with proper type conversion
/// - Fetches paginated wallet transaction history with filtering
/// - Handles wallet topup operations with request/response serialization
/// - Supports transaction filtering by type, date range, and pagination
/// - Uses structured data models for all wallet operations
/// - Provides comprehensive error propagation for API failures
/// - Manages JSON serialization for API communication

import '../../../../core/models/wallet_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final ApiClient _apiClient;

  WalletRepositoryImpl(this._apiClient);

  @override
  Future<double> getWalletBalance() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.walletBalance);
      final balance = response.data['balance'];
      if (balance == null) {
        return 0.0;
      }
      return (balance as num).toDouble();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PaginatedWalletTransactionList> getWalletTransactions({
    String? transactionType,
    DateTime? startTime,
    DateTime? endTime,
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (transactionType != null) queryParams['transaction_type'] = transactionType;
      if (startTime != null) queryParams['start_time'] = startTime.toIso8601String();
      if (endTime != null) queryParams['end_time'] = endTime.toIso8601String();
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;

      final response = await _apiClient.get(
        ApiEndpoints.walletTransactions,
        queryParameters: queryParams,
      );

      return PaginatedWalletTransactionList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WalletTopupResponse> topupWallet({
    required double amount,
    String? remarks,
  }) async {
    try {
      final request = WalletTopupRequest(
        amount: amount,
        remarks: remarks,
      );

      final response = await _apiClient.post(
        ApiEndpoints.walletTopup,
        data: request.toJson(),
      );

      return WalletTopupResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
} 