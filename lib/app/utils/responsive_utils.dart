import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  // Responsive padding based on screen width
  static double getPadding(BuildContext context, {double factor = 0.04}) {
    return screenWidth(context) * factor;
  }
  
  // Responsive margin
  static double getMargin(BuildContext context, {double factor = 0.03}) {
    return screenWidth(context) * factor;
  }
  
  // Responsive font size
  static double getFontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width <= 360) return baseSize * 0.85; // Small phones
    if (width <= 414) return baseSize; // Medium phones
    return baseSize * 1.1; // Large phones/tablets
  }
  
  // Responsive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width <= 360) return baseSize * 0.9;
    if (width <= 414) return baseSize;
    return baseSize * 1.1;
  }
  
  // Check if it's a small screen
  static bool isSmallScreen(BuildContext context) => screenWidth(context) <= 360;
  
  // Check if it's a large screen
  static bool isLargeScreen(BuildContext context) => screenWidth(context) >= 450;
  
  // Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    final width = screenWidth(context);
    if (width <= 360) return baseSpacing * 0.8;
    if (width <= 414) return baseSpacing;
    return baseSpacing * 1.2;
  }
}