import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });

    _controller.addListener(_onVideoProgress);
  }

  void _onVideoProgress() {
    if (_controller.value.position >= _controller.value.duration && !_hasNavigated) {
      _navigateNext();
    }
  }

  void _navigateNext() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          // Fallback skip after 4 seconds if video has issues
          Positioned.fill(
            child: IgnorePointer(
              child: _AutoSkipFallback(onTimeout: _navigateNext),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoSkipFallback extends StatefulWidget {
  final VoidCallback onTimeout;
  const _AutoSkipFallback({required this.onTimeout});

  @override
  State<_AutoSkipFallback> createState() => _AutoSkipFallbackState();
}

class _AutoSkipFallbackState extends State<_AutoSkipFallback> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) widget.onTimeout();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}


