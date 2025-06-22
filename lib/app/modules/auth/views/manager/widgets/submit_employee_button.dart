import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/add_employee_controller.dart';


class SubmitEmployeeButton extends StatefulWidget {
  final AddEmployeeController controller;

  const SubmitEmployeeButton({
    super.key,
    required this.controller,
  });

  @override
  State<SubmitEmployeeButton> createState() => _SubmitEmployeeButtonState();
}

class _SubmitEmployeeButtonState extends State<SubmitEmployeeButton> {
  @override
  void initState() {
    super.initState();
    // Listen to all text controllers for changes
    widget.controller.nameController.addListener(_updateButtonState);
    widget.controller.emailController.addListener(_updateButtonState);
    widget.controller.pinController.addListener(_updateButtonState);
    widget.controller.confirmPinController.addListener(_updateButtonState);
    widget.controller.departmentController.addListener(_updateButtonState);
    widget.controller.phoneController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    // Remove listeners to prevent memory leaks
    widget.controller.nameController.removeListener(_updateButtonState);
    widget.controller.emailController.removeListener(_updateButtonState);
    widget.controller.pinController.removeListener(_updateButtonState);
    widget.controller.confirmPinController.removeListener(_updateButtonState);
    widget.controller.departmentController.removeListener(_updateButtonState);
    widget.controller.phoneController.removeListener(_updateButtonState);
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
                      Icons.person_add,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Employee',
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
    return widget.controller.nameController.text.trim().isNotEmpty &&
           widget.controller.emailController.text.trim().isNotEmpty &&
           widget.controller.pinController.text.trim().isNotEmpty &&
           widget.controller.confirmPinController.text.trim().isNotEmpty &&
           widget.controller.departmentController.text.trim().isNotEmpty &&
           widget.controller.phoneController.text.trim().isNotEmpty;
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
            Text('Adding employee...'),
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
    
    await widget.controller.addEmployee();
  }
}