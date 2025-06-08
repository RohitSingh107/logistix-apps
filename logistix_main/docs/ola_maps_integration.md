# Ola Maps Integration Guide

## Overview

This guide explains how the Ola Maps integration works in the Logistix app, replacing the previous OpenStreetMap implementation with Ola Maps for enhanced mapping capabilities and better performance in the Indian market.

## Architecture

The Ola Maps functionality is organized with the following structure:

```
lib/
├── core/
│   ├── services/
│   │   └── ola_maps_service.dart          # Main Ola Maps API service
│   └── config/
│       └── ola_maps_config.dart           # Configuration and API keys
├── features/booking/
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── booking_screen.dart        # Main booking screen with map
│   │   │   ├── location_selection_screen.dart  # Location picker screen
│   │   │   └── simple_location_selection_screen.dart  # Simplified picker
│   │   └── widgets/
│   │       ├── map_widget.dart            # Wrapper for Ola Maps
│   │       └── ola_map_widget.dart        # Custom Ola Maps widget
│   └── data/
│       └── services/
│           └── location_service.dart      # Location management service
```

## Key Components

### 1. OlaMapsService (`ola_maps_service.dart`)

A comprehensive service that handles all Ola Maps API interactions:

**Features:**
- Geocoding (address to coordinates)
- Reverse geocoding (coordinates to address)
- Places autocomplete search
- Place details lookup
- Nearby search
- Directions and routing
- Distance matrix calculations
- Map tile URL generation

**Usage:**
```dart
final olaMapsService = OlaMapsService();

// Search for places
final results = await olaMapsService.placesAutocomplete('Chennai Airport');

// Get directions
final directions = await olaMapsService.getDirections(
  originLat: 13.0827,
  originLng: 80.2707,
  destLat: 13.0878,
  destLng: 80.2785,
);

// Reverse geocoding
final address = await olaMapsService.reverseGeocode(13.0827, 80.2707);
```

### 2. OlaMapWidget (`ola_map_widget.dart`)

A custom Flutter widget that provides map functionality:

**Features:**
- Interactive map with pan and zoom
- Custom markers support
- User location display
- Tap-to-select functionality
- Center marker (Uber-style)
- Location button with GPS access

**Usage:**
```dart
OlaMapWidget(
  initialPosition: OlaLatLng(13.0827, 80.2707),
  initialZoom: 15.0,
  onTap: (location) => print('Tapped at: $location'),
  markers: [
    OlaMapMarker(
      point: OlaLatLng(13.0827, 80.2707),
      child: Icon(Icons.location_pin, color: Colors.red),
    ),
  ],
  showUserLocation: true,
  showCenterMarker: true,
)
```

### 3. LocationService (`location_service.dart`)

Updated location service that integrates with Ola Maps:

**Features:**
- Current location access
- Place search using Ola Maps
- Address resolution
- Recent searches management
- Saved places (Home, Work)
- Distance calculations

**Usage:**
```dart
final locationService = LocationService();

// Search places
final places = await locationService.searchPlaces('Marina Beach');

// Get current location
final position = await locationService.getCurrentLocation();

// Calculate distance
final distance = await locationService.calculateDistance(from, to);
```

## Data Models

### OlaLatLng
```dart
class OlaLatLng {
  final double lat;
  final double lng;
  
  OlaLatLng(this.lat, this.lng);
}
```

### OlaMapMarker
```dart
class OlaMapMarker {
  final OlaLatLng point;
  final Widget child;
  final double width;
  final double height;
}
```

### PlaceResult
```dart
class PlaceResult {
  final String id;
  final String title;
  final String subtitle;
  final OlaLatLng location;
  final PlaceType placeType;
}
```

## Configuration

### API Key Setup

1. **Get Ola Maps API Key:**
   - Visit [Ola Maps Developer Portal](https://maps.olacabs.com/)
   - Sign up for an account
   - Create a new project
   - Generate API key

2. **Configure API Key:**
   ```dart
   // In lib/core/config/ola_maps_config.dart
   class OlaMapsConfig {
     static const String apiKey = 'YOUR_ACTUAL_OLA_MAPS_API_KEY';
   }
   ```

3. **Environment Variables (Recommended):**
   ```dart
   // In .env file
   OLA_MAPS_API_KEY=your_actual_api_key_here
   
   // In ola_maps_config.dart
   static const String apiKey = String.fromEnvironment(
     'OLA_MAPS_API_KEY',
     defaultValue: 'YOUR_FALLBACK_KEY',
   );
   ```

### Dependencies

Add these dependencies to `pubspec.yaml`:

```yaml
dependencies:
  # Core dependencies
  dio: ^5.4.0
  geolocator: ^11.0.0
  permission_handler: ^11.3.0
  cached_network_image: ^3.3.1
  shared_preferences: ^2.2.2
  
  # UI dependencies
  flutter_screenutil: ^5.9.0
```

## User Flow

### Location Selection Flow

1. **From Booking Screen:**
   - User taps pickup/drop location cards
   - Opens location selection screen
   - Can search, use current location, or select on map

2. **Search Flow:**
   - User types in search bar
   - Ola Maps autocomplete provides suggestions
   - Results show with place type icons
   - Recent searches are cached locally

3. **Map Selection Flow:**
   - User taps "Select on Map"
   - Interactive map opens with center marker
   - User pans map to desired location
   - Address is resolved via reverse geocoding
   - User confirms selection

4. **Current Location Flow:**
   - User taps "Current Location"
   - App requests location permission
   - GPS coordinates are obtained
   - Address is resolved and returned

## API Integration

### Geocoding
```dart
// Convert address to coordinates
final result = await olaMapsService.geocode('Marina Beach, Chennai');
if (result != null) {
  print('Location: ${result.location.lat}, ${result.location.lng}');
}
```

### Places Search
```dart
// Search for places with autocomplete
final places = await olaMapsService.placesAutocomplete(
  'Airport',
  lat: 13.0827,
  lng: 80.2707,
  radius: 5000,
);
```

### Directions
```dart
// Get route between two points
final directions = await olaMapsService.getDirections(
  originLat: pickupLat,
  originLng: pickupLng,
  destLat: dropLat,
  destLng: dropLng,
  mode: 'driving',
);

if (directions != null && directions.routes.isNotEmpty) {
  final route = directions.routes.first;
  final distance = route.legs.first.distance.text;
  final duration = route.legs.first.duration.text;
}
```

## Error Handling

### Network Errors
```dart
try {
  final result = await olaMapsService.geocode(address);
} catch (e) {
  // Handle network errors
  print('Geocoding failed: $e');
  // Show user-friendly error message
}
```

### Permission Errors
```dart
final permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  // Request permission
  final newPermission = await Geolocator.requestPermission();
  if (newPermission == LocationPermission.denied) {
    // Show permission denied message
  }
}
```

### API Quota Errors
```dart
// Monitor API usage and implement fallbacks
if (response.statusCode == 429) {
  // Rate limit exceeded
  // Implement exponential backoff
  // Or fallback to cached results
}
```

## Performance Optimizations

### Caching Strategy
- **Search Results:** Cache autocomplete results for 5 minutes
- **Reverse Geocoding:** Cache address lookups for 1 hour
- **Map Tiles:** Browser/system level caching
- **Recent Searches:** Persistent local storage

### Debouncing
```dart
// Search input debouncing
Timer? _debounceTimer;

void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 500), () {
    _performSearch(query);
  });
}
```

### Lazy Loading
- Load map tiles on demand
- Paginate search results
- Lazy load place details

## Testing

### Unit Tests
```dart
// Test location service
test('should return search results', () async {
  final service = LocationService();
  final results = await service.searchPlaces('Chennai');
  expect(results, isNotEmpty);
});
```

### Integration Tests
```dart
// Test map widget
testWidgets('should display map with markers', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: OlaMapWidget(
        initialPosition: OlaLatLng(13.0827, 80.2707),
        markers: [testMarker],
      ),
    ),
  );
  
  expect(find.byType(OlaMapWidget), findsOneWidget);
});
```

## Migration from OpenStreetMap

### Key Changes
1. **Dependencies:** Removed `flutter_map`, `latlong2`, `geocoding`
2. **Models:** `LatLng` → `OlaLatLng`
3. **Services:** New `OlaMapsService` with comprehensive API coverage
4. **Widgets:** Custom `OlaMapWidget` replacing `FlutterMap`

### Migration Steps
1. Update dependencies in `pubspec.yaml`
2. Replace import statements
3. Update model classes
4. Configure Ola Maps API key
5. Test all map-related functionality

## Troubleshooting

### Common Issues

1. **API Key Not Working:**
   - Verify key is correct in config
   - Check API key permissions
   - Ensure billing is set up

2. **Location Permission Denied:**
   - Check platform-specific permissions
   - Add permission descriptions in Info.plist/AndroidManifest.xml

3. **Map Not Loading:**
   - Check internet connectivity
   - Verify API key configuration
   - Check console for error messages

4. **Search Not Working:**
   - Verify API endpoints are accessible
   - Check request/response format
   - Monitor API quota usage

### Debug Tips

1. **Enable Logging:**
   ```dart
   // In OlaMapsService constructor
   if (kDebugMode) {
     _dio.interceptors.add(LogInterceptor(
       requestBody: true,
       responseBody: true,
     ));
   }
   ```

2. **Test API Directly:**
   ```bash
   curl -H "Authorization: Bearer YOUR_API_KEY" \
        "https://api.olamaps.io/places/v1/autocomplete?input=Chennai"
   ```

## Future Enhancements

1. **Offline Support:**
   - Cache map tiles for offline use
   - Store frequently accessed places

2. **Advanced Features:**
   - Real-time traffic information
   - Route optimization
   - Multiple waypoints

3. **Performance:**
   - Implement map clustering for many markers
   - Add progressive loading for large datasets

4. **Analytics:**
   - Track search patterns
   - Monitor API usage
   - Performance metrics

## Support

For issues or questions:
1. Check the Ola Maps documentation
2. Review error logs and console output
3. Test with different network conditions
4. Verify API key and permissions

## API Reference

### OlaMapsService Methods

| Method | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `geocode()` | Convert address to coordinates | `String address` | `OlaGeocodingResult?` |
| `reverseGeocode()` | Convert coordinates to address | `double lat, double lng` | `OlaReverseGeocodingResult?` |
| `placesAutocomplete()` | Search places with autocomplete | `String input, lat?, lng?, radius?` | `List<OlaPlaceResult>` |
| `placeDetails()` | Get detailed place information | `String placeId` | `OlaPlaceDetails?` |
| `nearbySearch()` | Find places near location | `lat, lng, radius, type?, keyword?` | `List<OlaPlaceResult>` |
| `getDirections()` | Get route between points | `originLat, originLng, destLat, destLng, mode?` | `OlaDirectionsResult?` |
| `getDistanceMatrix()` | Calculate distances/times | `origins, destinations, mode?` | `OlaDistanceMatrixResult?` |

### Configuration Options

| Setting | Default | Description |
|---------|---------|-------------|
| `apiKey` | Required | Your Ola Maps API key |
| `baseUrl` | `https://api.olamaps.io` | API base URL |
| `defaultLat` | `13.0827` | Default latitude (Chennai) |
| `defaultLng` | `80.2707` | Default longitude (Chennai) |
| `defaultZoom` | `15.0` | Default map zoom level |
| `connectTimeout` | `10s` | API connection timeout |
| `receiveTimeout` | `10s` | API response timeout | 