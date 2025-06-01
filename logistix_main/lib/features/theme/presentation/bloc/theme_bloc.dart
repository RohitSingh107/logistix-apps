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