/// startup_screen.dart - Application Startup/Splash Screen
/// 
/// Purpose:
/// - Provides initial branding screen when app launches
/// - Displays LOGISTIX logo and branding on orange background
/// - Handles app initialization and navigation to appropriate screen
/// 
/// Key Logic:
/// - Shows LOGISTIX branding with clean, minimal design
/// - Uses orange-brown background color matching the design
/// - Automatically navigates to login screen after brief display
/// - Provides smooth transition to authentication flow
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/widgets/auth_wrapper.dart';
import '../../../language/presentation/screens/language_selection_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));
    
    // Start animation
    _animationController.forward();
    
    // Check authentication status and navigate accordingly
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        // Check if user is already authenticated
        final authBloc = context.read<AuthBloc>();
        authBloc.add(CheckAuthStatus());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation from startup screen
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // User is authenticated, navigate to main screen
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthInitial) {
            // User is not authenticated, navigate to language selection screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LanguageSelectionScreen(),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFD2691E), // Orange-brown color from design
          body: SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // LOGISTIX Logo/Text
                          Text(
                            'LOGISTIX',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 2.0,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Subtitle
                          Text(
                            'Driver App',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 1.0,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
