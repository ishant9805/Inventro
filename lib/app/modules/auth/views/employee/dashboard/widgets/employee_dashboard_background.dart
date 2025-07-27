import 'package:flutter/material.dart';

/// Employee Dashboard Background - Provides consistent gradient background for employee dashboard
class EmployeeDashboardBackground extends StatelessWidget {
  final Widget child;

  const EmployeeDashboardBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
          ],
        ),
      ),
      child: child,
    );
  }
}