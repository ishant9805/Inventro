import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import '../../../data/services/employee_service.dart';

class AddEmployeeController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();
  final departmentController = TextEditingController();
  final phoneController = TextEditingController(); // Add phone field

  final isLoading = false.obs;
  final currentEmployeeCount = 0.obs;
  final String role = 'Employee'; // Auto-filled role
  final EmployeeService _employeeService = EmployeeService();

  @override
  void onInit() {
    super.onInit();
    _loadCurrentEmployeeCount();
  }

  Future<void> _loadCurrentEmployeeCount() async {
    try {
      final employees = await _employeeService.getEmployees();
      currentEmployeeCount.value = employees.length;
    } catch (e) {
      print('Error loading employee count: $e');
      currentEmployeeCount.value = 0;
    }
  }

  bool _validateFields() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter employee name');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter employee email');
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return false;
    }

    if (pinController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a 4-digit PIN');
      return false;
    }

    if (pinController.text.trim().length != 4) {
      Get.snackbar('Error', 'PIN must be exactly 4 digits');
      return false;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(pinController.text.trim())) {
      Get.snackbar('Error', 'PIN must contain only numbers');
      return false;
    }

    if (confirmPinController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please confirm the PIN');
      return false;
    }

    if (pinController.text.trim() != confirmPinController.text.trim()) {
      Get.snackbar('Error', 'PIN and Confirm PIN do not match');
      return false;
    }

    if (departmentController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter employee department');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter employee phone number');
      return false;
    }

    return true;
  }

  void _clearFields() {
    nameController.clear();
    emailController.clear();
    pinController.clear();
    confirmPinController.clear();
    departmentController.clear();
    phoneController.clear();
  }

  void _showUpgradeDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Upgrade Required'),
        content: const Text(
          'You have reached the maximum number of employees (10) for the basic version. Please upgrade to premium to add more employees.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to upgrade/purchase screen
              Get.snackbar('Info', 'Upgrade feature coming soon!');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Employee Limit'),
        content: const Text(
          'You are trying to add more employees than your current limit. Please update your employee limit in your profile settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to profile edit screen
              Get.snackbar('Info', 'Profile edit feature coming soon!');
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Future<void> addEmployee() async {
    if (_validateFields()) {
      final authController = Get.find<AuthController>();
      final managerId = authController.user.value?.id;
      // Fix: Use default limit of 10 for free version
      final managerEmployeeLimit = 10; // Free version allows 10 employees

      if (managerId == null) {
        Get.snackbar('Error', 'Manager ID not found. Please login again.');
        return;
      }

      // Check employee limits - only show upgrade dialog if exceeding 10
      final newEmployeeCount = currentEmployeeCount.value + 1;

      if (newEmployeeCount > 10) {
        // More than 10 employees - show upgrade dialog
        _showUpgradeDialog();
        return;
      }

      isLoading.value = true;
      try {
        // Update data structure to match backend schema
        final employeeData = {
          'email': emailController.text.trim(),
          'password': pinController.text.trim(), // Backend uses 'password' for 4-digit PIN
          'name': nameController.text.trim(),
          'role': role, // Auto-filled as 'Employee'
          'department': departmentController.text.trim(),
          'phone': phoneController.text.trim(), // Backend requires phone field
          'profile_picture': '', // Empty for now, can be added later
          'manager_id': managerId, // Auto-fetched from logged-in manager
        };

        final result = await _employeeService.addEmployee(employeeData);

        Get.snackbar(
          'Success',
          'Employee "${nameController.text.trim()}" added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );

        _clearFields();
        currentEmployeeCount.value = newEmployeeCount;

        print('Employee added successfully: $result');
      } catch (e) {
        print('Error adding employee: $e');
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 4),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    pinController.dispose();
    confirmPinController.dispose();
    departmentController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
