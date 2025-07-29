import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/modules/auth/controller/employee_dashboard_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';

/// Employee Profile Section - Shows employee profile information and action buttons
/// This is displayed when the profile button is tapped in the employee dashboard
class EmployeeProfileSection extends StatelessWidget {
  final AuthController authController;

  const EmployeeProfileSection({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
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
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      Text(
                        'Your account information',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Profile information
            Flexible(
              child: SingleChildScrollView(
                child: Obx(() {
                  final user = authController.user.value;
                  if (user == null) {
                    return const Center(
                      child: Text(
                        'No user information available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    );
                  }
                  
                  return Column(
                    children: [
                      _buildInfoCard([
                        _buildInfoRow('Name', user.name),
                        _buildInfoRow('Email', user.email),
                        _buildInfoRow('Role', user.role),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      if (user.company != null)
                        _buildInfoCard([
                          _buildInfoRow('Company', user.company!.name),
                        ])
                      else if (user.companyName?.isNotEmpty == true)
                        _buildInfoCard([
                          _buildInfoRow('Company', user.companyName!),
                        ]),
                    ],
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons - About Us positioned above logout
            Column(
              children: [
                // About Us Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back(); // Close profile dialog
                      Get.toNamed(AppRoutes.aboutUs);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('About Us'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4A00E0),
                      side: const BorderSide(color: Color(0xFF4A00E0)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleLogout(),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an information card with multiple rows
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  /// Builds an information row with label and value
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not available',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A202C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles logout action
  void _handleLogout() {
    Get.back(); // Close the profile dialog first
    
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close confirmation dialog
              
              // Perform logout using EmployeeDashboardController
              try {
                final dashboardController = Get.find<EmployeeDashboardController>();
                dashboardController.logout();
              } catch (e) {
                print('❌ Error finding EmployeeDashboardController, using AuthController directly');
                authController.logout();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}