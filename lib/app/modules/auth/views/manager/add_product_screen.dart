import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final TextEditingController partNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController batchNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController updatedOnController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const List<Color> baseColors = [
      Color(0xFF4A00E0),
      Color(0xFF00C3FF),
      Color(0xFF8F00FF),
    ];
    final List<Color> lightColors = baseColors.map((c) => c.withAlpha(170)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  const SizedBox(height: 22),
                  TextField(
                    controller: partNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Part Number',
                      border: UnderlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: UnderlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: UnderlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: UnderlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: batchNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Number',
                      border: UnderlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: expiryDateController,
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'DD / MM / YY',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: UnderlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: updatedOnController,
                    decoration: const InputDecoration(
                      labelText: 'Updated On',
                      hintText: 'DD / MM / YY',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: UnderlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement add product logic
                      Get.snackbar('Add Product', 'Feature coming soon!');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: const Color(0xFF4A00E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('Add Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
