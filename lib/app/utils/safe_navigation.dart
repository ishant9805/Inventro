import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/auth/controller/auth_controller.dart';

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
        // 🔧 FIXED: Smart fallback based on authentication state
        _handleSafeFallbackNavigation();
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
        // 🔧 FIXED: Use smart fallback instead of dashboard
        _handleSafeFallbackNavigation();
      }
    }
  }

  /// Smart fallback navigation based on authentication state
  static void _handleSafeFallbackNavigation() {
    try {
      // Check if user is authenticated
      bool isAuthenticated = false;
      try {
        final authController = Get.find<AuthController>();
        isAuthenticated = authController.user.value != null && 
                         authController.user.value!.token.isNotEmpty;
      } catch (e) {
        // AuthController not found or error - assume not authenticated
        isAuthenticated = false;
      }

      if (isAuthenticated) {
        // User is authenticated, safe to go to dashboard
        print('🔄 SafeNavigation: User authenticated, navigating to dashboard');
        Get.offAllNamed('/dashboard');
      } else {
        // User is not authenticated, go to role selection
        print('🔄 SafeNavigation: User not authenticated, navigating to role selection');
        Get.offAllNamed('/role-selection');
      }
    } catch (finalError) {
      print('All navigation methods failed: $finalError');
      // Absolute last resort - try role selection directly
      try {
        Get.offAllNamed('/role-selection');
      } catch (e) {
        print('Even role-selection navigation failed: $e');
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

  /// Safe navigation with authentication check
  static Future<void> safeNavigateWithAuthCheck(String route, {dynamic arguments}) async {
    try {
      // Check authentication before navigating to protected routes
      if (_isProtectedRoute(route)) {
        bool isAuthenticated = false;
        try {
          final authController = Get.find<AuthController>();
          isAuthenticated = authController.user.value != null && 
                           authController.user.value!.token.isNotEmpty;
        } catch (e) {
          isAuthenticated = false;
        }

        if (!isAuthenticated) {
          print('🚫 SafeNavigation: Blocked navigation to protected route $route - not authenticated');
          safeSnackbar(
            title: 'Authentication Required',
            message: 'Please login to access this feature',
            backgroundColor: Colors.orange.withOpacity(0.1),
            colorText: Colors.orange[800],
          );
          Get.offAllNamed('/role-selection');
          return;
        }
      }

      // Proceed with navigation
      Get.toNamed(route, arguments: arguments);
    } catch (e) {
      print('Error in safe navigation: $e');
      _handleSafeFallbackNavigation();
    }
  }

  /// Check if route requires authentication
  static bool _isProtectedRoute(String route) {
    const protectedRoutes = [
      '/dashboard',
      '/add-product',
      '/edit-product',
      '/add-employee',
      '/employee-list',
      '/manager-profile',
      '/employee-dashboard',
    ];
    return protectedRoutes.contains(route);
  }

  /// Force clear all navigation stacks and go to safe route
  static void forceResetNavigation() {
    try {
      print('🔄 SafeNavigation: Force resetting navigation stack');
      
      // Close all dialogs and overlays
      if (Get.isDialogOpen == true) {
        Get.until((route) => !Get.isDialogOpen!);
      }
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      
      // Clear navigation stack and go to role selection
      Get.offAllNamed('/role-selection');
    } catch (e) {
      print('Error in force reset navigation: $e');
    }
  }
}