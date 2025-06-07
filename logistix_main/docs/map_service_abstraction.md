# Map Service Abstraction Layer

## Overview

The Map Service Abstraction Layer provides a unified interface for working with different map providers (Ola Maps, Google Maps, OpenStreetMap, Mapbox, etc.) without changing the business logic. This allows easy switching between map providers and future extensibility.

## Architecture

### Core Components

1. **MapServiceInterface** - Abstract interface defining all map operations
2. **MapServiceFactory** - Factory for creating map service instances
3. **MapProviderConfig** - Configuration for different map providers
4. **Provider Implementations** - Concrete implementations for each map provider

### Directory Structure

```
lib/core/
├── services/
│   ├── map_service_interface.dart          # Abstract interface
│   ├── map_service_factory.dart            # Factory pattern
│   └── implementations/
│       ├── ola_maps_service_impl.dart      # Ola Maps implementation
│       ├── google_maps_service_impl.dart   # Google Maps (future)
│       ├── openstreet_map_service_impl.dart # OSM (future)
│       └── mapbox_service_impl.dart        # Mapbox (future)
└── config/
    └── map_provider_config.dart            # Provider configuration
```

## Key Features

### 1. **Unified Data Models**

All map providers use common data models:

```dart
// Common coordinate system
MapLatLng location = MapLatLng(13.0827, 80.2707);

// Common place result
MapPlaceResult place = MapPlaceResult(
  placeId: 'unique_id',
  description: 'Place description',
  location: location,
  types: ['restaurant', 'food'],
);

// Common geocoding result
MapGeocodingResult result = MapGeocodingResult(
  formattedAddress: 'Full address',
  location: location,
  types: ['street_address'],
);
```

### 2. **Provider-Agnostic Operations**

```dart
// Get map service instance
final mapService = MapServiceFactory.instance;

// Geocoding
final result = await mapService.geocode('Chennai, India');

// Reverse geocoding
final address = await mapService.reverseGeocode(13.0827, 80.2707);

// Places autocomplete
final suggestions = await mapService.placesAutocomplete('restaurant');

// Directions
final directions = await mapService.getDirections(
  originLat: 13.0827,
  originLng: 80.2707,
  destLat: 13.0878,
  destLng: 80.2785,
);
```

### 3. **Easy Provider Switching**

Change provider by updating a single configuration:

```dart
// In map_provider_config.dart
static const MapProvider currentProvider = MapProvider.olaMaps;
// Change to: MapProvider.googleMaps, MapProvider.openStreetMap, etc.
```

## Usage Guide

### Basic Setup

1. **Configure API Keys**

```dart
// lib/core/config/map_provider_config.dart
class MapProviderConfig {
  static const String olaMapsApiKey = 'YGZHUWNx9FCMEw8K8OzqTW7WGZMp4DSQ8Upv6xdM';
  static const String olaMapsProjectId = '0ac30075-fe27-4c12-84cc-ba9bda04231a';
  static const String googleMapsApiKey = 'your_google_maps_api_key';
  // ... other providers
}
```

2. **Get Map Service Instance**

```dart
import 'package:your_app/core/services/map_service_factory.dart';

final mapService = MapServiceFactory.instance;
```

### Common Operations

#### Geocoding

```dart
// Convert address to coordinates
final result = await mapService.geocode('Marina Beach, Chennai');
if (result != null) {
  print('Location: ${result.location.lat}, ${result.location.lng}');
  print('Address: ${result.formattedAddress}');
}
```

#### Reverse Geocoding

```dart
// Convert coordinates to address
final result = await mapService.reverseGeocode(13.0827, 80.2707);
if (result != null) {
  print('Address: ${result.formattedAddress}');
  for (final component in result.addressComponents) {
    print('${component.longName} (${component.types.join(', ')})');
  }
}
```

#### Places Search

```dart
// Autocomplete search
final suggestions = await mapService.placesAutocomplete(
  'coffee shop',
  lat: 13.0827,
  lng: 80.2707,
  radius: 1000,
);

for (final place in suggestions) {
  print('${place.description} - ${place.types.join(', ')}');
}
```

#### Nearby Search

```dart
// Find nearby places
final nearbyPlaces = await mapService.nearbySearch(
  lat: 13.0827,
  lng: 80.2707,
  radius: 500,
  type: 'restaurant',
);

for (final place in nearbyPlaces) {
  print('${place.description} - Rating: ${place.rating}');
}
```

#### Directions

```dart
// Get route between two points
final directions = await mapService.getDirections(
  originLat: 13.0827,
  originLng: 80.2707,
  destLat: 13.0878,
  destLng: 80.2785,
  mode: 'driving',
);

if (directions != null && directions.routes.isNotEmpty) {
  final route = directions.routes.first;
  print('Distance: ${route.legs.first.distance.text}');
  print('Duration: ${route.legs.first.duration.text}');
}
```

#### Distance Matrix

```dart
// Calculate distances between multiple points
final origins = [MapLatLng(13.0827, 80.2707)];
final destinations = [
  MapLatLng(13.0878, 80.2785),
  MapLatLng(13.0925, 80.2750),
];

final matrix = await mapService.getDistanceMatrix(
  origins: origins,
  destinations: destinations,
  mode: 'driving',
);

if (matrix != null) {
  for (final row in matrix.rows) {
    for (final element in row.elements) {
      print('Distance: ${element.distance.text}');
      print('Duration: ${element.duration.text}');
    }
  }
}
```

## Adding New Map Providers

### Step 1: Create Implementation

Create a new file `lib/core/services/implementations/your_provider_service_impl.dart`:

```dart
import '../map_service_interface.dart';

class YourProviderServiceImpl implements MapServiceInterface {
  @override
  String get providerName => 'Your Provider';

  @override
  bool get isConfigured => true; // Check API key configuration

  @override
  Future<MapGeocodingResult?> geocode(String address) async {
    // Implement geocoding using your provider's API
    // Convert provider-specific response to MapGeocodingResult
  }

  @override
  Future<MapReverseGeocodingResult?> reverseGeocode(double lat, double lng) async {
    // Implement reverse geocoding
  }

  // ... implement all other methods
}
```

### Step 2: Update Configuration

Add your provider to `map_provider_config.dart`:

```dart
enum MapProvider {
  olaMaps,
  googleMaps,
  openStreetMap,
  mapbox,
  yourProvider, // Add your provider
}

class MapProviderConfig {
  // Add configuration
  static const String yourProviderApiKey = 'YOUR_API_KEY';
  static const String yourProviderBaseUrl = 'https://api.yourprovider.com';
  
  // Update methods to handle your provider
  static String getCurrentProviderApiKey() {
    switch (currentProvider) {
      // ... existing cases
      case MapProvider.yourProvider:
        return yourProviderApiKey;
    }
  }
}
```

### Step 3: Update Factory

Add your provider to `map_service_factory.dart`:

```dart
static MapServiceInterface _createMapService() {
  switch (MapProviderConfig.currentProvider) {
    // ... existing cases
    case MapProvider.yourProvider:
      return YourProviderServiceImpl();
  }
}
```

### Step 4: Test Implementation

```dart
// Test your implementation
void testYourProvider() async {
  // Temporarily change provider
  final service = MapServiceFactory.getServiceByProvider(MapProvider.yourProvider);
  
  final result = await service.geocode('Test Address');
  print('Geocoding result: $result');
}
```

## Error Handling

### Service-Level Error Handling

```dart
try {
  final result = await mapService.geocode('Invalid Address');
  if (result == null) {
    print('No results found');
  }
} catch (e) {
  print('Geocoding error: $e');
  // Handle error appropriately
}
```

### Provider Availability Check

```dart
if (!MapServiceFactory.isCurrentProviderAvailable) {
  print('Current map provider is not properly configured');
  // Show error to user or fallback to alternative
}
```

### Graceful Degradation

```dart
// Try multiple providers if one fails
Future<MapGeocodingResult?> geocodeWithFallback(String address) async {
  for (final provider in MapServiceFactory.availableProviders) {
    try {
      final service = MapServiceFactory.getServiceByProvider(provider);
      final result = await service.geocode(address);
      if (result != null) return result;
    } catch (e) {
      print('Provider $provider failed: $e');
    }
  }
  return null;
}
```

## Performance Considerations

### Caching

Implement caching at the service level:

```dart
class CachedMapService implements MapServiceInterface {
  final MapServiceInterface _delegate;
  final Map<String, MapGeocodingResult> _geocodeCache = {};
  
  CachedMapService(this._delegate);
  
  @override
  Future<MapGeocodingResult?> geocode(String address) async {
    if (_geocodeCache.containsKey(address)) {
      return _geocodeCache[address];
    }
    
    final result = await _delegate.geocode(address);
    if (result != null) {
      _geocodeCache[address] = result;
    }
    return result;
  }
  
  // ... implement other methods with caching as needed
}
```

### Rate Limiting

Implement rate limiting to avoid API quota issues:

```dart
class RateLimitedMapService implements MapServiceInterface {
  final MapServiceInterface _delegate;
  final Map<String, DateTime> _lastRequestTime = {};
  final Duration _minInterval = Duration(milliseconds: 100);
  
  // ... implement rate limiting logic
}
```

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockMapService extends Mock implements MapServiceInterface {}

void main() {
  group('MapServiceFactory', () {
    test('should return configured service', () {
      final service = MapServiceFactory.instance;
      expect(service, isNotNull);
      expect(service.isConfigured, isTrue);
    });
    
    test('should handle geocoding', () async {
      final mockService = MockMapService();
      when(mockService.geocode('test')).thenAnswer(
        (_) async => MapGeocodingResult(
          formattedAddress: 'Test Address',
          location: MapLatLng(0, 0),
          types: ['test'],
        ),
      );
      
      final result = await mockService.geocode('test');
      expect(result, isNotNull);
      expect(result!.formattedAddress, 'Test Address');
    });
  });
}
```

### Integration Tests

```dart
void main() {
  group('Map Service Integration', () {
    test('should geocode real address', () async {
      final service = MapServiceFactory.instance;
      final result = await service.geocode('Chennai, India');
      
      expect(result, isNotNull);
      expect(result!.location.lat, closeTo(13.0827, 0.1));
      expect(result.location.lng, closeTo(80.2707, 0.1));
    });
  });
}
```

## Migration Guide

### From Direct Provider Usage

**Before:**
```dart
final olaMapsService = OlaMapsService();
final result = await olaMapsService.geocode('address');
```

**After:**
```dart
final mapService = MapServiceFactory.instance;
final result = await mapService.geocode('address');
```

### Updating Data Models

**Before:**
```dart
OlaLatLng location = OlaLatLng(13.0827, 80.2707);
```

**After:**
```dart
MapLatLng location = MapLatLng(13.0827, 80.2707);
```

## Best Practices

1. **Always check service availability** before making API calls
2. **Implement proper error handling** for network failures
3. **Use caching** for frequently accessed data
4. **Respect API rate limits** to avoid quota issues
5. **Test with multiple providers** to ensure compatibility
6. **Keep provider-specific logic** in implementation classes only
7. **Use dependency injection** for easier testing

## Troubleshooting

### Common Issues

1. **API Key Not Configured**
   ```dart
   if (!mapService.isConfigured) {
     print('Please configure API key for ${mapService.providerName}');
   }
   ```

2. **Network Connectivity**
   ```dart
   try {
     final result = await mapService.geocode('address');
   } on DioException catch (e) {
     if (e.type == DioExceptionType.connectionTimeout) {
       print('Network timeout - check internet connection');
     }
   }
   ```

3. **Invalid Coordinates**
   ```dart
   if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
     throw ArgumentError('Invalid coordinates');
   }
   ```

### Debug Mode

Enable debug logging in development:

```dart
// In map service implementations
if (kDebugMode) {
  print('[${providerName}] Request: $endpoint');
  print('[${providerName}] Response: $response');
}
```

## Future Enhancements

1. **Offline Support** - Cache tiles and data for offline usage
2. **Load Balancing** - Distribute requests across multiple providers
3. **Analytics** - Track usage patterns and performance metrics
4. **A/B Testing** - Compare different providers for specific use cases
5. **Custom Providers** - Support for enterprise or custom map services

## Contributing

When adding new features or providers:

1. Follow the existing interface contract
2. Add comprehensive tests
3. Update documentation
4. Ensure backward compatibility
5. Add proper error handling

## License

This abstraction layer is part of the Logistix application and follows the same licensing terms. 