import 'package:get/get.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
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
      SafeNavigation.safeSnackbar(
        title: 'Error', 
        message: 'Failed to load products: ${e.toString().replaceAll('Exception: ', '')}'
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProducts() async {
    await fetchProducts();
  }

  void logout() {
    // Optionally clear any employee-specific state here
    SafeNavigation.safeSnackbar(
      title: 'Logout Successful', 
      message: 'You have been logged out successfully',
      snackPosition: SnackPosition.BOTTOM, 
      duration: const Duration(seconds: 2),
    );
    
    // Navigate with delay to avoid conflicts
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.offAllNamed('/role-selection');
    });
  }
}
