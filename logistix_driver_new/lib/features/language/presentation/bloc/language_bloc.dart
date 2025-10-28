/// language_bloc.dart - Language State Management
/// 
/// Purpose:
/// - Manages language selection state across the application
/// - Handles language persistence using SharedPreferences
/// - Provides language change events and state updates
/// - Supports English and Hindi language options
/// 
/// Key Logic:
/// - Initializes with saved language preference or default to English
/// - Handles SetLanguage event to update current language
/// - Persists language selection to device storage
/// - Provides current language state to UI components
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language_event.dart';
import '../bloc/language_state.dart';
import '../../../../core/services/language_service.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageService _languageService;

  LanguageBloc({required LanguageService languageService})
      : _languageService = languageService,
        super(LanguageState(languageCode: 'en')) {
    on<LoadLanguage>(_onLoadLanguage);
    on<SetLanguage>(_onSetLanguage);
  }

  Future<void> _onLoadLanguage(LoadLanguage event, Emitter<LanguageState> emit) async {
    try {
      final savedLanguage = await _languageService.getSavedLanguage();
      emit(LanguageState(languageCode: savedLanguage));
    } catch (e) {
      // If error loading, use default English
      emit(LanguageState(languageCode: 'en'));
    }
  }

  Future<void> _onSetLanguage(SetLanguage event, Emitter<LanguageState> emit) async {
    try {
      await _languageService.saveLanguage(event.languageCode);
      emit(LanguageState(languageCode: event.languageCode));
    } catch (e) {
      // If error saving, still update state but log error
      emit(LanguageState(languageCode: event.languageCode));
    }
  }
}
