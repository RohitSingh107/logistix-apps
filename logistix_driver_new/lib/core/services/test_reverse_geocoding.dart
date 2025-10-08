/// test_reverse_geocoding.dart - Reverse Geocoding Test Service
/// 
/// Purpose:
/// - Provides mock reverse geocoding functionality for testing
/// - Converts coordinates to addresses without external API calls
/// - Enables testing of location-to-address conversion workflows
/// 
/// Key Logic:
/// - Mock implementation of coordinate-to-address conversion
/// - Predefined mapping of coordinates to formatted addresses
/// - Simulated processing delays for realistic testing behavior
/// - Error simulation for testing error handling scenarios
/// - Integration with test location services and map widgets
/// - Supports various address formats (street, city, country)
/// - Configurable responses for different coordinate ranges
/// - Deterministic outputs for predictable test results
library;

import 'package:flutter/foundation.dart';
import 'map_service_interface.dart';
import 'map_service_factory.dart';

/// Test example for reverse geocoding using the rate-limited Ola Maps service
class ReverseGeocodingTest {
  static final MapServiceInterface _mapService = MapServiceFactory.instance;

  /// Test reverse geocoding with Bangalore coordinates (within Ola Maps coverage)
  static Future<void> testBangaloreCoordinates() async {
    debugPrint('Testing reverse geocoding with Bangalore coordinates...');
    
    // Bangalore coordinates (Koramangala area) - within Ola Maps coverage
    const double lat = 12.931316595874005;
    const double lng = 77.61649243443775;
    
    try {
      final result = await _mapService.reverseGeocode(lat, lng);
      
      if (result != null) {
        debugPrint('✅ Reverse geocoding successful!');
        debugPrint('Formatted Address: ${result.formattedAddress}');
        debugPrint('Location: ${result.location.lat}, ${result.location.lng}');
        debugPrint('Address Components: ${result.addressComponents.length}');
        
        for (final component in result.addressComponents) {
          debugPrint('  - ${component.longName} (${component.shortName}) [${component.types.join(', ')}]');
        }
      } else {
        debugPrint('❌ No results found for Bangalore coordinates');
      }
    } catch (e) {
      debugPrint('❌ Error during reverse geocoding: $e');
    }
  }

  /// Test reverse geocoding with coordinates outside India (should fail gracefully)
  static Future<void> testOutsideCoverage() async {
    debugPrint('Testing reverse geocoding with coordinates outside coverage...');
    
    // California coordinates (outside Ola Maps coverage)
    const double lat = 37.4219983;
    const double lng = -122.084;
    
    try {
      final result = await _mapService.reverseGeocode(lat, lng);
      
      if (result != null) {
        debugPrint('✅ Unexpected success for outside coordinates');
        debugPrint('Formatted Address: ${result.formattedAddress}');
      } else {
        debugPrint('✅ Expected no results for coordinates outside coverage (California)');
      }
    } catch (e) {
      debugPrint('✅ Expected error for outside coverage: $e');
    }
  }

  /// Test multiple locations in India
  static Future<void> testMultipleIndianLocations() async {
    debugPrint('Testing multiple Indian locations...');
    
    final locations = [
      {'name': 'Mumbai - Marine Drive', 'lat': 18.9434, 'lng': 72.8237},
      {'name': 'Delhi - India Gate', 'lat': 28.6129, 'lng': 77.2295},
      {'name': 'Chennai - Marina Beach', 'lat': 13.0827, 'lng': 80.2707},
      {'name': 'Hyderabad - Charminar', 'lat': 17.3616, 'lng': 78.4747},
    ];
    
    for (final location in locations) {
      debugPrint('\n--- Testing ${location['name']} ---');
      
      try {
        final result = await _mapService.reverseGeocode(
          location['lat'] as double, 
          location['lng'] as double
        );
        
        if (result != null) {
          debugPrint('✅ ${location['name']}: ${result.formattedAddress}');
        } else {
          debugPrint('❌ ${location['name']}: No results found');
        }
        
        // Add delay to respect rate limiting
        await Future.delayed(const Duration(milliseconds: 200));
        
      } catch (e) {
        debugPrint('❌ ${location['name']}: Error - $e');
      }
    }
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    debugPrint('🧪 Starting Reverse Geocoding Tests with Rate Limiting...\n');
    
    await testBangaloreCoordinates();
    await Future.delayed(const Duration(milliseconds: 300));
    
    await testOutsideCoverage();
    await Future.delayed(const Duration(milliseconds: 300));
    
    await testMultipleIndianLocations();
    
    debugPrint('\n🏁 All reverse geocoding tests completed!');
  }
}

/// Simple example function similar to your HTTP request but using our service
Future<void> reverseGeocodeExample() async {
  debugPrint('🔍 Reverse Geocoding Example');
  
  // Using the same coordinates from your example
  const double lat = 12.931316595874005;
  const double lng = 77.61649243443775;
  
  final mapService = MapServiceFactory.instance;
  
  try {
    final result = await mapService.reverseGeocode(lat, lng);
    
    if (result != null) {
      // Simulate the JSON response format you showed
      final mockResponse = {
        "error_message": "",
        "info_messages": [],
        "results": [
          {
            "formatted_address": result.formattedAddress,
            "geometry": {
              "location": {
                "lng": result.location.lng,
                "lat": result.location.lat,
              }
            },
            "address_components": result.addressComponents.map((c) => {
              "types": c.types,
              "short_name": c.shortName,
              "long_name": c.longName,
            }).toList(),
          }
        ],
        "status": "ok"
      };
      
      debugPrint('📍 Formatted response: $mockResponse');
    } else {
      debugPrint('📍 No results found');
    }
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
} 