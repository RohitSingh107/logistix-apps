import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'geocoding_service.dart';

class LocationService {
  static const String _recentSearchesKey = 'recent_searches';
  static const String _savedPlacesKey = 'saved_places';
  
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

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

  Future<List<PlaceResult>> searchPlaces(String query) async {
    if (query.isEmpty) return [];
    
    // Check cache first
    if (_searchCache.containsKey(query)) {
      return _searchCache[query]!;
    }

    try {
      // Use platform-aware geocoding
      List<Location> locations = await GeocodingService.locationFromAddressSafe(query);
      
      List<PlaceResult> results = [];
      for (int i = 0; i < locations.take(5).length; i++) {
        final location = locations[i];
        
        // Get address details for each location
        try {
          // Use platform-aware reverse geocoding
          List<Placemark> placemarks = await GeocodingService.placemarkFromCoordinatesSafe(
            location.latitude,
            location.longitude,
          );
          
          if (placemarks.isNotEmpty) {
            final place = placemarks[0];
            
            // Create a better title
            String title = '';
            if (place.name != null && place.name!.isNotEmpty) {
              title = place.name!;
            } else if (place.street != null && place.street!.isNotEmpty) {
              title = place.street!;
            } else {
              title = 'Location ${i + 1}';
            }
            
            // Create a descriptive subtitle
            List<String> subtitleParts = [];
            
            // Add street if not already in title
            if (place.street != null && 
                place.street!.isNotEmpty && 
                place.street != title) {
              subtitleParts.add(place.street!);
            }
            
            // Add locality
            if (place.locality != null && place.locality!.isNotEmpty) {
              subtitleParts.add(place.locality!);
            }
            
            // Add administrative area
            if (place.administrativeArea != null && 
                place.administrativeArea!.isNotEmpty) {
              subtitleParts.add(place.administrativeArea!);
            }
            
            // Add postal code if available
            if (place.postalCode != null && place.postalCode!.isNotEmpty) {
              subtitleParts.add(place.postalCode!);
            }
            
            String subtitle = subtitleParts.join(', ');
            
            // If subtitle is empty, show coordinates
            if (subtitle.isEmpty) {
              subtitle = 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
            }
            
            results.add(PlaceResult(
              id: '${location.latitude}_${location.longitude}',
              title: title,
              subtitle: subtitle,
              location: LatLng(location.latitude, location.longitude),
              placeType: _determinePlaceType(place),
            ));
          }
        } catch (e) {
          // Fallback if reverse geocoding fails
          results.add(PlaceResult(
            id: '${location.latitude}_${location.longitude}',
            title: 'Location ${i + 1}',
            subtitle: 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
            location: LatLng(location.latitude, location.longitude),
            placeType: PlaceType.other,
          ));
        }
      }
      
      // Cache results
      _searchCache[query] = results;
      
      return results;
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  Future<String> getAddressFromLatLng(LatLng location) async {
    try {
      // Use platform-aware reverse geocoding
      List<Placemark> placemarks = await GeocodingService.placemarkFromCoordinatesSafe(
        location.latitude,
        location.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        return _formatAddress(placemarks[0]);
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    
    return 'Selected location';
  }

  String _formatAddress(Placemark place) {
    List<String> parts = [];
    
    if (place.name != null && place.name!.isNotEmpty) {
      parts.add(place.name!);
    }
    if (place.street != null && place.street!.isNotEmpty && place.street != place.name) {
      parts.add(place.street!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      parts.add(place.postalCode!);
    }
    
    return parts.join(', ');
  }

  PlaceType _determinePlaceType(Placemark place) {
    final name = place.name?.toLowerCase() ?? '';
    final street = place.street?.toLowerCase() ?? '';
    
    if (name.contains('airport') || street.contains('airport')) {
      return PlaceType.airport;
    } else if (name.contains('station') || street.contains('station')) {
      return PlaceType.station;
    } else if (name.contains('mall') || name.contains('shopping')) {
      return PlaceType.shopping;
    } else if (name.contains('hospital') || name.contains('clinic')) {
      return PlaceType.hospital;
    } else if (name.contains('school') || name.contains('college') || name.contains('university')) {
      return PlaceType.education;
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
    final recent = await getRecentSearches();
    
    // Remove if already exists
    recent.removeWhere((p) => p.id == place.id);
    
    // Add to beginning
    recent.insert(0, place);
    
    // Keep only last 10
    if (recent.length > 10) {
      recent.removeLast();
    }
    
    final jsonList = recent.map((p) => p.toJson()).toList();
    await prefs.setString(_recentSearchesKey, json.encode(jsonList));
  }

  // Saved places
  Future<List<SavedPlace>> getSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_savedPlacesKey);
    
    if (data == null) return _getDefaultSavedPlaces();
    
    try {
      final List<dynamic> jsonList = json.decode(data);
      final saved = jsonList.map((json) => SavedPlace.fromJson(json)).toList();
      
      // Add default places if not present
      if (!saved.any((p) => p.type == SavedPlaceType.home)) {
        saved.insert(0, _getDefaultSavedPlaces()[0]);
      }
      if (!saved.any((p) => p.type == SavedPlaceType.work)) {
        saved.insert(1, _getDefaultSavedPlaces()[1]);
      }
      
      return saved;
    } catch (e) {
      return _getDefaultSavedPlaces();
    }
  }

  List<SavedPlace> _getDefaultSavedPlaces() {
    return [
      SavedPlace(
        id: 'home',
        type: SavedPlaceType.home,
        name: 'Home',
        address: 'Add home location',
        icon: 'home',
      ),
      SavedPlace(
        id: 'work',
        type: SavedPlaceType.work,
        name: 'Work',
        address: 'Add work location',
        icon: 'work',
      ),
    ];
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

  void dispose() {
    _locationStreamController.close();
  }
}

// Models
class PlaceResult {
  final String id;
  final String title;
  final String subtitle;
  final LatLng location;
  final PlaceType placeType;

  PlaceResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.placeType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'lat': location.latitude,
    'lng': location.longitude,
    'placeType': placeType.index,
  };

  factory PlaceResult.fromJson(Map<String, dynamic> json) => PlaceResult(
    id: json['id'],
    title: json['title'],
    subtitle: json['subtitle'],
    location: LatLng(json['lat'], json['lng']),
    placeType: PlaceType.values[json['placeType']],
  );
}

enum PlaceType {
  airport,
  station,
  shopping,
  hospital,
  education,
  other,
}

class SavedPlace {
  final String id;
  final SavedPlaceType type;
  final String name;
  final String address;
  final LatLng? location;
  final String icon;

  SavedPlace({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    this.location,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'name': name,
    'address': address,
    'lat': location?.latitude,
    'lng': location?.longitude,
    'icon': icon,
  };

  factory SavedPlace.fromJson(Map<String, dynamic> json) => SavedPlace(
    id: json['id'],
    type: SavedPlaceType.values[json['type']],
    name: json['name'],
    address: json['address'],
    location: json['lat'] != null && json['lng'] != null
      ? LatLng(json['lat'], json['lng'])
      : null,
    icon: json['icon'],
  );
}

enum SavedPlaceType {
  home,
  work,
  other,
} 