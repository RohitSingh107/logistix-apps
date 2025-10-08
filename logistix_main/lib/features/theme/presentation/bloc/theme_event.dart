/// theme_event.dart - Theme Management Events
/// 
/// Purpose:
/// - Defines all events for theme state management in the application
/// - Provides event contracts for theme switching and persistence
/// - Supports different theme modes and dynamic theme changes
/// 
/// Key Logic:
/// - ThemeChanged: Event to switch between light/dark/system themes
/// - ThemeInitialized: Event to load saved theme preferences on app start
/// - ThemeReset: Event to reset theme to system default
/// - Immutable event classes using Equatable for state comparison
/// - Type-safe event definitions for BLoC pattern implementation
/// - Clear separation of theme-related user actions and system events

import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ChangeThemeEvent extends ThemeEvent {
  final String themeName;

  const ChangeThemeEvent(this.themeName);

  @override
  List<Object> get props => [themeName];
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
} 