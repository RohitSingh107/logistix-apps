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

import 'base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletTransaction extends BaseModel {
  final int id;
  final double amount;
  @JsonKey(name: 'type_tx')
  final String typeTx;
  final String? remarks;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.typeTx,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => _$WalletTransactionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WalletTransactionToJson(this);

  @override
  List<Object?> get props => [id, amount, typeTx, remarks, createdAt, updatedAt];
}

@JsonSerializable()
class WalletTopupResponse extends BaseModel {
  final String message;
  final double balance;
  final WalletTransaction wallet;

  const WalletTopupResponse({
    required this.message,
    required this.balance,
    required this.wallet,
  });

  factory WalletTopupResponse.fromJson(Map<String, dynamic> json) => _$WalletTopupResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WalletTopupResponseToJson(this);

  @override
  List<Object?> get props => [message, balance, wallet];
}

@JsonSerializable()
class WalletTopupRequest {
  final double amount;
  final String? remarks;

  WalletTopupRequest({
    required this.amount,
    this.remarks,
  });

  factory WalletTopupRequest.fromJson(Map<String, dynamic> json) => _$WalletTopupRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WalletTopupRequestToJson(this);
}

@JsonSerializable()
class PaginatedWalletTransactionList {
  final int count;
  final String? next;
  final String? previous;
  @JsonKey(defaultValue: [])
  final List<WalletTransaction> results;

  PaginatedWalletTransactionList({
    required this.count,
    this.next,
    this.previous,
    List<WalletTransaction>? results,
  }) : results = results ?? [];

  factory PaginatedWalletTransactionList.fromJson(Map<String, dynamic> json) => _$PaginatedWalletTransactionListFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedWalletTransactionListToJson(this);
}

@JsonSerializable()
class WalletBalanceResponse {
  final double balance;

  WalletBalanceResponse({
    required this.balance,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) => _$WalletBalanceResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WalletBalanceResponseToJson(this);
} 