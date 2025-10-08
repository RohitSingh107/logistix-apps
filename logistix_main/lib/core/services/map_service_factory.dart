/// map_service_factory.dart - Map Service Provider Factory
/// 
/// Purpose:
/// - Factory pattern implementation for map service creation
/// - Enables dynamic switching between different map providers
/// - Provides singleton access to map service instances
/// 
/// Key Logic:
/// - Singleton pattern with lazy initialization for map service instance
/// - Creates appropriate service implementation based on MapProviderConfig
/// - Supports multiple providers (Ola Maps, Google Maps, Mapbox, OSM)
/// - Provides instance reset functionality for provider switching
/// - Uses factory method pattern for service instantiation
/// - Handles unimplemented providers with meaningful error messages
/// - Ensures single instance per application lifecycle
/// - Integrates with configuration system for provider selection

import 'map_service_interface.dart';
import 'implementations/ola_maps_service_impl.dart';
import '../config/map_provider_config.dart';

/// Factory class for creating map service instances
/// This allows easy switching between different map providers
class MapServiceFactory {
  static MapServiceInterface? _instance;
  
  /// Get the current map service instance
  static MapServiceInterface get instance {
    _instance ??= _createMapService();
    return _instance!;
  }
  
  /// Force recreate the map service instance
  /// Useful when switching providers or updating configuration
  static void resetInstance() {
    _instance = null;
  }
  
  /// Create map service based on current configuration
  static MapServiceInterface _createMapService() {
    switch (MapProviderConfig.currentProvider) {
      case MapProvider.olaMaps:
        return OlaMapsServiceImpl();
      
      case MapProvider.googleMaps:
        // TODO: Implement GoogleMapsServiceImpl
        throw UnimplementedError('Google Maps service not yet implemented');
      
      case MapProvider.openStreetMap:
        // TODO: Implement OpenStreetMapServiceImpl
        throw UnimplementedError('OpenStreetMap service not yet implemented');
      
      case MapProvider.mapbox:
        // TODO: Implement MapboxServiceImpl
        throw UnimplementedError('Mapbox service not yet implemented');
    }
  }
  
  /// Get a specific map service instance by provider
  /// Useful for testing different providers or comparing results
  static MapServiceInterface getServiceByProvider(MapProvider provider) {
    switch (provider) {
      case MapProvider.olaMaps:
        return OlaMapsServiceImpl();
      
      case MapProvider.googleMaps:
        // TODO: Implement GoogleMapsServiceImpl
        throw UnimplementedError('Google Maps service not yet implemented');
      
      case MapProvider.openStreetMap:
        // TODO: Implement OpenStreetMapServiceImpl
        throw UnimplementedError('OpenStreetMap service not yet implemented');
      
      case MapProvider.mapbox:
        // TODO: Implement MapboxServiceImpl
        throw UnimplementedError('Mapbox service not yet implemented');
    }
  }
  
  /// Check if the current provider is available and configured
  static bool get isCurrentProviderAvailable {
    try {
      return instance.isConfigured;
    } catch (e) {
      return false;
    }
  }
  
  /// Get available providers (implemented ones)
  static List<MapProvider> get availableProviders {
    return [
      MapProvider.olaMaps,
      // Add other providers as they are implemented
    ];
  }
  
  /// Get all providers (including unimplemented ones)
  static List<MapProvider> get allProviders {
    return MapProvider.values;
  }
} 