import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/repositories/payment_repository.dart';
import '../../../../core/models/payment_model.dart';

// Events
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentEvent {
  final String? status;

  const LoadPayments({this.status});

  @override
  List<Object?> get props => [status];
}

class LoadPaymentById extends PaymentEvent {
  final String id;

  const LoadPaymentById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreatePayment extends PaymentEvent {
  final Map<String, dynamic> paymentData;

  const CreatePayment(this.paymentData);

  @override
  List<Object?> get props => [paymentData];
}

class ProcessPayment extends PaymentEvent {
  final String paymentId;

  const ProcessPayment(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class RefundPayment extends PaymentEvent {
  final String paymentId;
  final double? amount;

  const RefundPayment(this.paymentId, {this.amount});

  @override
  List<Object?> get props => [paymentId, amount];
}

class LoadCustomerPayments extends PaymentEvent {
  final String customerId;

  const LoadCustomerPayments(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class LoadPaymentMethods extends PaymentEvent {}

class AddPaymentMethod extends PaymentEvent {
  final Map<String, dynamic> methodData;

  const AddPaymentMethod(this.methodData);

  @override
  List<Object?> get props => [methodData];
}

// States
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentsLoaded extends PaymentState {
  final List<PaymentModel> payments;

  const PaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class PaymentLoaded extends PaymentState {
  final PaymentModel payment;

  const PaymentLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentCreated extends PaymentState {
  final PaymentModel payment;

  const PaymentCreated(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentProcessed extends PaymentState {
  final PaymentModel payment;

  const PaymentProcessed(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentRefunded extends PaymentState {
  final PaymentModel payment;

  const PaymentRefunded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentMethodsLoaded extends PaymentState {
  final Map<String, dynamic> paymentMethods;

  const PaymentMethodsLoaded(this.paymentMethods);

  @override
  List<Object?> get props => [paymentMethods];
}

class PaymentMethodAdded extends PaymentState {
  final Map<String, dynamic> paymentMethod;

  const PaymentMethodAdded(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentBloc(this._paymentRepository) : super(PaymentInitial()) {
    on<LoadPayments>(_onLoadPayments);
    on<LoadPaymentById>(_onLoadPaymentById);
    on<CreatePayment>(_onCreatePayment);
    on<ProcessPayment>(_onProcessPayment);
    on<RefundPayment>(_onRefundPayment);
    on<LoadCustomerPayments>(_onLoadCustomerPayments);
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<AddPaymentMethod>(_onAddPaymentMethod);
  }

  Future<void> _onLoadPayments(LoadPayments event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payments = await _paymentRepository.getPayments(status: event.status);
      emit(PaymentsLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onLoadPaymentById(LoadPaymentById event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payment = await _paymentRepository.getPaymentById(event.id);
      emit(PaymentLoaded(payment));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onCreatePayment(CreatePayment event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payment = await _paymentRepository.createPayment(event.paymentData);
      emit(PaymentCreated(payment));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onProcessPayment(ProcessPayment event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payment = await _paymentRepository.processPayment(event.paymentId);
      emit(PaymentProcessed(payment));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onRefundPayment(RefundPayment event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payment = await _paymentRepository.refundPayment(event.paymentId, amount: event.amount);
      emit(PaymentRefunded(payment));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onLoadCustomerPayments(LoadCustomerPayments event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final payments = await _paymentRepository.getCustomerPayments(event.customerId);
      emit(PaymentsLoaded(payments));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onLoadPaymentMethods(LoadPaymentMethods event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final paymentMethods = await _paymentRepository.getPaymentMethods();
      emit(PaymentMethodsLoaded(paymentMethods));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onAddPaymentMethod(AddPaymentMethod event, Emitter<PaymentState> emit) async {
    try {
      emit(PaymentLoading());
      final paymentMethod = await _paymentRepository.addPaymentMethod(event.methodData);
      emit(PaymentMethodAdded(paymentMethod));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
} 