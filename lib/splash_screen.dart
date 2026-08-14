import 'dart:async';
import 'package:amelia/core/navigate_to_home.dart';
import 'package:amelia/core/show_image.dart';
import 'package:flutter/material.dart';
import 'app_constants.dart';

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
    _timer = Timer(const Duration(seconds: 2), () {
      navigateToHome(context);
    });
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
                child: showImage(image: AppConstants.appIcon),
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
