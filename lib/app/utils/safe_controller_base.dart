import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'safe_navigation.dart';

/// A base controller that provides safe navigation and lifecycle management
/// for all controllers that handle navigation, snackbars, and argument passing
abstract class SafeControllerBase extends GetxController {
  bool _isDisposed = false;
  final isInitialized = false.obs;
  
  /// Check if controller is disposed to prevent operations on disposed controllers
  bool get isDisposed => _isDisposed;
  
  /// Safe method to show snackbars that won't interfere with navigation
  void showSafeSnackbar({
    required String title,
    required String message,
    SnackPosition? snackPosition,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
  }) {
    if (!_isDisposed) {
      SafeNavigation.safeSnackbar(
        title: title,
        message: message,
        snackPosition: snackPosition,
        backgroundColor: backgroundColor,
        colorText: colorText,
        duration: duration,
      );
    }
  }
  
  /// Safe method to navigate back
  void safeBack({dynamic result}) {
    if (!_isDisposed) {
      SafeNavigation.safeBack(result: result);
    }
  }
  
  /// Safe method to navigate to a route
  Future<T?>? safeToNamed<T>(String page, {dynamic arguments}) {
    if (!_isDisposed) {
      return Get.toNamed<T>(page, arguments: arguments);
    }
    return null;
  }
  
  /// Safe method to replace all routes
  Future<T?>? safeOffAllNamed<T>(String newRouteName, {dynamic arguments}) {
    if (!_isDisposed) {
      return Get.offAllNamed<T>(newRouteName, arguments: arguments);
    }
    return null;
  }
  
  /// Template method for handling invalid arguments
  void handleInvalidArguments(String errorMessage, String fallbackRoute) {
    if (!_isDisposed) {
      showSafeSnackbar(
        title: 'Error',
        message: errorMessage,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isDisposed) {
          safeOffAllNamed(fallbackRoute);
        }
      });
    }
  }
  
  /// Template method for validation errors
  void showValidationError(String message) {
    if (!_isDisposed) {
      showSafeSnackbar(
        title: 'Validation Error',
        message: message,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange[800],
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  @override
  void onClose() {
    _isDisposed = true;
    super.onClose();
  }
}