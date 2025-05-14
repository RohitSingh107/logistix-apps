import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class RequestOtp extends AuthEvent {
  final String phone;
  final bool isLogin;
  final String? firstName;
  final String? lastName;

  const RequestOtp(
    this.phone, {
    this.isLogin = true,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [phone, isLogin, firstName, lastName];
}

class VerifyOtp extends AuthEvent {
  final String phone;
  final String otp;
  final String sessionId;
  final bool isLogin;
  final String? firstName;
  final String? lastName;

  const VerifyOtp({
    required this.phone,
    required this.otp,
    required this.sessionId,
    required this.isLogin,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [phone, otp, sessionId, isLogin, firstName, lastName];
}



class RequestOtpForLogin extends AuthEvent {
  final String phone;
  final bool isLogin;
  final String? firstName;
  final String? lastName;

  const RequestOtpForLogin  (
    this.phone, {
    this.isLogin = true,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [phone, isLogin, firstName, lastName];
}

class VerifyOtpForLogin extends AuthEvent {
  final String phone;
  final String otp;
  final String sessionId;
  final bool isLogin;
  final String? firstName;
  final String? lastName;

  const VerifyOtpForLogin({
    required this.phone,
    required this.otp,
    required this.sessionId,
    required this.isLogin,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [phone, otp, sessionId, isLogin, firstName, lastName];
}





class Register extends AuthEvent {
  final String phone;
  final String firstName;
  final String lastName;

  const Register({
    required this.phone,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [phone, firstName, lastName];
}

class Logout extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpRequested extends AuthState {
  final String phone;
  final String sessionId;
  final bool isLogin;

  const OtpRequested({
    required this.phone, 
    required this.sessionId,
    required this.isLogin,
  });

  @override
  List<Object?> get props => [phone, sessionId, isLogin];
}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  String? phone;
  String? sessionId;
  String? _firstName;
  String? _lastName;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<RequestOtp>(_onRequestOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<RequestOtpForLogin>(_onRequestOtpForLogin);
    on<VerifyOtpForLogin>(_onVerifyOtpForLogin);
    on<Register>(_onRegister);
    on<Logout>(_onLogout);
  }
  
  // Method to store registration data
  void storeRegistrationData({
    required String firstName,
    required String lastName,
  }) {
    _firstName = firstName;
    _lastName = lastName;
  }

  Future<void> _onRequestOtp(RequestOtp event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // requestOtp is now only for phone verification (signup flow)
      // Store registration data
      _firstName = event.firstName;
      _lastName = event.lastName;
      
      // Store the registration data
      storeRegistrationData(
        firstName: _firstName ?? '',
        lastName: _lastName ?? '',
      );
      
      // Phone verification for signup
      await _authRepository.requestOtp(event.phone);
      
      phone = event.phone;
      // In a real app, you would get the session ID from the API response
      sessionId = 'dummy_session_id';
      
      emit(OtpRequested(
        phone: event.phone, 
        sessionId: sessionId!,
        isLogin: false, // Always false for phone verification
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtp event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // Verify OTP for phone verification (signup)
      final response = await _authRepository.verifyOtp(
        event.phone,
        event.otp,
        event.sessionId,
      );

      // Complete registration after phone verification
      final firstName = event.firstName ?? _firstName ?? '';
      final lastName = event.lastName ?? _lastName ?? '';
      
      if (firstName.isEmpty || lastName.isEmpty) {
        emit(AuthError("First name and last name are required for registration"));
        return;
      }
      
      // Complete registration
      await _authRepository.register(
        event.phone,
        firstName,
        lastName,
      );

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }


  Future<void> _onRequestOtpForLogin(RequestOtpForLogin event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // Only for login flow
      await _authRepository.requestOtpForLogin(event.phone);
      
      phone = event.phone;
      // In a real app, you would get the session ID from the API response
      sessionId = 'dummy_session_id';
      
      emit(OtpRequested(
        phone: event.phone, 
        sessionId: sessionId!,
        isLogin: true, // Always true for login
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtpForLogin(VerifyOtpForLogin event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // Verify OTP for login only
      final response = await _authRepository.verifyOtpForLogin(
        event.phone,
        event.otp,
        event.sessionId,
      );

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  Future<void> _onRegister(Register event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // Direct registration (without OTP) - this would be used if we implement a different registration flow
      await _authRepository.register(
        event.phone,
        event.firstName,
        event.lastName,
      );
      
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await _authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
} 