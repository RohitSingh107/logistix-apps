/**
 * location_service_test.dart - Location Service Tests
 * 
 * Purpose:
 * - Tests the location service functionality
 * - Verifies basic location service operations
 * - Tests distance calculation functionality
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import '../lib/core/services/location_service.dart';

void main() {
  group('LocationService Tests', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService();
    });

    test('should initialize location service', () {
      // Assert
      expect(locationService.isTracking, false);
    });

    test('should stop location tracking when not active', () {
      // Act
      locationService.stopLocationTracking();

      // Assert
      expect(locationService.isTracking, false);
    });

    test('should calculate distance between positions', () {
      // Arrange
      final position1 = Position(
        latitude: 28.7041,
        longitude: 77.1025,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      final position2 = Position(
        latitude: 28.7042,
        longitude: 77.1026,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      // Act
      final distance = locationService.calculateDistance(position1, position2);

      // Assert
      expect(distance, greaterThan(0.0));
    });

    test('should handle service disposal', () {
      // Act
      locationService.dispose();

      // Assert
      expect(locationService.isTracking, false);
    });
  });
} 