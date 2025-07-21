import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';
import '../../../../controller/auth_controller.dart';

/// Registration action buttons and login link section
class RegistrationActions extends StatelessWidget {
  final AuthController authController;
  final bool isCompanyValidated;
  final bool isNewCompany;
  final VoidCallback onRegister;

  const RegistrationActions({
    super.key,
    required this.authController,
    required this.isCompanyValidated,
    required this.isNewCompany,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Register Button
        Obx(() => ElevatedButton(
          onPressed: authController.isLoading.value || (!isCompanyValidated && !isNewCompany)
              ? null
              : onRegister,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: const Color(0xFF4A00E0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: authController.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Register as Manager',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        )),
        const SizedBox(height: 16),

        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account? "),
            GestureDetector(
              onTap: () {
                authController.clearTextControllers();
                Get.offAllNamed(AppRoutes.login);
              },
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Color(0xFF4A00E0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}