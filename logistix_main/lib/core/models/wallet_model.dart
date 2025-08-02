/**
 * wallet_model.dart - Wallet and Transaction Data Models
 * 
 * Purpose:
 * - Defines data models for wallet functionality and transaction management
 * - Handles wallet balance, topup operations, and transaction history
 * - Manages financial transaction records and pagination
 * 
 * Key Logic:
 * - WalletTransaction: Individual transaction record with amount and type
 * - WalletTopupResponse: Response for successful wallet topup operations
 * - WalletTopupRequest: Payload for requesting wallet balance additions
 * - WalletBalanceResponse: Current wallet balance information
 * - PaginatedWalletTransactionList: Paginated transaction history
 * - Extends BaseModel for consistent behavior and equality comparison
 * - Uses JSON serialization with snake_case field mapping
 * - Supports transaction types, remarks, and timestamps
 * - Handles nullable fields for optional transaction details
 */

import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final int id;
  final int userId;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WalletModel copyWith({
    int? id,
    int? userId,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        balance,
        createdAt,
        updatedAt,
      ];
}

class WalletTransactionModel extends Equatable {
  final int id;
  final int walletId;
  final int? tripId;
  final double amount; // Positive=credit, Negative=debit
  final String typeTx;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletTransactionModel({
    required this.id,
    required this.walletId,
    this.tripId,
    required this.amount,
    required this.typeTx,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as int,
      walletId: json['wallet_id'] as int,
      tripId: json['trip_id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      typeTx: json['type_tx'] as String,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'trip_id': tripId,
      'amount': amount,
      'type_tx': typeTx,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WalletTransactionModel copyWith({
    int? id,
    int? walletId,
    int? tripId,
    double? amount,
    String? typeTx,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletTransactionModel(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      tripId: tripId ?? this.tripId,
      amount: amount ?? this.amount,
      typeTx: typeTx ?? this.typeTx,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;

  @override
  List<Object?> get props => [
        id,
        walletId,
        tripId,
        amount,
        typeTx,
        remarks,
        createdAt,
        updatedAt,
      ];
}

enum TransactionType {
  credit,
  debit,
  refund,
  payment,
  withdrawal,
  deposit,
}

// Legacy classes for backward compatibility
class WalletTransaction extends Equatable {
  final int id;
  final double amount;
  final String typeTx;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.typeTx,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      typeTx: json['type_tx'] as String,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type_tx': typeTx,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, amount, typeTx, remarks, createdAt, updatedAt];
}

class WalletTopupResponse extends Equatable {
  final String message;
  final double balance;
  final WalletTransaction wallet;

  const WalletTopupResponse({
    required this.message,
    required this.balance,
    required this.wallet,
  });

  factory WalletTopupResponse.fromJson(Map<String, dynamic> json) {
    return WalletTopupResponse(
      message: json['message'] as String,
      balance: (json['balance'] as num).toDouble(),
      wallet: WalletTransaction.fromJson(json['wallet'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'balance': balance,
      'wallet': wallet.toJson(),
    };
  }

  @override
  List<Object?> get props => [message, balance, wallet];
}

class WalletTopupRequest extends Equatable {
  final double amount;
  final String? remarks;

  const WalletTopupRequest({
    required this.amount,
    this.remarks,
  });

  factory WalletTopupRequest.fromJson(Map<String, dynamic> json) {
    return WalletTopupRequest(
      amount: (json['amount'] as num).toDouble(),
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'remarks': remarks,
    };
  }

  @override
  List<Object?> get props => [amount, remarks];
}

class PaginatedWalletTransactionList extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<WalletTransaction> results;

  const PaginatedWalletTransactionList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedWalletTransactionList.fromJson(Map<String, dynamic> json) {
    return PaginatedWalletTransactionList(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [count, next, previous, results];
}

class WalletBalanceResponse extends Equatable {
  final double balance;

  const WalletBalanceResponse({
    required this.balance,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
    };
  }

  @override
  List<Object?> get props => [balance];
} 