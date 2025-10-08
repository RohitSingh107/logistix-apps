/// user_bloc.dart - User Profile Business Logic Component
/// 
/// Purpose:
/// - Manages user profile state and business logic using BLoC pattern
/// - Handles user profile loading and updating operations
/// - Provides centralized user data management across the application
/// 
/// Key Logic:
/// - LoadUserProfile: Fetches current user profile from repository
/// - UpdateUserProfile: Handles profile updates with optional parameters
/// - Manages user state transitions (loading, loaded, error)
/// - Provides comprehensive error handling for profile operations
/// - Supports partial profile updates (phone, name, profile picture)
/// - Integrates with UserRepository for data persistence
/// - Emits appropriate states for UI consumption
/// - Follows BLoC pattern for reactive state management

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/repositories/user_repository.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;

  const UpdateUserProfile({
    this.phone,
    this.firstName,
    this.lastName,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [firstName, lastName, profilePicture];
}

// States
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onLoadUserProfile(LoadUserProfile event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final user = await _userRepository.getCurrentUser();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(UpdateUserProfile event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final user = await _userRepository.updateUserProfile(
        phone: event.phone,
        firstName: event.firstName,
        lastName: event.lastName,
        profilePicture: event.profilePicture,
      );
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
} 