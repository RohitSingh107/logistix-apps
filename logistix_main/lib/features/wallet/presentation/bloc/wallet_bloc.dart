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

  const WalletLoaded({
    required this.balance,
    required this.transactions,
  });

  @override
  List<Object?> get props => [balance, transactions];

  WalletLoaded copyWith({
    double? balance,
    List<WalletTransaction>? transactions,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }
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
    on<AddBalance>(_onAddBalance);
  }

  Future<void> _onLoadWalletData(LoadWalletData event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final balance = await _walletRepository.getWalletBalance();
      final transactions = await _walletRepository.getWalletTransactions();

      emit(WalletLoaded(
        balance: balance,
        transactions: transactions,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onRefreshWalletData(RefreshWalletData event, Emitter<WalletState> emit) async {
    try {
      final balance = await _walletRepository.getWalletBalance();
      final transactions = await _walletRepository.getWalletTransactions();

      emit(WalletLoaded(
        balance: balance,
        transactions: transactions,
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