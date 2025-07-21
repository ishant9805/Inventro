import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
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

  // Enhanced fetch method with comprehensive error handling and token validation
  Future<void> fetchProducts() async {
    if (_isDisposed) return;
    
    try {
      // Clear any existing errors
      clearError();
      isLoading.value = true;

      print('🔄 DashboardController: Starting product fetch...');
      
      // Validate authentication before making request
      final authController = Get.find<AuthController>();
      if (authController.user.value?.token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      // Check if token validation is in progress with TIMEOUT
      if (authController.isTokenValidating.value) {
        print('🔄 DashboardController: Waiting for token validation to complete...');
        
        // Add timeout to prevent infinite waiting
        int timeoutCounter = 0;
        const maxTimeoutMs = 10000; // 10 seconds maximum wait
        const checkIntervalMs = 100;
        const maxChecks = maxTimeoutMs ~/ checkIntervalMs;
        
        while (authController.isTokenValidating.value && !_isDisposed && timeoutCounter < maxChecks) {
          await Future.delayed(const Duration(milliseconds: checkIntervalMs));
          timeoutCounter++;
        }
        
        // Handle timeout case
        if (timeoutCounter >= maxChecks) {
          print('⚠️ DashboardController: Token validation timeout, proceeding anyway...');
          // Don't throw error, just log and continue - the ProductService will handle auth validation
        }
        
        // Check if user is still authenticated after validation
        if (authController.user.value?.token == null) {
          throw Exception('Session expired. Please login again.');
        }
      }

      // Fetch products from API
      final List<Map<String, dynamic>> productList = await _productService.getProducts();
      
      if (_isDisposed) return; // Check disposal after async operation

      // Validate and convert products
      final List<ProductModel> validProducts = [];
      for (final productJson in productList) {
        try {
          // Validate product data before parsing
          if (_validateProductData(productJson)) {
            final product = ProductModel.fromJson(productJson);
            validProducts.add(product);
          } else {
            print('⚠️ DashboardController: Skipping invalid product data: $productJson');
          }
        } catch (e) {
          print('⚠️ DashboardController: Error parsing product: $e');
          print('📄 DashboardController: Product data: $productJson');
          // Continue with other products instead of failing completely
        }
      }

      if (!_isDisposed) {
        products.value = validProducts;
        _filterProducts(); // Apply current search filter
        print('✅ DashboardController: Successfully loaded ${validProducts.length} products');
      }

    } catch (e) {
      print('❌ DashboardController: Error fetching products: $e');
      
      if (!_isDisposed) {
        // Handle specific error types
        final errorMessage = _getErrorMessage(e);
        hasError.value = true;
        this.errorMessage.value = errorMessage;
        
        // Show user-friendly error message
        SafeNavigation.safeSnackbar(
          title: 'Error Loading Products',
          message: errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red[800],
          duration: const Duration(seconds: 4),
        );
        
        // If it's an authentication error, the AuthService will handle logout
        // For other errors, we can offer retry options
        if (!errorMessage.contains('login again')) {
          // Show retry option for non-auth errors after a delay
          Future.delayed(const Duration(seconds: 5), () {
            if (!_isDisposed && hasError.value) {
              // Show a simple retry message, user can manually call retry
              SafeNavigation.safeSnackbar(
                title: 'Retry Available',
                message: 'Pull down to refresh or try again later',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                colorText: Colors.blue[800],
                duration: const Duration(seconds: 3),
              );
            }
          });
        }
      }
    } finally {
      // CRITICAL: Always ensure loading is set to false, even if an exception occurs
      if (!_isDisposed) {
        isLoading.value = false;
        print('🏁 DashboardController: Loading state set to false');
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

  // Enhanced helper method to get user-friendly error messages
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().replaceAll('Exception: ', '');
    
    if (errorStr.contains('timeout') || errorStr.contains('TimeoutException')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (errorStr.contains('Network') || errorStr.contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (errorStr.contains('Authentication failed') || errorStr.contains('login again')) {
      return 'Your session has expired. Please login again.';
    } else if (errorStr.contains('Invalid response format')) {
      return 'Server returned invalid data. Please try again or contact support.';
    } else if (errorStr.contains('server') || errorStr.contains('backend') || errorStr.contains('Server')) {
      return 'Server error. Please try again later.';
    } else if (errorStr.contains('Connection refused') || errorStr.contains('No route to host')) {
      return 'Cannot connect to server. Please check your internet connection.';
    } else {
      return errorStr.isEmpty ? 'Unknown error occurred. Please try again.' : errorStr;
    }
  }

  // Refresh products (called after adding/updating/deleting products)
  Future<void> refreshProducts() async {
    if (_isDisposed) return;
    
    // Prevent multiple concurrent refresh operations
    if (isLoading.value) {
      print('🔄 DashboardController: Refresh already in progress, skipping...');
      return;
    }
    
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

  // Get products that are expired with null safety
  List<ProductModel> get expiredProducts {
    try {
      return products.where((product) {
        try {
          return product.isExpired; // Products that are already expired
        } catch (e) {
          return false; // Skip products with invalid dates
        }
      }).toList();
    } catch (e) {
      print('❌ Error getting expired products: $e');
      return [];
    }
  }

  // Get products that are expiring soon (but not yet expired) with null safety
  List<ProductModel> get expiringProducts {
    try {
      return products.where((product) {
        try {
          // Products expiring within 30 days but not yet expired
          return !product.isExpired && product.daysUntilExpiry <= 30 && product.daysUntilExpiry >= 0;
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