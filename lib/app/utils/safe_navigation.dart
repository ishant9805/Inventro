import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SafeNavigation {
  /// Safely navigate back, handling any overlay or snackbar issues
  static void safeBack({dynamic result}) {
    try {
      // Check if there's an active snackbar or overlay
      if (Get.isSnackbarOpen) {
        // Close snackbar first, then navigate back after a brief delay
        Get.closeCurrentSnackbar();
        Future.delayed(const Duration(milliseconds: 100), () {
          _performBack(result);
        });
      } else if (Get.isOverlaysOpen) {
        // Close any open overlays first
        Get.closeAllSnackbars();
        Future.delayed(const Duration(milliseconds: 100), () {
          _performBack(result);
        });
      } else {
        // Safe to navigate back immediately
        _performBack(result);
      }
    } catch (e) {
      // Fallback: force navigation using Navigator if GetX fails
      print('GetX navigation failed, using Navigator fallback: $e');
      try {
        Navigator.of(Get.context!).pop(result);
      } catch (navigatorError) {
        print('Navigator fallback also failed: $navigatorError');
      }
    }
  }

  static void _performBack(dynamic result) {
    try {
      // Check if we can pop using Navigator instead of Get.canPop()
      if (Get.context != null && Navigator.canPop(Get.context!)) {
        Get.back(result: result);
      } else {
        // If can't pop, go to a safe route
        Get.offAllNamed('/dashboard');
      }
    } catch (e) {
      print('Error in _performBack: $e');
      // Final fallback
      try {
        if (Get.context != null) {
          Navigator.of(Get.context!).pop(result);
        }
      } catch (navigatorError) {
        print('Final Navigator fallback failed: $navigatorError');
        // Last resort - try to navigate to dashboard
        try {
          Get.offAllNamed('/dashboard');
        } catch (finalError) {
          print('All navigation methods failed: $finalError');
        }
      }
    }
  }

  /// Safe snackbar that won't interfere with navigation
  static void safeSnackbar({
    required String title,
    required String message,
    SnackPosition? snackPosition,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
  }) {
    try {
      // Close any existing snackbar first
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      
      // Small delay to ensure cleanup
      Future.delayed(const Duration(milliseconds: 50), () {
        Get.snackbar(
          title,
          message,
          snackPosition: snackPosition ?? SnackPosition.BOTTOM,
          backgroundColor: backgroundColor,
          colorText: colorText,
          duration: duration ?? const Duration(seconds: 3),
        );
      });
    } catch (e) {
      print('Error showing snackbar: $e');
    }
  }
}