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
      return response.data['balance'].toDouble();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WalletTransaction>> getWalletTransactions({
    String? transactionType,
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.walletTransactions,
        queryParameters: {
          if (transactionType != null) 'transaction_type': transactionType,
          if (limit != null) 'limit': limit,
        },
      );

      return (response.data['transactions'] as List)
          .map((json) => WalletTransaction.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
} 