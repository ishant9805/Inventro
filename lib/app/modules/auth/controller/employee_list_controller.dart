import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/employee_service.dart';
import '../../../data/models/employee_model.dart';

class EmployeeListController extends GetxController {
  // ==================== OBSERVABLES ====================
  final isLoading = false.obs;
  final employees = <EmployeeModel>[].obs;
  final filteredEmployees = <EmployeeModel>[].obs;
  final searchQuery = ''.obs;

  // ==================== CONTROLLERS & SERVICES ====================
  final searchController = TextEditingController();
  final EmployeeService _employeeService = EmployeeService();

  // ==================== PRIVATE STATE ====================
  bool _isDisposed = false;

  // ==================== LIFECYCLE METHODS ====================
  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
    _initializeEmployees();
  }

  @override
  void onClose() {
    _cleanupController();
    super.onClose();
  }

  // ==================== INITIALIZATION METHODS ====================

  /// Sets up the search controller listener
  void _setupSearchListener() {
    searchController.addListener(_onSearchChanged);
  }

  /// Initializes the controller by loading employees
  Future<void> _initializeEmployees() async {
    await loadEmployees();
  }

  /// Cleans up resources when controller is disposed
  void _cleanupController() {
    _isDisposed = true;
    
    try {
      searchController.removeListener(_onSearchChanged);
      searchController.dispose();
    } catch (e) {
      print('❌ Error disposing search controller: $e');
    }
    
    super.onClose();
  }

  // ==================== PUBLIC METHODS ====================

  /// Loads employees from the API
  Future<void> loadEmployees() async {
    if (_isDisposed) return;
    
    try {
      _setLoadingState(true);
      
      final employeeList = await _employeeService.getEmployees();
      
      if (!_isDisposed) {
        final employeeModels = _processEmployeeData(employeeList);
        _updateEmployeeLists(employeeModels);
        print('✅ Loaded ${employees.length} employees');
      }
      
    } catch (e) {
      _handleLoadError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Deletes an employee with confirmation dialog
  Future<void> deleteEmployee(int employeeId, String employeeName) async {
    if (_isDisposed) return;
    
    final confirmed = await _showDeleteConfirmation(employeeName);
    if (!confirmed) return;

    try {
      _setLoadingState(true);
      await _employeeService.deleteEmployee(employeeId);
      
      _removeEmployeeFromLists(employeeId);
      _showSuccessMessage('Employee $employeeName deleted successfully');
      
    } catch (e) {
      _handleDeleteError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Refreshes the employee list
  void refreshEmployees() {
    if (!_isDisposed) {
      loadEmployees();
    }
  }

  /// Clears search input and filters
  void clearSearch() {
    if (_isDisposed) return;
    
    try {
      searchController.clear();
      searchQuery.value = '';
      _filterEmployees();
    } catch (e) {
      print('❌ Error clearing search: $e');
    }
  }

  // ==================== SEARCH & FILTERING METHODS ====================

  /// Handles search query changes
  void _onSearchChanged() {
    if (_isDisposed) return;
    
    searchQuery.value = searchController.text;
    _filterEmployees();
  }

  /// Filters employees based on current search query
  void _filterEmployees() {
    if (_isDisposed) return;
    
    try {
      if (searchQuery.value.isEmpty) {
        filteredEmployees.value = employees.toList();
      } else {
        filteredEmployees.value = _getFilteredEmployees();
      }
    } catch (e) {
      print('❌ Error filtering employees: $e');
      filteredEmployees.value = employees.toList(); // Fallback
    }
  }

  /// Gets employees that match the current search query
  List<EmployeeModel> _getFilteredEmployees() {
    final query = searchQuery.value.toLowerCase();
    
    return employees.where((employee) {
      return employee.name.toLowerCase().contains(query) ||
             employee.email.toLowerCase().contains(query) ||
             employee.department.toLowerCase().contains(query);
    }).toList();
  }

  // ==================== DATA PROCESSING METHODS ====================

  /// Processes raw employee data into EmployeeModel objects
  List<EmployeeModel> _processEmployeeData(List<Map<String, dynamic>> employeeList) {
    final employeeModels = <EmployeeModel>[];
    
    for (final employeeData in employeeList) {
      try {
        final employee = EmployeeModel.fromJson(employeeData);
        employeeModels.add(employee);
      } catch (e) {
        print('⚠️ Error parsing employee data: $e');
        // Continue with other employees instead of failing completely
      }
    }
    
    return employeeModels;
  }

  /// Updates employee lists with new data
  void _updateEmployeeLists(List<EmployeeModel> employeeModels) {
    employees.value = employeeModels;
    _filterEmployees(); // Update filtered list
  }

  /// Removes an employee from both lists
  void _removeEmployeeFromLists(int employeeId) {
    employees.removeWhere((emp) => emp.id == employeeId);
    filteredEmployees.removeWhere((emp) => emp.id == employeeId);
  }

  // ==================== DIALOG METHODS ====================

  /// Shows confirmation dialog for employee deletion
  Future<bool> _showDeleteConfirmation(String employeeName) async {
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
        content: Text(
          'Are you sure you want to delete $employeeName? This action cannot be undone.',
        ),
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
            child: const Text(
              'Delete', 
              style: TextStyle(color: Colors.white)
            ),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  // ==================== ERROR HANDLING METHODS ====================

  /// Handles errors when loading employees
  void _handleLoadError(dynamic error) {
    print('❌ Error loading employees: $error');
    if (!_isDisposed) {
      final errorMessage = _getErrorMessage(error);
      _showErrorMessage('Failed to load employees: $errorMessage');
    }
  }

  /// Handles errors when deleting employees
  void _handleDeleteError(dynamic error) {
    print('❌ Error deleting employee: $error');
    if (!_isDisposed) {
      final errorMessage = _getErrorMessage(error);
      _showErrorMessage('Failed to delete employee: $errorMessage');
    }
  }

  /// Gets user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().replaceAll('Exception: ', '');
    
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please check your internet connection.';
    } else if (errorStr.contains('Network') || errorStr.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('token') || errorStr.contains('authentication')) {
      return 'Authentication error. Please login again.';
    } else if (errorStr.contains('server') || errorStr.contains('backend')) {
      return 'Server error. Please try again later.';
    } else if (errorStr.contains('not found')) {
      return 'Employee not found. It may have been already deleted.';
    } else {
      return errorStr.isEmpty ? 'An unexpected error occurred' : errorStr;
    }
  }

  // ==================== STATE MANAGEMENT HELPERS ====================

  /// Sets loading state safely
  void _setLoadingState(bool loading) {
    if (!_isDisposed) {
      isLoading.value = loading;
    }
  }

  // ==================== UI FEEDBACK METHODS ====================

  /// Shows success message to user
  void _showSuccessMessage(String message) {
    if (!_isDisposed) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Shows error message to user
  void _showErrorMessage(String message) {
    if (!_isDisposed) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
      );
    }
  }
}
