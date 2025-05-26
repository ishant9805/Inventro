import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
        await _productService.addProduct({
          'part_number': partNumberController.text.trim(),
          'description': descriptionController.text.trim(),
          'location': locationController.text.trim(),
          'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
          'batch_number': batchNumberController.text.trim(),
          'expiry_date': expiryDateController.text.trim(),
          'updated_on': updatedOnController.text.trim(),
        });
        Get.snackbar('Success', 'Product added successfully');
        _clearFields();
      } catch (e) {
        Get.snackbar('Error', e.toString());
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