/// locale_provider.dart - Locale State Management Provider
/// 
/// Purpose:
/// - Manages the currently selected locale using Provider pattern
/// - Handles locale persistence using SharedPreferences
/// - Provides locale change notifications to the UI
/// - Supports English and Hindi languages
/// 
/// Key Logic:
/// - Loads saved locale preference on initialization
/// - Saves locale changes to device storage
/// - Notifies listeners when locale changes
/// - Provides fallback to English if no preference is saved
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  static const String _defaultLocale = 'en';
  
  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider by loading saved locale preference
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      
      if (savedLocaleCode != null && _isValidLocaleCode(savedLocaleCode)) {
        _currentLocale = Locale(savedLocaleCode);
      } else {
        _currentLocale = const Locale(_defaultLocale);
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // If error loading, use default locale
      _currentLocale = const Locale(_defaultLocale);
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Change the current locale
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      
      _currentLocale = locale;
      notifyListeners();
    } catch (e) {
      // If error saving, still update the locale in memory
      _currentLocale = locale;
      notifyListeners();
    }
  }

  /// Get supported locales
  List<Locale> get supportedLocales => const [
    Locale('en'),
    Locale('hi'),
  ];

  /// Get locale display name
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return 'हिन्दी';
      case 'en':
      default:
        return 'English';
    }
  }

  /// Get locale flag emoji
  String getLocaleFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return '🇮🇳';
      case 'en':
      default:
        return '🇺🇸';
    }
  }

  /// Get font family for locale
  String getFontFamily(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return 'NotoSansDevanagari'; // Will be handled by Google Fonts
      case 'en':
      default:
        return 'Inter';
    }
  }

  /// Check if locale code is valid
  bool _isValidLocaleCode(String code) {
    const validCodes = ['en', 'hi'];
    return validCodes.contains(code);
  }

  /// Clear saved locale preference
  Future<void> clearLocalePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
      _currentLocale = const Locale(_defaultLocale);
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }
}
