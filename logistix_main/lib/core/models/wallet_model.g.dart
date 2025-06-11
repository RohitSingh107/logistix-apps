// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) =>
    WalletTransaction(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      typeTx: json['type_tx'] as String,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$WalletTransactionToJson(WalletTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'type_tx': instance.typeTx,
      'remarks': instance.remarks,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

WalletTopupResponse _$WalletTopupResponseFromJson(Map<String, dynamic> json) =>
    WalletTopupResponse(
      message: json['message'] as String,
      balance: (json['balance'] as num).toDouble(),
      wallet:
          WalletTransaction.fromJson(json['wallet'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WalletTopupResponseToJson(
        WalletTopupResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'balance': instance.balance,
      'wallet': instance.wallet,
    };

WalletTopupRequest _$WalletTopupRequestFromJson(Map<String, dynamic> json) =>
    WalletTopupRequest(
      amount: (json['amount'] as num).toDouble(),
      remarks: json['remarks'] as String?,
    );

Map<String, dynamic> _$WalletTopupRequestToJson(WalletTopupRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'remarks': instance.remarks,
    };

PaginatedWalletTransactionList _$PaginatedWalletTransactionListFromJson(
        Map<String, dynamic> json) =>
    PaginatedWalletTransactionList(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)
              ?.map(
                  (e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$PaginatedWalletTransactionListToJson(
        PaginatedWalletTransactionList instance) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results,
    };

WalletBalanceResponse _$WalletBalanceResponseFromJson(
        Map<String, dynamic> json) =>
    WalletBalanceResponse(
      balance: (json['balance'] as num).toDouble(),
    );

Map<String, dynamic> _$WalletBalanceResponseToJson(
        WalletBalanceResponse instance) =>
    <String, dynamic>{
      'balance': instance.balance,
    };
