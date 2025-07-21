import 'package:get/get.dart';
import '../controller/add_employee_controller.dart';

class AddEmployeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddEmployeeController>(
      () => AddEmployeeController(),
      fenix: true,
    );
  }
}