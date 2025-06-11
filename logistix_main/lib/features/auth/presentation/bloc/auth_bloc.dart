/**
 * auth_bloc.dart - Authentication Business Logic Component
 * 
 * Purpose:
 * - Manages authentication state and business logic using BLoC pattern
 * - Handles OTP-based authentication flow for login and registration
 * - Provides centralized authentication state management
 * 
 * Key Logic:
 * - Implements OTP request and verification events
 * - Manages authentication states (loading, success, error, etc.)
 * - Handles both login and registration flows with OTP
 * - Stores user registration data temporarily during signup
 * - Manages token storage and retrieval
 * - Provides authentication status checking
 * - Handles logout functionality with token cleanup
 * - Integrates with AuthRepository and AuthService
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/auth_service.dart';

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
  final bool isLogin;
  final String? firstName;
  final String? lastName;

  const VerifyOtp({
    required this.phone,
    required this.otp,
    required this.isLogin,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [phone, otp, isLogin, firstName, lastName];
}

class CheckAuthStatus extends AuthEvent {}

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
  final bool isLogin;

  const OtpRequested({
    required this.phone,
    required this.isLogin,
  });

  @override
  List<Object?> get props => [phone, isLogin];
}

class AuthSuccess extends AuthState {
  final bool isNewUser;
  final Map<String, dynamic> userData;
  final bool isAuthenticated;

  const AuthSuccess({
    required this.isNewUser,
    required this.userData,
    this.isAuthenticated = true,
  });

  @override
  List<Object?> get props => [isNewUser, userData, isAuthenticated];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final AuthService _authService;
  String? _firstName;
  String? _lastName;

  AuthBloc(this._authRepository, this._authService) : super(AuthInitial()) {
    on<RequestOtp>(_onRequestOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<Logout>(_onLogout);

    // Check authentication status when bloc is created
    add(CheckAuthStatus());
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
      
      // Store registration data if provided
      if (event.firstName != null && event.lastName != null) {
        storeRegistrationData(
          firstName: event.firstName!,
          lastName: event.lastName!,
        );
      }
      
      await _authRepository.requestOtp(event.phone);
      
      emit(OtpRequested(
        phone: event.phone,
        isLogin: event.isLogin,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtp event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      final response = await _authRepository.verifyOtp(
        event.phone,
        event.otp,
      );

      // Save tokens if they exist in the response
      if (response['tokens'] != null) {
        await _authRepository.saveTokens(
          response['tokens']['access'],
          response['tokens']['refresh'],
        );
      }

      // Save user data
      if (response['user'] != null) {
        await _authService.saveUserData(response['user']);
      }

      emit(AuthSuccess(
        isNewUser: response['is_new_user'] ?? false,
        userData: response,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          emit(AuthSuccess(
            isNewUser: false,
            userData: {'user': userData},
            isAuthenticated: true,
          ));
          return;
        }
      }
      emit(AuthInitial());
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