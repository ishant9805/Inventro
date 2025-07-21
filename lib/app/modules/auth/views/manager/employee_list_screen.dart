import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import '../../controller/employee_list_controller.dart';
import 'widgets/employee_widgets/employee_list_header.dart';
import 'widgets/employee_widgets/employee_search_bar.dart';
import 'widgets/employee_widgets/employee_list_content.dart';

class EmployeeListScreen extends StatelessWidget {
  EmployeeListScreen({super.key});

  final EmployeeListController controller = Get.put(EmployeeListController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                EmployeeListHeader(controller: controller),
                const SizedBox(height: 24),
                EmployeeSearchBar(controller: controller),
                const SizedBox(height: 24),
                Expanded(
                  child: EmployeeListContent(controller: controller),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A00E0)),
        onPressed: () => SafeNavigation.safeBack(),
        tooltip: "Back to Dashboard",
      ),
      title: const Text(
        'Employee Management',
        style: TextStyle(
          color: Color(0xFF1A202C),
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF4A00E0)),
          onPressed: controller.refreshEmployees,
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed(AppRoutes.addEmployee),
      backgroundColor: const Color(0xFF4A00E0),
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.person_add),
      label: const Text(
        'Add Employee',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
