import 'package:flutter/material.dart';

/// Reusable screen layout wrapper for product management screens
class ProductScreenLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? customPadding;
  final Color? backgroundColor;
  final bool dismissKeyboardOnTap;

  const ProductScreenLayout({
    super.key,
    required this.child,
    this.customPadding,
    this.backgroundColor,
    this.dismissKeyboardOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      child: SingleChildScrollView(
        padding: customPadding ?? const EdgeInsets.all(24.0),
        child: child,
      ),
    );

    if (dismissKeyboardOnTap) {
      content = GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF8FAFC),
      body: content,
    );
  }
}