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
        // Handle authentication state changes
        if (state is AuthInitial) {
          // User is not authenticated, stay on login screen
        } else if (state is AuthSuccess) {
          // User is authenticated, navigate to main navigation
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
        } else if (state is AuthError) {
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