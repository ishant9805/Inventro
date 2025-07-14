import 'package:get/get.dart';
import '../controller/edit_product_controller.dart';

class EditProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProductController>(
      () => EditProductController(),
      fenix: true, // Allows the controller to be recreated if needed
    );
  }
}