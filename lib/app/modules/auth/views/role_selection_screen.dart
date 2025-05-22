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
                  icon: const Icon(Icons.person),
                  label: const Text("Employee Login"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                    backgroundColor: Colors.deepPurpleAccent,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    // TODO: Add employee login route when ready
                    Get.snackbar("Coming Soon", "Employee login coming soon!");
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.register);
                  },
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
}
