import 'package:get/get.dart';
import '../controller/employee_dashboard_controller.dart';

class EmployeeDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeDashboardController>(
      () => EmployeeDashboardController(),
      fenix: true,
    );
  }
}