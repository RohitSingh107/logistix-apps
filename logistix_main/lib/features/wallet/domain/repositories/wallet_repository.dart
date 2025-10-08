/// wallet_repository.dart - Wallet Repository Interface
/// 
/// Purpose:
/// - Defines the contract for wallet-related data operations
/// - Provides abstraction layer for wallet balance and transaction management
/// - Ensures consistent wallet data access patterns across the application
/// 
/// Key Logic:
/// - Abstract repository interface following domain-driven design
/// - Manages wallet balance retrieval for authenticated users
/// - Supports paginated transaction history with filtering capabilities
/// - Handles wallet topup operations with amount and remarks
/// - Provides transaction filtering by type, date range, and pagination
/// - Returns structured wallet models for type safety
/// - Follows async/await pattern for all wallet operations
/// - Supports comprehensive transaction management functionality

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