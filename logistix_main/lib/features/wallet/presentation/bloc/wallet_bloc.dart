/**
 * wallet_bloc.dart - Wallet Management Business Logic Component
 * 
 * Purpose:
 * - Manages wallet operations and state using BLoC pattern
 * - Handles balance retrieval, transaction history, and balance addition
 * - Provides paginated transaction loading and filtering capabilities
 * 
 * Key Logic:
 * - LoadWalletData: Fetches wallet balance and initial transaction history
 * - RefreshWalletData: Refreshes wallet data for pull-to-refresh functionality
 * - LoadMoreTransactions: Implements paginated loading for transaction history
 * - FilterTransactions: Supports transaction filtering by type and date range
 * - AddBalance: Handles wallet topup operations with success feedback
 * - Complex state management with loading, loaded, and error states
 * - Supports infinite scrolling with hasMoreTransactions tracking
 * - Manages current page and total count for pagination
 * - Provides comprehensive error handling for all wallet operations
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/wallet_model.dart';
import '../../domain/repositories/wallet_repository.dart';

// Events
abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletData extends WalletEvent {}

class RefreshWalletData extends WalletEvent {}

class LoadMoreTransactions extends WalletEvent {
  final int page;

  const LoadMoreTransactions(this.page);

  @override
  List<Object?> get props => [page];
}

class FilterTransactions extends WalletEvent {
  final String? transactionType;
  final DateTime? startTime;
  final DateTime? endTime;

  const FilterTransactions({
    this.transactionType,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [transactionType, startTime, endTime];
}

class AddBalance extends WalletEvent {
  final double amount;
  final String? remarks;

  const AddBalance(this.amount, {this.remarks});

  @override
  List<Object?> get props => [amount, remarks];
}

// States
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final double balance;
  final List<WalletTransaction> transactions;
  final bool hasMoreTransactions;
  final int currentPage;
  final int totalCount;

  const WalletLoaded({
    required this.balance,
    required this.transactions,
    this.hasMoreTransactions = false,
    this.currentPage = 1,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [balance, transactions, hasMoreTransactions, currentPage, totalCount];

  WalletLoaded copyWith({
    double? balance,
    List<WalletTransaction>? transactions,
    bool? hasMoreTransactions,
    int? currentPage,
    int? totalCount,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class WalletLoadingMore extends WalletState {
  final double balance;
  final List<WalletTransaction> transactions;
  final int currentPage;

  const WalletLoadingMore({
    required this.balance,
    required this.transactions,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [balance, transactions, currentPage];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddBalanceLoading extends WalletState {}

class AddBalanceSuccess extends WalletState {
  final String message;

  const AddBalanceSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;

  WalletBloc(this._walletRepository) : super(WalletInitial()) {
    on<LoadWalletData>(_onLoadWalletData);
    on<RefreshWalletData>(_onRefreshWalletData);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<FilterTransactions>(_onFilterTransactions);
    on<AddBalance>(_onAddBalance);
  }

  Future<void> _onLoadWalletData(LoadWalletData event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final balance = await _walletRepository.getWalletBalance();
      final transactionsResponse = await _walletRepository.getWalletTransactions(
        page: 1,
        pageSize: 20,
      );

      emit(WalletLoaded(
        balance: balance,
        transactions: transactionsResponse.results,
        hasMoreTransactions: transactionsResponse.next != null,
        currentPage: 1,
        totalCount: transactionsResponse.count,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onRefreshWalletData(RefreshWalletData event, Emitter<WalletState> emit) async {
    try {
      final balance = await _walletRepository.getWalletBalance();
      final transactionsResponse = await _walletRepository.getWalletTransactions(
        page: 1,
        pageSize: 20,
      );

      emit(WalletLoaded(
        balance: balance,
        transactions: transactionsResponse.results,
        hasMoreTransactions: transactionsResponse.next != null,
        currentPage: 1,
        totalCount: transactionsResponse.count,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onLoadMoreTransactions(LoadMoreTransactions event, Emitter<WalletState> emit) async {
    final currentState = state;
    if (currentState is WalletLoaded && currentState.hasMoreTransactions) {
      emit(WalletLoadingMore(
        balance: currentState.balance,
        transactions: currentState.transactions,
        currentPage: currentState.currentPage,
      ));

      try {
        final transactionsResponse = await _walletRepository.getWalletTransactions(
          page: event.page,
          pageSize: 20,
        );

        final allTransactions = [...currentState.transactions, ...transactionsResponse.results];

        emit(WalletLoaded(
          balance: currentState.balance,
          transactions: allTransactions,
          hasMoreTransactions: transactionsResponse.next != null,
          currentPage: event.page,
          totalCount: transactionsResponse.count,
        ));
      } catch (e) {
        emit(WalletLoaded(
          balance: currentState.balance,
          transactions: currentState.transactions,
          hasMoreTransactions: currentState.hasMoreTransactions,
          currentPage: currentState.currentPage,
          totalCount: currentState.totalCount,
        ));
        // Could emit a separate error state for loading more failures
      }
    }
  }

  Future<void> _onFilterTransactions(FilterTransactions event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final balance = await _walletRepository.getWalletBalance();
      final transactionsResponse = await _walletRepository.getWalletTransactions(
        transactionType: event.transactionType,
        startTime: event.startTime,
        endTime: event.endTime,
        page: 1,
        pageSize: 20,
      );

      emit(WalletLoaded(
        balance: balance,
        transactions: transactionsResponse.results,
        hasMoreTransactions: transactionsResponse.next != null,
        currentPage: 1,
        totalCount: transactionsResponse.count,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onAddBalance(AddBalance event, Emitter<WalletState> emit) async {
    emit(AddBalanceLoading());
    try {
      final topupResponse = await _walletRepository.topupWallet(
        amount: event.amount,
        remarks: event.remarks ?? 'Wallet topup',
      );
      
      emit(AddBalanceSuccess(topupResponse.message));
      
      // Refresh the wallet data after adding balance
      add(LoadWalletData());
    } catch (e) {
      emit(WalletError('Failed to add balance: ${e.toString()}'));
    }
  }
}

// Additional wallet states for booking integration
class WalletBalanceChecking extends WalletState {}

class WalletBalanceSufficient extends WalletState {
  final double balance;
  final double requiredAmount;

  const WalletBalanceSufficient({
    required this.balance,
    required this.requiredAmount,
  });

  @override
  List<Object?> get props => [balance, requiredAmount];
}

class WalletBalanceInsufficient extends WalletState {
  final double balance;
  final double requiredAmount;

  const WalletBalanceInsufficient({
    required this.balance,
    required this.requiredAmount,
  });

  double get shortfall => requiredAmount - balance;

  @override
  List<Object?> get props => [balance, requiredAmount];
} 