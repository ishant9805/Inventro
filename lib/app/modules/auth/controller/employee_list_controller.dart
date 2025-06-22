import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/employee_service.dart';
import '../../../data/models/employee_model.dart';

class EmployeeListController extends GetxController {
  final isLoading = false.obs;
  final employees = <EmployeeModel>[].obs;
  final filteredEmployees = <EmployeeModel>[].obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final EmployeeService _employeeService = EmployeeService();

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
    // Listen to search changes
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _filterEmployees();
  }

  void _filterEmployees() {
    if (searchQuery.value.isEmpty) {
      filteredEmployees.value = employees;
    } else {
      filteredEmployees.value = employees.where((employee) {
        final query = searchQuery.value.toLowerCase();
        return employee.name.toLowerCase().contains(query) ||
               employee.email.toLowerCase().contains(query) ||
               employee.department.toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> loadEmployees() async {
    isLoading.value = true;
    try {
      final employeeList = await _employeeService.getEmployees();
      employees.value = employeeList
          .map((data) => EmployeeModel.fromJson(data))
          .toList();
      
      // Update filtered list
      _filterEmployees();
      
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[600]),
              const SizedBox(width: 12),
              const Text('Delete Employee'),
            ],
          ),
          content: Text('Are you sure you want to delete $employeeName? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;
        await _employeeService.deleteEmployee(employeeId);
        
        // Remove from both lists
        employees.removeWhere((emp) => emp.id == employeeId);
        filteredEmployees.removeWhere((emp) => emp.id == employeeId);
        
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

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterEmployees();
  }
}
