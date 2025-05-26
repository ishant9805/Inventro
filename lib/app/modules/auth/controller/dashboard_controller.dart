import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/product_model.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;
  final ProductService _productService = ProductService();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // Fetch all products from backend
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final productList = await _productService.getProducts();
      
      // Convert to ProductModel objects
      products.value = productList
          .map((productJson) => ProductModel.fromJson(productJson))
          .toList();
      
      print('Fetched ${products.length} products');
      
    } catch (e) {
      print('Error fetching products: $e');
      Get.snackbar(
        'Error', 
        'Failed to load products: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh products list
  Future<void> refreshProducts() async {
    await fetchProducts();
  }

  // Get products that are expired or expiring soon
  List<ProductModel> get expiringProducts {
    return products.where((product) {
      return product.daysUntilExpiry <= 30; // Products expiring within 30 days
    }).toList();
  }

  // Get low stock products
  List<ProductModel> get lowStockProducts {
    return products.where((product) => product.quantity <= 10).toList();
  }

  // Delete product
  Future<void> deleteProduct(int productId) async {
    try {
      isLoading.value = true;
      await _productService.deleteProduct(productId);
      
      // Remove from local list
      products.removeWhere((product) => product.id == productId);
      
      Get.snackbar(
        'Success', 
        'Product deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 25),
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to delete product: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Debug method to test backend connection and authentication
  Future<void> testBackendConnection() async {
    try {
      Get.snackbar(
        'Testing', 
        'Testing backend connection...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      
      final result = await _productService.testBackendConnection();
      
      if (result['success'] == true) {
        Get.snackbar(
          'Backend Test Success', 
          'Connection successful (Status: ${result['status_code']})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 25),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Backend Test Failed', 
          'Error: ${result['error'] ?? 'Unknown error'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Test Error', 
        'Failed to test backend: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 5),
      );
    }
  }
}