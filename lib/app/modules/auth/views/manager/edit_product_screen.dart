import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import '../../controller/edit_product_controller.dart';
import 'widgets/edit_product_header.dart';
import 'widgets/edit_product_form.dart';

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller from GetX dependency injection (managed by binding)
    final controller = Get.find<EditProductController>();
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Obx(() {
            if (!controller.isInitialized.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
                ),
              );
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EditProductHeader(),
                  const SizedBox(height: 32),
                  EditProductForm(controller: controller),
                ],
              ),
            );
          }),
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
        tooltip: "Back to Dashboard",
      ),
      title: const Text(
        'Edit Product',
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