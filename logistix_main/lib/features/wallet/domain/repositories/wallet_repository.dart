import '../../../../core/models/wallet_model.dart';

abstract class WalletRepository {
  Future<double> getWalletBalance();
  
  Future<List<WalletTransaction>> getWalletTransactions({
    String? transactionType,
    int? limit,
  });
} 