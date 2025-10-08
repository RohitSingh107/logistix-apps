/// ola_maps_service.dart - Ola Maps Service Interface
/// 
/// Purpose:
/// - Defines the contract for Ola Maps service operations
/// - Provides abstract methods for map-related functionality
/// - Establishes standardized interface for Ola Maps integration
/// 
/// Key Logic:
/// - Abstract methods for geocoding and reverse geocoding
/// - Distance calculation and route planning interfaces
/// - Place search and autocomplete functionality contracts
/// - Standardized error handling for map service operations
/// - Defines data models for location and mapping responses
/// - Provides consistent API for different map service implementations
/// - Supports dependency injection through abstract interface

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/ola_maps_config.dart';

class OlaMapsService {
  static const String _baseUrl = OlaMapsConfig.baseUrl;
  static const String _apiKey = OlaMapsConfig.apiKey;
  
  late final Dio _dio;
  
  // Singleton pattern
  static final OlaMapsService _instance = OlaMapsService._internal();
  factory OlaMapsService() => _instance;
  
  OlaMapsService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: OlaMapsConfig.connectTimeout,
      receiveTimeout: OlaMapsConfig.receiveTimeout,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    ));
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  /// Geocoding - Convert address to coordinates
  Future<OlaGeocodingResult?> geocode(String address) async {
    try {
      final response = await _dio.get(
        '/places/v1/geocode',
        queryParameters: {
          'address': address,
          'language': 'en',
        },
      );

      if (response.statusCode == 200 && response.data['geocodingResults'] != null) {
        final results = response.data['geocodingResults'] as List;
        if (results.isNotEmpty) {
          return OlaGeocodingResult.fromJson(results.first);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return null;
    }
  }

  /// Reverse Geocoding - Convert coordinates to address
  Future<OlaReverseGeocodingResult?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '/places/v1/reverse-geocode',
        queryParameters: {
          'latlng': '$lat,$lng',
          'language': 'en',
        },
      );

      if (response.statusCode == 200 && response.data['results'] != null) {
        final results = response.data['results'] as List;
        if (results.isNotEmpty) {
          return OlaReverseGeocodingResult.fromJson(results.first);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      return null;
    }
  }

  /// Places Autocomplete - Get place suggestions
  Future<List<OlaPlaceResult>> placesAutocomplete(String input, {
    double? lat,
    double? lng,
    int? radius,
  }) async {
    try {
      final queryParams = {
        'input': input,
        'language': 'en',
      };
      
      if (lat != null && lng != null) {
        queryParams['location'] = '$lat,$lng';
      }
      if (radius != null) {
        queryParams['radius'] = radius.toString();
      }

      final response = await _dio.get(
        '/places/v1/autocomplete',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['predictions'] != null) {
        final predictions = response.data['predictions'] as List;
        return predictions
            .map((json) => OlaPlaceResult.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Places autocomplete error: $e');
      return [];
    }
  }

  /// Place Details - Get detailed information about a place
  Future<OlaPlaceDetails?> placeDetails(String placeId) async {
    try {
      final response = await _dio.get(
        '/places/v1/details',
        queryParameters: {
          'place_id': placeId,
          'language': 'en',
        },
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        return OlaPlaceDetails.fromJson(response.data['result']);
      }
      return null;
    } catch (e) {
      debugPrint('Place details error: $e');
      return null;
    }
  }

  /// Nearby Search - Find places near a location
  Future<List<OlaPlaceResult>> nearbySearch({
    required double lat,
    required double lng,
    int radius = 1000,
    String? type,
    String? keyword,
  }) async {
    try {
      final queryParams = {
        'location': '$lat,$lng',
        'radius': radius.toString(),
        'language': 'en',
      };
      
      if (type != null) queryParams['type'] = type;
      if (keyword != null) queryParams['keyword'] = keyword;

      final response = await _dio.get(
        '/places/v1/nearbysearch',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['results'] != null) {
        final results = response.data['results'] as List;
        return results
            .map((json) => OlaPlaceResult.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Nearby search error: $e');
      return [];
    }
  }

  /// Directions - Get route between two points
  Future<OlaDirectionsResult?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    bool alternatives = false,
  }) async {
    try {
      final response = await _dio.get(
        '/routing/v1/directions',
        queryParameters: {
          'origin': '$originLat,$originLng',
          'destination': '$destLat,$destLng',
          'mode': mode,
          'alternatives': alternatives.toString(),
          'language': 'en',
        },
      );

      if (response.statusCode == 200 && response.data['routes'] != null) {
        return OlaDirectionsResult.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Directions error: $e');
      return null;
    }
  }

  /// Distance Matrix - Get travel distance and time for multiple origins/destinations
  Future<OlaDistanceMatrixResult?> getDistanceMatrix({
    required List<OlaLatLng> origins,
    required List<OlaLatLng> destinations,
    String mode = 'driving',
  }) async {
    try {
      final originStrs = origins.map((o) => '${o.lat},${o.lng}').join('|');
      final destStrs = destinations.map((d) => '${d.lat},${d.lng}').join('|');

      final response = await _dio.get(
        '/routing/v1/distancematrix',
        queryParameters: {
          'origins': originStrs,
          'destinations': destStrs,
          'mode': mode,
          'language': 'en',
        },
      );

      if (response.statusCode == 200) {
        return OlaDistanceMatrixResult.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Distance matrix error: $e');
      return null;
    }
  }

  /// Get Map Tiles URL
  String getTileUrl(int z, int x, int y) {
    return '$_baseUrl/tiles/v1/styles/default/{z}/{x}/{y}?api_key=$_apiKey'
        .replaceAll('{z}', z.toString())
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString());
  }
}

// Models for Ola Maps API responses

class OlaLatLng {
  final double lat;
  final double lng;

  OlaLatLng(this.lat, this.lng);

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
  
  factory OlaLatLng.fromJson(Map<String, dynamic> json) => 
      OlaLatLng(json['lat'].toDouble(), json['lng'].toDouble());

  @override
  String toString() => 'OlaLatLng($lat, $lng)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OlaLatLng && 
      runtimeType == other.runtimeType &&
      lat == other.lat &&
      lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}

class OlaGeocodingResult {
  final String formattedAddress;
  final OlaLatLng location;
  final List<String> types;

  OlaGeocodingResult({
    required this.formattedAddress,
    required this.location,
    required this.types,
  });

  factory OlaGeocodingResult.fromJson(Map<String, dynamic> json) {
    return OlaGeocodingResult(
      formattedAddress: json['formatted_address'] ?? '',
      location: OlaLatLng.fromJson(json['geometry']['location']),
      types: List<String>.from(json['types'] ?? []),
    );
  }
}

class OlaReverseGeocodingResult {
  final String formattedAddress;
  final List<OlaAddressComponent> addressComponents;
  final OlaLatLng location;

  OlaReverseGeocodingResult({
    required this.formattedAddress,
    required this.addressComponents,
    required this.location,
  });

  factory OlaReverseGeocodingResult.fromJson(Map<String, dynamic> json) {
    return OlaReverseGeocodingResult(
      formattedAddress: json['formatted_address'] ?? '',
      addressComponents: (json['address_components'] as List?)
          ?.map((c) => OlaAddressComponent.fromJson(c))
          .toList() ?? [],
      location: OlaLatLng.fromJson(json['geometry']['location']),
    );
  }
}

class OlaAddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  OlaAddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory OlaAddressComponent.fromJson(Map<String, dynamic> json) {
    return OlaAddressComponent(
      longName: json['long_name'] ?? '',
      shortName: json['short_name'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }
}

class OlaPlaceResult {
  final String placeId;
  final String description;
  final String? name;
  final List<String> types;
  final OlaLatLng? location;
  final double? rating;

  OlaPlaceResult({
    required this.placeId,
    required this.description,
    this.name,
    required this.types,
    this.location,
    this.rating,
  });

  factory OlaPlaceResult.fromJson(Map<String, dynamic> json) {
    return OlaPlaceResult(
      placeId: json['place_id'] ?? json['id'] ?? '',
      description: json['description'] ?? json['formatted_address'] ?? '',
      name: json['name'],
      types: List<String>.from(json['types'] ?? []),
      location: json['geometry'] != null 
          ? OlaLatLng.fromJson(json['geometry']['location'])
          : null,
      rating: json['rating']?.toDouble(),
    );
  }
}

class OlaPlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final OlaLatLng location;
  final String? phoneNumber;
  final String? website;
  final double? rating;
  final List<String> types;

  OlaPlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.location,
    this.phoneNumber,
    this.website,
    this.rating,
    required this.types,
  });

  factory OlaPlaceDetails.fromJson(Map<String, dynamic> json) {
    return OlaPlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      location: OlaLatLng.fromJson(json['geometry']['location']),
      phoneNumber: json['formatted_phone_number'],
      website: json['website'],
      rating: json['rating']?.toDouble(),
      types: List<String>.from(json['types'] ?? []),
    );
  }
}

class OlaDirectionsResult {
  final List<OlaRoute> routes;
  final String status;

  OlaDirectionsResult({
    required this.routes,
    required this.status,
  });

  factory OlaDirectionsResult.fromJson(Map<String, dynamic> json) {
    return OlaDirectionsResult(
      routes: (json['routes'] as List?)
          ?.map((r) => OlaRoute.fromJson(r))
          .toList() ?? [],
      status: json['status'] ?? '',
    );
  }
}

class OlaRoute {
  final String summary;
  final List<OlaLeg> legs;
  final String encodedPolyline;
  final OlaBounds bounds;

  OlaRoute({
    required this.summary,
    required this.legs,
    required this.encodedPolyline,
    required this.bounds,
  });

  factory OlaRoute.fromJson(Map<String, dynamic> json) {
    return OlaRoute(
      summary: json['summary'] ?? '',
      legs: (json['legs'] as List?)
          ?.map((l) => OlaLeg.fromJson(l))
          .toList() ?? [],
      encodedPolyline: json['overview_polyline']?['points'] ?? '',
      bounds: OlaBounds.fromJson(json['bounds'] ?? {}),
    );
  }
}

class OlaLeg {
  final OlaDistance distance;
  final OlaDuration duration;
  final String startAddress;
  final String endAddress;
  final OlaLatLng startLocation;
  final OlaLatLng endLocation;

  OlaLeg({
    required this.distance,
    required this.duration,
    required this.startAddress,
    required this.endAddress,
    required this.startLocation,
    required this.endLocation,
  });

  factory OlaLeg.fromJson(Map<String, dynamic> json) {
    return OlaLeg(
      distance: OlaDistance.fromJson(json['distance'] ?? {}),
      duration: OlaDuration.fromJson(json['duration'] ?? {}),
      startAddress: json['start_address'] ?? '',
      endAddress: json['end_address'] ?? '',
      startLocation: OlaLatLng.fromJson(json['start_location'] ?? {}),
      endLocation: OlaLatLng.fromJson(json['end_location'] ?? {}),
    );
  }
}

class OlaDistance {
  final String text;
  final int value; // in meters

  OlaDistance({required this.text, required this.value});

  factory OlaDistance.fromJson(Map<String, dynamic> json) {
    return OlaDistance(
      text: json['text'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}

class OlaDuration {
  final String text;
  final int value; // in seconds

  OlaDuration({required this.text, required this.value});

  factory OlaDuration.fromJson(Map<String, dynamic> json) {
    return OlaDuration(
      text: json['text'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}

class OlaBounds {
  final OlaLatLng northeast;
  final OlaLatLng southwest;

  OlaBounds({required this.northeast, required this.southwest});

  factory OlaBounds.fromJson(Map<String, dynamic> json) {
    return OlaBounds(
      northeast: OlaLatLng.fromJson(json['northeast'] ?? {'lat': 0, 'lng': 0}),
      southwest: OlaLatLng.fromJson(json['southwest'] ?? {'lat': 0, 'lng': 0}),
    );
  }
}

class OlaDistanceMatrixResult {
  final List<OlaDistanceMatrixRow> rows;
  final String status;

  OlaDistanceMatrixResult({required this.rows, required this.status});

  factory OlaDistanceMatrixResult.fromJson(Map<String, dynamic> json) {
    return OlaDistanceMatrixResult(
      rows: (json['rows'] as List?)
          ?.map((r) => OlaDistanceMatrixRow.fromJson(r))
          .toList() ?? [],
      status: json['status'] ?? '',
    );
  }
}

class OlaDistanceMatrixRow {
  final List<OlaDistanceMatrixElement> elements;

  OlaDistanceMatrixRow({required this.elements});

  factory OlaDistanceMatrixRow.fromJson(Map<String, dynamic> json) {
    return OlaDistanceMatrixRow(
      elements: (json['elements'] as List?)
          ?.map((e) => OlaDistanceMatrixElement.fromJson(e))
          .toList() ?? [],
    );
  }
}

class OlaDistanceMatrixElement {
  final OlaDistance distance;
  final OlaDuration duration;
  final String status;

  OlaDistanceMatrixElement({
    required this.distance,
    required this.duration,
    required this.status,
  });

  factory OlaDistanceMatrixElement.fromJson(Map<String, dynamic> json) {
    return OlaDistanceMatrixElement(
      distance: OlaDistance.fromJson(json['distance'] ?? {}),
      duration: OlaDuration.fromJson(json['duration'] ?? {}),
      status: json['status'] ?? '',
    );
  }
} 