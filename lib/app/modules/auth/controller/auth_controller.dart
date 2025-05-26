import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  // Input fields for login and registration
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final companyNameController = TextEditingController();
  final numberOfEmployeesController = TextEditingController();

  // Auth state
  final isLoading = false.obs;
  final user = Rxn<UserModel>();

  final AuthService _authService = AuthService();

  // --- REGISTER MANAGER ---
  Future<void> registerManager() async {
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      isLoading.value = true;

      final body = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "name": nameController.text.trim(),
        "company_name": companyNameController.text.trim(),
        "company_size": int.tryParse(numberOfEmployeesController.text.trim()) ?? 0,
        "phone": "string",
        "profile_picture": "string",
      };

      await _authService.registerAdmin(body);
      Get.snackbar("Success", "Manager registered successfully");

      clearTextControllers();

      // Navigate to Login page
      Get.offAllNamed(AppRoutes.login);

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIN MANAGER ---
  Future<void> loginManager() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;

      // Step 1: Call login API to get token
      final tokenResult = await _authService.login(email, password);
      
      // Step 2: Use the token to fetch complete user profile
      final userProfile = await _authService.fetchUserProfile(tokenResult.token);
      
      // Step 3: Set the complete user profile in state
      user.value = userProfile;

      Get.snackbar("Success", "Login successful!");

      // Clear input fields
      emailController.clear();
      passwordController.clear();

      // Navigate to Manager Dashboard
      Get.offAllNamed(AppRoutes.dashboard);

    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGOUT MANAGER ---
  void logout() {
    // Clear user data
    user.value = null;
    clearTextControllers();
    
    // Show success message
    Get.snackbar(
      "Logout Successful", 
      "You have been logged out successfully",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2)
    );
    
    // Navigate to role selection screen
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  // --- Clear all TextControllers ---
  void clearTextControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    companyNameController.clear();
    numberOfEmployeesController.clear();
  }

  @override
  void onClose() {
    // Dispose all TextEditingControllers to avoid memory leaks
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    companyNameController.dispose();
    numberOfEmployeesController.dispose();
    super.onClose();
  }

  // --- Splash Screen Optimization Note ---
  // Avoid heavy initialization in splash screen. If you need to load data, do it asynchronously
  // and show a loading indicator. Keep splash screen logic lightweight.
}
// This controller handles the authentication logic for the app, including login and registration.