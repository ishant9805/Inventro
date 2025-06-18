import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
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
        // Get manager_id from AuthController
        final authController = Get.find<AuthController>();
        final managerId = authController.user.value?.id;
        if (managerId == null) {
          Get.snackbar('Error', 'Manager ID not found. Please login again.');
          isLoading.value = false;
          return;
        }
        // Prepare data according to backend schema
        final productData = {
          'part_number': partNumberController.text.trim(),
          'description': descriptionController.text.trim(),
          'location': locationController.text.trim(),
          'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
          'batch_number': batchNumberController.text.trim(),
          'expiry_date': expiryDateController.text.trim(),
          'manager_id': managerId,
        };

        print('Submitting product data: $productData');

        final result = await _productService.addProduct(productData);
        
        Get.snackbar(
          'Success', 
          'Product "${partNumberController.text.trim()}" added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );
        
        _clearFields();
        Get.offAllNamed('/dashboard');
        // Ensure dashboard product list is refreshed after adding
        final dashboardController = Get.isRegistered<DashboardController>()
            ? Get.find<DashboardController>()
            : null;
        dashboardController?.refreshProducts();
        print('Product added successfully: $result');
        
      } catch (e) {
        print('Error adding product: $e');
        Get.snackbar(
          'Error', 
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 4),
        );
      } finally {
        isLoading.value = false;
      }
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