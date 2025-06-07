import 'package:equatable/equatable.dart';
import 'base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_model.g.dart';

@JsonSerializable()
class WalletTransaction extends BaseModel {
  final int id;
  final double amount;
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