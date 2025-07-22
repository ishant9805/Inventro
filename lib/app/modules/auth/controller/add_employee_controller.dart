import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/modules/auth/controller/employee_list_controller.dart';
import '../../../data/services/employee_service.dart';

class AddEmployeeController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();
  final departmentController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;
  final currentEmployeeCount = 0.obs;
  final companyEmployeeCount = 0.obs;
  final companyEmployeeLimit = 0.obs;
  final String role = 'Employee';
  final EmployeeService _employeeService = EmployeeService();

  @override
  void onInit() {
    super.onInit();
    _loadEmployeeCounts();
  }

  /// Load both manager's and company-wide employee counts and limits
  Future<void> _loadEmployeeCounts() async {
    try {
      print('🔄 Loading employee counts...');
      
      // Load manager's current employee count
      final managerEmployees = await _employeeService.getEmployees();
      currentEmployeeCount.value = managerEmployees.length;
      print('   📊 Manager employees loaded: ${currentEmployeeCount.value}');

      // Load company-wide employee count
      final totalCompanyEmployees = await _employeeService.getCompanyEmployeeCount();
      companyEmployeeCount.value = totalCompanyEmployees;
      print('   🏢 Company total employees: ${companyEmployeeCount.value}');

      // Get company employee limit from user's company data
      final authController = Get.find<AuthController>();
      final companySize = authController.user.value?.company?.size ?? 
                         authController.user.value?.companySize ?? 
                         50; // Default fallback limit
      companyEmployeeLimit.value = companySize;
      print('   📈 Company employee limit: ${companyEmployeeLimit.value}');

      // Validation check: company count should be >= manager count
      if (companyEmployeeCount.value < currentEmployeeCount.value) {
        print('⚠️ Warning: Company count ($companyEmployeeCount.value) < Manager count (${currentEmployeeCount.value})');
        print('   This suggests the company-wide counting may be using fallback estimation.');
        print('   Consider this when interpreting capacity limits.');
        
        // Use manager count as minimum for company count to avoid inconsistency
        companyEmployeeCount.value = currentEmployeeCount.value;
        print('   🔧 Adjusted company count to minimum: ${companyEmployeeCount.value}');
      }

      final remaining = companyEmployeeLimit.value - companyEmployeeCount.value;
      print('📊 Final Employee Summary:');
      print('   Manager: ${currentEmployeeCount.value}');
      print('   Company Total: ${companyEmployeeCount.value}/${companyEmployeeLimit.value}');
      print('   Remaining Capacity: $remaining slots');
      
    } catch (e) {
      print('❌ Error loading employee counts: $e');
      // Set fallback values
      currentEmployeeCount.value = 0;
      companyEmployeeCount.value = 0;
      companyEmployeeLimit.value = 50; // Default company limit
      
      // Show user-friendly warning
      Get.snackbar(
        'Connection Warning',
        'Unable to load current employee counts. Displaying estimated values.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[800],
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning_amber, color: Colors.orange),
      );
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

  /// Show company limit exceeded dialog
  void _showCompanyLimitDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[600], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Company Employee Limit Exceeded',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your company has reached its maximum employee capacity of ${companyEmployeeLimit.value} employees.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Current employees: ${companyEmployeeCount.value}/${companyEmployeeLimit.value}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You cannot add more employees until the company limit is increased.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Refresh employee counts from server
  Future<void> refreshEmployeeCounts() async {
    await _loadEmployeeCounts();
  }

  Future<void> _showSuccessDialog() async {
    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            const Text('Success'),
          ],
        ),
        content: const Text('Employee added successfully!'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> addEmployee() async {
    if (!_validateFields()) return;

    final authController = Get.find<AuthController>();
    final managerId = authController.user.value?.id;

    if (managerId == null) {
      Get.snackbar('Error', 'Manager ID not found. Please login again.');
      return;
    }

    try {
      isLoading.value = true;

      // Refresh employee counts to get latest data
      await _loadEmployeeCounts();

      // Check company-wide employee limit (primary validation)
      final newCompanyTotal = companyEmployeeCount.value + 1;
      if (newCompanyTotal > companyEmployeeLimit.value) {
        _showCompanyLimitDialog();
        return;
      }

      print('🔍 Company Limit Check Passed:');
      print('   New total would be: $newCompanyTotal');
      print('   Company limit: ${companyEmployeeLimit.value}');

      // Prepare employee data for backend
      final employeeData = {
        'email': emailController.text.trim(),
        'password': pinController.text.trim(), // Backend uses 'password' for 4-digit PIN
        'name': nameController.text.trim(),
        'role': role, // Auto-filled as 'Employee'
        'department': departmentController.text.trim(),
        'phone': phoneController.text.trim(),
        'profile_picture': '',
        'manager_id': managerId,
      };

      print('📤 Submitting employee data: ${employeeData.keys.join(', ')}');

      // Submit to backend
      await _employeeService.addEmployee(employeeData);

      // Update local counts
      currentEmployeeCount.value = currentEmployeeCount.value + 1;
      companyEmployeeCount.value = companyEmployeeCount.value + 1;

      // Show success dialog
      await _showSuccessDialog();
      
      // Clear form fields
      _clearFields();
        
      // Navigate back to employee list
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offNamed('/employee-list');
        
      // Refresh employee list if controller exists
      try {
        final employeeListController = Get.find<EmployeeListController>();
        employeeListController.refreshEmployees();
      } catch (e) {
        print('ℹ️ EmployeeListController not found - that\'s okay');
      }
        
    } catch (e) {
      print('❌ Error adding employee: $e');
      
      // Parse error message for user-friendly display
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('limit') || errorMessage.contains('exceeded')) {
        // Backend returned a limit error, refresh counts and show dialog
        await _loadEmployeeCounts();
        _showCompanyLimitDialog();
      } else {
        // Show generic error
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isLoading.value = false;
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
