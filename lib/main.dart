import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/views/manager/dashboard.dart';
// Import app routes
import 'package:inventro/app/modules/auth/views/manager/login_screen.dart';  // Import login screen
import 'package:inventro/app/modules/auth/views/manager/register_screen.dart';  // Import register screen
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';  // Import AuthController for authentication logic

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Initialize the AuthController globally to handle state and logic
  // ignore: unused_field
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inventro App',
      initialRoute: '/login',  // Set login screen as initial route
      getPages: [
        // Define app routes
        GetPage(name: '/login', page: () => LoginScreen()),  // Login screen route
        GetPage(name: '/register', page: () => RegisterScreen()),  // Register screen route
        GetPage(name: '/dashboard', page: () => ManagerDashboard()),  // Dashboard screen route (can be any screen)
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

