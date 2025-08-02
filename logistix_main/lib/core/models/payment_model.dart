import 'package:equatable/equatable.dart';

class PaymentModel extends Equatable {
  final String id;
  final String bookingId;
  final String customerId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final String? gatewayResponse;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.gatewayResponse,
    required this.createdAt,
    required this.updatedAt,
    this.failureReason,
    required this.metadata,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      transactionId: json['transaction_id'] as String?,
      gatewayResponse: json['gateway_response'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      failureReason: json['failure_reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'status': status,
      'transaction_id': transactionId,
      'gateway_response': gatewayResponse,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'failure_reason': failureReason,
      'metadata': metadata,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? status,
    String? transactionId,
    String? gatewayResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? failureReason,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        customerId,
        amount,
        currency,
        paymentMethod,
        status,
        transactionId,
        gatewayResponse,
        createdAt,
        updatedAt,
        failureReason,
        metadata,
      ];
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled,
}

enum PaymentMethod {
  wallet,
  card,
  upi,
  netbanking,
  cod,
} 