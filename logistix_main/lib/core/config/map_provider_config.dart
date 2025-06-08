/// Configuration for different map providers
enum MapProvider {
  olaMaps,
  googleMaps,
  openStreetMap,
  mapbox,
}

/// Configuration class for map providers
class MapProviderConfig {
  // Current active provider
  static MapProvider currentProvider = MapProvider.olaMaps;
  
  // API Keys - Replace with your actual keys
  static const String olaMapsApiKey = 'YGZHUWNx9FCMEw8K8OzqTW7WGZMp4DSQ8Upv6xdM'; // Replace with your key
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String mapboxApiKey = 'YOUR_MAPBOX_API_KEY';
  
  // Base URLs
  static const String olaMapsBaseUrl = 'https://api.olamaps.io';
  static const String googleMapsBaseUrl = 'https://maps.googleapis.com/maps/api';
  static const String mapboxBaseUrl = 'https://api.mapbox.com';
  
  // Timeout settings (increased for better stability)
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  
  // Rate limiting settings
  static const int maxConcurrentRequests = 6; // Reduced from default to prevent 429 errors
  static const Duration requestDelay = Duration(milliseconds: 100); // Minimum delay between requests
  static const Duration retryDelay = Duration(milliseconds: 500); // Delay before retry on rate limit
  static const int maxRetries = 2; // Maximum number of retries for failed requests
  
  // Tile caching settings
  static const Duration tileCacheDuration = Duration(minutes: 5);
  static const int maxCachedTiles = 200;
  
  /// Get current API key based on selected provider
  static String get currentApiKey {
    switch (currentProvider) {
      case MapProvider.olaMaps:
        return olaMapsApiKey;
      case MapProvider.googleMaps:
        return googleMapsApiKey;
      case MapProvider.mapbox:
        return mapboxApiKey;
      case MapProvider.openStreetMap:
        return ''; // No API key needed for OSM
    }
  }
  
  /// Get current base URL based on selected provider
  static String get currentBaseUrl {
    switch (currentProvider) {
      case MapProvider.olaMaps:
        return olaMapsBaseUrl;
      case MapProvider.googleMaps:
        return googleMapsBaseUrl;
      case MapProvider.mapbox:
        return mapboxBaseUrl;
      case MapProvider.openStreetMap:
        return 'https://tile.openstreetmap.org';
    }
  }
  
  /// Check if current provider is properly configured
  static bool isCurrentProviderConfigured() {
    switch (currentProvider) {
      case MapProvider.olaMaps:
        return olaMapsApiKey.isNotEmpty && !olaMapsApiKey.contains('YOUR_');
      case MapProvider.googleMaps:
        return googleMapsApiKey.isNotEmpty && !googleMapsApiKey.contains('YOUR_');
      case MapProvider.mapbox:
        return mapboxApiKey.isNotEmpty && !mapboxApiKey.contains('YOUR_');
      case MapProvider.openStreetMap:
        return true; // No API key needed
    }
  }
  
  /// Get provider display name
  static String get currentProviderName {
    switch (currentProvider) {
      case MapProvider.olaMaps:
        return 'Ola Maps';
      case MapProvider.googleMaps:
        return 'Google Maps';
      case MapProvider.mapbox:
        return 'Mapbox';
      case MapProvider.openStreetMap:
        return 'OpenStreetMap';
    }
  }
  
  /// Switch to a different provider
  static void switchProvider(MapProvider provider) {
    currentProvider = provider;
  }
  
  /// API Rate limiting helper - check if we should make a request
  static bool shouldMakeRequest(String requestKey, DateTime? lastRequestTime) {
    if (lastRequestTime == null) return true;
    
    final timeSinceLastRequest = DateTime.now().difference(lastRequestTime);
    return timeSinceLastRequest >= requestDelay;
  }
} 