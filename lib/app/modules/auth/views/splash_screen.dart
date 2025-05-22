import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 2 seconds, then navigate
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(AppRoutes.roleSelection); // or AppRoutes.roleSelection
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gradient colors (approximated from your screenshot)
    const List<Color> gradientColors = [
      Color(0xFF4A00E0), // Deep blue/purple
      Color(0xFF00C3FF), // Cyan
      Color(0xFF8F00FF), // Purple
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7), // Semi-transparent white
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // App Name
                const Text(
                  'Inventro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Matches your screenshot
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
