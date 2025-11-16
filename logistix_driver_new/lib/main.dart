/// main.dart - Driver Application Entry Point
/// 
/// Purpose:
/// - Main entry point for the Logistix Driver Flutter application
/// - Handles app initialization, dependency injection, and error handling
/// - Sets up the root widget with BLoC providers and theme management
/// 
/// Key Logic:
/// - Initializes environment configuration (.env file)
/// - Sets up service locator for dependency injection
/// - Creates repository instances (AuthRepository, UserRepository)
/// - Provides comprehensive error handling with fallback UI
/// - Configures app routing and navigation for driver-specific screens
/// - Integrates BLoC state management (AuthBloc, UserBloc, ThemeBloc)
/// - Implements theme switching with persistent storage
/// - Handles authentication state and navigation flow for drivers
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/notification_service.dart';
import 'core/widgets/app_lifecycle_wrapper.dart';
import 'core/providers/locale_provider.dart';
import 'generated/l10n/app_localizations.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/startup_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/main_navigation_screen.dart';
import 'features/profile/presentation/bloc/user_bloc.dart';
import 'features/theme/presentation/bloc/theme_bloc.dart';
import 'features/theme/presentation/bloc/theme_event.dart';
import 'features/theme/presentation/bloc/theme_state.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/trip/presentation/bloc/trip_bloc.dart';
import 'core/services/auth_service.dart';
import 'core/config/app_config.dart';
import 'core/config/app_theme.dart';
import 'core/repositories/user_repository.dart';
import 'core/widgets/main_navigation_wrapper.dart';
import 'core/di/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/profile/presentation/screens/create_profile_screen.dart';
import 'features/vehicle/presentation/screens/vehicle_number_screen.dart';
import 'features/vehicle/presentation/screens/my_vehicles_screen.dart';
import 'features/driver/presentation/screens/create_driver_profile_screen.dart';
import 'features/driver/presentation/screens/driver_documents_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/wallet/presentation/screens/wallet_screen.dart';
import 'features/wallet/presentation/screens/transaction_history_screen.dart';
import 'features/notifications/presentation/screens/alerts_screen.dart';
import 'features/trip/presentation/screens/my_trips_screen.dart';
import 'features/trip/presentation/screens/active_trips_screen.dart';
import 'core/models/trip_model.dart';
import 'core/services/language_service.dart';
import 'features/language/presentation/bloc/language_bloc.dart';
import 'features/language/presentation/bloc/language_event.dart';
// import 'package:sentry_flutter/sentry_flutter.dart'; // Disabled

// Global navigator key for showing popups from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("Starting driver app initialization...");
    
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
API_BASE_URL=https://76281b72189e.ngrok-free.app
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
      
      // Set the navigator key for notification popups
      NotificationService.setNavigatorKey(navigatorKey);
      
      // Update driver FCM token on app start if user is authenticated
      try {
        final authService = serviceLocator<AuthService>();
        final isAuthenticated = await authService.isAuthenticated();
        if (isAuthenticated) {
          print("🚗 Updating driver FCM token on app start...");
          await PushNotificationService.updateDriverFcmToken();
        }
      } catch (e) {
        print("Warning: Failed to update driver FCM token on app start: $e");
      }
    } catch (e) {
      print("Push notification initialization failed: $e");
    }
    
    print("Starting driver app...");
    // Sentry disabled
    runApp(DriverApp(
      authRepository: authRepository,
      userRepository: userRepository,
      sharedPreferences: serviceLocator<SharedPreferences>(),
    ));
  } catch (e, stackTrace) {
    print("Fatal error during driver app initialization: $e");
    print("Stack trace: $stackTrace");
    // Show error UI instead of crashing
    // Sentry disabled
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to initialize driver app',
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

class DriverApp extends StatelessWidget {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final SharedPreferences sharedPreferences;
  
  const DriverApp({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.sharedPreferences,
  });

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
        BlocProvider(
          create: (context) => WalletBloc(serviceLocator())..add(LoadWalletData()),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(serviceLocator()),
        ),
        BlocProvider(
          create: (context) => TripBloc(serviceLocator()),
        ),
        BlocProvider(
          create: (context) => LanguageBloc(languageService: serviceLocator<LanguageService>())
            ..add(LoadLanguage()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ChangeNotifierProvider(
            create: (context) => LocaleProvider()..initialize(),
            child: Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return AppLifecycleWrapper(
                  child: MaterialApp(
                    title: 'Logistix Driver',
                    debugShowCheckedModeBanner: false,
                    navigatorKey: navigatorKey,
                    theme: themeState is ThemeLoaded 
                      ? AppTheme.getTheme(themeState.themeName)
                      : AppTheme.getTheme(AppTheme.lightTheme),
                    
                    // Localization configuration
                    locale: localeProvider.currentLocale,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: localeProvider.supportedLocales,
                    
                    home: const StartupScreen(),
                    routes: {
                      '/login': (context) => const LoginScreen(),
                      '/home': (context) => const MainNavigationScreen(),
                      '/profile/create': (context) {
                        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                        return CreateProfileScreen(
                          phone: args?['phone'] as String? ?? '',
                        );
                      },
                      '/driver/create': (context) => CreateDriverProfileScreen(),
                      '/driver/documents': (context) => const DriverDocumentsScreen(),
                      '/settings': (context) => const MainNavigationWrapper(
                        currentIndex: 4,
                        child: SettingsScreen(),
                      ),
                      '/wallet': (context) => const MainNavigationWrapper(
                        currentIndex: 2,
                        child: WalletScreen(),
                      ),
                      '/transaction-history': (context) => const MainNavigationWrapper(
                        currentIndex: 2,
                        child: TransactionHistoryScreen(),
                      ),
                      '/alerts': (context) => const MainNavigationWrapper(
                        currentIndex: 1,
                        child: AlertsScreen(),
                      ),
                      '/trips': (context) => const MainNavigationWrapper(
                        currentIndex: 3,
                        child: MyTripsScreen(),
                      ),
                      '/trip-details': (context) {
                        final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
                        return MainNavigationWrapper(
                          currentIndex: 3,
                          child: ActiveTripsScreen(trip: trip, isViewOnly: true),
                        );
                      },
                      '/driver-trip': (context) {
                        final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
                        return MainNavigationWrapper(
                          currentIndex: 3,
                          child: ActiveTripsScreen(trip: trip),
                        );
                      },
                      '/vehicle/add': (context) => const VehicleNumberScreen(),
                      '/vehicles': (context) => const MyVehiclesScreen(),
                    },
                    onGenerateRoute: (settings) {
                      // Handle any additional routes
                      return null;
                    },
                    onUnknownRoute: (settings) {
                      // Redirect to home if route is not found
                      return MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Redirects to the main HomeScreen
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
