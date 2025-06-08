import '../../../../core/models/wallet_model.dart';

abstract class WalletRepository {
  /// Get the current balance of the authenticated user's wallet
  Future<double> getWalletBalance();
  
  /// Get all transactions for the authenticated user's wallet
  Future<List<WalletTransaction>> getWalletTransactions({
    String? transactionType,
    int? limit,
  });
  
  /// Add money to the wallet
  Future<WalletTopupResponse> topupWallet({
    required double amount,
    String? remarks,
  });
} 