/// theme_bloc.dart - Theme Management Business Logic Component
/// 
/// Purpose:
/// - Manages application theme state and persistence using BLoC pattern
/// - Handles theme loading from storage and theme switching functionality
/// - Provides centralized theme management across the application
/// 
/// Key Logic:
/// - LoadThemeEvent: Loads saved theme preference from SharedPreferences
/// - ChangeThemeEvent: Updates current theme and persists selection
/// - Uses SharedPreferences for theme persistence across app sessions
/// - Defaults to light theme when no saved preference exists
/// - Provides error handling with fallback to default theme
/// - Supports multiple theme variants through AppTheme configuration
/// - Emits ThemeLoaded state with current theme selection
/// - Handles theme persistence failures gracefully
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_theme.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme';
  final SharedPreferences _prefs;

  ThemeBloc(this._prefs) : super(ThemeInitial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final savedTheme = _prefs.getString(_themeKey) ?? AppTheme.lightTheme;
      emit(ThemeLoaded(themeName: savedTheme));
    } catch (e) {
      // If there's an error, default to light theme
      emit(const ThemeLoaded(themeName: AppTheme.lightTheme));
    }
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      await _prefs.setString(_themeKey, event.themeName);
      emit(ThemeLoaded(themeName: event.themeName));
    } catch (e) {
      // If saving fails, still update the UI but the change won't persist
      emit(ThemeLoaded(themeName: event.themeName));
    }
  }
} 