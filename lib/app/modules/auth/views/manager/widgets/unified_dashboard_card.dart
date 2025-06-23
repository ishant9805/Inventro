import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';

class UnifiedDashboardCard extends StatelessWidget {
  final AuthController authController;

  const UnifiedDashboardCard({
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
        borderRadius: BorderRadius.circular(20),
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
          // Top row: Logo and action icons
          _buildTopRow(),
          const SizedBox(height: 20),
          
          // Middle row: Dashboard title
          _buildDashboardTitle(),
          const SizedBox(height: 16),
          
          // Bottom row: Welcome message and company info
          _buildWelcomeSection(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
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
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A00E0).withAlpha(76), // Equivalent to 30% opacity
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
     ],
    );
  }

  Widget _buildDashboardTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8F00FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.dashboard_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Manager Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A202C),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome message
        Obx(() => Text(
          'Welcome, ${authController.user.value?.name ?? "Manager"}!',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        )),
        
        const SizedBox(height: 12),
        
        // Company information
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.business,
                    color: Color(0xFF4A00E0),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Company: ${authController.user.value!.company!.name}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A00E0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Company information not available',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ),
      ],
    );
  }
}