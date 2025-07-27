import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'employee_profile_section.dart';

/// Employee Dashboard App Bar - Custom app bar for employee dashboard
/// Features profile button in top right, no logout button as specified
class EmployeeDashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthController authController;

  const EmployeeDashboardAppBar({
    super.key,
    required this.authController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // Remove back button
      title: Row(
        children: [
          // App Logo/Icon
          Container(
            padding: const EdgeInsets.all(8),
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
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // App Name and Employee Dashboard Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Inventro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
                Text(
                  'Employee Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Profile Button - Opens profile section as specified
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF4A00E0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4A00E0).withOpacity(0.3),
            ),
          ),
          child: IconButton(
            onPressed: _showEmployeeProfile,
            icon: const Icon(
              Icons.person,
              color: Color(0xFF4A00E0),
              size: 24,
            ),
            tooltip: "Profile",
          ),
        ),
      ],
    );
  }

  /// Shows the employee profile section
  void _showEmployeeProfile() {
    Get.dialog(
      EmployeeProfileSection(authController: authController),
      barrierDismissible: true,
    );
  }
}