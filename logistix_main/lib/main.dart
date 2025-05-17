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
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create placeholder .env file content if not exists
  try {
    // First, try to load from .env file
    await AppConfig.initialize();
  } catch (e) {
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
  
  // Force a specific IP for testing
  // If you're on an emulator, use 10.0.2.2 to connect to localhost
  // If you're on a real device, use your computer's actual IP address
  // dotenv.env['API_BASE_URL'] = 'http://10.0.2.2:8000';
  
  print("API URL set to: ${dotenv.env['API_BASE_URL']}");
  
  // Setup dependencies
  final prefs = await SharedPreferences.getInstance();
  
  // Create a basic Dio instance first
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  // Create AuthService using dio
  final authService = AuthService(dio, prefs);
  
  // Create ApiClient with full auth capabilities
  final apiClient = ApiClient(authService);
  
  // Create repositories
  final AuthRepository authRepository = AuthRepositoryImpl(apiClient, authService);
  final UserRepository userRepository = UserRepositoryImpl(apiClient);
  
  runApp(MyApp(
    authRepository: authRepository,
    userRepository: userRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  
  const MyApp({
    required this.authRepository, 
    required this.userRepository,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository),
        ),
        BlocProvider<UserBloc>(
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
        home: const LoginScreen(), // Directly show login screen
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
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
