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
