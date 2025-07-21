import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import '../../controller/add_employee_controller.dart';
import 'widgets/employee_widgets/add_employee_header.dart';
import 'widgets/employee_widgets/add_employee_form.dart';

class AddEmployeeScreen extends StatelessWidget {
  AddEmployeeScreen({super.key});

  final AddEmployeeController controller = Get.put(AddEmployeeController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AddEmployeeHeader(controller: controller),
                const SizedBox(height: 32),
                AddEmployeeForm(controller: controller),
              ],
            ),
          ),
        ),
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
        tooltip: "Back to Employee List",
      ),
      title: const Text(
        'Add Employee',
        style: TextStyle(
          color: Color(0xFF1A202C),
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }
}
