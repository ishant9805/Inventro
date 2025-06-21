import 'package:flutter/material.dart';

class ExpiryDatePicker extends StatefulWidget {
  final TextEditingController controller;

  const ExpiryDatePicker({
    super.key,
    required this.controller,
  });

  @override
  State<ExpiryDatePicker> createState() => _ExpiryDatePickerState();
}

class _ExpiryDatePickerState extends State<ExpiryDatePicker> {
  @override
  void initState() {
    super.initState();
    // Listen to controller changes to rebuild the widget
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expiry Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF4A00E0),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.controller.text.isEmpty
                        ? 'Select expiry date'
                        : widget.controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: widget.controller.text.isEmpty
                          ? Colors.grey[400]
                          : const Color(0xFF1A202C),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A00E0),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A202C),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      widget.controller.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }
}