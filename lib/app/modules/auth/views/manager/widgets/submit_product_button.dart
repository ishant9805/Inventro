import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/add_product_controller.dart';


class SubmitProductButton extends StatefulWidget {
  final AddProductController controller;

  const SubmitProductButton({
    super.key,
    required this.controller,
  });

  @override
  State<SubmitProductButton> createState() => _SubmitProductButtonState();
}

class _SubmitProductButtonState extends State<SubmitProductButton> {
  @override
  void initState() {
    super.initState();
    // Listen to all text controllers for changes
    widget.controller.partNumberController.addListener(_updateButtonState);
    widget.controller.descriptionController.addListener(_updateButtonState);
    widget.controller.locationController.addListener(_updateButtonState);
    widget.controller.quantityController.addListener(_updateButtonState);
    widget.controller.batchNumberController.addListener(_updateButtonState);
    widget.controller.expiryDateController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    // Remove listeners to prevent memory leaks
    widget.controller.partNumberController.removeListener(_updateButtonState);
    widget.controller.descriptionController.removeListener(_updateButtonState);
    widget.controller.locationController.removeListener(_updateButtonState);
    widget.controller.quantityController.removeListener(_updateButtonState);
    widget.controller.batchNumberController.removeListener(_updateButtonState);
    widget.controller.expiryDateController.removeListener(_updateButtonState);
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFormValid = _isFormValid();
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: widget.controller.isLoading.value || !isFormValid
              ? null
              : () => _handleSubmit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A00E0),
            disabledBackgroundColor: Colors.grey[300],
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: widget.controller.isLoading.value ? 0 : 4,
            shadowColor: const Color(0xFF4A00E0).withOpacity(0.3),
          ),
          child: widget.controller.isLoading.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Product',
                      style: TextStyle(
                        color: isFormValid ? Colors.white : Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  bool _isFormValid() {
    return widget.controller.partNumberController.text.trim().isNotEmpty &&
           widget.controller.descriptionController.text.trim().isNotEmpty &&
           widget.controller.locationController.text.trim().isNotEmpty &&
           widget.controller.quantityController.text.trim().isNotEmpty &&
           widget.controller.batchNumberController.text.trim().isNotEmpty &&
           widget.controller.expiryDateController.text.trim().isNotEmpty;
  }

  Future<void> _handleSubmit(BuildContext context) async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Show loading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text('Adding product...'),
          ],
        ),
        backgroundColor: const Color(0xFF4A00E0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    await widget.controller.addProduct();
  }
}