import 'dart:async';
import 'package:flutter/material.dart';

/// Splash Service
/// 
/// Manages splash screen timing and navigation logic
class SplashService {
  static const Duration _splashDuration = Duration(seconds: 3);
  
  /// Shows splash screen for a specified duration
  static Future<void> showSplash(BuildContext context, Widget nextScreen) async {
    // Show splash screen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    
    // Wait for splash duration
    await Future.delayed(_splashDuration);
    
    // Navigate to main app
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
  
  /// Shows splash screen with custom duration
  static Future<void> showSplashWithDuration(
    BuildContext context, 
    Widget nextScreen, 
    Duration duration,
  ) async {
    // Show splash screen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    
    // Wait for custom duration
    await Future.delayed(duration);
    
    // Navigate to main app
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
} 