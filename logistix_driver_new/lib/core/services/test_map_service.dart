/**
 * test_map_service.dart - Test Map Service Implementation
 * 
 * Purpose:
 * - Provides mock implementation of MapServiceInterface for testing
 * - Enables development and testing without external map service dependencies
 * - Implements all map service methods with mock data and responses
 * 
 * Key Logic:
 * - Mock geocoding with hardcoded location responses
 * - Simulated distance calculations using basic formulas
 * - Fake place suggestions for testing autocomplete functionality
 * - Configurable delays to simulate network latency in tests
 * - Deterministic responses for predictable testing scenarios
 * - Error simulation capabilities for testing error handling
 * - Supports unit testing and integration testing workflows
 */

import 'package:flutter/foundation.dart';
import 'map_service_factory.dart';
import 'map_service_interface.dart';

/// Utility class to test map service configuration
class MapServiceTester {
  static Future<void> testConfiguration() async {
    if (kDebugMode) {
      print('🧪 Testing Map Service Configuration...');
      
      final mapService = MapServiceFactory.instance;
      
      // Test 1: Check if service is configured
      print('✅ Provider: ${mapService.providerName}');
      print('✅ Configured: ${mapService.isConfigured}');
      
      if (!mapService.isConfigured) {
        print('❌ Map service is not properly configured!');
        return;
      }
      
      // Test 2: Test geocoding
      try {
        print('🔍 Testing geocoding...');
        final result = await mapService.geocode('Chennai, India');
        if (result != null) {
          print('✅ Geocoding successful: ${result.formattedAddress}');
          print('📍 Location: ${result.location.lat}, ${result.location.lng}');
        } else {
          print('⚠️ Geocoding returned null result');
        }
      } catch (e) {
        print('❌ Geocoding failed: $e');
      }
      
      // Test 3: Test reverse geocoding
      try {
        print('🔄 Testing reverse geocoding...');
        final result = await mapService.reverseGeocode(13.0827, 80.2707);
        if (result != null) {
          print('✅ Reverse geocoding successful: ${result.formattedAddress}');
        } else {
          print('⚠️ Reverse geocoding returned null result');
        }
      } catch (e) {
        print('❌ Reverse geocoding failed: $e');
      }
      
      // Test 4: Test places autocomplete
      try {
        print('🔍 Testing places autocomplete...');
        final results = await mapService.placesAutocomplete('restaurant');
        print('✅ Autocomplete returned ${results.length} results');
        if (results.isNotEmpty) {
          print('📋 First result: ${results.first.description}');
        }
      } catch (e) {
        print('❌ Places autocomplete failed: $e');
      }
      
      // Test 5: Test tile URL generation
      try {
        print('🗺️ Testing tile URL generation...');
        final tileUrl = mapService.getTileUrl(10, 512, 512);
        print('✅ Tile URL: $tileUrl');
      } catch (e) {
        print('❌ Tile URL generation failed: $e');
      }
      
      print('🏁 Map service testing completed!');
    }
  }
  
  /// Quick test that can be called from anywhere
  static Future<bool> quickTest() async {
    try {
      final mapService = MapServiceFactory.instance;
      if (!mapService.isConfigured) return false;
      
      final result = await mapService.geocode('Chennai');
      return result != null;
    } catch (e) {
      if (kDebugMode) print('Quick test failed: $e');
      return false;
    }
  }
} 