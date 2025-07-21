import 'package:get/get.dart';
import '../controller/employee_list_controller.dart';

class EmployeeListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeListController>(
      () => EmployeeListController(),
      fenix: true,
    );
  }
}