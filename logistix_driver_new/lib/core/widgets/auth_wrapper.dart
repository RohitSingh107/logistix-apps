import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/main_navigation_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔄 AuthWrapper: State changed to ${state.runtimeType}');
        
        // Handle authentication state changes
        if (state is AuthInitial) {
          print('🚪 AuthWrapper: User logged out, navigating to login screen');
          // User is not authenticated, navigate to login screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else if (state is AuthSuccess) {
          print('✅ AuthWrapper: User authenticated, navigating to main screen');
          // User is authenticated, navigate to main navigation
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
        } else if (state is AuthError) {
          print('❌ AuthWrapper: Authentication error: ${state.message}');
          // Authentication failed, show error and stay on login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            // User is authenticated, show main navigation
            return const MainNavigationScreen();
          } else {
            // User is not authenticated, show login screen
            return const LoginScreen();
          }
        },
      ),
    );
  }
} 