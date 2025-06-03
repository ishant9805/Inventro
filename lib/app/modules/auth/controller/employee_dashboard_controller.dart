import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/product_model.dart';

class EmployeeDashboardController extends GetxController {
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;
  final ProductService _productService = ProductService();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final productList = await _productService.getProducts();
      products.value = productList.map((productJson) => ProductModel.fromJson(productJson)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: \\${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProducts() async {
    await fetchProducts();
  }

  void logout() {
    // Optionally clear any employee-specific state here
    Get.snackbar('Logout Successful', 'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    Get.offAllNamed('/role-selection');
  }
}
