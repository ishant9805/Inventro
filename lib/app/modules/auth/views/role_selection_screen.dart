import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lighter version of your splash gradient
    const List<Color> baseColors = [
      Color(0xFF4A00E0), // Deep blue/purple
      Color(0xFF00C3FF), // Cyan
      Color(0xFF8F00FF), // Purple
    ];
    final List<Color> lightColors = baseColors.map((c) => c.withValues(alpha: 0.8)).toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: lightColors,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(210),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                 BoxShadow(
                   color: Colors.black.withValues(alpha: 0.2),
                   offset: const Offset(0, 4),
                 ),
               ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Your Role",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text("Manager Login"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Get.toNamed(AppRoutes.login);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: const Text("Employee Login",
                  style: TextStyle(color: Colors.white),                  
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                    backgroundColor: Colors.deepPurpleAccent,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Get.toNamed(AppRoutes.employeeLogin);
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _showManagerRegistrationDialog(context),
                  child: const Text(
                    "Register as Manager",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show dialog for manager registration company selection
  Future<void> _showManagerRegistrationDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Register as Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Choose how you want to register your company',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Add New Company Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.createCompanyScreen);
                },
                icon: const Icon(Icons.add_business, color: Colors.white),
                label: const Text(
                  'Add New Company',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Join Existing Company Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.managerRegistration);
                },
                icon: const Icon(Icons.business, color: Color(0xFF4A00E0)),
                label: const Text(
                  'Join Existing Company',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A00E0),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4A00E0), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
