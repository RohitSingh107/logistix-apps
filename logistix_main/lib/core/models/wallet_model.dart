import 'package:equatable/equatable.dart';
import 'base_model.dart';

class WalletTransaction extends BaseModel {
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
      id: json['id'],
      amount: json['amount'].toDouble(),
      typeTx: json['type_tx'],
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
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