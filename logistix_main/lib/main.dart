import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'core/network/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/dummy_auth_service.dart';
import 'core/config/app_config.dart';
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
  dotenv.env['API_BASE_URL'] = 'http://10.0.2.2:8000';
  
  print("API URL set to: ${dotenv.env['API_BASE_URL']}");
  
  // Setup dependencies
  final prefs = await SharedPreferences.getInstance();
  
  // Break the circular dependency by using a temporary dummy service
  final dummyAuthService = DummyAuthService(prefs);
  
  // Now we can create the ApiClient with the dummy service first
  final apiClient = ApiClient(dummyAuthService);
  
  // Then create the real AuthService with the ApiClient
  final authService = AuthService(apiClient, prefs);
  
  // Finally create the repository
  final AuthRepository authRepository = AuthRepositoryImpl(apiClient, authService);
  
  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  
  const MyApp({required this.authRepository, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authRepository),
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
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}

// Simple HomePage to navigate to after login
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistix Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(Logout());
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to Logistix!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
