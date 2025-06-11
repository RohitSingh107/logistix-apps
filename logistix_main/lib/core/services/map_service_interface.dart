/**
 * map_service_interface.dart - Map Service Provider Interface
 * 
 * Purpose:
 * - Defines abstract interface for map service providers
 * - Enables switching between different map providers (Ola Maps, Google Maps, etc.)
 * - Provides common data models and method signatures for all map services
 * 
 * Key Logic:
 * - Abstract interface with geocoding and reverse geocoding capabilities
 * - Places autocomplete and nearby search functionality
 * - Directions and distance matrix calculations
 * - Map tile URL generation for custom map implementations
 * - Common data models: MapLatLng, MapRoute, MapDirectionsResult, etc.
 * - Provider-agnostic design for easy switching between services
 * - Comprehensive location-based service definitions
 * - Standard response formats for all map providers
 * - Configuration checking and provider identification
 */

import 'dart:async';

/// Abstract interface for map services
/// This allows switching between different map providers (Ola Maps, Google Maps, etc.)
abstract class MapServiceInterface {
  
  /// Geocoding - Convert address to coordinates
  Future<MapGeocodingResult?> geocode(String address);
  
  /// Reverse Geocoding - Convert coordinates to address
  Future<MapReverseGeocodingResult?> reverseGeocode(double lat, double lng);
  
  /// Places Autocomplete - Get place suggestions
  Future<List<MapPlaceResult>> placesAutocomplete(
    String input, {
    double? lat,
    double? lng,
    int? radius,
  });
  
  /// Place Details - Get detailed information about a place
  Future<MapPlaceDetails?> placeDetails(String placeId);
  
  /// Nearby Search - Find places near a location
  Future<List<MapPlaceResult>> nearbySearch({
    required double lat,
    required double lng,
    int radius = 1000,
    String? type,
    String? keyword,
  });
  
  /// Directions - Get route between two points
  Future<MapDirectionsResult?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    bool alternatives = false,
  });
  
  /// Distance Matrix - Get travel distance and time for multiple origins/destinations
  Future<MapDistanceMatrixResult?> getDistanceMatrix({
    required List<MapLatLng> origins,
    required List<MapLatLng> destinations,
    String mode = 'driving',
  });
  
  /// Get Map Tiles URL - For custom map implementations
  String getTileUrl(int z, int x, int y);
  
  /// Get the provider name
  String get providerName;
  
  /// Check if the service is properly configured
  bool get isConfigured;
}

// Common data models that all map providers should use

class MapLatLng {
  final double lat;
  final double lng;

  MapLatLng(this.lat, this.lng);

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
  
  factory MapLatLng.fromJson(Map<String, dynamic> json) => 
      MapLatLng(json['lat'].toDouble(), json['lng'].toDouble());

  @override
  String toString() => 'MapLatLng($lat, $lng)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapLatLng && 
      runtimeType == other.runtimeType &&
      lat == other.lat &&
      lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}

class MapGeocodingResult {
  final String formattedAddress;
  final MapLatLng location;
  final List<String> types;

  MapGeocodingResult({
    required this.formattedAddress,
    required this.location,
    required this.types,
  });
}

class MapReverseGeocodingResult {
  final String formattedAddress;
  final List<MapAddressComponent> addressComponents;
  final MapLatLng location;

  MapReverseGeocodingResult({
    required this.formattedAddress,
    required this.addressComponents,
    required this.location,
  });
}

class MapAddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  MapAddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });
}

class MapPlaceResult {
  final String placeId;
  final String description;
  final String? name;
  final List<String> types;
  final MapLatLng? location;
  final double? rating;

  MapPlaceResult({
    required this.placeId,
    required this.description,
    this.name,
    required this.types,
    this.location,
    this.rating,
  });
}

class MapPlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final MapLatLng location;
  final String? phoneNumber;
  final String? website;
  final double? rating;
  final List<String> types;

  MapPlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.location,
    this.phoneNumber,
    this.website,
    this.rating,
    required this.types,
  });
}

class MapDirectionsResult {
  final List<MapRoute> routes;
  final String status;

  MapDirectionsResult({
    required this.routes,
    required this.status,
  });
}

class MapRoute {
  final String summary;
  final List<MapLeg> legs;
  final String encodedPolyline;
  final MapBounds bounds;

  MapRoute({
    required this.summary,
    required this.legs,
    required this.encodedPolyline,
    required this.bounds,
  });
}

class MapLeg {
  final MapDistance distance;
  final MapDuration duration;
  final String startAddress;
  final String endAddress;
  final MapLatLng startLocation;
  final MapLatLng endLocation;

  MapLeg({
    required this.distance,
    required this.duration,
    required this.startAddress,
    required this.endAddress,
    required this.startLocation,
    required this.endLocation,
  });
}

class MapDistance {
  final String text;
  final int value; // in meters

  MapDistance({required this.text, required this.value});
}

class MapDuration {
  final String text;
  final int value; // in seconds

  MapDuration({required this.text, required this.value});
}

class MapBounds {
  final MapLatLng northeast;
  final MapLatLng southwest;

  MapBounds({required this.northeast, required this.southwest});
}

class MapDistanceMatrixResult {
  final List<MapDistanceMatrixRow> rows;
  final String status;

  MapDistanceMatrixResult({required this.rows, required this.status});
}

class MapDistanceMatrixRow {
  final List<MapDistanceMatrixElement> elements;

  MapDistanceMatrixRow({required this.elements});
}

class MapDistanceMatrixElement {
  final MapDistance distance;
  final MapDuration duration;
  final String status;

  MapDistanceMatrixElement({
    required this.distance,
    required this.duration,
    required this.status,
  });
} 