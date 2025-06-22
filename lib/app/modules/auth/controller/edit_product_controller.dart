import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
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
  
  ProductModel? currentProduct;

  @override
  void onInit() {
    super.onInit();
    // Get product data from arguments
    final args = Get.arguments;
    if (args != null && args is ProductModel) {
      currentProduct = args;
      _populateFields();
    }
  }

  void _populateFields() {
    if (currentProduct != null) {
      partNumberController.text = currentProduct!.partNumber;
      descriptionController.text = currentProduct!.description;
      locationController.text = currentProduct!.location;
      quantityController.text = currentProduct!.quantity.toString();
      batchNumberController.text = currentProduct!.batchNumber.toString();
      
      // Format expiry date for display (DD/MM/YYYY)
      try {
        final dateTime = DateTime.parse(currentProduct!.expiryDate);
        expiryDateController.text = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      } catch (e) {
        expiryDateController.text = currentProduct!.formattedExpiryDate;
      }
      
      // Set updated on to current date
      final now = DateTime.now();
      updatedOnController.text = "${now.day}/${now.month}/${now.year}";
      
      isInitialized.value = true;
    }
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      if (expiryDateController.text.isNotEmpty) {
        final parts = expiryDateController.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      }
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      expiryDateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> updateProduct() async {
    if (_validateFields()) {
      isLoading.value = true;
      try {
        // Convert expiry date from DD/MM/YYYY to YYYY-MM-DD format
        String formattedExpiryDate = _formatExpiryDateForBackend(expiryDateController.text.trim());
        
        // Prepare data for update
        final productData = {
          'part_number': partNumberController.text.trim(),
          'description': descriptionController.text.trim(),
          'location': locationController.text.trim(),
          'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
          'batch_number': batchNumberController.text.trim(),
          'expiry_date': formattedExpiryDate,
        };

        print('Updating product data: $productData');

        final result = await _productService.updateProduct(currentProduct!.id!, productData);
        
        Get.snackbar(
          'Success', 
          'Product "${partNumberController.text.trim()}" updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );
        
        // Refresh the product list on dashboard
        final dashboardController = Get.isRegistered<DashboardController>()
            ? Get.find<DashboardController>()
            : null;
        dashboardController?.refreshProducts();
        
        // Navigate back to dashboard
        Get.offAllNamed('/dashboard');
        
        print('Product updated successfully: $result');
        
      } catch (e) {
        print('Error updating product: $e');
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

  String _formatExpiryDateForBackend(String dateString) {
    try {
      // Parse DD/MM/YYYY format
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        
        final dateTime = DateTime(year, month, day);
        return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
      }
      return dateString;
    } catch (e) {
      print('Error formatting date: $e');
      return dateString;
    }
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