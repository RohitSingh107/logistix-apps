/// language_event.dart - Language Events
/// 
/// Purpose:
/// - Defines events for language state management
/// - Handles language loading and setting operations
/// - Provides clear event definitions for BLoC pattern
library;

abstract class LanguageEvent {}

class LoadLanguage extends LanguageEvent {}

class SetLanguage extends LanguageEvent {
  final String languageCode;

  SetLanguage(this.languageCode);
}
