import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'booking_model.g.dart';

enum BookingStatus {
  @JsonValue('REQUESTED')
  requested,
  @JsonValue('SEARCHING')
  searching,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('CANCELLED')
  cancelled,
}

enum PaymentMode {
  @JsonValue('CASH')
  cash,
  @JsonValue('WALLET')
  wallet,
}

@JsonSerializable()
class BookingRequest extends BaseModel {
  final int id;
  @JsonKey(name: 'sender_name')
  final String senderName;
  @JsonKey(name: 'receiver_name')
  final String receiverName;
  @JsonKey(name: 'sender_phone')
  final String senderPhone;
  @JsonKey(name: 'receiver_phone')
  final String receiverPhone;
  @JsonKey(name: 'pickup_time')
  final DateTime pickupTime;
  @JsonKey(name: 'pickup_address')
  final String pickupAddress;
  @JsonKey(name: 'dropoff_address')
  final String dropoffAddress;
  @JsonKey(name: 'goods_type')
  final String goodsType;
  @JsonKey(name: 'goods_quantity')
  final String goodsQuantity;
  @JsonKey(name: 'payment_mode')
  final PaymentMode paymentMode;
  @JsonKey(name: 'estimated_fare')
  final double estimatedFare;
  final BookingStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const BookingRequest({
    required this.id,
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
    required this.pickupTime,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.goodsType,
    required this.goodsQuantity,
    required this.paymentMode,
    required this.estimatedFare,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) => _$BookingRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BookingRequestToJson(this);

  @override
  List<Object?> get props => [
        id,
        senderName,
        receiverName,
        senderPhone,
        receiverPhone,
        pickupTime,
        pickupAddress,
        dropoffAddress,
        goodsType,
        goodsQuantity,
        paymentMode,
        estimatedFare,
        status,
        createdAt,
        updatedAt,
      ];
}

@JsonSerializable()
class BookingAcceptRequest {
  @JsonKey(name: 'booking_request_id')
  final int bookingRequestId;

  BookingAcceptRequest({
    required this.bookingRequestId,
  });

  factory BookingAcceptRequest.fromJson(Map<String, dynamic> json) => _$BookingAcceptRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BookingAcceptRequestToJson(this);
} 