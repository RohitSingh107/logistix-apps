import 'dart:io';
import 'dart:math';
import 'dart:async'; // Add this for TimeoutException
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeocodingService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String _photonBaseUrl = 'https://photon.komoot.io';
  
  // Default location context (Chennai, India)
  static const double _defaultLat = 13.0827;
  static const double _defaultLon = 80.2707;
  static const String _defaultCountry = 'India';
  
  // Create HTTP client with custom settings
  static http.Client? _httpClient;
  
  static http.Client get httpClient {
    if (_httpClient == null) {
      // Create a client that can handle certificate issues
      _httpClient = http.Client();
    }
    return _httpClient!;
  }
  
  // Use Photon API (better for searching) as primary
  static Future<List<Location>> locationFromAddressPhoton(String address) async {
    try {
      final uri = Uri.parse('$_photonBaseUrl/api/').replace(
        queryParameters: {
          'q': address,
          'limit': '10',
          'lat': _defaultLat.toString(),
          'lon': _defaultLon.toString(),
          'lang': 'en',
        },
      );

      final response = await httpClient.get(
        uri,
        headers: {
          'User-Agent': 'LogistixApp/1.0',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Photon API timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List<dynamic>? ?? [];
        
        return features.map((feature) {
          final coords = feature['geometry']['coordinates'];
          return Location(
            latitude: coords[1].toDouble(),
            longitude: coords[0].toDouble(),
            timestamp: DateTime.now(),
          );
        }).toList();
      }
    } on HandshakeException catch (e) {
      print('SSL/Certificate error in Photon geocoding: $e');
      // Return empty list to trigger fallback
      return [];
    } on SocketException catch (e) {
      print('Network error in Photon geocoding: $e');
      return [];
    } on TimeoutException catch (e) {
      print('Timeout error in Photon geocoding: $e');
      return [];
    } catch (e) {
      print('Error in Photon geocoding: $e');
      return [];
    }
    
    return [];
  }
  
  // Enhanced Nominatim search with better parameters
  static Future<List<Location>> locationFromAddressNominatim(String address) async {
    try {
      // Add country context for better results
      String enhancedQuery = address;
      if (!address.toLowerCase().contains('india') && 
          !address.toLowerCase().contains('chennai') &&
          !address.toLowerCase().contains('tamil nadu')) {
        enhancedQuery = '$address, Chennai, Tamil Nadu, India';
      }
      
      final uri = Uri.parse('$_nominatimBaseUrl/search').replace(
        queryParameters: {
          'q': enhancedQuery,
          'format': 'json',
          'limit': '10',
          'addressdetails': '1',
          'extratags': '1',
          'namedetails': '1',
          'countrycodes': 'in', // Restrict to India for better results
          'viewbox': '${_defaultLon - 1},${_defaultLat - 1},${_defaultLon + 1},${_defaultLat + 1}',
          'bounded': '0', // Don't strictly bound, but prefer results in viewbox
        },
      );

      final response = await httpClient.get(
        uri,
        headers: {
          'User-Agent': 'LogistixApp/1.0',
          'Accept-Language': 'en',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Nominatim API timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Sort by importance and relevance
        data.sort((a, b) {
          double scoreA = _calculateRelevanceScore(a, address);
          double scoreB = _calculateRelevanceScore(b, address);
          return scoreB.compareTo(scoreA);
        });
        
        return data.take(5).map((item) {
          return Location(
            latitude: double.parse(item['lat']),
            longitude: double.parse(item['lon']),
            timestamp: DateTime.now(),
          );
        }).toList();
      }
    } on HandshakeException catch (e) {
      print('SSL/Certificate error in Nominatim geocoding: $e');
    } on SocketException catch (e) {
      print('Network error in Nominatim geocoding: $e');
    } on TimeoutException catch (e) {
      print('Timeout error in Nominatim geocoding: $e');
    } catch (e) {
      print('Error in Nominatim geocoding: $e');
    }
    
    return [];
  }

  // Calculate relevance score for sorting results
  static double _calculateRelevanceScore(Map<String, dynamic> item, String query) {
    double score = 0.0;
    
    // Importance from API
    if (item['importance'] != null) {
      score += double.tryParse(item['importance'].toString()) ?? 0.0;
    }
    
    // Type weighting
    String type = item['type']?.toString() ?? '';
    String className = item['class']?.toString() ?? '';
    
    // Prioritize specific types for Chennai/India context
    if (type == 'city' || type == 'town') score += 0.3;
    if (className == 'place') score += 0.2;
    if (className == 'highway' || className == 'railway') score += 0.1;
    if (className == 'amenity') score += 0.15;
    if (className == 'building') score += 0.1;
    
    // Name matching
    String displayName = item['display_name']?.toString().toLowerCase() ?? '';
    String queryLower = query.toLowerCase();
    
    // Exact match bonus
    if (displayName.contains(queryLower)) score += 0.5;
    
    // Partial match bonus
    List<String> queryWords = queryLower.split(' ');
    for (String word in queryWords) {
      if (word.length > 2 && displayName.contains(word)) {
        score += 0.1;
      }
    }
    
    // Distance from default location
    double lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0;
    double lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0;
    double distance = _calculateDistance(lat, lon, _defaultLat, _defaultLon);
    
    // Prefer closer results (within ~100km)
    if (distance < 100) {
      score += (100 - distance) / 100;
    }
    
    // Penalty for too far results
    if (distance > 500) {
      score -= 0.5;
    }
    
    return score;
  }
  
  // Simple distance calculation in km
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
  
  static double _toRadians(double degrees) => degrees * pi / 180;

  // Enhanced reverse geocoding
  static Future<List<Placemark>> placemarkFromCoordinatesNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.parse('$_nominatimBaseUrl/reverse').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'format': 'json',
          'addressdetails': '1',
          'namedetails': '1',
          'extratags': '1',
          'zoom': '18', // High zoom for detailed address
        },
      );

      final response = await httpClient.get(
        uri,
        headers: {
          'User-Agent': 'LogistixApp/1.0',
          'Accept-Language': 'en',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Nominatim reverse geocoding timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] ?? {};
        final nameDetails = data['namedetails'] ?? {};
        final extraTags = data['extratags'] ?? {};
        
        // Try to get the most specific name
        String name = '';
        if (nameDetails['name'] != null) {
          name = nameDetails['name'];
        } else if (extraTags['name'] != null) {
          name = extraTags['name'];
        } else if (address['amenity'] != null) {
          name = address['amenity'];
        } else if (address['building'] != null) {
          name = address['building'];
        } else if (address['shop'] != null) {
          name = address['shop'];
        }
        
        // Build a better formatted address
        List<String> addressParts = [];
        
        // Add house number and street
        if (address['house_number'] != null) {
          addressParts.add(address['house_number']);
        }
        if (address['road'] != null) {
          addressParts.add(address['road']);
        }
        
        String street = addressParts.join(' ');
        
        // Get locality
        String locality = address['suburb'] ?? 
                         address['neighbourhood'] ?? 
                         address['hamlet'] ?? 
                         address['village'] ?? 
                         address['town'] ?? 
                         address['city'] ?? '';
        
        return [
          Placemark(
            name: name,
            street: street,
            locality: locality,
            administrativeArea: address['state'] ?? '',
            postalCode: address['postcode'] ?? '',
            country: address['country'] ?? '',
          ),
        ];
      }
    } on HandshakeException catch (e) {
      print('SSL/Certificate error in Nominatim reverse geocoding: $e');
    } on SocketException catch (e) {
      print('Network error in Nominatim reverse geocoding: $e');
    } on TimeoutException catch (e) {
      print('Timeout error in Nominatim reverse geocoding: $e');
    } catch (e) {
      print('Error in Nominatim reverse geocoding: $e');
    }
    
    return [];
  }

  // Combined search using multiple providers with better error handling
  static Future<List<Location>> locationFromAddressMultiProvider(String address) async {
    List<Location> results = [];
    
    // Try Photon first (usually better for POI search)
    try {
      results = await locationFromAddressPhoton(address);
    } catch (e) {
      print('Photon search failed: $e');
    }
    
    // Always try Nominatim as well to get more results
    try {
      List<Location> nominatimResults = await locationFromAddressNominatim(address);
      
      // Merge results, avoiding duplicates
      for (var result in nominatimResults) {
        bool isDuplicate = results.any((existing) =>
          (existing.latitude - result.latitude).abs() < 0.001 &&
          (existing.longitude - result.longitude).abs() < 0.001
        );
        
        if (!isDuplicate) {
          results.add(result);
        }
      }
    } catch (e) {
      print('Nominatim search failed: $e');
    }
    
    // If no results from either provider, try a simplified search
    if (results.isEmpty && address.isNotEmpty) {
      try {
        // Try with just the main part of the query
        String simplifiedQuery = address.split(',').first.trim();
        if (simplifiedQuery != address) {
          List<Location> fallbackResults = await locationFromAddressNominatim(simplifiedQuery);
          results.addAll(fallbackResults);
        }
      } catch (e) {
        print('Fallback search failed: $e');
      }
    }
    
    return results.take(5).toList();
  }

  // Platform-aware methods with multi-provider support
  static Future<List<Location>> locationFromAddressSafe(String address) async {
    try {
      if (Platform.isLinux) {
        return await locationFromAddressMultiProvider(address);
      } else {
        // Try native first
        try {
          return await locationFromAddress(address);
        } catch (e) {
          // Fallback to multi-provider
          return await locationFromAddressMultiProvider(address);
        }
      }
    } catch (e) {
      print('Error in geocoding: $e');
      return [];
    }
  }

  static Future<List<Placemark>> placemarkFromCoordinatesSafe(
    double latitude,
    double longitude,
  ) async {
    try {
      if (Platform.isLinux) {
        return await placemarkFromCoordinatesNominatim(latitude, longitude);
      } else {
        // Try native first
        try {
          return await placemarkFromCoordinates(latitude, longitude);
        } catch (e) {
          // Fallback to Nominatim
          return await placemarkFromCoordinatesNominatim(latitude, longitude);
        }
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
      return [];
    }
  }
  
  // Cleanup method
  static void dispose() {
    _httpClient?.close();
    _httpClient = null;
  }
  
  // Utility method to format display name for search results
  static String formatDisplayName(Map<String, dynamic> item) {
    final address = item['address'] ?? {};
    final nameDetails = item['namedetails'] ?? {};
    
    List<String> parts = [];
    
    // Add specific name if available
    if (nameDetails['name'] != null) {
      parts.add(nameDetails['name']);
    } else if (address['amenity'] != null) {
      parts.add(address['amenity']);
    }
    
    // Add street
    if (address['road'] != null) {
      parts.add(address['road']);
    }
    
    // Add area
    String area = address['suburb'] ?? 
                  address['neighbourhood'] ?? 
                  address['village'] ?? '';
    if (area.isNotEmpty) {
      parts.add(area);
    }
    
    // Add city
    String city = address['city'] ?? address['town'] ?? '';
    if (city.isNotEmpty) {
      parts.add(city);
    }
    
    return parts.join(', ');
  }
} 