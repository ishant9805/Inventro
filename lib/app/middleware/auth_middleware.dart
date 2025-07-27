import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/auth/controller/auth_controller.dart';
import '../data/models/user_model.dart';
import '../utils/safe_navigation.dart';

/// Middleware to protect routes that require authentication
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (route == null) return null;
    
    print('🛡️ AuthMiddleware: Checking access to route: $route');
    
    try {
      // Check if user is authenticated
      bool isAuthenticated = false;
      UserModel? currentUser;
      
      try {
        final authController = Get.find<AuthController>();
        currentUser = authController.user.value;
        isAuthenticated = currentUser != null && 
                         currentUser.token.isNotEmpty;
      } catch (e) {
        print('⚠️ AuthMiddleware: AuthController not found - $e');
        isAuthenticated = false;
      }

      if (!isAuthenticated) {
        print('🚫 AuthMiddleware: Access denied to $route - user not authenticated');
        
        // Show authentication required message
        Future.delayed(const Duration(milliseconds: 100), () {
          SafeNavigation.safeSnackbar(
            title: 'Authentication Required',
            message: 'Please login to access this feature',
            backgroundColor: Colors.orange.withOpacity(0.1),
            colorText: Colors.orange[800],
            duration: const Duration(seconds: 3),
          );
        });
        
        return const RouteSettings(name: '/role-selection');
      }

      // For employee routes, check if user is actually an employee
      if (_isEmployeeRoute(route)) {
        if (currentUser?.role.toLowerCase() != 'employee') {
          print('🚫 AuthMiddleware: Access denied to employee route $route - user is not employee');
          
          Future.delayed(const Duration(milliseconds: 100), () {
            SafeNavigation.safeSnackbar(
              title: 'Access Denied',
              message: 'This feature is only available for employees',
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red[800],
              duration: const Duration(seconds: 3),
            );
          });
          
          return const RouteSettings(name: '/role-selection');
        }
      }

      // For manager routes, check if user is actually a manager/admin
      if (_isManagerRoute(route)) {
        final userRole = currentUser?.role.toLowerCase();
        if (userRole != 'manager' && userRole != 'admin') {
          print('🚫 AuthMiddleware: Access denied to manager route $route - user is not manager');
          
          Future.delayed(const Duration(milliseconds: 100), () {
            SafeNavigation.safeSnackbar(
              title: 'Access Denied',
              message: 'This feature is only available for managers',
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red[800],
              duration: const Duration(seconds: 3),
            );
          });
          
          return const RouteSettings(name: '/role-selection');
        }
      }

      print('✅ AuthMiddleware: Access granted to $route');
      return null; // Allow navigation to continue
      
    } catch (e) {
      print('❌ AuthMiddleware: Error in route protection - $e');
      return const RouteSettings(name: '/role-selection');
    }
  }

  /// Check if route is employee-specific
  bool _isEmployeeRoute(String route) {
    const employeeRoutes = [
      '/employee-dashboard',
    ];
    return employeeRoutes.contains(route);
  }

  /// Check if route is manager-specific
  bool _isManagerRoute(String route) {
    const managerRoutes = [
      '/dashboard',
      '/add-product',
      '/edit-product',
      '/add-employee',
      '/employee-list',
      '/manager-profile',
    ];
    return managerRoutes.contains(route);
  }
}

/// Middleware to prevent authenticated users from accessing login/register screens
/// 🔧 FIXED: Allow authenticated users to access login screens for account switching
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (route == null) return null;
    
    print('🛡️ GuestMiddleware: Checking guest access to route: $route');
    
    try {
      // 🔧 FIXED: Don't redirect authenticated users from login screens
      // This allows employees to manually logout and login again without being auto-redirected
      final guestOnlyRoutes = [
        '/role-selection',
        '/register',
        '/manager-registration',
        '/company-creation',
      ];
      
      // Check if this is a guest-only route (not login screens)
      if (!guestOnlyRoutes.contains(route)) {
        print('✅ GuestMiddleware: Login screens are accessible to all users');
        return null; // Allow access to login screens even for authenticated users
      }
      
      // Check if user is authenticated only for guest-only routes
      bool isAuthenticated = false;
      UserModel? currentUser;
      
      try {
        final authController = Get.find<AuthController>();
        currentUser = authController.user.value;
        isAuthenticated = currentUser != null && 
                         currentUser.token.isNotEmpty;
      } catch (e) {
        isAuthenticated = false;
      }

      if (isAuthenticated && guestOnlyRoutes.contains(route)) {
        print('🔄 GuestMiddleware: User is authenticated, redirecting from guest-only route $route');
        
        // Redirect based on user role for guest-only routes
        final userRole = currentUser?.role.toLowerCase();
        if (userRole == 'employee') {
          return const RouteSettings(name: '/employee-dashboard');
        } else {
          return const RouteSettings(name: '/dashboard');
        }
      }

      print('✅ GuestMiddleware: Access granted to $route');
      return null; // Allow navigation to continue
      
    } catch (e) {
      print('❌ GuestMiddleware: Error in guest protection - $e');
      return null; // Allow navigation to continue on error
    }
  }
}