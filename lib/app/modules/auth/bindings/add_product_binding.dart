import 'package:get/get.dart';
import '../controller/add_product_controller.dart';

class AddProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductController>(
      () => AddProductController(),
      fenix: true,
    );
  }
}