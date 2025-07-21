import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/company_service.dart';
import 'dashboard_controller.dart';
import 'employee_list_controller.dart';
import 'add_product_controller.dart';
import 'edit_product_controller.dart';
import 'add_employee_controller.dart';
import 'employee_dashboard_controller.dart';
import 'company_controller.dart';

class AuthController extends GetxController {
  // Input fields for login and registration
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final companyNameController = TextEditingController();
  final numberOfEmployeesController = TextEditingController();

  // Auth state
  final isLoading = false.obs;
  final user = Rxn<UserModel>();
  final isTokenValidating = false.obs;

  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    // FIXED: More conservative delay to ensure proper initialization order
    Future.delayed(const Duration(milliseconds: 1000), () {
      _initializeAuthState();
    });
  }

  /// FIXED: Enhanced initialization with CONSERVATIVE token validation and better error handling
  Future<void> _initializeAuthState() async {
    try {
      print('🔄 AuthController: Initializing auth state...');
      
      // Load user from preferences first
      await loadUserFromPrefs();
      
      // CRITICAL FIX: Only validate token in very specific circumstances
      if (user.value != null) {
        print('🔄 AuthController: User found in storage');
        
        // Check token age to determine if validation is necessary
        final tokenAgeHours = (await _authService.getTokenAgeInSeconds()) / 3600;
        print('🕐 AuthController: Token age - ${tokenAgeHours.toStringAsFixed(1)} hours');
        
        // CONSERVATIVE APPROACH: Only validate tokens older than 24 hours on app launch
        // This prevents false session expiration messages from network issues
        if (tokenAgeHours >= 24) {
          print('🔄 AuthController: Token is very old (>24h), validating with server...');
          await _validateStoredToken();
        } else {
          print('✅ AuthController: Token is recent (<24h), skipping validation to prevent false expiration messages');
          // Still check if we're in a reasonable time frame (< 7 days)
          if (tokenAgeHours >= 168) { // 7 days
            print('⚠️ AuthController: Token is extremely old (>7 days), clearing session quietly');
            await _clearSessionQuietly();
          }
        }
      } else {
        print('🔄 AuthController: No stored user found');
      }
    } catch (e) {
      print('❌ AuthController: Error initializing auth state - $e');
      // FIXED: Only clear data on critical parse errors, not network/validation errors
      if (e.toString().contains('corrupted') || 
          e.toString().contains('parse') || 
          e.toString().contains('FormatException') ||
          e.toString().contains('invalid format')) {
        print('🔧 AuthController: Detected corrupted data, clearing session');
        await _handleInitializationError();
      } else {
        print('⚠️ AuthController: Non-critical error during initialization, keeping session intact');
      }
    }
  }

  /// FIXED: More conservative token validation that only triggers on confirmed authentication failure
  Future<void> _validateStoredToken() async {
    if (user.value?.token == null) return;
    
    try {
      isTokenValidating.value = true;
      print('🔑 AuthController: Validating stored token...');
      
      // Validate token with server using conservative approach
      final validationResult = await _authService.validateTokenConservatively();
      
      if (validationResult == TokenValidationResult.invalid) {
        print('🔑 AuthController: Token confirmed invalid by server, clearing session...');
        await _handleInvalidToken();
      } else if (validationResult == TokenValidationResult.networkError) {
        print('⚠️ AuthController: Network error during validation, keeping session intact');
        // Don't show any user message for network errors
      } else {
        print('✅ AuthController: Token validation successful or inconclusive');
      }
    } catch (e) {
      print('❌ AuthController: Error validating token - $e');
      // FIXED: Never clear session on validation errors during app launch
      print('⚠️ AuthController: Keeping session intact due to validation error');
    } finally {
      isTokenValidating.value = false;
    }
  }

  /// FIXED: Only show session expired message when we're certain the token is invalid
  Future<void> _handleInvalidToken() async {
    try {
      print('🔑 AuthController: Handling confirmed invalid token...');
      
      // Clear user data
      user.value = null;
      await clearUserPrefs();
      
      // FIXED: Only show session expired message if user was previously authenticated
      // and we have confirmed the token is invalid (not just network error)
      if (Get.currentRoute != '/role-selection' && Get.currentRoute != '/splash') {
        SafeNavigation.safeSnackbar(
          title: 'Session Expired',
          message: 'Your session has expired. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange[800],
          duration: const Duration(seconds: 3),
        );
      }
      
      // Navigate to role selection after a delay
      Future.delayed(const Duration(seconds: 1), () {
        if (Get.currentRoute != '/role-selection') {
          Get.offAllNamed('/role-selection');
        }
      });
      
    } catch (e) {
      print('❌ AuthController: Error handling invalid token - $e');
    }
  }

  /// NEW: Quietly clear session without showing user messages (for very old tokens)
  Future<void> _clearSessionQuietly() async {
    try {
      print('🔄 AuthController: Quietly clearing very old session...');
      
      // Clear user data without showing messages
      user.value = null;
      await clearUserPrefs();
      
      // Navigate to role selection without drama
      Future.delayed(const Duration(seconds: 500), () {
        if (Get.currentRoute != '/role-selection') {
          Get.offAllNamed('/role-selection');
        }
      });
      
    } catch (e) {
      print('❌ AuthController: Error quietly clearing session - $e');
    }
  }

  // --- REGISTER MANAGER ---
  Future<void> registerManager({String? companyId}) async {
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      SafeNavigation.safeSnackbar(
        title: "Error", 
        message: "Passwords do not match"
      );
      return;
    }

    try {
      isLoading.value = true;

      final body = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "name": nameController.text.trim(),
        if (companyId != null) "company_id": companyId,
        "phone": "string",
        "profile_picture": "string",
      };

      await _authService.registerAdmin(body);
      SafeNavigation.safeSnackbar(
        title: "Success", 
        message: "Manager registered successfully"
      );

      // Fetch company details and employee count if registering with existing company
      if (companyId != null) {
        final companyService = CompanyService();
        await companyService.getCompanyById(companyId);
        
        // Redirect to login after registration
        clearTextControllers();
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      clearTextControllers();
      // Navigate to Login page
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      SafeNavigation.safeSnackbar(
        title: "Error", 
        message: e.toString()
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIN MANAGER --- Enhanced with better session management
  Future<void> loginManager() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SafeNavigation.safeSnackbar(
        title: 'Error', 
        message: 'Please fill all fields'
      );
      return;
    }

    try {
      isLoading.value = true;

      // Step 1: Call login API to get token
      final tokenResult = await _authService.login(email, password);
      
      // Step 2: Use the token to fetch complete user profile
      final userProfile = await _authService.fetchUserProfile(tokenResult.token);

      // Step 3: Set the complete user profile in state and save to storage
      user.value = userProfile;
      await saveUserToPrefs(userProfile);

      SafeNavigation.safeSnackbar(
        title: "Success", 
        message: "Login successful!"
      );

      // Clear input fields
      emailController.clear();
      passwordController.clear();

      // Navigate to dashboard
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      SafeNavigation.safeSnackbar(
        title: "Error", 
        message: _getErrorMessage(e.toString())
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Enhanced method to get user-friendly error messages
  String _getErrorMessage(String error) {
    final errorStr = error.replaceAll('Exception: ', '');
    
    if (errorStr.contains('timeout') || errorStr.contains('TimeoutException')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (errorStr.contains('Network') || errorStr.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('Authentication failed') || errorStr.contains('Login failed')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorStr.contains('server') || errorStr.contains('Server')) {
      return 'Server error. Please try again later.';
    } else {
      return errorStr.isEmpty ? 'An unexpected error occurred' : errorStr;
    }
  }

  // --- LOGOUT --- Enhanced with proper cleanup
  Future<void> logout() async {
    try {
      print('🔄 AuthController: Logging out user...');
      
      // 🔧 STEP 1: Force dispose of all related controllers to prevent them from continuing operations
      await _disposeAllControllers();
      
      // 🔧 STEP 2: Clear user state
      user.value = null;
      
      // 🔧 STEP 3: Clear stored preferences
      await clearUserPrefs();
      
      // 🔧 STEP 4: Clear any cached data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // 🔧 STEP 5: Clear text controllers
      clearTextControllers();
      
      // 🔧 STEP 6: Show success message
      SafeNavigation.safeSnackbar(
        title: 'Logout Successful', 
        message: 'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM, 
        duration: const Duration(seconds: 2),
      );
      
      // 🔧 STEP 7: Force reset navigation to prevent any navigation conflicts
      await Future.delayed(const Duration(milliseconds: 300)); // Give time for cleanup
      SafeNavigation.forceResetNavigation();
      
    } catch (e) {
      print('❌ AuthController: Error during logout - $e');
      // Still navigate to role selection even if cleanup fails
      SafeNavigation.forceResetNavigation();
    }
  }

  /// Properly dispose all related GetX controllers to prevent zombie operations
  Future<void> _disposeAllControllers() async {
    try {
      print('🗑️ AuthController: Disposing all related controllers...');
      
      // Dispose dashboard-related controllers
      if (Get.isRegistered<DashboardController>()) {
        Get.delete<DashboardController>(force: true);
        print('✅ DashboardController disposed');
      }
      
      // Dispose employee-related controllers
      if (Get.isRegistered<EmployeeListController>()) {
        Get.delete<EmployeeListController>(force: true);
        print('✅ EmployeeListController disposed');
      }
      
      if (Get.isRegistered<AddEmployeeController>()) {
        Get.delete<AddEmployeeController>(force: true);
        print('✅ AddEmployeeController disposed');
      }
      
      // Dispose product-related controllers
      if (Get.isRegistered<AddProductController>()) {
        Get.delete<AddProductController>(force: true);
        print('✅ AddProductController disposed');
      }
      
      if (Get.isRegistered<EditProductController>()) {
        Get.delete<EditProductController>(force: true);
        print('✅ EditProductController disposed');
      }
      
      // Dispose employee dashboard controller
      if (Get.isRegistered<EmployeeDashboardController>()) {
        Get.delete<EmployeeDashboardController>(force: true);
        print('✅ EmployeeDashboardController disposed');
      }
      
      // Dispose company controller
      if (Get.isRegistered<CompanyController>()) {
        Get.delete<CompanyController>(force: true);
        print('✅ CompanyController disposed');
      }
      
      // Give a brief moment for all disposals to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      print('🎯 AuthController: All controllers disposed successfully');
      
    } catch (e) {
      print('❌ AuthController: Error disposing controllers - $e');
      // Continue with logout even if disposal fails
    }
  }

  /// Handles initialization errors
  Future<void> _handleInitializationError() async {
    try {
      print('🔄 AuthController: Handling initialization error...');
      
      // Clear all stored data
      user.value = null;
      await clearUserPrefs();
      
      // Clear SharedPreferences completely
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
    } catch (e) {
      print('❌ AuthController: Error during initialization error handling - $e');
    }
  }

  void clearTextControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    companyNameController.clear();
    numberOfEmployeesController.clear();
  }

  // --- Enhanced Persistent Login: Save user to SharedPreferences ---
  Future<void> saveUserToPrefs(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save basic user data
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_role', user.role);
      await prefs.setString('user_token', user.token);
      
      // Save optional fields
      if (user.phone != null) await prefs.setString('user_phone', user.phone!);
      if (user.profilePicture != null) await prefs.setString('user_profile_picture', user.profilePicture!);
      if (user.companyName != null) await prefs.setString('user_company_name', user.companyName!);
      if (user.companySize != null) await prefs.setInt('user_company_size', user.companySize!);
      if (user.id != null) await prefs.setInt('user_id', user.id!);
      if (user.companyId != null) await prefs.setString('user_company_id', user.companyId!);
      
      // Save company data if available
      if (user.company != null) {
        await prefs.setString('user_company', jsonEncode({
          'id': user.company!.id,
          'name': user.company!.name,
          'size': user.company!.size,
          'created_at': user.company!.createdAt,
          'updated_at': user.company!.updatedAt,
        }));
      }
      
      // Save login timestamp for session tracking
      await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
      
      print('✅ AuthController: User data saved to preferences successfully');
    } catch (e) {
      print('❌ AuthController: Error saving user to preferences - $e');
    }
  }

  // --- Enhanced Persistent Login: Load user from SharedPreferences ---
  Future<void> loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      
      if (token != null && token.isNotEmpty) {
        // Load company data if available
        CompanyModel? company;
        final companyJson = prefs.getString('user_company');
        if (companyJson != null) {
          try {
            company = CompanyModel.fromJson(jsonDecode(companyJson));
          } catch (e) {
            print('⚠️ AuthController: Error parsing company data - $e');
          }
        }
        
        // Create user model
        user.value = UserModel(
          name: prefs.getString('user_name') ?? '',
          email: prefs.getString('user_email') ?? '',
          role: prefs.getString('user_role') ?? 'manager',
          token: token,
          phone: prefs.getString('user_phone'),
          profilePicture: prefs.getString('user_profile_picture'),
          companyName: prefs.getString('user_company_name'),
          companySize: prefs.getInt('user_company_size'),
          id: prefs.getInt('user_id'),
          companyId: prefs.getString('user_company_id'),
          company: company,
        );
        
        print('✅ AuthController: User loaded from preferences');
        
        // Check how long ago the user logged in
        final loginTimestamp = prefs.getString('login_timestamp');
        if (loginTimestamp != null) {
          try {
            final loginTime = DateTime.parse(loginTimestamp);
            final hoursSinceLogin = DateTime.now().difference(loginTime).inHours;
            print('🕐 AuthController: Last login was $hoursSinceLogin hours ago');
          } catch (e) {
            print('⚠️ AuthController: Error parsing login timestamp - $e');
          }
        }
      } else {
        print('🔄 AuthController: No token found in preferences');
      }
    } catch (e) {
      print('❌ AuthController: Error loading user from preferences - $e');
      // Clear corrupted data
      await clearUserPrefs();
    }
  }

  // --- Enhanced Persistent Login: Clear user from SharedPreferences ---
  Future<void> clearUserPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove user-specific keys
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_role');
      await prefs.remove('user_token');
      await prefs.remove('user_phone');
      await prefs.remove('user_profile_picture');
      await prefs.remove('user_company_name');
      await prefs.remove('user_company_size');
      await prefs.remove('user_id');
      await prefs.remove('user_company_id');
      await prefs.remove('user_company');
      await prefs.remove('login_timestamp');
      await prefs.remove('token_timestamp');
      
      print('✅ AuthController: User preferences cleared');
    } catch (e) {
      print('❌ AuthController: Error clearing user preferences - $e');
    }
  }

  @override
  void onClose() {
    // Dispose all TextEditingControllers to avoid memory leaks
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    companyNameController.dispose();
    numberOfEmployeesController.dispose();
    super.onClose();
  }
}