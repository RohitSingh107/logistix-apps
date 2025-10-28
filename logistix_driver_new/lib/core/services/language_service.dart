/// language_service.dart - Language Persistence Service
/// 
/// Purpose:
/// - Manages language preference persistence using SharedPreferences
/// - Provides methods to save and retrieve language settings
/// - Handles default language fallback
/// - Supports multiple language codes
/// 
/// Key Logic:
/// - Saves selected language code to device storage
/// - Retrieves saved language or returns default (English)
/// - Handles storage errors gracefully
/// - Provides language validation
library;

import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  /// Save language preference to device storage
  Future<void> saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Handle storage error - could log to crashlytics
      throw Exception('Failed to save language preference: $e');
    }
  }

  /// Get saved language preference or return default
  Future<String> getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null && _isValidLanguageCode(savedLanguage)) {
        return savedLanguage;
      }
      
      return _defaultLanguage;
    } catch (e) {
      // Handle storage error - return default language
      return _defaultLanguage;
    }
  }

  /// Check if language code is valid
  bool _isValidLanguageCode(String code) {
    const validCodes = ['en', 'hi'];
    return validCodes.contains(code);
  }

  /// Clear saved language preference
  Future<void> clearLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);
    } catch (e) {
      throw Exception('Failed to clear language preference: $e');
    }
  }
}
