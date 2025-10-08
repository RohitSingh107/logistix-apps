/// ola_maps_service_impl.dart - Ola Maps Service Implementation
/// 
/// Purpose:
/// - Implements the MapServiceInterface for Ola Maps integration
/// - Provides location services, geocoding, and mapping functionality
/// - Handles Ola Maps API communication and response processing
/// 
/// Key Logic:
/// - geocodeAddress: Converts addresses to coordinates using Ola Maps API
/// - reverseGeocode: Converts coordinates to human-readable addresses
/// - calculateDistance: Computes distance and duration between locations
/// - getPlaceSuggestions: Provides autocomplete suggestions for places
/// - Implements authentication and rate limiting for Ola Maps API
/// - Handles API key management and request headers
/// - Transforms Ola Maps responses to standardized map data models

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../map_service_interface.dart';
import '../../config/map_provider_config.dart';
import 'dart:math' as math;

/// Ola Maps implementation of MapServiceInterface
class OlaMapsServiceImpl implements MapServiceInterface {
  late final Dio _dio;
  
  // Singleton pattern
  static final OlaMapsServiceImpl _instance = OlaMapsServiceImpl._internal();
  factory OlaMapsServiceImpl() => _instance;
  
  OlaMapsServiceImpl._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: MapProviderConfig.olaMapsBaseUrl,
      connectTimeout: MapProviderConfig.connectTimeout,
      receiveTimeout: MapProviderConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'LogistixApp/1.0',
      },
    ));
    
    // Add retry interceptor for rate limiting
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        if (e.response?.statusCode == 429) {
          // Rate limited - add delay and retry once
          await Future.delayed(const Duration(milliseconds: 500));
          debugPrint('[OlaMaps] Rate limited, retrying after delay...');
          
          try {
            final cloneReq = await _dio.request(
              e.requestOptions.path,
              options: Options(
                method: e.requestOptions.method,
                headers: e.requestOptions.headers,
              ),
              data: e.requestOptions.data,
              queryParameters: e.requestOptions.queryParameters,
            );
            return handler.resolve(cloneReq);
          } catch (retryError) {
            debugPrint('[OlaMaps] Retry failed: $retryError');
          }
        }
        return handler.next(e);
      },
    ));
    
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[OlaMaps] $obj'),
      ));
    }
  }

  @override
  String get providerName => 'Ola Maps';

  @override
  bool get isConfigured => MapProviderConfig.isCurrentProviderConfigured();

  @override
  Future<MapGeocodingResult?> geocode(String address) async {
    try {
      final response = await _dio.get(
        '/places/v1/geocode',
        queryParameters: {
          'address': address,
          'language': 'en',
          'api_key': MapProviderConfig.olaMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['geocodingResults'] != null) {
        final results = response.data['geocodingResults'] as List;
        if (results.isNotEmpty) {
          final result = results.first;
          return MapGeocodingResult(
            formattedAddress: result['formatted_address'] ?? '',
            location: MapLatLng(
              result['geometry']['location']['lat'].toDouble(),
              result['geometry']['location']['lng'].toDouble(),
            ),
            types: List<String>.from(result['types'] ?? []),
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('[OlaMaps] Geocoding error: $e');
      return null;
    }
  }

  @override
  Future<MapReverseGeocodingResult?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '/places/v1/reverse-geocode',
        queryParameters: {
          'latlng': '$lat,$lng',
          'language': 'en',
          'api_key': MapProviderConfig.olaMapsApiKey,
        },
      );

      if (response.statusCode == 200) {
        // Handle different response statuses
        final status = response.data['status'] ?? '';
        
        if (status == 'zero_results') {
          debugPrint('[OlaMaps] No results found for coordinates: $lat,$lng (possibly outside coverage area)');
          return null;
        }
        
        if (status == 'ok' && response.data['results'] != null) {
          final results = response.data['results'] as List;
          if (results.isNotEmpty) {
            final result = results.first;
            
            // Extract address components properly
            final addressComponents = <MapAddressComponent>[];
            if (result['address_components'] != null) {
              for (final component in result['address_components']) {
                addressComponents.add(MapAddressComponent(
                  longName: component['long_name'] ?? '',
                  shortName: component['short_name'] ?? '',
                  types: List<String>.from(component['types'] ?? []),
                ));
              }
            }
            
            return MapReverseGeocodingResult(
              formattedAddress: result['formatted_address'] ?? result['name'] ?? '',
              addressComponents: addressComponents,
              location: MapLatLng(
                result['geometry']['location']['lat'].toDouble(),
                result['geometry']['location']['lng'].toDouble(),
              ),
            );
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('[OlaMaps] Reverse geocoding error: $e');
      return null;
    }
  }

  @override
  Future<List<MapPlaceResult>> placesAutocomplete(
    String input, {
    double? lat,
    double? lng,
    int? radius,
  }) async {
    try {
      debugPrint('[OlaMaps] Starting places autocomplete for: "$input"');
      
      final queryParams = {
        'input': input,
        'language': 'en',
        'api_key': MapProviderConfig.olaMapsApiKey,
      };
      
      if (lat != null && lng != null) {
        queryParams['location'] = '$lat,$lng';
        debugPrint('[OlaMaps] Using location: $lat, $lng');
      }
      if (radius != null) {
        queryParams['radius'] = radius.toString();
        debugPrint('[OlaMaps] Using radius: $radius');
      }

      debugPrint('[OlaMaps] Making API request with params: $queryParams');

      final response = await _dio.get(
        '/places/v1/autocomplete',
        queryParameters: queryParams,
      );

      debugPrint('[OlaMaps] API response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['predictions'] != null) {
        final predictions = response.data['predictions'] as List;
        debugPrint('[OlaMaps] Received ${predictions.length} predictions');
        
        final results = predictions
            .map((json) {
              try {
                return MapPlaceResult(
                  placeId: json['place_id'] ?? json['id'] ?? '',
                  description: json['description'] ?? json['formatted_address'] ?? '',
                  name: json['name'],
                  types: List<String>.from(json['types'] ?? []),
                  location: json['geometry'] != null && json['geometry']['location'] != null
                      ? MapLatLng(
                          json['geometry']['location']['lat'].toDouble(),
                          json['geometry']['location']['lng'].toDouble(),
                        )
                      : null,
                  rating: json['rating']?.toDouble(),
                );
              } catch (e) {
                debugPrint('[OlaMaps] Error parsing prediction: $e');
                return null;
              }
            })
            .where((result) => result != null)
            .cast<MapPlaceResult>()
            .toList();
        
        debugPrint('[OlaMaps] Successfully parsed ${results.length} results');
        return results;
      } else {
        debugPrint('[OlaMaps] Invalid response format: ${response.data}');
        return [];
      }
    } catch (e) {
      debugPrint('[OlaMaps] Places autocomplete error: $e');
      return [];
    }
  }

  @override
  Future<MapPlaceDetails?> placeDetails(String placeId) async {
    try {
      final response = await _dio.get(
        '/places/v1/details',
        queryParameters: {
          'place_id': placeId,
          'language': 'en',
          'api_key': MapProviderConfig.olaMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        final result = response.data['result'];
        return MapPlaceDetails(
          placeId: result['place_id'] ?? '',
          name: result['name'] ?? '',
          formattedAddress: result['formatted_address'] ?? '',
          location: MapLatLng(
            result['geometry']['location']['lat'].toDouble(),
            result['geometry']['location']['lng'].toDouble(),
          ),
          phoneNumber: result['formatted_phone_number'],
          website: result['website'],
          rating: result['rating']?.toDouble(),
          types: List<String>.from(result['types'] ?? []),
        );
      }
      return null;
    } catch (e) {
      debugPrint('[OlaMaps] Place details error: $e');
      return null;
    }
  }

  @override
  Future<List<MapPlaceResult>> nearbySearch({
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
        'api_key': MapProviderConfig.olaMapsApiKey,
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
            .map((json) => MapPlaceResult(
                  placeId: json['place_id'] ?? json['id'] ?? '',
                  description: json['description'] ?? json['formatted_address'] ?? '',
                  name: json['name'],
                  types: List<String>.from(json['types'] ?? []),
                  location: json['geometry'] != null 
                      ? MapLatLng(
                          json['geometry']['location']['lat'].toDouble(),
                          json['geometry']['location']['lng'].toDouble(),
                        )
                      : null,
                  rating: json['rating']?.toDouble(),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[OlaMaps] Nearby search error: $e');
      return [];
    }
  }

  @override
  Future<MapDirectionsResult?> getDirections({
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
          'api_key': MapProviderConfig.olaMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['routes'] != null) {
        final routes = (response.data['routes'] as List)
            .map((r) => MapRoute(
                  summary: r['summary'] ?? '',
                  legs: (r['legs'] as List?)
                      ?.map((l) => MapLeg(
                            distance: MapDistance(
                              text: l['distance']?['text'] ?? '',
                              value: l['distance']?['value'] ?? 0,
                            ),
                            duration: MapDuration(
                              text: l['duration']?['text'] ?? '',
                              value: l['duration']?['value'] ?? 0,
                            ),
                            startAddress: l['start_address'] ?? '',
                            endAddress: l['end_address'] ?? '',
                            startLocation: MapLatLng(
                              l['start_location']?['lat']?.toDouble() ?? 0.0,
                              l['start_location']?['lng']?.toDouble() ?? 0.0,
                            ),
                            endLocation: MapLatLng(
                              l['end_location']?['lat']?.toDouble() ?? 0.0,
                              l['end_location']?['lng']?.toDouble() ?? 0.0,
                            ),
                          ))
                      .toList() ?? [],
                  encodedPolyline: r['overview_polyline']?['points'] ?? '',
                  bounds: MapBounds(
                    northeast: MapLatLng(
                      r['bounds']?['northeast']?['lat']?.toDouble() ?? 0.0,
                      r['bounds']?['northeast']?['lng']?.toDouble() ?? 0.0,
                    ),
                    southwest: MapLatLng(
                      r['bounds']?['southwest']?['lat']?.toDouble() ?? 0.0,
                      r['bounds']?['southwest']?['lng']?.toDouble() ?? 0.0,
                    ),
                  ),
                ))
            .toList();

        return MapDirectionsResult(
          routes: routes,
          status: response.data['status'] ?? '',
        );
      }
      return null;
    } catch (e) {
      debugPrint('[OlaMaps] Directions error: $e');
      return null;
    }
  }

  @override
  Future<MapDistanceMatrixResult?> getDistanceMatrix({
    required List<MapLatLng> origins,
    required List<MapLatLng> destinations,
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
          'api_key': MapProviderConfig.olaMapsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final rows = (response.data['rows'] as List?)
            ?.map((r) => MapDistanceMatrixRow(
                  elements: (r['elements'] as List?)
                      ?.map((e) => MapDistanceMatrixElement(
                            distance: MapDistance(
                              text: e['distance']?['text'] ?? '',
                              value: e['distance']?['value'] ?? 0,
                            ),
                            duration: MapDuration(
                              text: e['duration']?['text'] ?? '',
                              value: e['duration']?['value'] ?? 0,
                            ),
                            status: e['status'] ?? '',
                          ))
                      .toList() ?? [],
                ))
            .toList() ?? [];

        return MapDistanceMatrixResult(
          rows: rows,
          status: response.data['status'] ?? '',
        );
      }
      return null;
    } catch (e) {
      debugPrint('[OlaMaps] Distance matrix error: $e');
      return null;
    }
  }

  @override
  String getTileUrl(int z, int x, int y) {
    // Note: Ola Maps doesn't provide traditional raster tiles like /{z}/{x}/{y}
    // Instead, they provide static map images via their Static Tiles API
    // This method is kept for compatibility but should use static API in practice
    
    // Convert tile coordinates back to lat/lng for static API
    final lat = _tileYToLatitude(y, z);
    final lng = _tileXToLongitude(x, z);
    
    // Use static tiles API with 256x256 tile size
    return '${MapProviderConfig.olaMapsBaseUrl}/tiles/v1/styles/default-light-standard/static/$lng,$lat,$z/256x256.png?api_key=${MapProviderConfig.olaMapsApiKey}';
  }
  
  /// Convert tile X coordinate to longitude
  double _tileXToLongitude(int x, int z) {
    return x / math.pow(2, z) * 360.0 - 180.0;
  }
  
  /// Convert tile Y coordinate to latitude  
  double _tileYToLatitude(int y, int z) {
    final n = math.pi - 2.0 * math.pi * y / math.pow(2, z);
    return 180.0 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
  }
} 