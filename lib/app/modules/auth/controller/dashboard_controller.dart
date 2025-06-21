import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/product_model.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;
  final ProductService _productService = ProductService();

  // Add error message observable
  var errorMessage = ''.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // Fetch all products from backend
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      print('🔄 DashboardController: Starting product fetch...');
      
      // Get products from service
      final productMaps = await _productService.getProducts();
      
      print('📦 DashboardController: Raw product data received: ${productMaps.length} items');
      
      // Convert to ProductModel objects with error handling
      final List<ProductModel> productList = [];
      for (int i = 0; i < productMaps.length; i++) {
        try {
          final productData = productMaps[i];
          print('🔍 Processing product $i: ${productData.keys.toList()}');
          
          final product = ProductModel.fromJson(productData);
          productList.add(product);
          
          print('✅ Successfully created ProductModel: ${product.partNumber}');
        } catch (e) {
          print('❌ Error parsing product at index $i: $e');
          print('📋 Product data: ${productMaps[i]}');
          // Continue with other products instead of failing completely
        }
      }
      
      products.value = productList;
      print('✅ DashboardController: Successfully loaded ${products.length} products');
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
      print('❌ DashboardController: Error fetching products: $e');
      
      // Show user-friendly error message
      Get.snackbar(
        'Error Loading Products',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh products (called after adding/updating/deleting products)
  Future<void> refreshProducts() async {
    print('🔄 DashboardController: Refreshing products...');
    await fetchProducts();
  }

  // Method to retry after error
  Future<void> retryFetch() async {
    print('🔄 DashboardController: Retrying product fetch...');
    await fetchProducts();
  }

  // Method to clear error state
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
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
        backgroundColor: Colors.red.withValues(alpha: 25),
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
          backgroundColor: Colors.red.withValues(alpha: 25),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Test Error', 
        'Failed to test backend: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 25),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 5),
      );
    }
  }
}