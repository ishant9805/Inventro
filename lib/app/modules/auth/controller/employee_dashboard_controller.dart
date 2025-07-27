import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/product_model.dart';
import 'auth_controller.dart';

/// Employee Dashboard Controller - Handles product loading and user interactions for employees
/// This controller is specifically for employee role with read-only access to company products
class EmployeeDashboardController extends GetxController {
  // ==================== OBSERVABLES ====================
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;
  final searchQuery = ''.obs;
  final errorMessage = ''.obs;
  final hasError = false.obs;

  // ==================== CONTROLLERS & SERVICES ====================
  final searchController = TextEditingController();
  final ProductService _productService = ProductService();

  // ==================== PRIVATE STATE ====================
  bool _isDisposed = false;

  // ==================== LIFECYCLE METHODS ====================
  @override
  void onInit() {
    super.onInit();
    _setupSearchListener();
    fetchProducts();
  }

  @override
  void onClose() {
    _cleanupController();
    super.onClose();
  }

  // ==================== INITIALIZATION METHODS ====================

  /// Sets up the search controller listener
  void _setupSearchListener() {
    searchController.addListener(_onSearchChanged);
  }

  /// Cleans up resources when controller is disposed
  void _cleanupController() {
    _isDisposed = true;
    
    try {
      searchController.removeListener(_onSearchChanged);
      searchController.dispose();
    } catch (e) {
      print('❌ Error disposing search controller: $e');
    }
  }

  // ==================== PRODUCT FETCHING METHODS ====================

  /// Fetches all products for the employee's company
  Future<void> fetchProducts() async {
    if (_isDisposed) return;
    
    try {
      _setLoadingState(true);
      _clearError();
      
      final productList = await _productService.getProducts();
      if (_isDisposed) return;

      final validProducts = _processProductData(productList);
      _updateProductList(validProducts);
      
      print('✅ EmployeeDashboardController: Successfully loaded ${products.length} products');
      
    } catch (e) {
      _handleFetchError(e);
    } finally {
      _setLoadingState(false);
    }
  }

  /// Refreshes the product list
  Future<void> refreshProducts() async {
    if (_isDisposed) return;
    await fetchProducts();
  }

  // ==================== SEARCH METHODS ====================

  /// Handles search query changes
  void _onSearchChanged() {
    if (_isDisposed) return;
    searchQuery.value = searchController.text;
  }

  /// Clears search input
  void clearSearch() {
    if (_isDisposed) return;
    
    try {
      searchController.clear();
      searchQuery.value = '';
    } catch (e) {
      print('❌ Error clearing search: $e');
    }
  }

  /// Gets filtered products based on search query
  List<ProductModel> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return products.toList();
    }
    
    final query = searchQuery.value.toLowerCase();
    return products.where((product) {
      return product.partNumber.toLowerCase().contains(query) ||
             product.description.toLowerCase().contains(query) ||
             product.location.toLowerCase().contains(query) ||
             product.batchNumber.toString().toLowerCase().contains(query); // Fixed: convert int to string
    }).toList();
  }

  // ==================== PRODUCT DETAIL METHODS ====================

  /// Shows detailed product information in a modal dialog
  void showProductDetails(ProductModel product) {
    if (_isDisposed) return;
    
    Get.dialog(
      _buildProductDetailDialog(product),
      barrierDismissible: true,
    );
  }

  /// Builds the product detail dialog content
  Widget _buildProductDetailDialog(ProductModel product) {
    final isExpired = product.isExpired;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with product part number
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isExpired 
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFF4A00E0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: isExpired ? Colors.red : const Color(0xFF4A00E0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.partNumber,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.red : const Color(0xFF1A202C),
                        ),
                      ),
                      if (isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'EXPIRED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Product details
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDetailRow('Description', product.description),
                    _buildDetailRow('Location', product.location),
                    _buildDetailRow('Quantity', '${product.quantity}'),
                    _buildDetailRow('Batch Number', product.batchNumber.toString()), // Fixed: convert int to string
                    _buildDetailRow('Expiry Date', product.formattedExpiryDate),
                    // Removed updatedOn reference as it doesn't exist in ProductModel
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a detail row for the product dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A202C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Proper employee logout that clears all authentication data
  Future<void> logout() async {
    try {
      print('🔄 EmployeeDashboardController: Starting employee logout...');
      
      // Get the AuthController and use its comprehensive logout method
      final authController = Get.find<AuthController>();
      
      // 🔧 ENHANCED: Use AuthController's logout method with additional employee-specific cleanup
      // This properly clears:
      // - User data from memory (authController.user.value = null)
      // - All SharedPreferences data (including employee session data)
      // - Disposes related controllers
      // - Shows success message
      // - Navigates to role selection
      await authController.logout();
      
      print('✅ EmployeeDashboardController: Employee logout completed successfully');
      
    } catch (e) {
      print('❌ EmployeeDashboardController: Error during logout - $e');
      
      // 🔧 FALLBACK: Manual cleanup if AuthController logout fails
      try {
        final authController = Get.find<AuthController>();
        
        // Clear user data from memory
        authController.user.value = null;
        
        // Clear all stored preferences (critical for preventing auto-login)
        await authController.clearUserPrefs();
        
        // Clear any additional session data
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Show success message
        SafeNavigation.safeSnackbar(
          title: 'Logout Successful', 
          message: 'You have been logged out successfully',
          snackPosition: SnackPosition.BOTTOM, 
          duration: const Duration(seconds: 2),
        );
        
        // Navigate to role selection
        Future.delayed(const Duration(milliseconds: 300), () {
          SafeNavigation.forceResetNavigation();
        });
        
        print('✅ EmployeeDashboardController: Fallback logout completed');
        
      } catch (fallbackError) {
        print('❌ EmployeeDashboardController: Fallback logout also failed - $fallbackError');
        
        // Last resort: Just navigate away
        SafeNavigation.forceResetNavigation();
      }
    }
  }

  // ==================== DATA PROCESSING METHODS ====================

  /// Processes raw product data into ProductModel objects
  List<ProductModel> _processProductData(List<Map<String, dynamic>> productList) {
    final productModels = <ProductModel>[];
    
    for (final productData in productList) {
      try {
        if (_isValidProductData(productData)) {
          final product = ProductModel.fromJson(productData);
          productModels.add(product);
        }
      } catch (e) {
        print('⚠️ Error parsing product data: $e');
        // Continue with other products instead of failing completely
      }
    }
    
    return productModels;
  }

  /// Validates if product data contains required fields
  bool _isValidProductData(Map<String, dynamic> data) {
    try {
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

  /// Updates the product list with new data
  void _updateProductList(List<ProductModel> productModels) {
    if (!_isDisposed) {
      products.value = productModels;
    }
  }

  // ==================== ERROR HANDLING METHODS ====================

  /// Handles errors that occur during product fetching
  void _handleFetchError(dynamic error) {
    print('❌ EmployeeDashboardController: Error fetching products: $error');
    
    if (!_isDisposed) {
      final errorMsg = _getErrorMessage(error);
      _setError(errorMsg);
      _showErrorMessage(errorMsg);
    }
  }

  /// Gets user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().replaceAll('Exception: ', '');
    
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please check your internet connection.';
    } else if (errorStr.contains('Network') || errorStr.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('token') || errorStr.contains('authentication')) {
      return 'Authentication error. Please login again.';
    } else if (errorStr.contains('server') || errorStr.contains('backend')) {
      return 'Server error. Please try again later.';
    } else {
      return errorStr.isEmpty ? 'An unexpected error occurred' : errorStr;
    }
  }

  // ==================== STATE MANAGEMENT HELPERS ====================

  /// Sets loading state safely
  void _setLoadingState(bool loading) {
    if (!_isDisposed) {
      isLoading.value = loading;
    }
  }

  /// Sets error state
  void _setError(String message) {
    if (!_isDisposed) {
      errorMessage.value = message;
      hasError.value = message.isNotEmpty;
    }
  }

  /// Clears error state
  void _clearError() {
    if (!_isDisposed) {
      errorMessage.value = '';
      hasError.value = false;
    }
  }

  // ==================== UI FEEDBACK METHODS ====================

  /// Shows error message to user
  void _showErrorMessage(String message) {
    if (!_isDisposed) {
      SafeNavigation.safeSnackbar(
        title: 'Error',
        message: message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        duration: const Duration(seconds: 4),
      );
    }
  }
}
