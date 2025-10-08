/// theme_state.dart - Theme Management States
/// 
/// Purpose:
/// - Defines all possible states for theme management in the application
/// - Provides state contracts for theme transitions and persistence
/// - Supports different theme modes with proper state representation
/// 
/// Key Logic:
/// - ThemeState: Base abstract state class for theme management
/// - ThemeLoaded: State containing current theme mode and configuration
/// - ThemeLoading: Intermediate state during theme initialization/changes
/// - Immutable state classes using Equatable for efficient comparisons
/// - Type-safe state definitions supporting light/dark/system theme modes
/// - Clear state transitions for smooth theme switching experience
library;

import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final String themeName;

  const ThemeLoaded({required this.themeName});

  @override
  List<Object> get props => [themeName];
} 