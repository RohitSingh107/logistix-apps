import 'package:flutter/material.dart';

/// App Colors - Brand Color Palette
/// 
/// This class defines all the brand colors used throughout the Logistix app
/// based on the provided color palette design.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ===== ORANGE COLOR SCHEME =====
  /// Primary orange - vibrant orange for main branding
  static const Color primaryOrange = Color(0xFFFF8300);
  
  /// Secondary orange - burnt orange/terracotta for accents
  static const Color secondaryOrange = Color(0xFFFFC486);
  
  /// Light orange - desaturated beige/peach for backgrounds
  static const Color lightOrange = Color(0xFFFFC486);

  // ===== BLACK - GREY - WHITE SCHEME =====
  /// Pure black for text and strong contrasts
  static const Color pureBlack = Color(0xFF000000);
  
  /// Neutral grey for secondary text and borders
  static const Color neutralGrey = Color(0xFFB8B8B8);
  
  /// Pure white for backgrounds and light text
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ===== GREEN COLOR SCHEME =====
  /// Dark green - forest green for success states
  static const Color darkGreen = Color(0xFF3FAA35);
  
  /// Light green - pale sage for subtle accents
  static const Color lightGreen = Color(0xFFC8EDD7);

  // ===== SEMANTIC COLORS =====
  /// Success color (using dark green)
  static const Color success = darkGreen;
  
  /// Error color (using a complementary red)
  static const Color error = Color(0xFFE53E3E);
  
  /// Warning color (using orange variant)
  static const Color warning = Color(0xFFFF8C42);
  
  /// Info color (using a blue that complements the palette)
  static const Color info = Color(0xFF3182CE);

  // ===== BACKGROUND COLORS =====
  /// Primary background color
  static const Color background = pureWhite;
  
  /// Secondary background color
  static const Color backgroundSecondary = Color(0xFFF8F9FA);
  
  /// Surface color for cards and elevated elements
  static const Color surface = pureWhite;
  
  /// Surface variant for subtle differences
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  // ===== TEXT COLORS =====
  /// Primary text color
  static const Color textPrimary = pureBlack;
  
  /// Secondary text color
  static const Color textSecondary = neutralGrey;
  
  /// Disabled text color
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  /// Text on primary background
  static const Color textOnPrimary = pureWhite;

  // ===== BORDER COLORS =====
  /// Primary border color
  static const Color border = Color(0xFFE0E0E0);
  
  /// Focused border color
  static const Color borderFocused = primaryOrange;
  
  /// Error border color
  static const Color borderError = error;

  // ===== SHADOW COLORS =====
  /// Primary shadow color
  static const Color shadow = Color(0x1A000000);
  
  /// Secondary shadow color
  static const Color shadowSecondary = Color(0x0D000000);

  // ===== GRADIENT COLORS =====
  /// Primary gradient colors
  static const List<Color> primaryGradient = [
    primaryOrange,
    secondaryOrange,
  ];
  
  /// Secondary gradient colors
  static const List<Color> secondaryGradient = [
    darkGreen,
    lightGreen,
  ];

  // ===== UTILITY METHODS =====
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Get primary orange with opacity
  static Color primaryOrangeWithOpacity(double opacity) {
    return primaryOrange.withOpacity(opacity);
  }
  
  /// Get dark green with opacity
  static Color darkGreenWithOpacity(double opacity) {
    return darkGreen.withOpacity(opacity);
  }
} 