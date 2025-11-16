/// app_permission_service.dart - App Permission Service
/// 
/// Purpose:
/// - Handles all app permissions in one place
/// - Requests permissions at appropriate times
/// - Provides user-friendly permission request flow
/// 
/// Key Logic:
/// - Location permissions (fine, coarse, background)
/// - Notification permissions
/// - Overlay permission (display over other apps)
/// - Camera permission (for document photos)
/// - Storage permission (for file access)
/// - Phone permission (for calling customers)
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class AppPermissionService {
  /// Request all essential permissions for the app
  static Future<Map<String, bool>> requestAllPermissions(BuildContext context) async {
    final results = <String, bool>{};
    
    // Request location permissions
    results['location'] = await requestLocationPermissions();
    
    // Request notification permissions
    results['notification'] = await requestNotificationPermissions();
    
    // Request camera permission
    results['camera'] = await requestCameraPermission();
    
    // Request storage permission (for Android)
    if (Platform.isAndroid) {
      results['storage'] = await requestStoragePermission();
    }
    
    // Request phone permission (for calling)
    results['phone'] = await requestPhonePermission();
    
    return results;
  }

  /// Request location permissions (fine, coarse, background)
  static Future<bool> requestLocationPermissions() async {
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

      // For Android, also check fine location permission
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
              debugPrint('⚠️ Background location permission not granted, but continuing');
            }
          }
        }
      }

      debugPrint('✅ Location permissions granted');
      return true;
    } catch (e) {
      debugPrint('❌ Error requesting location permissions: $e');
      return false;
    }
  }

  /// Request notification permissions
  static Future<bool> requestNotificationPermissions() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (status != PermissionStatus.granted) {
          final result = await Permission.notification.request();
          return result.isGranted;
        }
        return true;
      }
      // iOS notification permissions are handled by Firebase Messaging
      return true;
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('❌ Camera permission permanently denied');
        return false;
      }
      
      final result = await Permission.camera.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('❌ Error requesting camera permission: $e');
      return false;
    }
  }

  /// Request storage permission (for Android)
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true; // iOS doesn't need explicit storage permission
    }
    
    try {
      // For Android 13+, use photos permission
      if (await _isAndroid13OrHigher()) {
        final status = await Permission.photos.status;
        if (status.isGranted) {
          return true;
        }
        final result = await Permission.photos.request();
        return result.isGranted;
      } else {
        // For Android < 13, use storage permission
        final status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }
        final result = await Permission.storage.request();
        return result.isGranted;
      }
    } catch (e) {
      debugPrint('❌ Error requesting storage permission: $e');
      return false;
    }
  }

  /// Request phone permission (for making calls)
  static Future<bool> requestPhonePermission() async {
    try {
      final status = await Permission.phone.status;
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('❌ Phone permission permanently denied');
        return false;
      }
      
      final result = await Permission.phone.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('❌ Error requesting phone permission: $e');
      return false;
    }
  }

  /// Request overlay permission (display over other apps)
  static Future<bool> requestOverlayPermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      return true; // iOS doesn't have overlay permission
    }
    
    try {
      final status = await Permission.systemAlertWindow.status;
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        return await _showOverlayPermissionDialog(context);
      }
      
      final result = await Permission.systemAlertWindow.request();
      if (result.isGranted) {
        return true;
      } else if (result.isPermanentlyDenied) {
        return await _showOverlayPermissionDialog(context);
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error requesting overlay permission: $e');
      return false;
    }
  }

  /// Show dialog for overlay permission
  static Future<bool> _showOverlayPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'To keep the app on top during active trips, please grant "Display over other apps" permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Check if Android version is 10 or higher
  static Future<bool> _isAndroid10OrHigher() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      // Android 10 is API level 29
      // We'll check by attempting to access locationAlways permission
      // If it's available, we're on Android 10+
      await Permission.locationAlways.status;
      // If we can check the status, we're on Android 10+
      return true;
    } catch (e) {
      // If there's an error, assume older Android
      return false;
    }
  }

  /// Check if Android version is 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      // Android 13 is API level 33
      // Check if photos permission is available (Android 13+)
      try {
        await Permission.photos.status;
        return true; // Photos permission exists, so Android 13+
      } catch (e) {
        // Photos permission doesn't exist, so Android < 13
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Check if all essential permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    try {
      // Check location
      final locationStatus = await Geolocator.checkPermission();
      if (locationStatus == LocationPermission.denied || 
          locationStatus == LocationPermission.deniedForever) {
        return false;
      }

      // Check notification (Android)
      if (Platform.isAndroid) {
        final notificationStatus = await Permission.notification.status;
        if (!notificationStatus.isGranted) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error checking permissions: $e');
      return false;
    }
  }

  /// Request permissions with explanation dialog
  static Future<Map<String, bool>> requestWithExplanation(BuildContext context) async {
    // Show explanation dialog first
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This app needs certain permissions to function properly:\n\n'
          '• Location: To track your position during trips\n'
          '• Notifications: To receive trip requests and updates\n'
          '• Camera: To take photos of documents\n'
          '• Storage: To access document files\n'
          '• Phone: To call customers\n'
          '• Display over apps: To show trip info while using other apps\n\n'
          'Grant these permissions to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );

    if (shouldRequest == true) {
      return await requestAllPermissions(context);
    }

    return {};
  }
}

