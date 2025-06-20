/**
 * main.dart - Application Entry Point
 * 
 * Purpose:
 * - Main entry point for the Logistix Flutter application
 * - Handles app initialization, dependency injection, and error handling
 * - Sets up the root widget with BLoC providers and theme management
 * 
 * Key Logic:
 * - Initializes environment configuration (.env file)
 * - Sets up service locator for dependency injection
 * - Creates repository instances (AuthRepository, UserRepository)
 * - Tests map service configuration
 * - Provides comprehensive error handling with fallback UI
 * - Configures app routing and navigation
 * - Integrates BLoC state management (AuthBloc, UserBloc, ThemeBloc)
 * - Implements theme switching with persistent storage
 * - Handles authentication state and navigation flow
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/profile/presentation/bloc/user_bloc.dart';
import 'features/theme/presentation/bloc/theme_bloc.dart';
import 'features/theme/presentation/bloc/theme_event.dart';
import 'features/theme/presentation/bloc/theme_state.dart';
import 'core/services/auth_service.dart';
import 'core/config/app_config.dart';
import 'core/config/app_theme.dart';
import 'core/repositories/user_repository.dart';
import 'core/di/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/profile/presentation/screens/create_profile_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/booking/presentation/screens/map_test_screen.dart';
import 'features/wallet/presentation/screens/wallet_screen.dart';
import 'core/services/test_map_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("Starting app initialization...");
    
    // Initialize Firebase
    print("🔥 Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
    
    // Set up Firebase Messaging background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Create placeholder .env file content if not exists
    try {
      print("Attempting to load .env file...");
      await AppConfig.initialize();
      print("Successfully loaded .env file");
    } catch (e) {
      print("Error loading .env file: $e");
      print("Using test environment configuration");
      // If .env file doesn't exist or has issues, use dotenv.testLoad for development
      dotenv.testLoad(
        fileInput: '''
# For emulators, 10.0.2.2 points to the host machine's localhost
# For real devices, use your computer's actual IP address
API_BASE_URL=http://10.0.2.2:8000
API_KEY=development_key
'''
      );
    }
    
    print("API URL set to: ${dotenv.env['API_BASE_URL']}");
    
    // Setup dependencies
    print("Setting up service locator...");
    await setupServiceLocator();
    print("Service locator setup complete");
    
    // Create repositories
    print("Creating repositories...");
    final AuthRepository authRepository = serviceLocator<AuthRepository>();
    final UserRepository userRepository = serviceLocator<UserRepository>();
    print("Repositories created successfully");
    
    // Initialize Push Notifications
    print("🔔 Initializing Push Notifications...");
    try {
      await PushNotificationService.initialize(
        userRepository: userRepository,
        authService: serviceLocator<AuthService>(),
      );
    } catch (e) {
      print("Push notification initialization failed: $e");
    }
    
    // Test map service configuration
    print("Testing map service configuration...");
    try {
      await MapServiceTester.testConfiguration();
    } catch (e) {
      print("Map service test failed: $e");
    }
    
    print("Starting app...");
    runApp(MyApp(
      authRepository: authRepository,
      userRepository: userRepository,
      sharedPreferences: serviceLocator<SharedPreferences>(),
    ));
  } catch (e, stackTrace) {
    print("Fatal error during app initialization: $e");
    print("Stack trace: $stackTrace");
    // Show error UI instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $e',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final SharedPreferences sharedPreferences;
  
  const MyApp({
    Key? key,
    required this.authRepository,
    required this.userRepository,
    required this.sharedPreferences,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository, serviceLocator<AuthService>()),
        ),
        BlocProvider(
          create: (context) => UserBloc(userRepository),
        ),
        BlocProvider(
          create: (context) => ThemeBloc(sharedPreferences)..add(const LoadThemeEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Logistix',
            debugShowCheckedModeBanner: false,
            theme: themeState is ThemeLoaded 
              ? AppTheme.getTheme(themeState.themeName)
              : AppTheme.getTheme(AppTheme.lightTheme),
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthSuccess) {
                  return const HomeScreen();
                }
                return const LoginScreen();
              },
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => const HomeScreen(),
              '/profile/create': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                return CreateProfileScreen(
                  phone: args?['phone'] as String? ?? '',
                );
              },
              '/settings': (context) => const SettingsScreen(),
              '/map-test': (context) => const MapTestScreen(),
              '/wallet': (context) => const WalletScreen(),
            },
          );
        },
      ),
    );
  }
}

// Redirects to the main HomeScreen
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Navigate to the main HomeScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/home');
    });
    
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
