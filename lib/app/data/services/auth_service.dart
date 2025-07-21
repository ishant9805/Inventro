import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import '../../modules/auth/controller/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for token validation results to distinguish between different failure types
enum TokenValidationResult {
  valid,
  invalid,
  networkError,
  inconclusive
}

class AuthService {
  final String baseUrl = 'https://backend.tecsohub.com/';

  // Helper method to get auth headers WITHOUT validation (for immediate post-login use)
  Map<String, String> getAuthHeaders() {
    final authController = Get.find<AuthController>();
    final token = authController.user.value?.token;
    
    final headers = {'Content-Type': 'application/json'};
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// FIXED: Validates if the current token is still valid with proper error handling
  /// Only validates tokens that are older than grace period to avoid immediate post-login validation
  Future<bool> isTokenValid() async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.user.value?.token;
      
      if (token == null || token.isEmpty) {
        print('🔑 AuthService: No token found');
        return false;
      }

      // CRITICAL FIX: Extend grace period to prevent race conditions
      final tokenAge = await getTokenAgeInSeconds();
      if (tokenAge < 120) { // Increased from 30s to 2 minutes
        print('🔑 AuthService: Token is fresh (${tokenAge}s old), skipping validation to prevent race conditions');
        return true; // Assume valid for fresh tokens
      }

      // FIXED: Try multiple endpoints to validate token robustly
      final validationEndpoints = [
        '${baseUrl}user/profile',
        '${baseUrl}user/me', 
        '${baseUrl}companies/', // Fallback endpoint
      ];

      for (String endpoint in validationEndpoints) {
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 8)); // Reduced timeout

          // FIXED: Proper status code handling
          if (response.statusCode == 200) {
            print('🔑 AuthService: Token validation - VALID (200) via $endpoint');
            return true;
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            print('🔑 AuthService: Token validation - INVALID (${response.statusCode}) via $endpoint');
            return false;
          }
          // For other status codes (404, 500, etc.), try next endpoint
          print('🔑 AuthService: Endpoint $endpoint returned ${response.statusCode}, trying next...');
          
        } catch (e) {
          print('🔑 AuthService: Error testing endpoint $endpoint - $e, trying next...');
          continue; // Try next endpoint
        }
      }

      // FIXED: If all endpoints fail with non-auth errors, assume token is valid
      // This prevents false logouts due to server issues
      print('🔑 AuthService: All validation endpoints failed with non-auth errors, assuming token valid');
      return true;
      
    } catch (e) {
      print('🔑 AuthService: Token validation failed - $e, assuming token valid to prevent false logouts');
      return true; // Assume valid on network errors to avoid false positives
    }
  }

  /// Get token age in seconds
  Future<int> getTokenAgeInSeconds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString('token_timestamp');
      
      if (timestampStr == null) return 999999; // Very old if no timestamp
      
      final tokenTime = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final ageInSeconds = now.difference(tokenTime).inSeconds;
      
      return ageInSeconds;
    } catch (e) {
      print('⚠️ AuthService: Error checking token age - $e');
      return 999999; // Assume very old on error
    }
  }

  /// Handles authentication errors and redirects to login if needed
  Future<void> handleAuthError() async {
    try {
      print('🔑 AuthService: Handling authentication error - clearing session');
      
      final authController = Get.find<AuthController>();
      await authController.clearUserPrefs();
      authController.user.value = null;
      
      // Clear any cached data
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (e) {
        print('⚠️ AuthService: Error clearing preferences - $e');
      }
      
      // Navigate to login after a short delay to avoid navigation conflicts
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.currentRoute != '/role-selection') {
          Get.offAllNamed('/role-selection');
        }
      });
      
    } catch (e) {
      print('❌ AuthService: Error handling auth error - $e');
    }
  }

  /// Enhanced token validation for API requests with smarter logic
  Future<bool> validateTokenForRequest() async {
    try {
      // First check if we have a token
      final authController = Get.find<AuthController>();
      final token = authController.user.value?.token;
      
      if (token == null || token.isEmpty) {
        print('🔑 AuthService: No token available for request');
        await handleAuthError();
        return false;
      }

      // For fresh tokens (< 5 minutes), skip validation to avoid race conditions
      final tokenAgeMinutes = (await getTokenAgeInSeconds()) / 60;
      if (tokenAgeMinutes < 5) {
        print('🔑 AuthService: Token is fresh (${tokenAgeMinutes.toStringAsFixed(1)} min), skipping validation');
        return true;
      }

      // Only validate older tokens
      final isValid = await isTokenValid();
      
      if (!isValid) {
        print('🔑 AuthService: Token expired or invalid');
        await handleAuthError();
        return false;
      }

      return true;
    } catch (e) {
      print('❌ AuthService: Error validating token for request - $e');
      // Don't clear session on validation errors - could be network issues
      return true; // Allow request to proceed
    }
  }

  // REGISTER
  Future<bool> registerAdmin(Map<String, dynamic> body) async {
    final endpoint = path.join(baseUrl, 'register/manager');
    final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
    //print(uri);
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    //print(response.statusCode);

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Registration failed',
      );
    }
  }

  // LOGIN
  Future<UserModel> login(String email, String password) async {
    final endpoint = path.join(baseUrl, 'token');
    final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
    
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 30));
      
      print('🔐 AuthService: Login response - ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Store token with timestamp for future validation
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token_timestamp', DateTime.now().toIso8601String());
        
        return UserModel(
          name: 'User', // Default or from response if available
          email: email,
          role: 'manager', // Default or from response if available
          token: data['access_token'],
          id: data['id'], // Assuming user_id is returned in the response
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Login failed');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Login request timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  // FETCH USER PROFILE with enhanced error handling
  Future<UserModel> fetchUserProfile(String token, {String? fallbackRole}) async {
    final endpoint = path.join(baseUrl, 'user/profile');
    final uri = Uri.parse(endpoint.replaceAll('\\', '/'));
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(const Duration(seconds: 30));
      
      print('👤 AuthService: Profile fetch - ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Use fallbackRole if role is missing
        return UserModel.fromJson({
          ...data,
          'token': token,
        }, fallbackRole: fallbackRole);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load user profile (${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Profile request timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  /// Check if token is older than specified hours
  Future<bool> isTokenOlderThan(int hours) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString('token_timestamp');
      
      if (timestampStr == null) return true;
      
      final tokenTime = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(tokenTime).inHours;
      
      print('🕐 AuthService: Token age - $difference hours');
      return difference >= hours;
    } catch (e) {
      print('⚠️ AuthService: Error checking token age - $e');
      return true; // Assume old if we can't determine
    }
  }

  /// NEW: Conservative token validation that distinguishes between auth failures and network errors
  /// This method is specifically designed to prevent false session expiration messages
  Future<TokenValidationResult> validateTokenConservatively() async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.user.value?.token;
      
      if (token == null || token.isEmpty) {
        print('🔑 AuthService: No token found for conservative validation');
        return TokenValidationResult.invalid;
      }

      print('🔑 AuthService: Starting conservative token validation...');
      
      // Try multiple validation attempts with different endpoints
      final validationEndpoints = [
        '${baseUrl}user/profile',
        '${baseUrl}user/me', 
        '${baseUrl}companies/', // Fallback endpoint
      ];

      int successCount = 0;
      int authFailureCount = 0;
      int networkErrorCount = 0;

      for (String endpoint in validationEndpoints) {
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            successCount++;
            print('🔑 AuthService: Conservative validation - SUCCESS (200) via $endpoint');
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            authFailureCount++;
            print('🔑 AuthService: Conservative validation - AUTH FAILURE (${response.statusCode}) via $endpoint');
          } else {
            networkErrorCount++;
            print('🔑 AuthService: Conservative validation - SERVER ERROR (${response.statusCode}) via $endpoint');
          }
          
        } catch (e) {
          networkErrorCount++;
          print('🔑 AuthService: Conservative validation - NETWORK ERROR via $endpoint: $e');
        }
        
        // Small delay between requests to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Analyze results conservatively
      print('🔑 AuthService: Conservative validation results - Success: $successCount, Auth Failures: $authFailureCount, Network Errors: $networkErrorCount');

      if (successCount > 0) {
        // At least one successful validation
        return TokenValidationResult.valid;
      } else if (authFailureCount >= 2) {
        // Multiple auth failures indicate token is truly invalid
        return TokenValidationResult.invalid;
      } else if (authFailureCount == 1 && networkErrorCount == 0) {
        // Single auth failure with no network errors might be invalid
        return TokenValidationResult.invalid;
      } else {
        // Mostly network errors or inconclusive results
        if (networkErrorCount >= 2) {
          return TokenValidationResult.networkError;
        } else {
          return TokenValidationResult.inconclusive;
        }
      }
      
    } catch (e) {
      print('❌ AuthService: Error during conservative token validation - $e');
      return TokenValidationResult.networkError;
    }
  }
}
