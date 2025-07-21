import 'package:flutter/material.dart';

/// Header section with icon, title and description for company creation
class CompanyCreationHeader extends StatelessWidget {
  final List<Color> gradientColors;

  const CompanyCreationHeader({
    super.key,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pull indicator
        Center(
          child: Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Icon container
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A00E0).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.business,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Title
        const Center(
          child: Text(
            'Setup Your Company',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Description
        Center(
          child: Text(
            'Create your company profile to get started with Inventro',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}