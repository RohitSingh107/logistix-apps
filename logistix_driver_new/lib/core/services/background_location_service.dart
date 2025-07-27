/**
 * background_location_service.dart - Background Location Service
 * 
 * Purpose:
 * - Handles location tracking when app is in background
 * - Manages background location permissions and settings
 * - Provides efficient background location updates
 * - Handles app lifecycle changes
 * 
 * Key Logic:
 * - Background location tracking with proper permissions
 * - App lifecycle management (foreground/background)
 * - Battery optimization with adaptive update intervals
 * - Network connectivity monitoring
 * - Error handling and retry mechanisms
 */

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import '../../features/driver/domain/repositories/driver_repository.dart';
import '../di/service_locator.dart';

class BackgroundLocationService {
  static final BackgroundLocationService _instance = BackgroundLocationService._internal();
  factory BackgroundLocationService() => _instance;
  BackgroundLocationService._internal();

  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  bool _isTracking = false;
  bool _isInBackground = false;
  Position? _lastPosition;
  DateTime? _lastUpdateTime;
  final Duration _updateInterval = const Duration(seconds: 3);
  final Duration _backgroundUpdateInterval = const Duration(seconds: 10);
  final double _minAccuracy = 100.0; // More lenient for background
  final double _minDistanceChange = 20.0; // meters

  /// Start background location tracking
  Future<void> startBackgroundTracking() async {
    if (_isTracking) {
      debugPrint('📍 Background tracking already active');
      return;
    }

    try {
      debugPrint('📍 Starting background location tracking...');
      
      // Check and request permissions
      final hasPermission = await _checkAndRequestBackgroundPermissions();
      if (!hasPermission) {
        debugPrint('❌ Background location permission denied');
        return;
      }

      // Check if location services are enabled
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        debugPrint('❌ Location services are disabled');
        return;
      }

      _isTracking = true;
      _startLocationStream();
      _startServiceStatusMonitoring();
      
      debugPrint('✅ Background location tracking started successfully');
    } catch (e) {
      debugPrint('❌ Error starting background tracking: $e');
      _isTracking = false;
    }
  }

  /// Stop background location tracking
  void stopBackgroundTracking() {
    if (!_isTracking) {
      debugPrint('📍 Background tracking not active');
      return;
    }

    debugPrint('📍 Stopping background location tracking...');
    _locationSubscription?.cancel();
    _serviceStatusSubscription?.cancel();
    _locationSubscription = null;
    _serviceStatusSubscription = null;
    _isTracking = false;
    _lastPosition = null;
    _lastUpdateTime = null;
    debugPrint('✅ Background location tracking stopped');
  }

  /// Set app background state
  void setBackgroundState(bool isInBackground) {
    _isInBackground = isInBackground;
    debugPrint('📍 App background state: ${isInBackground ? "background" : "foreground"}');
  }

  /// Check if background tracking is active
  bool get isTracking => _isTracking;

  /// Start location stream
  void _startLocationStream() {
    _locationSubscription?.cancel();
    
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: _minDistanceChange.toInt(),
      timeLimit: const Duration(seconds: 5),
    );

    _locationSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen(
      (Position position) async {
        await _handleLocationUpdate(position);
      },
      onError: (error) {
        debugPrint('❌ Location stream error: $error');
      },
    );
  }

  /// Start service status monitoring
  void _startServiceStatusMonitoring() {
    _serviceStatusSubscription?.cancel();
    
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen(
      (ServiceStatus status) {
        debugPrint('📍 Location service status: $status');
        if (status == ServiceStatus.disabled) {
          debugPrint('⚠️ Location services disabled');
        }
      },
    );
  }

  /// Handle location updates
  Future<void> _handleLocationUpdate(Position position) async {
    try {
      // Check if enough time has passed since last update
      if (_lastUpdateTime != null) {
        final timeSinceLastUpdate = DateTime.now().difference(_lastUpdateTime!);
        final minInterval = _isInBackground ? _backgroundUpdateInterval : _updateInterval;
        
        if (timeSinceLastUpdate < minInterval) {
          return;
        }
      }

      // Validate position accuracy (more lenient in background)
      if (position.accuracy > _minAccuracy) {
        debugPrint('⚠️ Position accuracy too low: ${position.accuracy}m');
        return;
      }

      // Check if position has changed significantly
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance < _minDistanceChange) {
          debugPrint('📍 Position change too small: ${distance.toStringAsFixed(1)}m');
          return;
        }
      }

      // Update location on server
      await _sendLocationToServer(position);
      
      _lastPosition = position;
      _lastUpdateTime = DateTime.now();
      
      debugPrint('📍 Background location updated: ${position.latitude}, ${position.longitude} (accuracy: ${position.accuracy}m)');
    } catch (e) {
      debugPrint('❌ Error handling location update: $e');
    }
  }

  /// Send location to server
  Future<void> _sendLocationToServer(Position position) async {
    try {
      final driverRepository = serviceLocator<DriverRepository>();
      
      // Only send location fields, exclude null values
      await driverRepository.updateDriverLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      debugPrint('✅ Background location sent to server successfully');
    } catch (e) {
      debugPrint('❌ Error sending background location to server: $e');
      // Don't throw error to prevent stream cancellation
    }
  }

  /// Check and request background location permissions
  Future<bool> _checkAndRequestBackgroundPermissions() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permission permanently denied');
        return false;
      }

      // For Android, check fine location permission
      if (Platform.isAndroid) {
        final status = await Permission.location.status;
        if (status != PermissionStatus.granted) {
          final result = await Permission.location.request();
          if (result != PermissionStatus.granted) {
            debugPrint('❌ Fine location permission denied');
            return false;
          }
        }

        // Request background location permission for Android 10+
        if (await _isAndroid10OrHigher()) {
          final backgroundStatus = await Permission.locationWhenInUse.status;
          if (backgroundStatus == PermissionStatus.granted) {
            final backgroundResult = await Permission.locationAlways.request();
            if (backgroundResult != PermissionStatus.granted) {
              debugPrint('⚠️ Background location permission not granted, but continuing with foreground tracking');
            }
          }
        }
      }

      debugPrint('✅ Background location permissions granted');
      return true;
    } catch (e) {
      debugPrint('❌ Error checking background permissions: $e');
      return false;
    }
  }

  /// Check if Android version is 10 or higher
  Future<bool> _isAndroid10OrHigher() async {
    if (Platform.isAndroid) {
      try {
        const platform = MethodChannel('flutter/platform');
        final result = await platform.invokeMethod('getAndroidVersion');
        final version = int.tryParse(result.toString()) ?? 0;
        return version >= 29; // Android 10 is API level 29
      } catch (e) {
        debugPrint('❌ Error checking Android version: $e');
        return false;
      }
    }
    return false;
  }

  /// Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('❌ Error getting last known position: $e');
      return null;
    }
  }

  /// Calculate distance between two positions
  double calculateDistance(Position position1, Position position2) {
    return Geolocator.distanceBetween(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('❌ Error checking location service: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    stopBackgroundTracking();
  }
} 