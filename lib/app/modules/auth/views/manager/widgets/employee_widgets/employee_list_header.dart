import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/employee_list_controller.dart';
// import 'package:inventro/app/modules/auth/controller/auth_controller.dart';

/// Header section showing team overview with employee count and statistics
class EmployeeListHeader extends StatelessWidget {
  final EmployeeListController controller;

  const EmployeeListHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF00C3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Team Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Text(
                  '${controller.employees.length} total employees • ${controller.filteredEmployees.length} shown',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                )),
              ],
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withOpacity(0.2),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Obx(() {
          //     // Get company limit from AuthController
          //     final authController = Get.find<AuthController>();
          //     final companyLimit = authController.user.value?.company?.size ?? 
          //                        authController.user.value?.companySize ?? 
          //                        50;
              
          //     return Text(
          //       'Employees: ${controller.employees.length}',
          //       style: const TextStyle(
          //         color: Colors.white,
          //         fontSize: 14,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     );
          //   }),
          // ),
        ],
      ),
    );
  }
}