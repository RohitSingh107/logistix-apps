/// image_utils.dart - Image URL and Validation Utilities
/// 
/// Purpose:
/// - Provides utility functions for handling profile picture URLs
/// - Manages URL construction and validation for image assets
/// - Handles both relative and absolute URL formats
/// 
/// Key Logic:
/// - Constructs full URLs from relative profile picture paths
/// - Handles both absolute URLs (http/https) and relative paths
/// - Properly combines base URL with relative paths for API images
/// - Validates profile picture URL format and accessibility
/// - Cleans URL paths by removing extra slashes for consistency
/// - Provides null safety for missing or invalid image URLs
/// - Uses URI parsing for robust URL validation
/// - Integrates with AppConfig for base URL configuration
library;

import '../config/app_config.dart';

class ImageUtils {
  /// Constructs a full URL for profile pictures or returns null if invalid
  static String? getFullProfilePictureUrl(String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      return null;
    }
    
    // Check if it's already a full URL
    if (profilePicture.startsWith('http://') || profilePicture.startsWith('https://')) {
      return profilePicture;
    }
    
    // Construct full URL by combining base URL with relative path
    final baseUrl = AppConfig.baseUrl;
    
    // Remove any leading slash from profile picture path
    final cleanPath = profilePicture.startsWith('/') 
        ? profilePicture.substring(1) 
        : profilePicture;
    
    // Ensure base URL doesn't end with slash, then append path
    final cleanBaseUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    
    return '$cleanBaseUrl/$cleanPath';
  }
  
  /// Validates if a profile picture URL is valid
  static bool isValidProfilePictureUrl(String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      return false;
    }
    
    try {
      final fullUrl = getFullProfilePictureUrl(profilePicture);
      if (fullUrl == null) return false;
      
      final uri = Uri.parse(fullUrl);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      print('Error validating profile picture URL: $e');
      return false;
    }
  }
} 