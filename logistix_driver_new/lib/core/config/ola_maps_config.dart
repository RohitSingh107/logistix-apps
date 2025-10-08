/// ola_maps_config.dart - Ola Maps Service Configuration
/// 
/// Purpose:
/// - Provides configuration constants for Ola Maps integration
/// - Manages API settings, timeouts, and default map parameters
/// - Centralizes Ola Maps-specific configuration values
/// 
/// Key Logic:
/// - API key and base URL configuration for Ola Maps service
/// - Default location coordinates (Chennai, India) for map initialization
/// - Map zoom level settings (min, max, default) for user experience
/// - Network timeout configurations for API reliability
/// - Search functionality settings (max results, debounce delay)
/// - Recent searches configuration for user convenience
/// - All settings are compile-time constants for performance
library;

class OlaMapsConfig {
  // Replace with your actual Ola Maps API key
  static const String apiKey = 'YOUR_OLA_MAPS_API_KEY';
  
  // Base URL for Ola Maps API
  static const String baseUrl = 'https://api.olamaps.io';
  
  // Default location (Chennai, India)
  static const double defaultLat = 13.0827;
  static const double defaultLng = 80.2707;
  
  // Map settings
  static const double defaultZoom = 15.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 20.0;
  
  // API timeout settings
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Search settings
  static const int maxSearchResults = 10;
  static const int maxRecentSearches = 5;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
} 