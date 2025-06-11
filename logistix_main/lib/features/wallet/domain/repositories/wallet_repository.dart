import '../../../../core/models/wallet_model.dart';

abstract class WalletRepository {
  /// Get the current balance of the authenticated user's wallet
  Future<double> getWalletBalance();
  
  /// Get paginated transactions for the authenticated user's wallet
  Future<PaginatedWalletTransactionList> getWalletTransactions({
    String? transactionType,
    DateTime? startTime,
    DateTime? endTime,
    int? page,
    int? pageSize,
  });
  
  /// Add money to the wallet
  Future<WalletTopupResponse> topupWallet({
    required double amount,
    String? remarks,
  });
} 