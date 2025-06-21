import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
import '../../../data/services/product_service.dart';


class AddProductController extends GetxController {
  final partNumberController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final quantityController = TextEditingController();
  final batchNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final updatedOnController = TextEditingController();

  final isLoading = false.obs;
  final ProductService _productService = ProductService();

  @override
  void onInit() {
    super.onInit();
    // Set current date for Updated On field
    final now = DateTime.now();
    updatedOnController.text = "${now.day}/${now.month}/${now.year}";
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      expiryDateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> addProduct() async {
    if (_validateFields()) {
      isLoading.value = true;
      try {
        // Convert expiry date from DD/MM/YYYY to YYYY-MM-DD format
        String formattedExpiryDate = _formatExpiryDateForBackend(expiryDateController.text.trim());
        
        // Prepare data according to your requirements
        final productData = {
          'part_number': partNumberController.text.trim(),
          'description': descriptionController.text.trim(),
          'location': locationController.text.trim(),
          'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
          'batch_number': int.tryParse(batchNumberController.text.trim()) ?? 0,
          'expiry_date': formattedExpiryDate, // Format: YYYY-MM-DD
        };

        print('Submitting product data: $productData');

        final result = await _productService.addProduct(productData);
        
        Get.snackbar(
          'Success', 
          'Product "${partNumberController.text.trim()}" added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );
        
        _clearFields();
        
        // Refresh the product list on dashboard
        final dashboardController = Get.isRegistered<DashboardController>()
            ? Get.find<DashboardController>()
            : null;
        dashboardController?.refreshProducts();
        
        // Navigate back to dashboard
        Get.offAllNamed('/dashboard');
        
        print('Product added successfully: $result');
        
      } catch (e) {
        print('Error adding product: $e');
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

  // Helper method to format expiry date from DD/MM/YYYY to YYYY-MM-DD
  String _formatExpiryDateForBackend(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    // If parsing fails, return today's date in YYYY-MM-DD format
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _validateFields() {
    if (partNumberController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Part Number is required');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Description is required');
      return false;
    }
    if (locationController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Location is required');
      return false;
    }
    if (quantityController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Quantity is required');
      return false;
    }
    if (int.tryParse(quantityController.text.trim()) == null || int.parse(quantityController.text.trim()) < 0) {
      Get.snackbar('Error', 'Please enter a valid quantity (0 or greater)');
      return false;
    }
    if (batchNumberController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Batch Number is required');
      return false;
    }
    if (expiryDateController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Expiry Date is required');
      return false;
    }
    return true;
  }

  void _clearFields() {
    partNumberController.clear();
    descriptionController.clear();
    locationController.clear();
    quantityController.clear();
    batchNumberController.clear();
    expiryDateController.clear();
    // Reset updated on to current date
    final now = DateTime.now();
    updatedOnController.text = "${now.day}/${now.month}/${now.year}";
  }

  @override
  void onClose() {
    partNumberController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    quantityController.dispose();
    batchNumberController.dispose();
    expiryDateController.dispose();
    updatedOnController.dispose();
    super.onClose();
  }
}