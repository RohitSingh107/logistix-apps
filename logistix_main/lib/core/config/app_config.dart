import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Default to a usable development URL depending on platform
  static String get baseUrl {
    final configUrl = dotenv.env['API_BASE_URL'];
    String result;
    
    // If config exists, use it
    if (configUrl != null && configUrl.isNotEmpty) {
      result = configUrl;
    } else {
      // Otherwise, use a sensible default based on platform
      if (kIsWeb) {
        result = '/api'; // relative URL for web
      } else {
        // For mobile, use 10.0.2.2 which maps to host machine's localhost when using emulator
        // or use your computer's actual local network IP for real devices
        result = 'http://192.168.210.156:8000';
      }
    }
    
    print("AppConfig.baseUrl returning: $result");
    return result;
  }
  
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    print("AppConfig initialized with env: ${dotenv.env}");
  }
} 