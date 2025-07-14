import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/product_model.dart';

class EditProductController extends GetxController {
  final partNumberController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final quantityController = TextEditingController();
  final batchNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final updatedOnController = TextEditingController();

  final isLoading = false.obs;
  final isInitialized = false.obs;
  final ProductService _productService = ProductService();
  
  // Add a flag to track if the controller is disposed
  bool _isDisposed = false;
  
  ProductModel? currentProduct;

  @override
  void onInit() {
    super.onInit();
    // Get product data from arguments with better error handling
    try {
      final args = Get.arguments;
      print('📋 EditProductController: Received arguments type: ${args.runtimeType}');
      
      if (args != null) {
        if (args is ProductModel) {
          // Direct ProductModel argument
          currentProduct = args;
          print('✅ EditProductController: Direct ProductModel received');
          _populateFields();
        } else if (args is Map<String, dynamic> && args.containsKey('product')) {
          // Wrapped in map format
          final productData = args['product'];
          if (productData is ProductModel) {
            currentProduct = productData;
            print('✅ EditProductController: ProductModel from map received');
            _populateFields();
          } else {
            print('❌ EditProductController: Invalid product data in map');
            _handleInvalidProduct();
          }
        } else {
          print('❌ EditProductController: Unsupported argument format: ${args.runtimeType}');
          _handleInvalidProduct();
        }
      } else {
        print('❌ EditProductController: No arguments received');
        _handleInvalidProduct();
      }
    } catch (e) {
      print('❌ EditProductController: Error in onInit: $e');
      _handleInvalidProduct();
    }
  }

  void _handleInvalidProduct() {
    if (!_isDisposed) {
      SafeNavigation.safeSnackbar(
        title: 'Error',
        message: 'Invalid product data. Returning to dashboard.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      
      // Navigate back to dashboard after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isDisposed) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      });
    }
  }

  void _populateFields() {
    if (currentProduct == null || _isDisposed) {
      print('❌ Cannot populate fields: product is null or controller disposed');
      return;
    }
    
    try {
      // Safely populate fields with null checks
      partNumberController.text = currentProduct!.partNumber;
      descriptionController.text = currentProduct!.description;
      locationController.text = currentProduct!.location;
      quantityController.text = currentProduct!.quantity.toString();
      batchNumberController.text = currentProduct!.batchNumber.toString();
      
      // Format expiry date for display (DD/MM/YYYY) with error handling
      try {
        if (currentProduct!.expiryDate.isNotEmpty) {
          final dateTime = DateTime.parse(currentProduct!.expiryDate);
          expiryDateController.text = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
        } else {
          // Set to tomorrow if no date
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          expiryDateController.text = "${tomorrow.day}/${tomorrow.month}/${tomorrow.year}";
        }
      } catch (e) {
        print('⚠️ Error parsing expiry date: $e');
        // Fallback to formatted expiry date or tomorrow
        expiryDateController.text = currentProduct!.formattedExpiryDate.isNotEmpty 
            ? currentProduct!.formattedExpiryDate 
            : "${DateTime.now().add(const Duration(days: 1)).day}/${DateTime.now().add(const Duration(days: 1)).month}/${DateTime.now().add(const Duration(days: 1)).year}";
      }
      
      // Set updated on to current date
      final now = DateTime.now();
      updatedOnController.text = "${now.day}/${now.month}/${now.year}";
      
      if (!_isDisposed) {
        isInitialized.value = true;
      }
      
      print('✅ EditProductController: Fields populated successfully');
    } catch (e) {
      print('❌ Error populating fields: $e');
      if (!_isDisposed) {
        Get.snackbar(
          'Error',
          'Failed to load product data. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[800],
        );
      }
    }
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    if (_isDisposed) return;
    
    DateTime initialDate = DateTime.now().add(const Duration(days: 1)); // Default to tomorrow
    
    try {
      if (expiryDateController.text.isNotEmpty) {
        final parts = expiryDateController.text.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]) ?? 1;
          final month = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          // Validate date components
          if (year >= 1900 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            initialDate = DateTime(year, month, day);
          }
        }
      }
    } catch (e) {
      print('⚠️ Error parsing current expiry date: $e');
      initialDate = DateTime.now().add(const Duration(days: 1));
    }

    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      );
      
      if (picked != null && !_isDisposed) {
        expiryDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      }
    } catch (e) {
      print('❌ Error showing date picker: $e');
      if (!_isDisposed) {
        Get.snackbar(
          'Error',
          'Failed to open date picker. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[800],
        );
      }
    }
  }

  Future<void> updateProduct() async {
    if (_isDisposed || currentProduct == null) {
      print('❌ Cannot update: controller disposed or product is null');
      return;
    }
    
    if (!_validateFields()) {
      return;
    }

    try {
      isLoading.value = true;
      
      // Convert expiry date from DD/MM/YYYY to YYYY-MM-DD format
      String formattedExpiryDate = _formatExpiryDateForBackend(expiryDateController.text.trim());
      
      // Debug: Log the formatted date
      print('🗓️ Original date: ${expiryDateController.text.trim()}');
      print('🗓️ Formatted for backend: $formattedExpiryDate');
      
      // Prepare data for update with validation
      final productData = {
        'part_number': partNumberController.text.trim(),
        'description': descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
        'batch_number': int.tryParse(batchNumberController.text.trim()) ?? 0,
        'expiry_date': formattedExpiryDate,
      };

      print('🔄 Updating product data: $productData');

      final result = await _productService.updateProduct(currentProduct!.id!, productData)
          .timeout(const Duration(seconds: 45)); // Add timeout
      
      if (!_isDisposed) {
        Get.snackbar(
          'Success', 
          'Product "${partNumberController.text.trim()}" updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );
        
        // Use WidgetsBinding to ensure safe navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            // Update the product in dashboard without full refresh
            try {
              final dashboardController = Get.isRegistered<DashboardController>()
                  ? Get.find<DashboardController>()
                  : null;
              
              if (dashboardController != null) {
                // Create updated product model from current data
                final updatedProduct = currentProduct!.copyWith(
                  partNumber: partNumberController.text.trim(),
                  description: descriptionController.text.trim(),
                  location: locationController.text.trim(),
                  quantity: int.tryParse(quantityController.text.trim()) ?? 0,
                  batchNumber: int.tryParse(batchNumberController.text.trim()) ?? 0,
                  expiryDate: formattedExpiryDate,
                  updatedAt: DateTime.now().toIso8601String(),
                );
                
                // Update in dashboard list instead of full refresh
                dashboardController.updateProductInList(updatedProduct);
                print('✅ Product updated in dashboard locally');
              } else {
                print('❌ Dashboard controller not found');
              }
            } catch (e) {
              print('❌ Error updating dashboard: $e');
            }
            
            // Navigate back to dashboard
            Get.offAllNamed('/dashboard');
          }
        });
      }
      
      print('✅ Product update completed: $result');
      
    } catch (e) {
      print('❌ Error updating product: $e');
      if (!_isDisposed) {
        final errorMessage = _getErrorMessage(e);
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
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().replaceAll('Exception: ', '');
    
    if (errorStr.contains('timeout') || errorStr.contains('TimeoutException')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (errorStr.contains('Network') || errorStr.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('token') || errorStr.contains('authentication')) {
      return 'Authentication error. Please login again.';
    } else if (errorStr.contains('server') || errorStr.contains('backend')) {
      return 'Server error. Please try again later.';
    } else if (errorStr.contains('Invalid')) {
      return 'Invalid data provided. Please check your inputs.';
    } else {
      return errorStr.isEmpty ? 'An unexpected error occurred' : errorStr;
    }
  }

  String _formatExpiryDateForBackend(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        
        if (day != null && month != null && year != null) {
          // Validate date components
          if (year >= 1900 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            return '${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
          }
        }
      }
    } catch (e) {
      print('❌ Error formatting date: $e');
    }
    
    // If parsing fails, return tomorrow's date in YYYY-MM-DD format
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
  }

  bool _validateFields() {
    if (_isDisposed) return false;
    
    try {
      if (partNumberController.text.trim().isEmpty) {
        _showValidationError('Part Number is required');
        return false;
      }
      
      if (descriptionController.text.trim().isEmpty) {
        _showValidationError('Description is required');
        return false;
      }
      
      if (locationController.text.trim().isEmpty) {
        _showValidationError('Location is required');
        return false;
      }
      
      if (quantityController.text.trim().isEmpty) {
        _showValidationError('Quantity is required');
        return false;
      }
      
      final quantity = int.tryParse(quantityController.text.trim());
      if (quantity == null || quantity < 0) {
        _showValidationError('Please enter a valid quantity (0 or greater)');
        return false;
      }
      
      if (batchNumberController.text.trim().isEmpty) {
        _showValidationError('Batch Number is required');
        return false;
      }
      
      final batchNumber = int.tryParse(batchNumberController.text.trim());
      if (batchNumber == null || batchNumber < 0) {
        _showValidationError('Please enter a valid batch number (0 or greater)');
        return false;
      }
      
      if (expiryDateController.text.trim().isEmpty) {
        _showValidationError('Expiry Date is required');
        return false;
      }
      
      // Validate expiry date format
      try {
        final parts = expiryDateController.text.trim().split('/');
        if (parts.length != 3) {
          _showValidationError('Please enter expiry date in DD/MM/YYYY format');
          return false;
        }
        
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        
        if (day == null || month == null || year == null) {
          _showValidationError('Please enter a valid expiry date');
          return false;
        }
        
        if (year < DateTime.now().year || year > 2030) {
          _showValidationError('Expiry year must be between ${DateTime.now().year} and 2030');
          return false;
        }
        
        if (month < 1 || month > 12) {
          _showValidationError('Month must be between 1 and 12');
          return false;
        }
        
        if (day < 1 || day > 31) {
          _showValidationError('Day must be between 1 and 31');
          return false;
        }
        
        // Validate actual date
        final expiryDate = DateTime(year, month, day);
        if (expiryDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          _showValidationError('Expiry date cannot be in the past');
          return false;
        }
        
      } catch (e) {
        _showValidationError('Please enter a valid expiry date');
        return false;
      }
      
      return true;
    } catch (e) {
      print('❌ Error in validation: $e');
      _showValidationError('Validation error occurred. Please check your inputs.');
      return false;
    }
  }

  void _showValidationError(String message) {
    if (!_isDisposed) {
      Get.snackbar(
        'Validation Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        colorText: Colors.orange[800],
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    
    // Safely dispose all controllers
    try {
      partNumberController.dispose();
      descriptionController.dispose();
      locationController.dispose();
      quantityController.dispose();
      batchNumberController.dispose();
      expiryDateController.dispose();
      updatedOnController.dispose();
    } catch (e) {
      print('❌ Error disposing controllers: $e');
    }
    
    super.onClose();
  }
}