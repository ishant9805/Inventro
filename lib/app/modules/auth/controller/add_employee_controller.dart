import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/employee_service.dart';

class AddEmployeeController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final departmentController = TextEditingController();
  final managerIdController = TextEditingController();

  final isLoading = false.obs;
  final EmployeeService _employeeService = EmployeeService();

  Future<void> addEmployee() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'PIN and Confirm PIN do not match');
      return;
    }
    isLoading.value = true;
    try {
      await _employeeService.addEmployee({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'role': 'employee',
        'department': departmentController.text,
        'manager_id': managerIdController.text,
      });
      Get.snackbar('Success', 'Employee added successfully');
      // Optionally clear fields or navigate
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    departmentController.dispose();
    managerIdController.dispose();
    super.onClose();
  }
}
