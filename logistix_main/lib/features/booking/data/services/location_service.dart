import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/services/map_service_interface.dart';
import '../../../../core/services/map_service_factory.dart';

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
      
      // Use Map Service Places Autocomplete API with location awareness
      final mapResults = await _mapService.placesAutocomplete(
        query,
        lat: searchLocation?.lat,
        lng: searchLocation?.lng,
        radius: radius,
      );
      
      List<PlaceResult> results = [];
      for (final mapResult in mapResults) {
        results.add(PlaceResult(
          id: mapResult.placeId,
          title: mapResult.name ?? mapResult.description,
          subtitle: mapResult.description,
          location: mapResult.location ?? MapLatLng(0, 0),
          placeType: _determinePlaceTypeFromMap(mapResult.types),
        ));
      }
      
      // Cache results
      _searchCache[cacheKey] = results;
      
      return results;
    } catch (e) {
      print('Search places error: $e');
      return [];
    }
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