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
      
      // 🔧 STEP 1: Call login API to get token
      final tokenResult = await _authService.login(email, pin);
      
      // 🔧 STEP 2: Use the token to fetch complete user profile
      final userProfile = await _authService.fetchUserProfile(tokenResult.token, fallbackRole: 'employee');
      
      // 🔧 STEP 3: Validate that this is indeed an employee
      if (userProfile.role.toLowerCase() == 'employee') {
        // Get AuthController and save user info properly
        final authController = Get.find<AuthController>();
        
        // 🔧 STEP 4: Set user in memory
        authController.user.value = userProfile;
        
        // 🔧 STEP 5: Save user data to persistent storage for session persistence
        // This ensures employee sessions persist across app restarts and are properly cleared on logout
        await authController.saveUserToPrefs(userProfile);
        
        print('✅ EmployeeLoginController: Employee session established and persisted');
        
        // 🔧 STEP 6: Clear input fields after successful login
        emailController.clear();
        pinController.clear();
        
        // 🔧 STEP 7: Navigate to employee dashboard
        SafeNavigation.safeSnackbar(
          title: 'Success', 
          message: 'Login successful!'
        );
        Get.offAllNamed('/employee-dashboard');
      } else {
        // User exists but is not an employee
        SafeNavigation.safeSnackbar(
          title: 'Login Failed', 
          message: 'You are not registered as an employee.'
        );
      }
    } catch (e) {
      SafeNavigation.safeSnackbar(
        title: 'Login Failed', 
        message: e.toString().replaceAll('Exception: ', '')
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
