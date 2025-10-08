/// app_lifecycle_wrapper.dart - App Lifecycle Management
/// 
/// Purpose:
/// - Handles app lifecycle changes (foreground/background)
/// - Manages background location tracking based on app state
/// - Provides seamless location tracking across app states
/// 
/// Key Logic:
/// - Listens to app lifecycle changes
/// - Starts/stops background location tracking appropriately
/// - Manages driver availability state
/// - Handles location permissions across app states
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/background_location_service.dart';
import '../services/location_service.dart';
import '../services/push_notification_service.dart';
import '../services/auth_service.dart';
import '../di/service_locator.dart';

class AppLifecycleWrapper extends StatefulWidget {
  final Widget child;
  
  const AppLifecycleWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper> 
    with WidgetsBindingObserver {
  late final BackgroundLocationService _backgroundLocationService;
  late final LocationService _locationService;
  late final AuthService _authService;
  bool _isInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _backgroundLocationService = serviceLocator<BackgroundLocationService>();
    _locationService = serviceLocator<LocationService>();
    _authService = serviceLocator<AuthService>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  void _handleAppResumed() {
    debugPrint('📍 App resumed - switching to foreground tracking');
    _isInBackground = false;
    _backgroundLocationService.setBackgroundState(false);
    
    // If location tracking is active, ensure it's using foreground mode
    if (_locationService.isTracking) {
      debugPrint('📍 Ensuring foreground location tracking is active');
    }
    
    // Update driver FCM token when app comes to foreground
    _updateDriverFcmTokenOnResume();
  }

  /// Update driver FCM token when app is resumed
  Future<void> _updateDriverFcmTokenOnResume() async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        debugPrint('🚗 Updating driver FCM token on app resume...');
        await PushNotificationService.updateDriverFcmToken();
      }
    } catch (e) {
      debugPrint('Warning: Failed to update driver FCM token on app resume: $e');
    }
  }

  void _handleAppPaused() {
    debugPrint('📍 App paused - switching to background tracking');
    _isInBackground = true;
    _backgroundLocationService.setBackgroundState(true);
    
    // If location tracking is active, switch to background mode
    if (_locationService.isTracking) {
      debugPrint('📍 Switching to background location tracking');
      _backgroundLocationService.startBackgroundTracking();
    }
  }

  void _handleAppDetached() {
    debugPrint('📍 App detached - stopping location tracking');
    _locationService.stopLocationTracking();
    _backgroundLocationService.stopBackgroundTracking();
  }

  void _handleAppInactive() {
    debugPrint('📍 App inactive');
    // Keep location tracking active but mark as background
    _isInBackground = true;
    _backgroundLocationService.setBackgroundState(true);
  }

  void _handleAppHidden() {
    debugPrint('📍 App hidden - switching to background tracking');
    _isInBackground = true;
    _backgroundLocationService.setBackgroundState(true);
    
    // If location tracking is active, switch to background mode
    if (_locationService.isTracking) {
      debugPrint('📍 Switching to background location tracking');
      _backgroundLocationService.startBackgroundTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 