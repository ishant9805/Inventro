import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
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
    Future.delayed(const Duration(seconds: 2), () async {
      final authController = Get.find<AuthController>();
      await authController.loadUserFromPrefs();
      
      // 🔧 FIXED: Proper role-based routing for session restoration
      if (authController.user.value != null) {
        final userRole = authController.user.value!.role.toLowerCase();
        print('🔄 SplashScreen: Restoring session for ${userRole} user');
        
        if (userRole == 'employee') {
          // Employee session restoration - go directly to employee dashboard
          Get.offAllNamed('/employee-dashboard');
        } else {
          // Manager/Admin session restoration - go to manager dashboard
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        // No saved session - go to role selection
        print('🔄 SplashScreen: No saved session, going to role selection');
        Get.offAllNamed(AppRoutes.roleSelection);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const List<Color> gradientColors = [
      Color(0xFF4A00E0),
      Color(0xFF00C3FF),
      Color(0xFF8F00FF),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Inventro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
