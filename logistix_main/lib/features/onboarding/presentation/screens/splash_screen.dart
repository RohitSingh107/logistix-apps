import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateAfterSplash() {
    final authState = context.read<AuthBloc>().state;
    final routeName = authState is AuthSuccess ? '/home' : '/login';
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Lottie.asset(
            'assets/animations/splash.json',
            controller: _animationController,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              _animationController
                ..duration = composition.duration
                ..forward().whenComplete(_navigateAfterSplash);
            },
          ),
        ),
      ),
    );
  }
}


