import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';

class DashboardHeader extends StatelessWidget {
  final AuthController authController;

  const DashboardHeader({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // App Logo/Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF00C3FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // App Name
          const Text(
            'Inventro',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          // Profile Icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Get.toNamed(AppRoutes.managerProfile),
              icon: const Icon(
                Icons.person,
                color: Color(0xFF4A00E0),
                size: 24,
              ),
              tooltip: "Profile",
            ),
          ),
          const SizedBox(width: 8),
          // Logout Icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => authController.logout(),
              icon: const Icon(
                Icons.logout,
                color: Color(0xFFDC3545),
                size: 24,
              ),
              tooltip: "Logout",
            ),
          ),
        ],
      ),
    );
  }
}