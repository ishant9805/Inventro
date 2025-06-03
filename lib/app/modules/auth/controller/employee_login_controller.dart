import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class EmployeeLoginController extends GetxController {
  final emailController = TextEditingController();
  final pinController = TextEditingController();
  final isLoading = false.obs;
  final AuthService _authService = AuthService();

  // Employee login logic
  Future<void> loginEmployee() async {
    final email = emailController.text.trim();
    final pin = pinController.text.trim();

    if (email.isEmpty || pin.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;
      final user = await _authService.login(email, pin);
      // Optionally check user.role == 'employee' if backend provides role
      Get.snackbar('Success', 'Login successful!');
      // Save user info in state if needed
      // Navigate to employee dashboard (create this screen if not exists)
      // Example: Get.offAllNamed(AppRoutes.employeeDashboard);
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    pinController.dispose();
    super.onClose();
  }
}
