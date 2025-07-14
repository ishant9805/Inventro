import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'package:inventro/app/routes/app_pages.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';

void main() {
  // Initialize controllers
  Get.put(AuthController());
  Get.put(DashboardController(), permanent: true); // Make it permanent instead of lazy
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inventro App',
      initialRoute: AppRoutes.splash, 
      getPages: AppPages.pages,       
      debugShowCheckedModeBanner: false,
    );
  }
}