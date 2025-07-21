import 'package:flutter/material.dart';

/// Company ID input section with validation button
class CompanyIdInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onValidate;

  const CompanyIdInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.business),
              labelText: 'Company ID',
              hintText: 'Enter company ID to join',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Company ID is required';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onValidate,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search, size: 18),
            label: const Text('Validate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}