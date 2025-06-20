import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';

class WelcomeCard extends StatelessWidget {
  final AuthController authController;

  const WelcomeCard({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A00E0), Color(0xFF8F00FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dashboard, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manager Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6C757D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      'Welcome, ${authController.user.value?.name ?? "Manager"}!',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => authController.user.value?.company != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A00E0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4A00E0).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.business,
                      color: Color(0xFF4A00E0),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Company: ${authController.user.value!.company!.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A00E0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
          ),
        ],
      ),
    );
  }
}