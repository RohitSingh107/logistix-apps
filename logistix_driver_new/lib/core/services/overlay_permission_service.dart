/// overlay_permission_service.dart - Overlay Permission Service
/// 
/// Purpose:
/// - Handles "Display over other apps" permission request
/// - Allows app to stay on top during active trips
/// - Provides user-friendly permission request flow
/// 
/// Key Logic:
/// - Checks if overlay permission is granted
/// - Requests permission with proper explanation
/// - Opens settings if permission is denied
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class OverlayPermissionService {
  /// Check if overlay permission is granted
  static Future<bool> isOverlayPermissionGranted() async {
    if (!Platform.isAndroid) {
      // iOS doesn't have overlay permission
      return true;
    }
    
    try {
      final status = await Permission.systemAlertWindow.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Error checking overlay permission: $e');
      return false;
    }
  }

  /// Request overlay permission
  static Future<bool> requestOverlayPermission(BuildContext context) async {
    if (!Platform.isAndroid) {
      // iOS doesn't have overlay permission
      return true;
    }

    try {
      final status = await Permission.systemAlertWindow.status;
      
      if (status.isGranted) {
        debugPrint('✅ Overlay permission already granted');
        return true;
      }

      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        return await _showPermissionDeniedDialog(context);
      }

      // Request permission
      final result = await Permission.systemAlertWindow.request();
      
      if (result.isGranted) {
        debugPrint('✅ Overlay permission granted');
        return true;
      } else if (result.isPermanentlyDenied) {
        return await _showPermissionDeniedDialog(context);
      } else {
        debugPrint('❌ Overlay permission denied');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error requesting overlay permission: $e');
      return false;
    }
  }

  /// Show dialog when permission is permanently denied
  static Future<bool> _showPermissionDeniedDialog(BuildContext context) async {
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
            onPressed: () {
              Navigator.of(context).pop(false);
            },
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

  /// Request permission with explanation dialog
  static Future<bool> requestWithExplanation(BuildContext context) async {
    if (await isOverlayPermissionGranted()) {
      return true;
    }

    // Show explanation dialog first
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keep App on Top'),
        content: const Text(
          'To ensure you can see trip information while using other apps, we need permission to display over other apps. This helps you stay updated during active trips.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );

    if (shouldRequest == true) {
      return await requestOverlayPermission(context);
    }

    return false;
  }
}

