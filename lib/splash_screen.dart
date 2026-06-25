import 'dart:async';
import 'package:flutter/material.dart';
import 'app_constants.dart';
import 'appName_view_app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  /// Start the timer when the widget is initialized
  void initState() {
    super.initState();
    _startTimer();
  }

  /// Navigate to the home screen after 2 seconds
  void _startTimer() {
    _timer = Timer(const Duration(seconds: 2), _navigateToHome);
  }

  /// Navigate to the home screen
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppNameApp(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  /// Cancel the timer when the widget is disposed
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //*--- App Logo ---
              SizedBox(
                height: 150,
                width: 150,
                child: Image.asset(AppConstants.splashScreenImage),
              ),
              // const SizedBox(height: 16),
              //* --- Linear Progress Indicator ---
              const LinearProgressIndicator(
                color: AppConstants.primaryColor,
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
