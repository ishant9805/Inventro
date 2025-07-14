import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import '../../../data/services/auth_service.dart';

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
      SafeNavigation.safeSnackbar(
        title: 'Error', 
        message: 'Please fill all fields'
      );
      return;
    }

    try {
      isLoading.value = true;
      // Step 1: Call login API to get token
      final tokenResult = await _authService.login(email, pin);
      // Step 2: Use the token to fetch complete user profile
      final userProfile = await _authService.fetchUserProfile(tokenResult.token, fallbackRole: 'employee');
      // Step 3: Check if role is employee
      if (userProfile.role.toLowerCase() == 'employee') {
        // Save user info in AuthController for token access
        final authController = Get.find<AuthController>();
        authController.user.value = userProfile;
        // Navigate to employee dashboard
        SafeNavigation.safeSnackbar(
          title: 'Success', 
          message: 'Login successful!'
        );
        Get.offAllNamed('/employee-dashboard');
      } else {
        SafeNavigation.safeSnackbar(
          title: 'Login Failed', 
          message: 'You are not registered as an employee.'
        );
      }
    } catch (e) {
      SafeNavigation.safeSnackbar(
        title: 'Login Failed', 
        message: e.toString()
      );
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
