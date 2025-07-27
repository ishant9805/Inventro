import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/employee_dashboard_controller.dart';
import '../../../controller/auth_controller.dart';
import 'widgets/employee_dashboard_app_bar.dart';
import 'widgets/employee_product_list.dart';
import 'widgets/employee_search_bar.dart';
import 'widgets/employee_dashboard_background.dart';

/// Employee Dashboard - Main dashboard view for employees
/// Shows company products in a clean, read-only interface with search functionality
class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeeDashboardController controller = Get.put(EmployeeDashboardController());
    final AuthController authController = Get.find<AuthController>();
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: EmployeeDashboardAppBar(authController: authController),
        body: EmployeeDashboardBackground(
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.refreshProducts,
              color: const Color(0xFF4A00E0),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: EmployeeSearchBar(controller: controller),
                  ),
                  
                  // Product List
                  Expanded(
                    child: EmployeeProductList(controller: controller),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}