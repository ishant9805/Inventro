import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Import for TokenValidationResult enum

class SessionRecoveryService {
  final String baseUrl = 'https://backend.tecsohub.com/';
  static SessionRecoveryService? _instance;
  
  factory SessionRecoveryService() {
    _instance ??= SessionRecoveryService._internal();
    return _instance!;
  }
  
  SessionRecoveryService._internal();

  /// Validates session when app resumes after long inactivity
  Future<bool> validateAndRecoverSession() async {
    try {
      print('🔄 SessionRecoveryService: Validating session on app resume...');
      
      final authController = Get.find<AuthController>();
      final currentUser = authController.user.value;
      
      // Check if user exists and has a token
      if (currentUser?.token == null || currentUser!.token.isEmpty) {
        print('🔄 SessionRecoveryService: No user session found or token is empty');
        return false;
      }

      // Check how long the app has been inactive
      final inactivityHours = await _getAppInactivityHours();
      print('🕐 SessionRecoveryService: App was inactive for $inactivityHours hours');
      
      // FIXED: More conservative approach - only validate for very long inactivity periods
      // This prevents false session expiration messages from temporary network issues
      if (inactivityHours >= 6) { // Increased from 1 hour to 6 hours
        print('🔑 SessionRecoveryService: Long inactivity detected (>6h), validating token...');
        
        // Use conservative validation method that distinguishes between auth and network errors
        final validationResult = await _validateTokenConservatively(currentUser.token);
        
        if (validationResult == TokenValidationResult.invalid) {
          print('🔑 SessionRecoveryService: Token confirmed invalid, triggering session recovery...');
          await _handleExpiredSession();
          return false;
        } else if (validationResult == TokenValidationResult.networkError) {
          print('⚠️ SessionRecoveryService: Network error during validation, assuming session valid');
          await _updateLastActivityTimestamp();
          return true; // Assume valid on network errors
        } else {
          print('✅ SessionRecoveryService: Token valid or inconclusive after long inactivity');
          await _updateLastActivityTimestamp();
          return true;
        }
      } else {
        print('✅ SessionRecoveryService: Short inactivity (<6h), session assumed valid');
        await _updateLastActivityTimestamp();
        return true;
      }
      
    } catch (e) {
      print('❌ SessionRecoveryService: Error during session validation - $e');
      // FIXED: Don't trigger session expiration on validation errors
      print('⚠️ SessionRecoveryService: Assuming session valid due to validation error');
      await _updateLastActivityTimestamp();
      return true;
    }
  }

  /// UPDATED: Conservative token validation method for session recovery
  Future<TokenValidationResult> _validateTokenConservatively(String token) async {
    try {
      print('🔑 SessionRecoveryService: Starting conservative token validation...');
      
      // Single validation attempt with proper error handling
      final response = await http.get(
        Uri.parse('${baseUrl}user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('🔑 SessionRecoveryService: Token validation - VALID (200)');
        return TokenValidationResult.valid;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('🔑 SessionRecoveryService: Token validation - INVALID (${response.statusCode})');
        return TokenValidationResult.invalid;
      } else {
        print('🔑 SessionRecoveryService: Token validation - SERVER ERROR (${response.statusCode})');
        return TokenValidationResult.networkError;
      }
    } catch (e) {
      print('🔑 SessionRecoveryService: Token validation - NETWORK ERROR: $e');
      return TokenValidationResult.networkError;
    }
  }

  /// Gets app inactivity duration in hours
  Future<int> _getAppInactivityHours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivityStr = prefs.getString('last_activity_timestamp');
      
      if (lastActivityStr == null) {
        return 999; // Assume long inactivity if no timestamp
      }
      
      final lastActivity = DateTime.parse(lastActivityStr);
      final now = DateTime.now();
      final inactivityHours = now.difference(lastActivity).inHours;
      
      return inactivityHours;
    } catch (e) {
      print('⚠️ SessionRecoveryService: Error calculating inactivity - $e');
      return 999; // Assume long inactivity on error
    }
  }

  /// Updates the last activity timestamp
  Future<void> _updateLastActivityTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_activity_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      print('⚠️ SessionRecoveryService: Error updating activity timestamp - $e');
    }
  }

  /// Handles expired session by clearing data and showing appropriate message
  Future<void> _handleExpiredSession() async {
    try {
      print('🔑 SessionRecoveryService: Handling expired session...');
      
      final authController = Get.find<AuthController>();
      
      // Clear user data
      authController.user.value = null;
      await authController.clearUserPrefs();
      
      // Clear all stored preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Show user-friendly message
      Get.snackbar(
        'Session Expired',
        'Your session has expired due to inactivity. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      
      // Navigate to role selection after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (Get.currentRoute != '/role-selection') {
          Get.offAllNamed('/role-selection');
        }
      });
      
    } catch (e) {
      print('❌ SessionRecoveryService: Error handling expired session - $e');
    }
  }

  /// Records user activity for session tracking
  Future<void> recordUserActivity() async {
    await _updateLastActivityTimestamp();
  }

  /// Initializes session tracking on app start
  Future<void> initializeSessionTracking() async {
    await _updateLastActivityTimestamp();
    print('✅ SessionRecoveryService: Session tracking initialized');
  }

  /// Cleans up session data on logout
  Future<void> cleanupSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_activity_timestamp');
      print('✅ SessionRecoveryService: Session data cleaned up');
    } catch (e) {
      print('⚠️ SessionRecoveryService: Error cleaning up session - $e');
    }
  }
}