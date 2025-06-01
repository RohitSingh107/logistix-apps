import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/profile/presentation/bloc/user_bloc.dart';
import 'core/network/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/config/app_config.dart';
import 'core/repositories/user_repository.dart';
import 'core/repositories/user_repository_impl.dart';
import 'core/di/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/profile/presentation/screens/create_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("Starting app initialization...");
    
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
    
    print("Starting app...");
    runApp(MyApp(
      authRepository: authRepository,
      userRepository: userRepository,
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
  
  const MyApp({
    Key? key,
    required this.authRepository,
    required this.userRepository,
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
      ],
      child: MaterialApp(
        title: 'Logistix',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
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
