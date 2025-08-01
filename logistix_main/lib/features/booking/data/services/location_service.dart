/**
 * location_service.dart - Location and Places Service
 * 
 * Purpose:
 * - Provides location services including current position and place search
 * - Manages GPS permissions and location streaming
 * - Integrates with map services for geocoding and place autocomplete
 * 
 * Key Logic:
 * - Singleton pattern for consistent location service access
 * - GPS location retrieval with permission handling
 * - Real-time location updates via stream
 * - Place search with caching and location-aware results
 * - Recent searches and saved places management
 * - Geocoding and reverse geocoding through map service integration
 * - Fallback to default location (Chennai) when GPS unavailable
 * - Search result caching for performance optimization
 * - Place type determination from map service responses
 * - Persistent storage of user preferences and search history
 */

import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/services/map_service_interface.dart';
import '../../../../core/services/map_service_factory.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class LocationService {
  static const String _recentSearchesKey = 'recent_searches';
  static const String _savedPlacesKey = 'saved_places';
  
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final MapServiceInterface _mapService = MapServiceFactory.instance;
  
  // Cache for search results
  final Map<String, List<PlaceResult>> _searchCache = {};
  
  // Stream controller for location updates
  final StreamController<Position> _locationStreamController = 
      StreamController<Position>.broadcast();
  
  Stream<Position> get locationStream => _locationStreamController.stream;

  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _locationStreamController.add(position);
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get default location - current location or fallback to Chennai
  Future<MapLatLng> getDefaultLocation() async {
    final position = await getCurrentLocation();
    if (position != null) {
      return MapLatLng(position.latitude, position.longitude);
    }
    // Fallback to Chennai, India
    return MapLatLng(13.0827, 80.2707);
  }

  Future<void> startLocationUpdates() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _locationStreamController.add(position);
    });
  }

  Future<List<PlaceResult>> searchPlaces(String query, {
    MapLatLng? userLocation,
    int radius = 50000, // 50km default radius
  }) async {
    if (query.isEmpty) return [];
    
    // Create cache key including location
    final cacheKey = userLocation != null 
        ? '${query}_${userLocation.lat}_${userLocation.lng}_$radius'
        : query;
    
    // Check cache first
    if (_searchCache.containsKey(cacheKey)) {
      debugPrint('Returning cached results for: $query');
      return _searchCache[cacheKey]!;
    }

    try {
      // Get current location if not provided
      MapLatLng? searchLocation = userLocation;
      if (searchLocation == null) {
        final position = await getCurrentLocation();
        if (position != null) {
          searchLocation = MapLatLng(position.latitude, position.longitude);
        }
      }
      
      debugPrint('Searching for: "$query" with location: ${searchLocation?.lat}, ${searchLocation?.lng}');
      
      // Use Map Service Places Autocomplete API with location awareness
      final mapResults = await _mapService.placesAutocomplete(
        query,
        lat: searchLocation?.lat,
        lng: searchLocation?.lng,
        radius: radius,
      );
      
      debugPrint('API returned ${mapResults.length} results for: $query');
      
      List<PlaceResult> results = [];
      for (final mapResult in mapResults) {
        // Skip results without proper location data
        if (mapResult.location == null || 
            mapResult.location!.lat == 0 || 
            mapResult.location!.lng == 0) {
          debugPrint('Skipping result without valid location: ${mapResult.name}');
          continue;
        }
        
        results.add(PlaceResult(
          id: mapResult.placeId,
          title: mapResult.name ?? mapResult.description,
          subtitle: mapResult.description,
          location: mapResult.location!,
          placeType: _determinePlaceTypeFromMap(mapResult.types),
        ));
      }
      
      debugPrint('Processed ${results.length} valid results for: $query');
      
      // Cache results only if we have valid results
      if (results.isNotEmpty) {
        _searchCache[cacheKey] = results;
      }
      
      return results;
    } catch (e) {
      debugPrint('Search places error for "$query": $e');
      
      // Try fallback search with smaller radius
      if (radius > 10000) {
        debugPrint('Trying fallback search with smaller radius');
        return await searchPlaces(query, userLocation: userLocation, radius: 10000);
      }
      
      return [];
    }
  }

  /// Unified search method for consistent search across all screens
  Future<List<PlaceResult>> unifiedSearch(String query, {
    MapLatLng? userLocation,
    int radius = 25000, // Reduced default radius for better results
    bool includeRecentSearches = true,
    bool includeSavedPlaces = true,
  }) async {
    if (query.isEmpty) {
      // Return recent searches and saved places when query is empty
      List<PlaceResult> results = [];
      
      if (includeSavedPlaces) {
        final savedPlaces = await getSavedPlaces();
        for (final savedPlace in savedPlaces) {
          if (savedPlace.location != null) {
            results.add(PlaceResult(
              id: 'saved_${savedPlace.name.toLowerCase()}',
              title: savedPlace.name,
              subtitle: savedPlace.address,
              location: savedPlace.location!,
              placeType: PlaceType.other,
            ));
          }
        }
      }
      
      if (includeRecentSearches) {
        final recentSearches = await getRecentSearches();
        results.addAll(recentSearches);
      }
      
      return results;
    }
    
    // Use the enhanced search with fallback
    return await searchWithFallback(query, userLocation: userLocation, radius: radius);
  }

  /// Enhanced search with multiple fallback strategies
  Future<List<PlaceResult>> enhancedSearch(String query, {
    MapLatLng? userLocation,
    int radius = 25000,
  }) async {
    if (query.isEmpty) return [];
    
    debugPrint('Enhanced search for: "$query"');
    
    // Strategy 1: Normal search with user location
    var results = await searchPlaces(query, userLocation: userLocation, radius: radius);
    if (results.isNotEmpty) {
      debugPrint('Strategy 1 successful: ${results.length} results');
      return results;
    }
    
    // Strategy 2: Search without location bias
    debugPrint('Trying strategy 2: Search without location bias');
    results = await searchPlaces(query, userLocation: null, radius: radius);
    if (results.isNotEmpty) {
      debugPrint('Strategy 2 successful: ${results.length} results');
      return results;
    }
    
    // Strategy 3: Search with smaller radius
    debugPrint('Trying strategy 3: Search with smaller radius');
    results = await searchPlaces(query, userLocation: userLocation, radius: 10000);
    if (results.isNotEmpty) {
      debugPrint('Strategy 3 successful: ${results.length} results');
      return results;
    }
    
    // Strategy 4: Search with larger radius
    debugPrint('Trying strategy 4: Search with larger radius');
    results = await searchPlaces(query, userLocation: userLocation, radius: 50000);
    if (results.isNotEmpty) {
      debugPrint('Strategy 4 successful: ${results.length} results');
      return results;
    }
    
    debugPrint('All search strategies failed for: "$query"');
    return [];
  }

  /// Search with automatic fallback
  Future<List<PlaceResult>> searchWithFallback(String query, {
    MapLatLng? userLocation,
    int radius = 25000,
  }) async {
    if (query.isEmpty) return [];
    
    // Try the enhanced search first
    final mainResults = await enhancedSearch(query, userLocation: userLocation, radius: radius);
    
    // If main search returns results, use them
    if (mainResults.isNotEmpty) {
      return mainResults;
    }
    
    // If main search fails, return empty results (no mock data)
    debugPrint('Search failed for: "$query" - returning empty results');
    return [];
  }

  Future<String> getAddressFromLatLng(MapLatLng location) async {
    try {
      final result = await _mapService.reverseGeocode(
        location.lat, 
        location.lng,
      );
      
      if (result != null) {
        return result.formattedAddress;
      }
      
      return 'Unknown location';
    } catch (e) {
      print('Reverse geocoding error: $e');
      return 'Unknown location';
    }
  }

  Future<MapLatLng?> getLatLngFromAddress(String address) async {
    try {
      final result = await _mapService.geocode(address);
      return result?.location;
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  PlaceType _determinePlaceTypeFromMap(List<String> types) {
    for (final type in types) {
      final lowerType = type.toLowerCase();
      if (lowerType.contains('airport')) {
        return PlaceType.airport;
      } else if (lowerType.contains('transit_station') || lowerType.contains('subway_station')) {
        return PlaceType.station;
      } else if (lowerType.contains('shopping_mall') || lowerType.contains('store')) {
        return PlaceType.shopping;
      } else if (lowerType.contains('hospital') || lowerType.contains('doctor')) {
        return PlaceType.hospital;
      } else if (lowerType.contains('school') || lowerType.contains('university')) {
        return PlaceType.education;
      }
    }
    return PlaceType.other;
  }

  // Recent searches
  Future<List<PlaceResult>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_recentSearchesKey);
    
    if (data == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList
          .map((json) => PlaceResult.fromJson(json))
          .toList()
          .take(5)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addToRecentSearches(PlaceResult place) async {
    final prefs = await SharedPreferences.getInstance();
    List<PlaceResult> recent = await getRecentSearches();
    
    // Remove if already exists
    recent.removeWhere((p) => p.id == place.id);
    
    // Add to beginning
    recent.insert(0, place);
    
    // Keep only 5 recent searches
    if (recent.length > 5) {
      recent = recent.take(5).toList();
    }
    
    final jsonList = recent.map((p) => p.toJson()).toList();
    await prefs.setString(_recentSearchesKey, json.encode(jsonList));
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }

  // Saved places (Home, Work, etc.)
  Future<List<SavedPlace>> getSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_savedPlacesKey);
    
    if (data == null) {
      // Return default saved places structure
      return [
        SavedPlace(
          id: 'home',
          type: SavedPlaceType.home,
          name: 'Home',
          address: '',
          location: null,
          icon: 'home',
        ),
        SavedPlace(
          id: 'work',
          type: SavedPlaceType.work,
          name: 'Work',
          address: '',
          location: null,
          icon: 'work',
        ),
      ];
    }
    
    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((json) => SavedPlace.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePlaceLocation(SavedPlaceType type, PlaceResult place) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await getSavedPlaces();
    
    final index = saved.indexWhere((p) => p.type == type);
    if (index != -1) {
      saved[index] = SavedPlace(
        id: type.toString(),
        type: type,
        name: type == SavedPlaceType.home ? 'Home' : 'Work',
        address: place.subtitle,
        location: place.location,
        icon: type == SavedPlaceType.home ? 'home' : 'work',
      );
    }
    
    final jsonList = saved.map((p) => p.toJson()).toList();
    await prefs.setString(_savedPlacesKey, json.encode(jsonList));
  }

  Future<double> calculateDistance(MapLatLng from, MapLatLng to) async {
    try {
      final result = await _mapService.getDistanceMatrix(
        origins: [from],
        destinations: [to],
      );
      
      if (result != null && result.rows.isNotEmpty && result.rows.first.elements.isNotEmpty) {
        return result.rows.first.elements.first.distance.value / 1000.0; // Convert to km
      }
      
      // Fallback to Haversine formula
      return _calculateHaversineDistance(from, to);
    } catch (e) {
      return _calculateHaversineDistance(from, to);
    }
  }

  double _calculateHaversineDistance(MapLatLng from, MapLatLng to) {
    const double R = 6371; // Earth's radius in kilometers
    
    double lat1Rad = from.lat * (math.pi / 180);
    double lat2Rad = to.lat * (math.pi / 180);
    double deltaLatRad = (to.lat - from.lat) * (math.pi / 180);
    double deltaLngRad = (to.lng - from.lng) * (math.pi / 180);

    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    double c = 2 * math.asin(math.sqrt(a));

    return R * c;
  }

  /// Test method to verify search functionality
  Future<void> testSearchFunctionality() async {
    debugPrint('=== Testing Search Functionality ===');
    
    final testQueries = [
      'airport',
      'restaurant',
      'hospital',
      'mall',
      'hotel',
      'bank',
      'school',
      'park',
      'temple',
      'police',
    ];
    
    for (final query in testQueries) {
      debugPrint('Testing search for: "$query"');
      
      // Test main search
      final mainResults = await searchPlaces(query);
      debugPrint('Main search results: ${mainResults.length}');
      
      // Test unified search
      final unifiedResults = await unifiedSearch(query);
      debugPrint('Unified search results: ${unifiedResults.length}');
      
      // Test enhanced search
      final enhancedResults = await enhancedSearch(query);
      debugPrint('Enhanced search results: ${enhancedResults.length}');
      
      // Test fallback search
      final fallbackResults = await searchWithFallback(query);
      debugPrint('Fallback search results: ${fallbackResults.length}');
      
      debugPrint('---');
    }
    
    debugPrint('=== Search Functionality Test Complete ===');
  }

  void dispose() {
    _locationStreamController.close();
  }
}

// Updated models to work with Map Service abstraction
class PlaceResult {
  final String id;
  final String title;
  final String subtitle;
  final MapLatLng location;
  final PlaceType placeType;

  PlaceResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.placeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'location': location.toJson(),
      'placeType': placeType.index,
    };
  }

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      location: MapLatLng.fromJson(json['location']),
      placeType: PlaceType.values[json['placeType']],
    );
  }
}

class SavedPlace {
  final String id;
  final SavedPlaceType type;
  final String name;
  final String address;
  final MapLatLng? location;
  final String icon;

  SavedPlace({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    required this.location,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'name': name,
      'address': address,
      'location': location?.toJson(),
      'icon': icon,
    };
  }

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id'],
      type: SavedPlaceType.values[json['type']],
      name: json['name'],
      address: json['address'],
      location: json['location'] != null ? MapLatLng.fromJson(json['location']) : null,
      icon: json['icon'],
    );
  }
}

enum PlaceType {
  home,
  work,
  airport,
  station,
  shopping,
  hospital,
  education,
  other,
}

enum SavedPlaceType {
  home,
  work,
} 