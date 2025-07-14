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
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    // Only setState if the widget is still mounted
    if (mounted) {
      setState(() {});
    }
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
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
                if (widget.controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clearDate,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.clear,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Check if widget is still mounted before proceeding
    if (!mounted) return;

    DateTime initialDate = DateTime.now();

    // Try to parse existing date if available
    if (widget.controller.text.isNotEmpty) {
      try {
        final parts = widget.controller.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        print('Error parsing existing date: $e');
        initialDate = DateTime.now();
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A00E0),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    // Check if widget is still mounted and date was picked
    if (mounted && picked != null) {
      widget.controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  void _clearDate() {
    // Check if widget is still mounted before clearing
    if (!mounted) return;

    widget.controller.clear();
  }
}