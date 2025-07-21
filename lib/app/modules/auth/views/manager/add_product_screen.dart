import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/add_product_controller.dart';
import 'widgets/product_widgets/add_product_header.dart';
import 'widgets/product_widgets/add_product_form.dart';
import 'widgets/product_widgets/product_screen_app_bar.dart';
import 'widgets/product_widgets/product_screen_layout.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final AddProductController controller = Get.put(AddProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProductScreenAppBar(title: 'Add Product'),
      body: ProductScreenLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AddProductHeader(),
            const SizedBox(height: 32),
            AddProductForm(controller: controller),
          ],
        ),
      ),
    );
  }
}
