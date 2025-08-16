import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language Service
/// 
/// Manages language selection and localization throughout the app
class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _countryKey = 'selected_country';
  
  static const String english = 'English';
  static const String hindi = 'Hindi';
  
  static const Locale englishLocale = Locale('en', 'IN');
  static const Locale hindiLocale = Locale('hi', 'IN');
  
  /// Get the currently selected language
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? english;
  }
  
  /// Set the selected language
  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
  
  /// Get the locale for the selected language
  static Future<Locale> getLocale() async {
    final language = await getLanguage();
    switch (language) {
      case hindi:
        return hindiLocale;
      case english:
      default:
        return englishLocale;
    }
  }
  
  /// Get the currently selected country
  static Future<String> getCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_countryKey) ?? 'India';
  }
  
  /// Set the selected country
  static Future<void> setCountry(String country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryKey, country);
  }
  
  /// Check if language is set
  static Future<bool> isLanguageSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_languageKey);
  }
  
  /// Clear language settings (for testing)
  static Future<void> clearLanguageSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
    await prefs.remove(_countryKey);
  }
  
  /// Get supported languages
  static List<String> getSupportedLanguages() {
    return [english, hindi];
  }
  
  /// Get language display name
  static String getLanguageDisplayName(String language) {
    switch (language) {
      case hindi:
        return 'हिन्दी';
      case english:
      default:
        return 'English';
    }
  }
  
  /// Get language alphabet character
  static String getLanguageAlphabet(String language) {
    switch (language) {
      case hindi:
        return 'अ';
      case english:
      default:
        return 'a';
    }
  }
} 