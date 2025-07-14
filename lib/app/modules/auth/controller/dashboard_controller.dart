import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/product_model.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;
  final filteredProducts = <ProductModel>[].obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final ProductService _productService = ProductService();

  // Add error message observable
  var errorMessage = ''.obs;
  var hasError = false.obs;
  
  // Add a flag to track if the controller is disposed
  bool _isDisposed = false;
  
  // Add initialization tracking
  final isInitialized = false.obs;
  
  // Add a flag to prevent multiple concurrent initializations
  bool _isInitializing = false;

  @override
  void onInit() {
    super.onInit();
    // Initialize products fetch with proper error handling
    _initializeProducts();
    // Listen to search changes
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    _isDisposed = true;
    
    // Safely dispose search controller
    try {
      searchController.removeListener(_onSearchChanged);
      searchController.dispose();
    } catch (e) {
      print('Error disposing search controller: $e');
    }
    
    super.onClose();
  }

  // Enhanced initialization method with concurrency protection
  Future<void> _initializeProducts() async {
    // Prevent multiple concurrent initializations
    if (_isInitializing || _isDisposed) return;
    
    _isInitializing = true;
    
    try {
      await fetchProducts();
      if (!_isDisposed) {
        isInitialized.value = true;
      }
    } catch (e) {
      print('❌ Failed to initialize products: $e');
      if (!_isDisposed) {
        isInitialized.value = true; // Still mark as initialized to show error state
      }
    } finally {
      _isInitializing = false;
    }
  }

  // Add method to check if controller needs reinitialization
  void checkAndReinitialize() {
    if (_isDisposed) return;
    
    // Only reinitialize if not already initialized and not currently loading
    if (!isInitialized.value && !isLoading.value && !_isInitializing) {
      print('🔄 DashboardController: Reinitializing on return to dashboard');
      _initializeProducts();
    } else if (isInitialized.value && products.isEmpty) {
      // Handle edge case where initialized but no products
      print('🔄 DashboardController: Refreshing empty product list');
      refreshProducts();
    }
  }

  void _onSearchChanged() {
    if (_isDisposed) return;
    
    searchQuery.value = searchController.text;
    _filterProducts();
  }

  void _filterProducts() {
    if (_isDisposed) return;
    
    try {
      if (searchQuery.value.isEmpty) {
        filteredProducts.value = products.toList();
      } else {
        filteredProducts.value = products.where((product) {
          final query = searchQuery.value.toLowerCase();
          return product.partNumber.toLowerCase().contains(query) ||
                 product.description.toLowerCase().contains(query) ||
                 product.location.toLowerCase().contains(query) ||
                 product.batchNumber.toString().contains(query);
        }).toList();
      }
    } catch (e) {
      print('❌ Error filtering products: $e');
      // Fallback to showing all products
      filteredProducts.value = products.toList();
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().replaceAll('Exception: ', '');
    
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please check your internet connection.';
    } else if (errorStr.contains('Network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('token')) {
      return 'Authentication error. Please login again.';
    } else if (errorStr.contains('server') || errorStr.contains('backend')) {
      return 'Server error. Please try again later.';
    } else {
      return errorStr.isEmpty ? 'Unknown error occurred' : errorStr;
    }
  }

  // Enhanced fetch method with better loading state management
  Future<void> fetchProducts() async {
    if (_isDisposed) return;
    
    try {
      // Only set loading if not already loading
      if (!isLoading.value) {
        isLoading.value = true;
      }
      hasError.value = false;
      errorMessage.value = '';
      
      print('🔄 DashboardController: Starting product fetch...');
      
      // Get products from service with timeout
      final productMaps = await _productService.getProducts()
          .timeout(const Duration(seconds: 45)); // Extended timeout
      
      print('📦 DashboardController: Raw product data received: ${productMaps.length} items');
      
      // Convert to ProductModel objects with better error handling
      final List<ProductModel> productList = [];
      for (int i = 0; i < productMaps.length; i++) {
        try {
          final productData = productMaps[i];
          
          // Validate required fields before creating model
          if (_validateProductData(productData)) {
            final product = ProductModel.fromJson(productData);
            productList.add(product);
            print('✅ Successfully created ProductModel: ${product.partNumber}');
          } else {
            print('⚠️ Skipping invalid product at index $i: missing required fields');
          }
        } catch (e) {
          print('❌ Error parsing product at index $i: $e');
          print('📋 Product data: ${productMaps[i]}');
          // Continue with other products instead of failing completely
        }
      }
      
      if (!_isDisposed) {
        products.value = productList;
        // Update filtered products safely
        _filterProducts();
        print('✅ DashboardController: Successfully loaded ${products.length} products');
      }
      
    } catch (e) {
      print('❌ DashboardController: Error fetching products: $e');
      
      if (!_isDisposed) {
        hasError.value = true;
        errorMessage.value = _getErrorMessage(e);
        
        // Show user-friendly error message using safe snackbar
        SafeNavigation.safeSnackbar(
          title: 'Error Loading Products',
          message: errorMessage.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      // Always ensure loading is set to false
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  // Helper method to validate product data before parsing
  bool _validateProductData(Map<String, dynamic> data) {
    try {
      // Check for required fields
      return data.containsKey('part_number') &&
             data.containsKey('description') &&
             data.containsKey('location') &&
             data.containsKey('quantity') &&
             data.containsKey('batch_number') &&
             data.containsKey('expiry_date');
    } catch (e) {
      return false;
    }
  }

  // Refresh products (called after adding/updating/deleting products)
  Future<void> refreshProducts() async {
    if (_isDisposed) return;
    
    print('🔄 DashboardController: Refreshing products...');
    await fetchProducts();
  }

  // Method to retry after error
  Future<void> retryFetch() async {
    if (_isDisposed) return;
    
    print('🔄 DashboardController: Retrying product fetch...');
    clearError();
    await fetchProducts();
  }

  // Method to clear error state
  void clearError() {
    if (_isDisposed) return;
    
    hasError.value = false;
    errorMessage.value = '';
  }

  // Get products that are expired or expiring soon with null safety
  List<ProductModel> get expiringProducts {
    try {
      return products.where((product) {
        try {
          return product.daysUntilExpiry <= 7; // Products expiring within 7 days
        } catch (e) {
          return false; // Skip products with invalid dates
        }
      }).toList();
    } catch (e) {
      print('❌ Error getting expiring products: $e');
      return [];
    }
  }

  // Get low stock products with null safety
  List<ProductModel> get lowStockProducts {
    try {
      return products.where((product) {
        try {
          return product.quantity <= 2;
        } catch (e) {
          return false; // Skip products with invalid quantity
        }
      }).toList();
    } catch (e) {
      print('❌ Error getting low stock products: $e');
      return [];
    }
  }

  // Delete product with improved error handling
  Future<void> deleteProduct(int productId) async {
    if (_isDisposed) return;
    
    try {
      isLoading.value = true;
      await _productService.deleteProduct(productId);
      
      // Remove from both lists and trigger UI update
      products.removeWhere((product) => product.id == productId);
      _filterProducts(); // This will update filteredProducts and trigger UI refresh
      
      if (!_isDisposed) {
        SafeNavigation.safeSnackbar(
          title: 'Success',
          message: 'Product deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 2),
        );
      }
      
    } catch (e) {
      print('❌ Error deleting product: $e');
      if (!_isDisposed) {
        SafeNavigation.safeSnackbar(
          title: 'Error',
          message: 'Failed to delete product: ${_getErrorMessage(e)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (!_isDisposed) {
        isLoading.value = false;
      }
    }
  }

  // Add a method to handle product updates from edit screen
  void updateProductInList(ProductModel updatedProduct) {
    if (_isDisposed) return;
    
    try {
      final index = products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
        products.refresh(); // Force observable update
        _filterProducts(); // Update filtered list and trigger UI refresh
        print('✅ DashboardController: Product updated in local list - ${updatedProduct.partNumber}');
        print('📊 DashboardController: Total products: ${products.length}');
      } else {
        print('❌ DashboardController: Product not found for update - ID: ${updatedProduct.id}');
      }
    } catch (e) {
      print('❌ Error updating product in list: $e');
    }
  }

  // Add a method to handle new products from add screen  
  void addProductToList(ProductModel newProduct) {
    if (_isDisposed) return;
    
    try {
      products.add(newProduct);
      products.refresh(); // Force observable update
      _filterProducts(); // Update filtered list and trigger UI refresh
      print('✅ DashboardController: Product added to local list - ${newProduct.partNumber}');
      print('📊 DashboardController: Total products: ${products.length}');
    } catch (e) {
      print('❌ Error adding product to list: $e');
    }
  }

  // Clear search with null safety
  void clearSearch() {
    if (_isDisposed) return;
    
    try {
      searchController.clear();
      searchQuery.value = '';
      _filterProducts();
    } catch (e) {
      print('❌ Error clearing search: $e');
    }
  }

  // Test backend connection (for debugging)
  Future<void> testBackendConnection() async {
    if (_isDisposed) return;
    
    try {
      SafeNavigation.safeSnackbar(
        title: 'Testing Connection',
        message: 'Checking backend connectivity...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
        colorText: Colors.blue[800],
        duration: const Duration(seconds: 2),
      );
      
      // Try to fetch a single product or ping the server
      await _productService.getProducts();
      
      if (!_isDisposed) {
        SafeNavigation.safeSnackbar(
          title: 'Connection Successful',
          message: 'Backend is reachable',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green[800],
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (!_isDisposed) {
        SafeNavigation.safeSnackbar(
          title: 'Connection Failed',
          message: 'Unable to reach backend: ${_getErrorMessage(e)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 4),
        );
      }
    }
  }
}