import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/views/manager/company_details_screen.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/company_service.dart';
import '../../../data/services/employee_service.dart';

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

  final AuthService _authService = AuthService();

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
        final companyData = await companyService.getCompanyById(companyId);
        
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

  // --- LOGIN MANAGER ---
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

      // Step 3: Set the complete user profile in state
      user.value = userProfile;
      await saveUserToPrefs(userProfile);

      SafeNavigation.safeSnackbar(
        title: "Success", 
        message: "Login successful!"
      );

      // Clear input fields
      emailController.clear();
      passwordController.clear();

      // Navigate to Manager Dashboard
      Get.offAllNamed(AppRoutes.dashboard);

    } catch (e) {
      SafeNavigation.safeSnackbar(
        title: "Login Failed", 
        message: e.toString()
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGOUT MANAGER ---
  void logout() {
    // Clear user data
    user.value = null;
    clearUserPrefs();
    clearTextControllers();
    
    // Show success message using safe snackbar
    SafeNavigation.safeSnackbar(
      title: "Logout Successful", 
      message: "You have been logged out successfully",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    
    // Navigate to role selection screen with delay to avoid conflicts
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.offAllNamed(AppRoutes.roleSelection);
    });
  }

  // --- Clear all TextControllers ---
  void clearTextControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    companyNameController.clear();
    numberOfEmployeesController.clear();
  }

  // --- Persistent Login: Save user to SharedPreferences ---
  Future<void> saveUserToPrefs(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role);
    await prefs.setString('user_token', user.token);
    if (user.phone != null) await prefs.setString('user_phone', user.phone!);
    if (user.profilePicture != null) await prefs.setString('user_profile_picture', user.profilePicture!);
    if (user.companyName != null) await prefs.setString('user_company_name', user.companyName!);
    if (user.companySize != null) await prefs.setInt('user_company_size', user.companySize!);
    if (user.id != null) await prefs.setInt('user_id', user.id!);
    if (user.companyId != null) await prefs.setString('user_company_id', user.companyId!); // Add this line
    if (user.company != null) await prefs.setString('user_company', jsonEncode({
      'id': user.company!.id,
      'name': user.company!.name,
      'size': user.company!.size,
      'created_at': user.company!.createdAt,
      'updated_at': user.company!.updatedAt,
    }));
  }

  // --- Persistent Login: Load user from SharedPreferences ---
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    if (token != null && token.isNotEmpty) {
      CompanyModel? company;
      final companyJson = prefs.getString('user_company');
      if (companyJson != null) {
        company = CompanyModel.fromJson(jsonDecode(companyJson));
      }
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
        companyId: prefs.getString('user_company_id'), // Add this line
        company: company,
      );
    }
  }

  // --- Persistent Login: Clear user from SharedPreferences ---
  Future<void> clearUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_token');
    await prefs.remove('user_phone');
    await prefs.remove('user_profile_picture');
    await prefs.remove('user_company_name');
    await prefs.remove('user_company_size');
    await prefs.remove('user_id');
  }

  @override
  void onInit() {
    super.onInit();
    loadUserFromPrefs();
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

  // --- Splash Screen Optimization Note ---
  // Avoid heavy initialization in splash screen. If you need to load data, do it asynchronously
  // and show a loading indicator. Keep splash screen logic lightweight.
  
}