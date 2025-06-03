import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';
import '../../controller/add_product_controller.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final AddProductController controller = Get.put(AddProductController());

  @override
  Widget build(BuildContext context) {
    controller.updatedOnController.text = "01/06/2025";

    const List<Color> baseColors = [
      Color(0xFF4A00E0),
      Color(0xFF00C3FF),
      Color(0xFF8F00FF),
    ];
    final List<Color> lightColors = baseColors.map((c) => c.withAlpha(170)).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Get.offAllNamed(AppRoutes.dashboard);
          },
          tooltip: "Back to Dashboard",
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: lightColors,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(210),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Product',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller.partNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Part Number',
                      border: UnderlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller.descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: UnderlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller.locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: UnderlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller.quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: UnderlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller.batchNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Number',
                      border: UnderlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.expiryDateController.text =
                            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: controller.expiryDateController,
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'DD / MM / YYYY',
                          hintStyle: TextStyle(color: Colors.black38),
                          border: UnderlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller.updatedOnController,
                    decoration: const InputDecoration(
                      labelText: 'Updated On',
                      hintText: 'DD / MM / YYYY',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: UnderlineInputBorder(),
                    ),
                    readOnly: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 28),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.addProduct(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: const Color(0xFF4A00E0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Add Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
