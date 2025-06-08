import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/booking_model.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../domain/repositories/booking_repository.dart';

// Events
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CheckWalletBalance extends BookingEvent {
  final double requiredAmount;

  const CheckWalletBalance(this.requiredAmount);

  @override
  List<Object?> get props => [requiredAmount];
}

class CreateBookingEvent extends BookingEvent {
  final String senderName;
  final String receiverName;
  final String senderPhone;
  final String receiverPhone;
  final double pickupLatitude;
  final double pickupLongitude;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final DateTime pickupTime;
  final String pickupAddress;
  final String dropoffAddress;
  final int vehicleTypeId;
  final String goodsType;
  final String goodsQuantity;
  final PaymentMode paymentMode;
  final double estimatedFare;

  const CreateBookingEvent({
    required this.senderName,
    required this.receiverName,
    required this.senderPhone,
    required this.receiverPhone,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.pickupTime,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.vehicleTypeId,
    required this.goodsType,
    required this.goodsQuantity,
    required this.paymentMode,
    required this.estimatedFare,
  });

  @override
  List<Object?> get props => [
        senderName,
        receiverName,
        senderPhone,
        receiverPhone,
        pickupLatitude,
        pickupLongitude,
        dropoffLatitude,
        dropoffLongitude,
        pickupTime,
        pickupAddress,
        dropoffAddress,
        vehicleTypeId,
        goodsType,
        goodsQuantity,
        paymentMode,
        estimatedFare,
      ];
}

class ResetBookingState extends BookingEvent {}

// States
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class WalletBalanceChecking extends BookingState {}

class WalletBalanceSufficient extends BookingState {
  final double balance;
  final double requiredAmount;

  const WalletBalanceSufficient({
    required this.balance,
    required this.requiredAmount,
  });

  @override
  List<Object?> get props => [balance, requiredAmount];
}

class WalletBalanceInsufficient extends BookingState {
  final double balance;
  final double requiredAmount;
  final double shortfall;

  const WalletBalanceInsufficient({
    required this.balance,
    required this.requiredAmount,
    required this.shortfall,
  });

  @override
  List<Object?> get props => [balance, requiredAmount, shortfall];
}

class BookingSuccess extends BookingState {
  final BookingRequest booking;

  const BookingSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;
  final WalletRepository _walletRepository;

  BookingBloc({
    required BookingRepository bookingRepository,
    required WalletRepository walletRepository,
  })  : _bookingRepository = bookingRepository,
        _walletRepository = walletRepository,
        super(BookingInitial()) {
    on<CheckWalletBalance>(_onCheckWalletBalance);
    on<CreateBookingEvent>(_onCreateBooking);
    on<ResetBookingState>(_onResetBookingState);
  }

  Future<void> _onCheckWalletBalance(
    CheckWalletBalance event,
    Emitter<BookingState> emit,
  ) async {
    emit(WalletBalanceChecking());
    
    try {
      final balance = await _walletRepository.getWalletBalance();
      
      if (balance >= event.requiredAmount) {
        emit(WalletBalanceSufficient(
          balance: balance,
          requiredAmount: event.requiredAmount,
        ));
      } else {
        final shortfall = event.requiredAmount - balance;
        emit(WalletBalanceInsufficient(
          balance: balance,
          requiredAmount: event.requiredAmount,
          shortfall: shortfall,
        ));
      }
    } catch (e) {
      emit(BookingError('Failed to check wallet balance: ${e.toString()}'));
    }
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    
    try {
      final booking = await _bookingRepository.createBooking(
        senderName: event.senderName,
        receiverName: event.receiverName,
        senderPhone: event.senderPhone,
        receiverPhone: event.receiverPhone,
        pickupLatitude: event.pickupLatitude,
        pickupLongitude: event.pickupLongitude,
        dropoffLatitude: event.dropoffLatitude,
        dropoffLongitude: event.dropoffLongitude,
        pickupTime: event.pickupTime,
        pickupAddress: event.pickupAddress,
        dropoffAddress: event.dropoffAddress,
        vehicleTypeId: event.vehicleTypeId,
        goodsType: event.goodsType,
        goodsQuantity: event.goodsQuantity,
        paymentMode: event.paymentMode,
        estimatedFare: event.estimatedFare,
      );
      
      emit(BookingSuccess(booking));
    } catch (e) {
      emit(BookingError('Failed to create booking: ${e.toString()}'));
    }
  }

  Future<void> _onResetBookingState(
    ResetBookingState event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingInitial());
  }
} 