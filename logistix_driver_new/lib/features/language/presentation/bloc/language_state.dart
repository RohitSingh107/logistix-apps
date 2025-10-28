/// language_state.dart - Language State
/// 
/// Purpose:
/// - Defines state for language management
/// - Holds current language code and related information
/// - Provides immutable state for BLoC pattern
library;

class LanguageState {
  final String languageCode;
  final String languageName;
  final bool isRTL;

  LanguageState({
    required this.languageCode,
  }) : languageName = _getLanguageName(languageCode),
       isRTL = _isRTLLanguage(languageCode);

  static String _getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'हिन्दी';
      case 'en':
      default:
        return 'English';
    }
  }

  static bool _isRTLLanguage(String code) {
    return code == 'ar' || code == 'he' || code == 'fa'; // Hindi is LTR
  }

  LanguageState copyWith({
    String? languageCode,
  }) {
    return LanguageState(
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageState && other.languageCode == languageCode;
  }

  @override
  int get hashCode => languageCode.hashCode;
}