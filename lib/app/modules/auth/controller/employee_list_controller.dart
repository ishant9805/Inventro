import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/employee_service.dart';
import '../../../data/models/employee_model.dart';

class EmployeeListController extends GetxController {
  final isLoading = false.obs;
  final employees = <EmployeeModel>[].obs;
  final EmployeeService _employeeService = EmployeeService();

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    isLoading.value = true;
    try {
      final employeeList = await _employeeService.getEmployees();
      employees.value = employeeList
          .map((data) => EmployeeModel.fromJson(data))
          .toList();
      
      print('Loaded ${employees.length} employees');
    } catch (e) {
      print('Error loading employees: $e');
      Get.snackbar(
        'Error',
        'Failed to load employees: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEmployee(int employeeId, String employeeName) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Employee'),
          content: Text('Are you sure you want to delete $employeeName?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;
        await _employeeService.deleteEmployee(employeeId);
        
        // Remove from local list
        employees.removeWhere((emp) => emp.id == employeeId);
        
        Get.snackbar(
          'Success',
          'Employee $employeeName deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error deleting employee: $e');
      Get.snackbar(
        'Error',
        'Failed to delete employee: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshEmployees() {
    loadEmployees();
  }
}
