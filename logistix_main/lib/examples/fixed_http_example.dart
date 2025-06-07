import 'package:flutter/foundation.dart';
import '../core/services/map_service_factory.dart';
import '../core/services/map_service_interface.dart';

/// FIXED VERSION: Instead of using basic http package with placeholder API key,
/// use the rate-limited MapService that handles 429 errors properly
/// 
/// Before (problematic):
/// ```dart
/// import 'package:http/http.dart' as http;
/// 
/// void main() async {
///   final response = await http.get(Uri.parse('https://api.olamaps.io/places/v1/reverse-geocode?latlng=12.931316595874005%2C77.61649243443775&api_key=YOUR_SECRET_TOKEN'));
///   print(response.body);
/// }
/// ```
/// 
/// After (fixed with rate limiting):

Future<void> main() async {
  await reverseGeocodeFixed();
}

/// Fixed version that handles rate limiting and uses proper API key
Future<void> reverseGeocodeFixed() async {
  debugPrint('🔧 Fixed Reverse Geocoding Example');
  
  // Get the configured map service with rate limiting
  final MapServiceInterface mapService = MapServiceFactory.instance;
  
  // Check if service is properly configured
  if (!mapService.isConfigured) {
    debugPrint('❌ Map service not configured. Please set API key in MapProviderConfig.');
    return;
  }
  
  // Bangalore coordinates (same as your example) - these are in India so they should work
  const double lat = 12.931316595874005;
  const double lng = 77.61649243443775;
  
  try {
    debugPrint('🌍 Requesting reverse geocoding for: $lat, $lng');
    debugPrint('🔑 Using provider: ${mapService.providerName}');
    
    // This call now includes:
    // - Proper API key from config
    // - Rate limiting and retry logic
    // - Error handling for 429 responses
    // - Proper timeout settings
    final result = await mapService.reverseGeocode(lat, lng);
    
    if (result != null) {
      // Format the response to match the expected JSON structure you showed
      final formattedResponse = {
        "error_message": "",
        "info_messages": [],
        "results": [
          {
            "formatted_address": result.formattedAddress,
            "types": "point_of_interest", // This would come from the raw response
            "name": _extractPlaceName(result.formattedAddress),
            "geometry": {
              "viewport": {
                "southwest": {
                  "lng": result.location.lng - 0.001, // Approximate viewport
                  "lat": result.location.lat - 0.001
                },
                "northeast": {
                  "lng": result.location.lng + 0.001,
                  "lat": result.location.lat + 0.001
                }
              },
              "location": {
                "lng": result.location.lng,
                "lat": result.location.lat
              },
              "location_type": "rooftop"
            },
            "address_components": result.addressComponents.map((component) => {
              "types": component.types,
              "short_name": component.shortName,
              "long_name": component.longName
            }).toList(),
            "plus_code": {
              "compound_code": "NA",
              "global_code": "NA"
            },
            "place_id": "ola-platform:${DateTime.now().millisecondsSinceEpoch}", // Mock place_id
            "layer": ["venue"]
          }
        ],
        "plus_code": {
          "compound_code": "NA",
          "global_code": "NA"
        },
        "status": "ok"
      };
      
      debugPrint('✅ Success! Response:');
      debugPrint(formattedResponse.toString());
      
      // Individual field access
      debugPrint('\n📍 Key Information:');
      debugPrint('   Address: ${result.formattedAddress}');
      debugPrint('   Coordinates: ${result.location.lat}, ${result.location.lng}');
      debugPrint('   Components: ${result.addressComponents.length}');
      
    } else {
      debugPrint('❌ No results found. This might happen if:');
      debugPrint('   - Coordinates are outside Ola Maps coverage area');
      debugPrint('   - API quota exceeded');
      debugPrint('   - Network issues');
    }
    
  } catch (e) {
    debugPrint('❌ Error during reverse geocoding: $e');
    debugPrint('💡 The service handles rate limiting automatically, so this error is likely due to:');
    debugPrint('   - Network connectivity issues');
    debugPrint('   - Invalid API key');
    debugPrint('   - Service unavailability');
  }
}

/// Helper function to extract place name from formatted address
String _extractPlaceName(String formattedAddress) {
  // Simple logic to extract the first part as place name
  final parts = formattedAddress.split(',');
  return parts.isNotEmpty ? parts.first.trim() : 'Unknown Place';
}

/// Example of how to handle different coordinate sets
Future<void> testMultipleCoordinates() async {
  final mapService = MapServiceFactory.instance;
  
  final testCoordinates = [
    {'name': 'Bangalore - Koramangala', 'lat': 12.931316595874005, 'lng': 77.61649243443775},
    {'name': 'Mumbai - Bandra', 'lat': 19.0596, 'lng': 72.8295},
    {'name': 'Delhi - Connaught Place', 'lat': 28.6304, 'lng': 77.2177},
  ];
  
  for (final coord in testCoordinates) {
    debugPrint('\n🧪 Testing: ${coord['name']}');
    
    try {
      final result = await mapService.reverseGeocode(
        coord['lat'] as double, 
        coord['lng'] as double
      );
      
      if (result != null) {
        debugPrint('✅ Found: ${result.formattedAddress}');
      } else {
        debugPrint('❌ No results for ${coord['name']}');
      }
      
      // Respect rate limiting - wait between requests
      await Future.delayed(const Duration(milliseconds: 200));
      
    } catch (e) {
      debugPrint('❌ Error for ${coord['name']}: $e');
    }
  }
}

/// Usage in a Flutter widget
class ReverseGeocodingWidget {
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    final mapService = MapServiceFactory.instance;
    
    try {
      final result = await mapService.reverseGeocode(lat, lng);
      return result?.formattedAddress;
    } catch (e) {
      debugPrint('Failed to get address: $e');
      return null;
    }
  }
} 